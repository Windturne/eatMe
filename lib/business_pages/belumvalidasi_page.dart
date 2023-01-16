import 'package:eatme_mobileapp/api/formvalidasi_api.dart';
import 'package:eatme_mobileapp/business_pages/daftarbisnis_page.dart';
import 'package:eatme_mobileapp/cutomer_pages/Profil/kontak_page.dart';
import 'package:eatme_mobileapp/models/formvalidasi.dart';
import 'package:eatme_mobileapp/template/Buttons/button_template.dart';
import 'package:eatme_mobileapp/template/Buttons/textbutton_template.dart';
import 'package:eatme_mobileapp/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../appGlobalConfig.dart';

class BelumValidasiPage extends StatefulWidget {
  @override
  _BelumValidasiPageState createState() => _BelumValidasiPageState();
}

class _BelumValidasiPageState extends State<BelumValidasiPage> {
  FormValidasi form;
  bool isFormAvailable = false;

  void initState() {
    super.initState();

    init();
  }

  Future init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final idUser = prefs.getInt('idUser');

    // final user = await UserApi.getUserById(idUser);
    final form = await FormValidasiApi.getFormByUserId(idUser);

    if (!mounted) return;

    if (form.isEmpty) {
      print('Form is empty');
    } else {
      print('Form is not empty');
      this.isFormAvailable = true;
      setState(() {
        this.form = form[0];
      });
    }
  }

  void daftarPressed() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => DaftarBisnisPage()));
    print('daftar');
  }

  void kontakAdminPressed() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => KontakPage()));
  }

  Future logoutPressed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String idUser = prefs.getInt('idUser').toString();

    final response = await http.put(
        Uri.parse(AppGlobalConfig.getUrlApi() + 'user/' + idUser),
        body: {'token_notifikasi': 'null'},
        headers: {'Accept': 'application/json'});

    if (response.statusCode == 200) {
      print('Edit token notifikasi = null');
      print(response.body);
    }

    prefs.remove('idUser');
    prefs.remove('namaUser');
    prefs.remove('emailUser');
    prefs.remove('roleUser');
    prefs.remove('idBisnisCart');
    Navigator.pushReplacementNamed(context, '/_LoginPage');
  }

  // OneSignal.shared.removeExternalUserId();

  @override
  Widget build(BuildContext context) {
    if (this.isFormAvailable == false) {
      return Scaffold(
        resizeToAvoidBottomInset: true, //supaya textField ngga ketutup keyboard
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 70.h,
                    ),
                    Image.asset(
                      'assets/images/form.png',
                      width: double.infinity,
                    ),
                    SizedBox(
                      height: 40.h,
                    ),
                    Text(
                      'OOPS...',
                      style: TextStyle(
                          color: black,
                          fontWeight: FontWeight.w500,
                          fontSize: 24),
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
                    Text(
                      'Bisnis anda belum terdaftar',
                      style: descriptionTextBlack14,
                    ),
                    SizedBox(
                      height: 50.h,
                    ),
                    this.isFormAvailable == false
                        ? ButtonTemplate('DAFTAR', lightOrange,
                            onPressed: daftarPressed)
                        : '',
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButtonTemplate('Logout', darkGrey,
                            onPressed: logoutPressed)
                      ],
                    ),
                  ],
                )),
          ),
        ),
      );
    } else if (this.isFormAvailable == true && this.form.validasiAdmin == 0) {
      return Scaffold(
        resizeToAvoidBottomInset: true, //supaya textField ngga ketutup keyboard
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 70.h,
                    ),
                    Image.asset(
                      'assets/images/form.png',
                      width: double.infinity,
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    Text(
                      'FORM DALAM PROSES VALIDASI',
                      style: TextStyle(
                        color: black,
                        fontWeight: FontWeight.w500,
                        fontSize: 24,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
                    Text(
                      'Form bisnis anda sedang diperiksa oleh administrator. Admin akan memberikan informasi lebih lanjut melalui email yang sudah dicantumkan dalam form',
                      style: descriptionTextBlack14,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 50.h,
                    ),
                    // this.isFormAvailable == true
                    //     ? ButtonTemplate('KONTAK ADMIN', lightOrange,
                    //         onPressed: kontakAdminPressed)
                    //     : '',
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButtonTemplate('Logout', darkGrey,
                            onPressed: logoutPressed)
                      ],
                    ),
                    SizedBox(
                      height: 10.h,
                    )
                  ],
                )),
          ),
        ),
      );
    }
  }
}
