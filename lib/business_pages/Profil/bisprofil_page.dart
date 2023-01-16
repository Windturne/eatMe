import 'package:eatme_mobileapp/api/bisniskuliner_api.dart';
import 'package:eatme_mobileapp/api/pemilikbisniskuliner_api.dart';
import 'package:eatme_mobileapp/business_pages/Profil/kontakalamat_page.dart';
import 'package:eatme_mobileapp/business_pages/Profil/profilbisnis_page.dart';
import 'package:eatme_mobileapp/business_pages/Profil/rekeningpendapatan_page.dart';
import 'package:eatme_mobileapp/cutomer_pages/Profil/gantipassword_page.dart';
import 'package:eatme_mobileapp/cutomer_pages/Profil/kontak_page.dart';
import 'package:eatme_mobileapp/main.dart';
import 'package:eatme_mobileapp/main_pages/login_page.dart';
import 'package:eatme_mobileapp/models/bisniskuliner.dart';
import 'package:eatme_mobileapp/template/Cards/cardprofil_template.dart';
import 'package:flutter/material.dart';
import 'package:eatme_mobileapp/template/Buttons/textbutton_template.dart';
import 'package:eatme_mobileapp/theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../appGlobalConfig.dart';

class BisProfilPage extends StatefulWidget {
  @override
  _BisProfilPageState createState() => _BisProfilPageState();
}

class _BisProfilPageState extends State<BisProfilPage> {
  bool isOpen = false;
  BisnisKuliner objBisnisKuliner;

  @override
  void initState() {
    super.initState();

    init();
  }

  Future init() async {
    print('[INIT] Bisnis Profil Page');

    //Get User's Name
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final idUser = prefs.getInt('idUser');

    //Ambil ID pemilik bisnis kuliner dengan user ID yang login
    final pemilikbisniskuliner =
        await PemilikBisnisKulinerApi.getPemilikBisnisKulinerByIdUser(idUser);
    // int idPemilikBisnisKuliner;
    // for (int i = 0; i < pemilikbisniskuliner.length; i++) {
    //   if (idUser == pemilikbisniskuliner[i].idUser) {
    //     idPemilikBisnisKuliner = pemilikbisniskuliner[i].id;
    //   }
    // }

    //Ambil bisnis kuliner dengan ID Pemilik Bisnis Kuliner yang sudah didapat
    final bisniskuliner = await BisnisKulinerApi.getBisnisKulinerByIdPemilik(
        pemilikbisniskuliner[0]?.id);
    // BisnisKuliner tmpBisnisKuliner;
    // for (int i = 0; i < bisniskuliner.length; i++) {
    //   if (idPemilikBisnisKuliner == bisniskuliner[i].idPemilikBisnis) {
    //     tmpBisnisKuliner = bisniskuliner[i];
    //   }
    // }

    //Switch state
    bool switchState = false;
    if (bisniskuliner[0]?.statusBisnis == 0) {
      switchState = false;
    } else {
      switchState = true;
    }

    print('tmpBisnisKulinerNama: ' + bisniskuliner[0]?.namaBisnis);

    if (!mounted) return;

    setState(() {
      this.isOpen = switchState;
      this.objBisnisKuliner = bisniskuliner[0];
    });
  }

  void kontakAlamatOnTap() {
    // Navigator.of(context).pushNamed('/_KontakAlamatPage');
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => KontakAlamatPage(objBisnisKuliner)));
  }

  void rekeningPendapatanOnTap() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RekeningPendapatanPage(objBisnisKuliner)));
  }

  void profilBisnisOnTap() {
    var argumentsPassed = new ArgumentsProfile(objBisnisKuliner, init);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProfilBisnisPage(argumentsPassed)));
  }

  void gantiPasswordOnTap() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => GantiPasswordPage()));
  }

  void kontakOnTap() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => KontakPage()));
  }

  Future logoutPressed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String idUser = prefs.getInt('idUser').toString();
    int idBisnis = prefs.getInt('idBisnisLoggedIn');

    //Ubah status toko menjadi tutup
    final responseBisnis = await http.put(
        Uri.parse(AppGlobalConfig.getUrlApi() +
            'bisniskuliner/' +
            idBisnis.toString()),
        body: {
          'status_bisnis': '0',
        },
        headers: {
          'Accept': 'application/json'
        });
    if (responseBisnis.statusCode == 200) {
      print('Status toko tutup (logout)');
      print(responseBisnis.body);
    }

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
    prefs.remove('idBisnisLoggedIn');

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
                  height: 20.h,
                ),
                //CARD PROFILE
                Text(
                  objBisnisKuliner?.namaBisnis ?? 'namaBisnisNull',
                  style: descriptionTextBlack12,
                ),
                SizedBox(
                  height: 3.h,
                ),
                Text(
                  'ID bisnis kuliner: ' + objBisnisKuliner?.id?.toString() ??
                      'idBisnisNull',
                  style: descriptionTextBlack12,
                ),
                SizedBox(
                  height: 15.h,
                ),
                Row(
                  children: [
                    Text(
                      'Status bisnis kuliner : ',
                      style: descriptionTextBlack12,
                    ),
                    isOpen
                        ? Text(
                            'Buka',
                            style: descriptionTextBlack12,
                          )
                        : Text(
                            'Tutup',
                            style: descriptionTextBlack12,
                          ),
                  ],
                ),
                Switch(
                  value: isOpen,
                  onChanged: (value) async {
                    int statusBisnis;
                    if (value == true) {
                      statusBisnis = 1;
                      //Edit database
                      final response = await http.put(
                          Uri.parse(AppGlobalConfig.getUrlApi() +
                              'bisniskuliner/' +
                              objBisnisKuliner?.id?.toString()),
                          body: {
                            'status_bisnis': 1.toString(),
                          },
                          headers: {
                            'Accept': 'application/json'
                          });

                      print(response.body);
                    } else {
                      statusBisnis = 0;
                      //Edit database
                      final response = await http.put(
                          Uri.parse(AppGlobalConfig.getUrlApi() +
                              'bisniskuliner/' +
                              objBisnisKuliner?.id?.toString()),
                          body: {
                            'status_bisnis': 0.toString(),
                          },
                          headers: {
                            'Accept': 'application/json'
                          });

                      print(response.body);
                    }

                    final response = await http.put(
                        Uri.parse(AppGlobalConfig.getUrlApi() +
                            'bisniskuliner/' +
                            objBisnisKuliner?.id?.toString()),
                        body: {
                          'status_bisnis': statusBisnis.toString(),
                        },
                        headers: {
                          'Accept': 'application/json'
                        });

                    print(response.body);
                    if (!mounted) return;
                    setState(() {
                      isOpen = value;
                      print(isOpen);
                    });
                  },
                  activeTrackColor: lightOrange,
                  activeColor: darkOrange,
                ),
                SizedBox(
                  height: 5.h,
                ),

                SizedBox(
                  height: 60.h,
                ),
                Text(
                  'Informasi Bisnis',
                  style: titlePage,
                ),
                SizedBox(
                  height: 20.h,
                ),
                CardProfileTemplate('Kontak & Alamat', kontakAlamatOnTap),
                SizedBox(
                  height: 5.h,
                ),
                CardProfileTemplate(
                    'Rekening Pendapatan', rekeningPendapatanOnTap),
                SizedBox(
                  height: 5.h,
                ),
                CardProfileTemplate('Profil Bisnis', profilBisnisOnTap),
                SizedBox(
                  height: 5.h,
                ),
                CardProfileTemplate('Ganti password', gantiPasswordOnTap),
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
                ),
                SizedBox(
                  height: 50.h,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
