import 'package:eatme_mobileapp/api/nota_api.dart';
import 'package:eatme_mobileapp/api/user_api.dart';
import 'package:eatme_mobileapp/appGlobalConfig.dart';
import 'package:eatme_mobileapp/business_pages/Pesanan/bispesananselesai_page.dart';
import 'package:eatme_mobileapp/main.dart';
import 'package:flutter/material.dart';
import 'package:eatme_mobileapp/theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class BisCardPendapatanTemplate extends StatefulWidget {
  int idNota;
  int totalHarga;
  int komisi;
  int pendapatanBersih;
  String tanggalPendapatan;

  @override
  _BisCardPendapatanTemplateState createState() =>
      _BisCardPendapatanTemplateState(this.idNota, this.totalHarga, this.komisi,
          this.pendapatanBersih, this.tanggalPendapatan);

  BisCardPendapatanTemplate(this.idNota, this.totalHarga, this.komisi,
      this.pendapatanBersih, this.tanggalPendapatan);
}

class _BisCardPendapatanTemplateState extends State<BisCardPendapatanTemplate> {
  int idNota;
  int totalHarga;
  int komisi;
  int pendapatanBersih;
  String tanggalPendapatan;

  _BisCardPendapatanTemplateState(this.idNota, this.totalHarga, this.komisi,
      this.pendapatanBersih, this.tanggalPendapatan);

  Future cardPressed() async {
    print('card pressed');
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // var namaUser = prefs.getString('namaUser');
    var nota = await NotaApi.getNotaByIdNota(this.idNota);
    var user = await UserApi.getUserById(nota[0].idUser);
    var namaUser = user[0].name;

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
                  DateFormat('dd-MM-yyyy, hh:mm')
                      .format(DateTime.parse(tanggalPendapatan)),
                  style: descriptionTextBlack10,
                  textAlign: TextAlign.end,
                ),
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NOTA(ID: ' + idNota.toString() + ')',
                        style: titleCard,
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total',
                                style: descriptionTextBlack12,
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                              Text(
                                'Komisi (10%)',
                                style: descriptionTextBlack12,
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                              Text(
                                'Pendapatan bersih',
                                style: descriptionTextBlack12,
                              )
                            ],
                          ),
                          SizedBox(
                            width: 5.w,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ': ' +
                                    AppGlobalConfig.convertToIdr(totalHarga, 2),
                                style: descriptionTextBlack12,
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                              Text(
                                ': ' + AppGlobalConfig.convertToIdr(komisi, 2),
                                style: descriptionTextBlack12,
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                              Text(
                                ': ' +
                                    AppGlobalConfig.convertToIdr(
                                        pendapatanBersih, 2),
                                style: descriptionTextBlack12,
                              )
                            ],
                          )
                        ],
                      )
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
