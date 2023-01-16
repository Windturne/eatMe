import 'package:eatme_mobileapp/api/pemilikbisniskuliner_api.dart';
import 'package:eatme_mobileapp/models/bisniskuliner.dart';
import 'package:eatme_mobileapp/models/pemilikbisniskuliner.dart';
import 'package:eatme_mobileapp/template/Buttons/button_template.dart';
import 'package:eatme_mobileapp/template/Buttons/iconbutton_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme.dart';

// ignore: must_be_immutable
class RekeningPendapatanPage extends StatefulWidget {
  @override
  _RekeningPendapatanPageState createState() => _RekeningPendapatanPageState();

  BisnisKuliner objBisnisKuliner;
  RekeningPendapatanPage(this.objBisnisKuliner);
}

class _RekeningPendapatanPageState extends State<RekeningPendapatanPage> {
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
        'subject': 'Pengajuan Perubahan Rekening Pendapatan: ' +
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
                    'Rekening Pendapatan',
                    style: titlePage,
                  ),
                  SizedBox(
                    height: 40.h,
                  ),
                  Text(
                    'Nama Pemilik Rekening',
                    style: descriptionTextBlack10,
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  Text(
                    pemilikBisnisKuliner?.namaRekening ?? 'namaRekeningNull',
                    style: descriptionTextBlack12,
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  Text(
                    'Nomor Rekening ',
                    style: descriptionTextBlack10,
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  Text(
                    pemilikBisnisKuliner?.noRekening ?? 'noRekNull',
                    style: descriptionTextBlack12,
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  Text(
                    'Nama Bank',
                    style: descriptionTextBlack10,
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  Text(
                    pemilikBisnisKuliner?.bankRekening ?? 'bankNull',
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
