import 'package:eatme_mobileapp/api/bisniskuliner_api.dart';
import 'package:eatme_mobileapp/api/order_api.dart';
import 'package:eatme_mobileapp/cutomer_pages/Pesanan/pesananTerkonfirmasi_page.dart';
import 'package:eatme_mobileapp/main.dart';
import 'package:eatme_mobileapp/models/bisniskuliner.dart';
import 'package:eatme_mobileapp/models/order.dart';
import 'package:eatme_mobileapp/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class CardSedangBerjalanTemplate extends StatefulWidget {
  int idNota;
  int idBisnis;

  @override
  _CardSedangBerjalanTemplateState createState() =>
      _CardSedangBerjalanTemplateState(this.idNota, this.idBisnis);

  CardSedangBerjalanTemplate(this.idNota, this.idBisnis);
}

class _CardSedangBerjalanTemplateState
    extends State<CardSedangBerjalanTemplate> {
  int idNota;
  int idBisnis;

  List<Orders> listOrder = [];
  BisnisKuliner bisniskuliner;

  _CardSedangBerjalanTemplateState(this.idNota, this.idBisnis);

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

    if (!mounted) return;

    setState(() {
      this.listOrder = order;
      this.bisniskuliner = bisnis[0];
    });
  }

  void cardPressed() {
    var argumentsPassed = new ArgumentsPesananTerkonfirmasi(
        this.listOrder, this.bisniskuliner, this.idNota);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PesananTerkonfirmasiPage(argumentsPassed)));
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
          padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5.r),
                child: Image.asset(
                  'assets/images/illustration.jpg',
                  height: 70.h,
                  width: 70.w,
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
                    bisniskuliner?.namaBisnis ?? 'namaNull',
                    style: titleCard,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Siap diambil',
                    style: descriptionTextOrange12,
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
