import 'package:eatme_mobileapp/appGlobalConfig.dart';
import 'package:flutter/material.dart';
import 'package:eatme_mobileapp/template/Buttons/button_template.dart';
import 'package:eatme_mobileapp/template/textField_template.dart';
import 'package:eatme_mobileapp/template/Buttons/textbutton_template.dart';
import 'package:eatme_mobileapp/theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool isRoleSwitched = false;
  TextEditingController namaController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController konfirmasiPasswordController =
      new TextEditingController();

  Future daftarPressed() async {
    //Cek isEmpty
    if (namaController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        konfirmasiPasswordController.text.isEmpty) {
      Alert(
          style: AlertStyle(
              descStyle: descriptionTextBlack12,
              isCloseButton: false,
              titleStyle: titlePage),
          context: context,
          title: "Daftar Akun Gagal",
          desc: "Data tidak lengkap",
          type: AlertType.error,
          buttons: [
            DialogButton(
                color: lightOrange,
                child: Text('OK', style: buttonText),
                onPressed: () => Navigator.pop(context))
          ]).show();
      print("empty register form");
    } else {
      //Cek password dan konfirmasi password sama atau tidak
      if (passwordController.text == konfirmasiPasswordController.text) {
        //Loading setelah tekan tombol
        ProgressDialog progressDialog = ProgressDialog(context);
        progressDialog.style(message: 'Loading...');
        progressDialog.show();

        //TEMP: Daftarkan token notifikasi user
        // var status = await OneSignal.shared.getDeviceState();
        // String tokenId = status.userId;

        //Panggil API
        final response = await http.post(
            Uri.parse(AppGlobalConfig.getUrlApi() + 'user/register'),
            body: {
              'name': namaController.text.toString(),
              'email': emailController.text.toString(),
              'password': passwordController.text.toString(),
              // 'token_notifikasi': tokenId
            },
            headers: {
              'Accept': 'application/json'
            });

        progressDialog.hide();

        if (response.statusCode == 200) {
          Alert(
              style: AlertStyle(
                  descStyle: descriptionTextBlack12,
                  isCloseButton: false,
                  titleStyle: titlePage),
              context: context,
              title: "Daftar Akun Berhasil",
              desc: "Silakan melakukan login",
              type: AlertType.success,
              buttons: [
                DialogButton(
                    color: lightOrange,
                    child: Text('OK', style: buttonText),
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/_LoginPage'))
              ]).show();
        } else if (response.statusCode == 422) {
          Alert(
              style: AlertStyle(
                  descStyle: descriptionTextBlack12,
                  isCloseButton: false,
                  titleStyle: titlePage),
              context: context,
              title: "Daftar Akun Gagal",
              desc:
                  "Mohon cek format email beserta password (minimal 6 karakter)",
              type: AlertType.error,
              buttons: [
                DialogButton(
                    color: lightOrange,
                    child: Text('OK', style: buttonText),
                    onPressed: () => Navigator.pop(context))
              ]).show();
        } else if (response.statusCode == 500) {
          Alert(
              style: AlertStyle(
                  descStyle: descriptionTextBlack12,
                  isCloseButton: false,
                  titleStyle: titlePage),
              context: context,
              title: "Daftar Akun Gagal",
              desc: "Akun sudah terdaftar silakan melakukan login",
              type: AlertType.error,
              buttons: [
                DialogButton(
                    color: lightOrange,
                    child: Text('OK', style: buttonText),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, '/_LoginPage');
                    })
              ]).show();
        }
      } else {
        Alert(
            style: AlertStyle(
                descStyle: descriptionTextBlack12,
                isCloseButton: false,
                titleStyle: titlePage),
            context: context,
            title: "Daftar Akun Gagal",
            desc: "Password tidak sama",
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

  void loginPressed() {
    Navigator.pushReplacementNamed(context, '/_LoginPage');
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
                TextFieldTemplate("nama lengkap", false, false, namaController),
                SizedBox(
                  height: 15.h,
                ),
                TextFieldTemplate("email", false, false, emailController),
                SizedBox(
                  height: 15.h,
                ),
                TextFieldTemplate("password", true, false, passwordController),
                SizedBox(
                  height: 15.h,
                ),
                TextFieldTemplate("konfirmasi password", true, false,
                    konfirmasiPasswordController),
                SizedBox(
                  height: 10.h,
                ),
                SizedBox(
                  height: 80.h,
                ),
                ButtonTemplate("DAFTAR", lightOrange, onPressed: daftarPressed),
                SizedBox(
                  height: 10.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Sudah memiliki akun? ",
                      style: descriptionTextGrey12,
                    ),
                    TextButtonTemplate("Login", lightOrange,
                        onPressed: loginPressed)
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
