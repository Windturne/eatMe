import 'package:eatme_mobileapp/template/Buttons/button_template.dart';
import 'package:eatme_mobileapp/template/Buttons/iconbutton_template.dart';
import 'package:eatme_mobileapp/template/textField_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../appGlobalConfig.dart';
import '../../theme.dart';

class UbahProfilPage extends StatefulWidget {
  @override
  _UbahProfilPageState createState() => _UbahProfilPageState();
}

class _UbahProfilPageState extends State<UbahProfilPage> {
  TextEditingController namaController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  int idUser;

  void initState() {
    super.initState();

    init();
  }

  Future init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final nama = prefs.getString('namaUser');
    final email = prefs.getString('emailUser');
    final id = prefs.getInt('idUser');
    if (!mounted) return;
    setState(() {
      namaController.text = nama;
      emailController.text = email;
      idUser = id;
    });
  }

  void backButtonPressed() {
    Navigator.pop(context);
  }

  Future simpanPressed() async {
    //Loading setelah tekan tombol
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.style(message: 'Loading...');
    progressDialog.show();

    if (namaController.text.isEmpty || emailController.text.isEmpty) {
      Alert(
          style: AlertStyle(
              descStyle: descriptionTextBlack12,
              isCloseButton: false,
              titleStyle: titlePage),
          context: context,
          title: "Ubah Profil Gagal",
          desc: "Data tidak lengkap",
          type: AlertType.error,
          buttons: [
            DialogButton(
                color: lightOrange,
                child: Text('OK', style: buttonText),
                onPressed: () {
                  int count = 0;
                  Navigator.of(context).popUntil((_) => count++ >= 2);
                })
          ]).show();
    } else {
      final response = await http.put(
          Uri.parse(AppGlobalConfig.getUrlApi() + 'user/' + idUser.toString()),
          body: {
            'name': namaController.text.toString(),
            'email': emailController.text.toString(),
          },
          headers: {
            'Accept': 'application/json'
          });

      if (response.statusCode == 200) {
        Alert(
            style: AlertStyle(
                descStyle: descriptionTextBlack12,
                isCloseButton: false,
                titleStyle: titlePage),
            context: context,
            title: "Ubah Profil Berhasil",
            desc: "Profil berhasil diubah",
            type: AlertType.success,
            buttons: [
              DialogButton(
                  color: lightOrange,
                  child: Text('OK', style: buttonText),
                  onPressed: () async {
                    //Update sharedPreferences
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setString('namaUser', namaController.text);
                    prefs.setString('emailUser', emailController.text);
                    Navigator.pushReplacementNamed(
                        context, '/_CustomerBottomNav');
                  })
            ]).show();
      } else {
        Alert(
            style: AlertStyle(
                descStyle: descriptionTextBlack12,
                isCloseButton: false,
                titleStyle: titlePage),
            context: context,
            title: "Ubah Profil Gagal",
            desc: "Terjadi kesalahan",
            type: AlertType.error,
            buttons: [
              DialogButton(
                  color: lightOrange,
                  child: Text('OK', style: buttonText),
                  onPressed: () => Navigator.pushReplacementNamed(
                      context, '/_CustomerBottomNav'))
            ]).show();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 30.h,
                  ),
                  IconButtonTemplate(black, Icons.arrow_back_ios_rounded,
                      onPressed: backButtonPressed),
                  SizedBox(
                    height: 23.h,
                  ),
                  Text(
                    'Ubah Profil',
                    style: titlePage,
                  ),
                  SizedBox(
                    height: 40.h,
                  ),
                  Text(
                    'Nama',
                    style: descriptionTextGrey12,
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  TextFieldTemplate('Jane Doe', false, false, namaController),
                  SizedBox(
                    height: 20.h,
                  ),
                  Text(
                    'Email',
                    style: descriptionTextGrey12,
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  TextFieldTemplate(
                      'janedoe@gmail.com', false, false, emailController),
                  SizedBox(
                    height: 40.h,
                  ),
                  ButtonTemplate('SIMPAN', lightOrange,
                      onPressed: simpanPressed)
                ],
              )),
        ),
      ),
    );
  }
}
