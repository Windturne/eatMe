import 'package:eatme_mobileapp/api/user_api.dart';
import 'package:eatme_mobileapp/cutomer_pages/Profil/ewallet_page.dart';
import 'package:eatme_mobileapp/cutomer_pages/Profil/gantipassword_page.dart';
import 'package:eatme_mobileapp/cutomer_pages/Profil/kontak_page.dart';
import 'package:eatme_mobileapp/cutomer_pages/Profil/ubahprofil_page.dart';
import 'package:eatme_mobileapp/main_pages/login_page.dart';
import 'package:eatme_mobileapp/models/user.dart';
import 'package:eatme_mobileapp/template/Cards/cardprofil_template.dart';
import 'package:flutter/material.dart';
import 'package:eatme_mobileapp/template/Buttons/textbutton_template.dart';
import 'package:eatme_mobileapp/theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../appGlobalConfig.dart';

class ProfilPage extends StatefulWidget {
  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  User user;

  void initState() {
    super.initState();

    init();
  }

  Future init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final idUser = prefs.getInt('idUser');
    final user = await UserApi.getUserById(idUser);
    if (!mounted) return;
    setState(() {
      this.user = user[0];
    });
  }

  void ubahProfilPressed() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => UbahProfilPage()));
  }

  void gantiPasswordOnTap() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => GantiPasswordPage()));
  }

  void ewalletOnTap() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => EwalletPage()));
  }

  void kontakOnTap() {
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

    OneSignal.shared.removeExternalUserId();
    Navigator.pushAndRemoveUntil<dynamic>(
      context,
      MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => LoginPage(),
      ),
      (route) => false, //if you want to disable back feature set to false
    );
    // Navigator.pushReplacementNamed(context, '/_LoginPage');
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
                Text(
                  "Profil",
                  style: titlePage,
                ),
                SizedBox(
                  height: 40.h,
                ),
                //CARD PROFILE
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5.r),
                          child: Image.asset(
                            'assets/images/profilepic.png',
                            height: 100.h,
                            width: 100.w,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(
                          width: 18.w,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              this.user?.name ?? 'namaUserNull',
                              style: titleCard,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              height: 25.h,
                              width: 42.w,
                              decoration: BoxDecoration(
                                  border: Border.all(color: lightGrey),
                                  borderRadius: BorderRadius.circular(5.r)),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 2.h, horizontal: 2.w),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 12,
                                      color: darkOrange,
                                      // textDirection: TextDirection.ltr,
                                    ),
                                    SizedBox(
                                      width: 2.w,
                                    ),
                                    Text(
                                      this.user?.ratingUser != null &&
                                              this.user?.ratingUser != 0
                                          ? this
                                              .user
                                              ?.ratingUser
                                              ?.toStringAsFixed(1)
                                          : '0.0',
                                      style: descriptionTextGrey12,
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            TextButtonTemplate('Ubah profil', lightOrange,
                                onPressed: ubahProfilPressed)
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 5.h,
                ),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 5.h, horizontal: 15.w),
                    child: Row(
                      children: [
                        Icon(
                          Icons.emoji_events_outlined,
                          color: black,
                          size: 20,
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        Text(
                          this.user?.makananDiselamatkan.toString() +
                              ' makanan telah diselamatkan',
                          style: descriptionTextBlack12,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 60.h,
                ),
                Text(
                  'Akun',
                  style: titlePage,
                ),
                SizedBox(
                  height: 20.h,
                ),
                CardProfileTemplate('Ganti password', gantiPasswordOnTap),
                SizedBox(
                  height: 5.h,
                ),
                CardProfileTemplate('E-Wallet', ewalletOnTap),
                SizedBox(
                  height: 5.h,
                ),
                CardProfileTemplate('Kontak eatMe!', kontakOnTap),
                SizedBox(
                  height: 80.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButtonTemplate('Logout', darkGrey,
                        onPressed: logoutPressed)
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
