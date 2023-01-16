import 'package:eatme_mobileapp/api/user_api.dart';
import 'package:eatme_mobileapp/business_pages/Pesanan/bispesananselesai_page.dart';
import 'package:eatme_mobileapp/template/Buttons/textbutton_template.dart';
import 'package:flutter/material.dart';
import 'package:eatme_mobileapp/theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../main.dart';

// ignore: must_be_immutable
class BisCardSelesai extends StatefulWidget {
  int idNota;
  int idUser;
  int totalItem;
  int totalHarga;
  final VoidCallback initBisPesananPage;

  @override
  _BisCardSelesaiState createState() => _BisCardSelesaiState(
      this.idNota, this.idUser, this.totalItem, this.totalHarga);
  BisCardSelesai(this.idNota, this.idUser, this.totalItem, this.totalHarga,
      this.initBisPesananPage);
}

class _BisCardSelesaiState extends State<BisCardSelesai> {
  int idNota;
  int idUser;
  int totalItem;
  int totalHarga;
  String namaUser;

  _BisCardSelesaiState(
      this.idNota, this.idUser, this.totalItem, this.totalHarga);

  @override
  void initState() {
    super.initState();

    init();
  }

  Future init() async {
    print('[INIT] BisCardKonfirmasi Page');

    final user = await UserApi.getUserById(idUser);
    final namaUser = user[0].name;

    if (!mounted) return;

    setState(() {
      this.namaUser = namaUser;
    });
  }

  void lihatDetailPressed() {
    var argumentsPassed =
        new ArgumentsBisPesananSelesai(widget.idNota, totalHarga, namaUser);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BisPesananSelesaiPage(argumentsPassed)));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Card(
        elevation: 5,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                child: Text(
                  '',
                  style: descriptionTextBlack10,
                  textAlign: TextAlign.end,
                ),
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'NOTA (ID: ' + idNota.toString() + ')',
                            style: titleCard,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                      Text(
                        namaUser ?? 'namaUserNull',
                        style: descriptionTextBlack12,
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                      Text(
                        totalItem.toString() + ' item(s)',
                        style: descriptionTextBlack12,
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      TextButtonTemplate('Lihat detail', lightOrange,
                          onPressed: lihatDetailPressed)
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
