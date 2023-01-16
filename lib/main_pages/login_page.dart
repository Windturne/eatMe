import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:eatme_mobileapp/api/pemilikbisniskuliner_api.dart';
import 'package:eatme_mobileapp/appGlobalConfig.dart';
import 'package:eatme_mobileapp/main_pages/lupapassword_page.dart';
import 'package:eatme_mobileapp/template/Buttons/button_template.dart';
import 'package:eatme_mobileapp/template/textField_template.dart';
import 'package:eatme_mobileapp/template/Buttons/textbutton_template.dart';
import 'package:eatme_mobileapp/theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

//CEK
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   var idUser = prefs.getInt('idUser');
//   // var namaUser = prefs.getString('namaUser');
//   var roleUser = prefs.getBool('roleUser'); //false = customer; true = business
//   print('sharedPreferences idUser : ' + idUser.toString());
//   print('sharedPreferences roleUser : ' + roleUser.toString());

//   runApp(MaterialApp(
//       home: idUser == null
//           ? LoginPage()
//           : roleUser == false
//               ? CustomerBottomNav()
//               : BusinessBottomNav()));
// }

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isRoleSwitched = false;
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  @override
  void initState() {
    super.initState();

    init();
  }

  Future init() async {
    //Dialog box
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        print('Awesome Notification Is Not Allowed');
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text(
                    'Aktifkan Notifikasi',
                    style: titlePage,
                    textAlign: TextAlign.center,
                  ),
                  content: Text(
                    'Aplikasi ini akan mengirimkan notifikasi, mohon untuk mengaktifkan akses notifikasi',
                    style: descriptionTextBlack14,
                    textAlign: TextAlign.center,
                  ),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'TOLAK',
                          style: titleCard,
                        )),
                    TextButton(
                        onPressed: () async {
                          AwesomeNotifications()
                              .requestPermissionToSendNotifications()
                              .then((_) => Navigator.pop(context));
                        },
                        child: Text(
                          'IJINKAN',
                          style: descriptionTextOrangeMedium12,
                        ))
                  ],
                ));
      } else {
        print('Awesome Notification is Allowed');
      }
    });
  }

  Future loginPressed() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Alert(
          style: AlertStyle(
              descStyle: descriptionTextBlack12,
              isCloseButton: false,
              titleStyle: titlePage),
          context: context,
          title: "Login Gagal",
          desc: "Data tidak lengkap",
          type: AlertType.error,
          buttons: [
            DialogButton(
                color: lightOrange,
                child: Text('OK', style: buttonText),
                onPressed: () => Navigator.pop(context))
          ]).show();
      print("empty form");
    } else {
      //Loading setelah tekan tombol
      ProgressDialog progressDialog = ProgressDialog(context);
      progressDialog.style(message: 'Loading...');
      progressDialog.show();

      //Panggil API
      final response = await http
          .post(Uri.parse(AppGlobalConfig.getUrlApi() + 'user/login'), body: {
        'email': emailController.text.toString(),
        'password': passwordController.text.toString()
      }, headers: {
        'Accept': 'application/json'
      });

      progressDialog.hide();

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        //Simpan data user
        final Map dataUser = json.decode(response.body);
        prefs.setInt('idUser', dataUser['data']['user']['id']);
        prefs.setString('namaUser', dataUser['data']['user']['name']);
        prefs.setString('emailUser', dataUser['data']['user']['email']);
        prefs.setBool('roleUser', isRoleSwitched);

        //Edit token notifikasi user
        var status = await OneSignal.shared.getDeviceState();
        String tokenId = status.userId;

        print('Token ID: ' + tokenId);

        final response2 = await http.put(
            Uri.parse(AppGlobalConfig.getUrlApi() +
                'user/' +
                dataUser['data']['user']['id'].toString()),
            body: {'token_notifikasi': tokenId},
            headers: {'Accept': 'application/json'});

        if (response2.statusCode == 200) {
          print('Edit token notifikasi');
          print(response2.body);
        }

        //Set External User ID for notification (user X terhubung dengan device ini)
        // OneSignal.shared
        //     .setExternalUserId(dataUser['data']['user']['email'])
        //     .then((results) {
        //   print(results.toString());
        // }).catchError((error) {
        //   print(error.toString());
        // });

        //Cek masuk sebagai konsumen atau akun bisnis
        if (!isRoleSwitched) {
          Navigator.pushReplacementNamed(context, '/_CustomerBottomNav');
        } else {
          //CEK bisnis sudah registrasi belum. Kalau sudah masuk bottomNav
          final pemilikBisnis =
              await PemilikBisnisKulinerApi.getPemilikBisnisKulinerByIdUser(
                  dataUser['data']['user']['id']);

          if (pemilikBisnis.isEmpty) {
            Navigator.pushReplacementNamed(context, '/_BelumValidasiPage');
          } else {
            if (!mounted) return;
            Navigator.pushReplacementNamed(context, '/_BusinessBottomNav');
          }
        }
      } else {
        Alert(
            style: AlertStyle(
                descStyle: descriptionTextBlack12,
                isCloseButton: false,
                titleStyle: titlePage),
            context: context,
            title: "Login Gagal",
            desc: "Email/password yang dimasukkan salah",
            type: AlertType.error,
            buttons: [
              DialogButton(
                  color: lightOrange,
                  child: Text('OK', style: buttonText),
                  onPressed: () => Navigator.pop(context))
            ]).show();
      }
    }
  }

  void lupaPasswordPressed() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LupaPasswordPage()));
  }

  void daftarAkunPressed() {
    Navigator.pushReplacementNamed(context, '/_RegisterPage');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, //supaya textField ngga ketutup keyboard
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 80.h,
                ),
                Container(
                  width: double.infinity,
                  child: Text(
                    "eatMe!",
                    style: mainTitle,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 80.h,
                ),
                Row(
                  children: [
                    Text(
                      "Login sebagai akun bisnis",
                      style: descriptionTextBlack12,
                    ),
                    Switch(
                      value: isRoleSwitched,
                      onChanged: (value) {
                        if (!mounted) return;
                        setState(() {
                          isRoleSwitched = value;
                          print(isRoleSwitched);
                        });
                      },
                      activeTrackColor: lightOrange,
                      activeColor: darkOrange,
                    )
                  ],
                ),
                SizedBox(
                  height: 40.h,
                ),
                TextFieldTemplate("email", false, false, emailController),
                SizedBox(
                  height: 15.h,
                ),
                TextFieldTemplate("password", true, false, passwordController),
                SizedBox(
                  height: 10.h,
                ),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  TextButtonTemplate("lupa password?", darkGrey,
                      onPressed: lupaPasswordPressed),
                ]),
                SizedBox(
                  height: 80.h,
                ),
                ButtonTemplate("LOGIN", lightOrange, onPressed: loginPressed),
                SizedBox(
                  height: 10.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Tidak memiliki akun? ",
                      style: descriptionTextGrey12,
                    ),
                    TextButtonTemplate("Daftar Akun", darkGrey,
                        onPressed: daftarAkunPressed)
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
