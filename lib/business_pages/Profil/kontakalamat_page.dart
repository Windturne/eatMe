import 'package:eatme_mobileapp/api/pemilikbisniskuliner_api.dart';
import 'package:eatme_mobileapp/models/bisniskuliner.dart';
import 'package:eatme_mobileapp/models/pemilikbisniskuliner.dart';
import 'package:eatme_mobileapp/template/Buttons/button_template.dart';
import 'package:eatme_mobileapp/template/Buttons/iconbutton_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme.dart';

class KontakAlamatPage extends StatefulWidget {
  @override
  _KontakAlamatPageState createState() => _KontakAlamatPageState();

  final BisnisKuliner objBisnisKuliner;
  const KontakAlamatPage(this.objBisnisKuliner);
}

class _KontakAlamatPageState extends State<KontakAlamatPage> {
  PemilikBisnisKuliner pemilikBisnisKuliner;

  @override
  void initState() {
    super.initState();

    init();
  }

  Future init() async {
    print('[INIT] Bisnis Profil Page');

    //Ambil id pemilik bisnis kuliner
    PemilikBisnisKuliner pemilikTmp;
    var response = await PemilikBisnisKulinerApi.getPemilikBisnisKulinerById(
        widget.objBisnisKuliner.idPemilikBisnis);
    pemilikTmp = response[0];

    if (!mounted) return;

    setState(() {
      this.pemilikBisnisKuliner = pemilikTmp;
    });
  }

  void backButtonPressed() {
    Navigator.pop(context);
  }

  String encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  void ajukanPerubahanPressed() {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'eatmemobileapp@gmail.com',
      query: encodeQueryParameters(<String, String>{
        'subject': 'Pengajuan Perubahan Kontak dan Alamat: ' +
            widget.objBisnisKuliner.namaBisnis +
            ' ( ID: ' +
            widget.objBisnisKuliner.id.toString() +
            ' )',
        'body':
            'Cantumkan data yang ingin diubah beserta alasan pengubahan. Administrator akan segera memproses dan menghubungi dalam waktu maksimal 2x24 jam.'
      }),
    );
    launch(emailLaunchUri.toString());
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
                    'Kontak & Alamat',
                    style: titlePage,
                  ),
                  SizedBox(
                    height: 40.h,
                  ),
                  Text(
                    'Nomor Telepon Pemilik Bisnis Kuliner',
                    style: descriptionTextBlack10,
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  Text(
                    pemilikBisnisKuliner?.noTelp ?? 'notelpNull',
                    style: descriptionTextBlack12,
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  Text(
                    'Email Pemilik Bisnis Kuliner ',
                    style: descriptionTextBlack10,
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  Text(
                    pemilikBisnisKuliner?.emailPemilik ?? 'emailNull',
                    style: descriptionTextBlack12,
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  Text(
                    'Alamat Bisnis Kuliner',
                    style: descriptionTextBlack10,
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  Text(
                    widget.objBisnisKuliner.alamatBisnis ?? 'alamatNull',
                    style: descriptionTextBlack12,
                  ),
                  SizedBox(
                    height: 100.h,
                  ),
                  ButtonTemplate('AJUKAN PERUBAHAN', lightOrange,
                      onPressed: ajukanPerubahanPressed),
                  SizedBox(
                    height: 10.h,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      '*Apabila ada perubahan informasi mohon ajukan perubahan untuk melakukan proses validasi ulang*',
                      style: descriptionTextBlack10,
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              )),
        ),
      ),
    );
  }
}
