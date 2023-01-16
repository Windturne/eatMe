import 'package:eatme_mobileapp/template/Buttons/iconbutton_template.dart';
import 'package:flutter/material.dart';
import 'package:eatme_mobileapp/template/Buttons/button_template.dart';
import 'package:eatme_mobileapp/template/textField_template.dart';
import 'package:eatme_mobileapp/theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as http;

import '../appGlobalConfig.dart';

class LupaPasswordPage extends StatefulWidget {
  @override
  _LupaPasswordPageState createState() => _LupaPasswordPageState();
}

class _LupaPasswordPageState extends State<LupaPasswordPage> {
  TextEditingController emailController = new TextEditingController();

  void backButtonPressed() {
    Navigator.pop(context);
  }

  Future kirimVerifikasiPressed() async {
    if (emailController.text.isEmpty) {
      Alert(
          style: AlertStyle(
              descStyle: descriptionTextBlack12,
              isCloseButton: false,
              titleStyle: titlePage),
          context: context,
          title: "Verifikasi Gagal",
          desc: "Mohon mengisi form email terlebih dahulu",
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
      final response = await http.post(
          Uri.parse(AppGlobalConfig.getUrlApi() + 'user/forgot-password'),
          body: {
            'email': emailController.text.toString(),
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
            title: "Reset Password",
            desc:
                "Link reset password berhasil dikirimkan. Mohon cek inbox pada email.",
            type: AlertType.success,
            buttons: [
              DialogButton(
                  color: lightOrange,
                  child: Text('OK', style: buttonText),
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/_LoginPage'))
            ]).show();
      } else {
        Alert(
            style: AlertStyle(
                descStyle: descriptionTextBlack12,
                isCloseButton: false,
                titleStyle: titlePage),
            context: context,
            title: "Verifikasi Gagal",
            desc: "Email belum terdaftar",
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButtonTemplate(black, Icons.arrow_back_rounded,
                        onPressed: backButtonPressed),
                  ],
                ),
                SizedBox(
                  height: 23.h,
                ),
                Text(
                  "Lupa Password",
                  style: titlePage,
                ),
                SizedBox(
                  height: 40.h,
                ),
                TextFieldTemplate("email", false, false, emailController),
                SizedBox(
                  height: 80.h,
                ),
                ButtonTemplate("KIRIM LINK VERIFIKASI", lightOrange,
                    onPressed: kirimVerifikasiPressed)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
