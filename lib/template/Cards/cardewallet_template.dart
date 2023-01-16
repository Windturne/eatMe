import 'package:eatme_mobileapp/api/bisniskuliner_api.dart';
import 'package:eatme_mobileapp/api/order_api.dart';
import 'package:eatme_mobileapp/appGlobalConfig.dart';
import 'package:eatme_mobileapp/cutomer_pages/Pesanan/pesananselesai_page.dart';
import 'package:eatme_mobileapp/models/transaksi.dart';
import 'package:flutter/material.dart';
import 'package:eatme_mobileapp/theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../main.dart';

// ignore: must_be_immutable
class CardEwalletTemplate extends StatefulWidget {
  Transaksi transaksi;

  @override
  _CardEwalletTemplateState createState() =>
      _CardEwalletTemplateState(this.transaksi);

  CardEwalletTemplate(this.transaksi);
}

class _CardEwalletTemplateState extends State<CardEwalletTemplate> {
  Transaksi transaksi;
  String namaBisnis;

  _CardEwalletTemplateState(this.transaksi);

  @override
  void initState() {
    super.initState();

    init();
  }

  Future init() async {
    print('[INIT] BisCardKonfirmasi Page');

    //Get Bisnis Kuliner name
    if (transaksi.idBisnisKuliner != null) {
      final bisnisKuliner = await BisnisKulinerApi.getBisnisKulinerById(
          transaksi.idBisnisKuliner);
      if (!mounted) return;
      setState(() {
        this.namaBisnis = bisnisKuliner[0].namaBisnis;
      });
    }

    if (!mounted) return;
  }

  Future cardPressed() async {
    if (widget.transaksi.tipeTransaksi == 'pembelian') {
      final listOrder = await OrderApi.getOrdersByIdNota(this.transaksi.idNota);
      final bisniskuliner = await BisnisKulinerApi.getBisnisKulinerById(
          this.transaksi.idBisnisKuliner);

      var argumentsPassed = new ArgumentsPesananSelesai(
          listOrder, bisniskuliner[0], this.transaksi.idNota);

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PesananSelesaiPage(argumentsPassed)));
    }
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
                          .format(DateTime.parse(transaksi.tanggalTransaksi)) ??
                      'tanggalNull',
                  style: descriptionTextBlack10,
                  textAlign: TextAlign.end,
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
                        transaksi.tipeTransaksi == 'topup' &&
                                transaksi.tipeTransaksi != null
                            ? 'Top-up Saldo'
                            : 'Pengurangan Saldo Transaksi',
                        style: titleCard,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    AppGlobalConfig.convertToIdr(
                            transaksi.jumlahTransaksi, 2) ??
                        'jmlTransaksiNull',
                    style: descriptionTextBlack12,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  if (transaksi.tipeTransaksi == 'topup' &&
                      transaksi.statusTopup == 0) ...[
                    Text(
                      'Sedang diproses',
                      style: descriptionTextOrange12,
                    )
                  ] else if (transaksi.tipeTransaksi == 'topup' &&
                      transaksi.statusTopup == 1) ...[
                    Text(
                      'Dana berhasil ditambahkan',
                      style: descriptionTextGreen12,
                    )
                  ] else ...[
                    Text(
                      AppGlobalConfig.titleCase(this.namaBisnis) ??
                          'namaBisnisNull',
                      style: descriptionTextRed12,
                    )
                  ]
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
