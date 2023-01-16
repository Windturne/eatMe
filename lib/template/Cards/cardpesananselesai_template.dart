import 'package:eatme_mobileapp/api/bisniskuliner_api.dart';
import 'package:eatme_mobileapp/api/nota_api.dart';
import 'package:eatme_mobileapp/api/order_api.dart';
import 'package:eatme_mobileapp/cutomer_pages/Pesanan/pesananselesai_page.dart';
import 'package:eatme_mobileapp/main.dart';
import 'package:eatme_mobileapp/models/bisniskuliner.dart';
import 'package:eatme_mobileapp/models/nota.dart';
import 'package:eatme_mobileapp/models/order.dart';
import 'package:flutter/material.dart';
import 'package:eatme_mobileapp/theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class CardPesananSelesai extends StatefulWidget {
  int idNota;
  int idBisnis;

  @override
  _CardPesananSelesaiState createState() =>
      _CardPesananSelesaiState(this.idNota, this.idBisnis);

  CardPesananSelesai(this.idNota, this.idBisnis);
}

class _CardPesananSelesaiState extends State<CardPesananSelesai> {
  int idNota;
  int idBisnis;

  List<Orders> listOrder = [];
  BisnisKuliner bisniskuliner;
  Nota nota;

  _CardPesananSelesaiState(this.idNota, this.idBisnis);

  @override
  void initState() {
    super.initState();

    init();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future init() async {
    print('[INIT] Checkout Page');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int idUser = prefs.getInt('idUser');

    //Get Orders
    final order = await OrderApi.getOrdersByIdNotaAndUser(idNota, idUser);

    //Get Bisnis
    final bisnis = await BisnisKulinerApi.getBisnisKulinerById(this.idBisnis);

    //Get Nota
    final nota = await NotaApi.getNotaByIdNota(idNota);

    if (!mounted) return;

    setState(() {
      this.listOrder = order;
      this.bisniskuliner = bisnis[0];
      this.nota = nota[0];
    });
  }

  void cardPressed() {
    var argumentsPassed = new ArgumentsPesananSelesai(
        this.listOrder, this.bisniskuliner, this.idNota);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PesananSelesaiPage(argumentsPassed)));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: cardPressed,
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
                  DateFormat('dd-MM-yyyy')
                      .format(DateTime.parse(nota?.tanggalPengambilan)),
                  style: descriptionTextBlack10,
                  textAlign: TextAlign.end,
                ),
              ),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5.r),
                    child: Image.asset(
                      'assets/images/illustration.jpg',
                      height: 80.h,
                      width: 80.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(
                    width: 18.w,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            this.bisniskuliner.namaBisnis ?? 'namaBisnisNull',
                            style: titleCard,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                      Text(
                        this.nota?.totalItem.toString() + ' item(s)',
                        style: descriptionTextBlack12,
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                      this.nota?.ratingBisnis == 0
                          ? Text(
                              'Belum dinilai',
                              style: descriptionTextBlack12,
                            )
                          : Text('')
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
