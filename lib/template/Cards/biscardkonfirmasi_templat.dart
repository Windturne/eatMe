import 'dart:math';

import 'package:eatme_mobileapp/api/nota_api.dart';
import 'package:eatme_mobileapp/api/user_api.dart';
import 'package:eatme_mobileapp/business_pages/Pesanan/konfirmasipesanan_page.dart';
import 'package:eatme_mobileapp/main.dart';
import 'package:eatme_mobileapp/models/nota.dart';
import 'package:eatme_mobileapp/models/user.dart';
import 'package:eatme_mobileapp/template/Buttons/textbutton_template.dart';
import 'package:flutter/material.dart';
import 'package:eatme_mobileapp/theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

import '../../appGlobalConfig.dart';

// ignore: must_be_immutable
class BisCardKonfirmasi extends StatefulWidget {
  int idNota;
  int idUser;
  int totalItem;
  int totalHarga;
  final VoidCallback initBisPesananPage;

  @override
  _BisCardKonfirmasiState createState() => _BisCardKonfirmasiState(
      this.idNota, this.idUser, this.totalItem, this.totalHarga);

  BisCardKonfirmasi(this.idNota, this.idUser, this.totalItem, this.totalHarga,
      this.initBisPesananPage);
}

class _BisCardKonfirmasiState extends State<BisCardKonfirmasi> {
  int idNota;
  int idUser;
  int totalItem;
  int totalHarga;
  User user;
  _BisCardKonfirmasiState(
      this.idNota, this.idUser, this.totalItem, this.totalHarga);

  @override
  void initState() {
    super.initState();

    init();
  }

  Future init() async {
    print('[INIT] BisCardKonfirmasi Page');

    final user = await UserApi.getUserById(idUser);
    // final namaUser = user[0].name;

    if (!mounted) return;

    setState(() {
      this.user = user[0];
    });
  }

  void lihatDetailPressed() {
    var argumentsPassed = new ArgumentsStatusPesanan(
        widget.idNota, totalHarga, this.user.name, widget.initBisPesananPage);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => KonfirmasiPesananPage(argumentsPassed)));
  }

  // Future konfirmasiPressed() async {
  //   await showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //             title: Text(
  //               'Konfirmasi Pesanan',
  //               style: titlePage,
  //               textAlign: TextAlign.center,
  //             ),
  //             content: Text(
  //               'Konfirmasi pesanan? Pesanan yang sudah dikonfirmasi tidak bisa dibatalkan',
  //               style: descriptionTextBlack12,
  //             ),
  //             actions: [
  //               TextButton(
  //                   onPressed: () {
  //                     Navigator.pop(context);
  //                   },
  //                   child: Text(
  //                     'TIDAK',
  //                     style: titleCard,
  //                   )),
  //               TextButton(
  //                   onPressed: () async {
  //                     updateStatusNota();
  //                     Navigator.pop(context);
  //                   },
  //                   child: Text(
  //                     'YA',
  //                     style: descriptionTextOrangeMedium12,
  //                   ))
  //             ],
  //           )).then((value) => showDialogTerkonfirmasi());
  // }

  int randomNumbers() {
    Random rand = new Random();
    return rand.nextInt(90000) + 10000;
  }

  Future updateStatusNota() async {
    //Generate PIN
    //Ambil field PIN di database, masukkan ke set (supaya tdk dobel)
    List<Nota> nota = await NotaApi.getAllPinCodes();
    Set<int> allPinCodes = Set();

    if (nota?.length != 0 && nota.length != null) {
      for (int i = 0; i < nota.length; i++) {
        allPinCodes.add(nota[i].pinPengambilan);
      }
    }

    //Random number
    bool repeat = true;

    while (repeat) {
      int pinCode = randomNumbers();

      if (!allPinCodes.add(pinCode)) {
        print('gagal, random ulang');
      } else {
        repeat = false;
        print('Pin Code generated');

        //Update Status Nota
        final response = await http.put(
            Uri.parse(
                AppGlobalConfig.getUrlApi() + 'nota/' + this.idNota.toString()),
            body: {
              'pin_pengambilan': pinCode.toString(),
              'status_nota': 1.toString()
            },
            headers: {
              'Accept': 'application/json'
            });

        print(response.body);

        Navigator.pop(context);
      }
    }
  }

  Future showDialogTerkonfirmasi() async {
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                'Pesanan Terkonfirmasi',
                style: titlePage,
                textAlign: TextAlign.center,
              ),
              content: Text(
                'Pesanan berhasil di konfirmasi, silakan melihat list pesanan yang siap diambil pada tab "Siap Diambil" ',
                style: descriptionTextBlack12,
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      int count = 0;
                      Navigator.of(context).popUntil((_) => count++ >= 2);
                      widget.initBisPesananPage();
                    },
                    child: Text(
                      'OK',
                      style: titleCard,
                    )),
              ],
            ));
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            this.user?.name ?? 'namaUserNull',
                            style: descriptionTextBlack12,
                          ),
                          SizedBox(
                            width: 4.w,
                          ),
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
                            this.user?.ratingUser?.toString() != 0.toString()
                                ? double.parse(
                                        this.user?.ratingUser?.toString())
                                    .toStringAsFixed(1)
                                : '0.0',
                            style: descriptionTextGrey12,
                          )
                        ],
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
                  Spacer(),
                  // SizedBox(
                  //   width: 100.w,
                  //   child: ElevatedButton(
                  //       child: Text(
                  //         'KONFIRMASI',
                  //         style: TextStyle(
                  //             fontSize: 12.sp,
                  //             color: white,
                  //             fontWeight: FontWeight.w700),
                  //       ),
                  //       style: ElevatedButton.styleFrom(
                  //           primary: lightOrange,
                  //           shape: RoundedRectangleBorder(
                  //               borderRadius: BorderRadius.circular(20.r)),
                  //           padding: EdgeInsets.symmetric(vertical: 10.h)),
                  //       onPressed: konfirmasiPressed),
                  // )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
