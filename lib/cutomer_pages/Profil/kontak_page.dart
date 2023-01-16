import 'package:eatme_mobileapp/template/Buttons/iconbutton_template.dart';
import 'package:eatme_mobileapp/template/Cards/cardprofil_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme.dart';

class KontakPage extends StatefulWidget {
  @override
  _KontakPageState createState() => _KontakPageState();
}

class _KontakPageState extends State<KontakPage> {
  void backButtonPressed() {
    Navigator.pop(context);
  }

  void telpOnTap() {
    var whatsapp = "628113412233";
    var whatsappURL = "https://wa.me/" + whatsapp;
    launch(whatsappURL);
  }

  void emailOnTap() async {
    const mailUrl = 'mailto:eatmemobileapp@gmail.com';
    try {
      await launch(mailUrl);
    } catch (e) {
      print(e);
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
                    'Kontak eatMe!',
                    style: titlePage,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  CardProfileTemplate('Telp: 0811-341-2233', telpOnTap),
                  SizedBox(
                    height: 5.h,
                  ),
                  CardProfileTemplate(
                      'Email: eatmemobileapp@gmail.com', emailOnTap)
                ],
              )),
        ),
      ),
    );
  }
}
