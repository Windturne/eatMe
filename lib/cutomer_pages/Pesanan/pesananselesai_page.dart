import 'dart:convert';

import 'package:eatme_mobileapp/api/detailbundle_api.dart';
import 'package:eatme_mobileapp/api/menu_api.dart';
import 'package:eatme_mobileapp/api/nota_api.dart';
import 'package:eatme_mobileapp/cutomer_pages/Pesanan/komplain_page.dart';
import 'package:eatme_mobileapp/main.dart';
import 'package:eatme_mobileapp/models/detailbundle.dart';
import 'package:eatme_mobileapp/models/menus.dart';
import 'package:eatme_mobileapp/models/nota.dart';
import 'package:eatme_mobileapp/template/Buttons/button_template.dart';
import 'package:eatme_mobileapp/template/Buttons/iconbutton_template.dart';
import 'package:eatme_mobileapp/template/Buttons/textbutton_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';

import '../../appGlobalConfig.dart';
import '../../theme.dart';

class PesananSelesaiPage extends StatefulWidget {
  @override
  _PesananSelesaiPageState createState() => _PesananSelesaiPageState();

  final ArgumentsPesananSelesai argumentsPassed;
  PesananSelesaiPage(this.argumentsPassed);
}

class _PesananSelesaiPageState extends State<PesananSelesaiPage> {
  double ratingStars = 0;
  List<Menus> listMenu = [];
  List<DetailBundle> listBundle = [];
  Menus menu;
  DetailBundle bundle;
  Nota nota;

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

    //Get Menus
    final menus = await MenusApi.getAllMenus();

    //Get Bundles
    final bundles = await DetailBundleApi.getAllBundle();

    //Get Nota
    final nota = await NotaApi.getNotaByIdNota(widget.argumentsPassed.idNota);

    if (!mounted) return;

    setState(() {
      this.listMenu = menus;
      this.listBundle = bundles;
      this.nota = nota[0];
    });
  }

  void closePagePressed() {
    Navigator.pop(context);
  }

  Future submitRating() async {
    //Loading setelah tekan tombol
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.style(message: 'Loading...');
    progressDialog.show();

    //ADD rating bisnis ke tabel nota
    final response = await http.put(
        Uri.parse(
            AppGlobalConfig.getUrlApi() + 'nota/' + this.nota.id.toString()),
        body: {
          'rating_bisnis': ratingStars.toString(),
        },
        headers: {
          'Accept': 'application/json'
        });

    if (response.statusCode == 200) {
      print(response.body);
    }

    //EDIT rata2 rating di id bisnis kuliner
    if (widget.argumentsPassed.bisnis.ratingBisnis == 0) {
      final response = await http.put(
          Uri.parse(AppGlobalConfig.getUrlApi() +
              'bisniskuliner/' +
              widget.argumentsPassed.bisnis.id.toString()),
          body: {
            'rating_bisnis': ratingStars.toString(),
          },
          headers: {
            'Accept': 'application/json'
          });

      if (response.statusCode == 200) {
        print(response.body);
      }
    } else {
      double sumAll = 0;
      final listRating =
          await NotaApi.getRataRataBisnis(widget.argumentsPassed.bisnis.id);
      for (int i = 0; i < listRating.length; i++) {
        sumAll += listRating[i].ratingBisnis;
      }
      final ratingMean = sumAll / listRating.length;

      final response = await http.put(
          Uri.parse(AppGlobalConfig.getUrlApi() +
              'bisniskuliner/' +
              widget.argumentsPassed.bisnis.id.toString()),
          body: {
            'rating_bisnis': ratingMean.toString(),
          },
          headers: {
            'Accept': 'application/json'
          });

      if (response.statusCode == 200) {
        print(response.body);
      }
    }

    //Add pendapatan ke bisnis kuliner
    final urlApiPendapatan = AppGlobalConfig.getUrlApi() + 'pendapatan';
    final komisiPendapatan = this.nota.totalHarga * 0.1;
    final responsePendapatan = await http.post(Uri.parse(urlApiPendapatan),
        headers: {
          "Content-Type": "application/json; charset=utf-8",
        },
        body: json.encode({
          'id_bisnis_kuliner': widget.argumentsPassed.bisnis.id.toString(),
          'id_nota': this.nota.id.toString(),
          'total_harga': this.nota.totalHarga.toString(),
          'komisi': komisiPendapatan.toString(),
          'pendapatan_bersih':
              (this.nota.totalHarga - komisiPendapatan).toString(),
          'tanggal_pendapatan': this.nota.tanggalPengambilan
        }));

    if (responsePendapatan.statusCode == 200) {
      print(responsePendapatan.body);
    }

    // int count = 0;
    // Navigator.of(context).popUntil((_) => count++ >= 3);
    Navigator.pushReplacementNamed(context, '/_CustomerBottomNav');
  }

  Widget buildRating() => RatingBar.builder(
        minRating: 1,
        itemBuilder: (context, _) => Icon(
          Icons.star,
          color: darkOrange,
        ),
        onRatingUpdate: (rating) {
          if (!mounted) return;
          setState(() {
            this.ratingStars = rating;
            print(ratingStars);
          });
        },
      );

  void beriPenilaianPressed() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                'Beri Penilaian Kepada Bisnis Kuliner',
                style: titlePage,
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.argumentsPassed.bisnis.namaBisnis,
                    style: descriptionTextBlack14,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  buildRating(),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: submitRating,
                    child: Text(
                      'SUBMIT',
                      style: descriptionTextOrangeMedium12,
                    ))
              ],
            ));
  }

  void ajukanKomplainPressed() {
    var argumentsPassed = new ArgumentsKomplain(this.nota.id, 'user');
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => KomplainPage(argumentsPassed)));
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
                  IconButtonTemplate(black, Icons.cancel_outlined,
                      onPressed: closePagePressed),
                  Container(
                    width: double.infinity,
                    child: Text(
                      widget.argumentsPassed?.bisnis?.namaBisnis ??
                          'namaBisnisNull',
                      style: titlePage,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: 40.h,
                  ),
                  Text(
                    'NOTA (ID: ' +
                        widget.argumentsPassed?.idNota?.toString() +
                        ')',
                    style: descriptionTextBlack12,
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  //CARD
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r)),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 20.h, horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListView.builder(
                              itemCount:
                                  widget.argumentsPassed?.listOrder?.length,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                print(
                                    widget.argumentsPassed?.listOrder?.length);
                                final order =
                                    widget.argumentsPassed?.listOrder[index];

                                if (order.idDetailBundle == null) {
                                  for (int i = 0; i < listMenu.length; i++) {
                                    if (order.idMenu == listMenu[i].id) {
                                      this.menu = listMenu[i];
                                    }
                                  }
                                } else {
                                  //Ambil Menu
                                  for (int i = 0; i < listMenu.length; i++) {
                                    if (order.idMenu == listMenu[i].id) {
                                      this.menu = listMenu[i];
                                    }
                                  }

                                  //Ambil bundle
                                  for (int i = 0; i < listBundle.length; i++) {
                                    if (order.idDetailBundle ==
                                        listBundle[i].id) {
                                      this.bundle = listBundle[i];
                                    }
                                  }
                                }

                                // print('Nama makanan: ' +
                                //     this.menu.namaMakanan);

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 210.w,
                                          child: order.idDetailBundle == null
                                              ? Text(
                                                  order.jumlahMakanan
                                                              .toString() +
                                                          'x ' +
                                                          menu?.namaMakanan ??
                                                      'namaMakananNull',
                                                  style: descriptionTextBlack12,
                                                )
                                              : Text(
                                                  order.jumlahMakanan
                                                              .toString() +
                                                          'x ' +
                                                          '[BUNDLE] ' +
                                                          bundle?.isiMenu ??
                                                      'namaMakananNull',
                                                  style: descriptionTextBlack12,
                                                ),
                                        ),
                                        Spacer(),
                                        Text(
                                          AppGlobalConfig.convertToIdr(
                                                  menu?.hargaMakanan ?? 0, 2) ??
                                              'hargaMakananNull',
                                          style: descriptionTextBlack12,
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 3.h,
                                    ),
                                    Text(
                                      order.catatanMakanan ??
                                          'Tidak ada catatan',
                                      style: descriptionTextGrey10,
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                  ],
                                );
                              }),
                          SizedBox(
                            height: 15.h,
                          ),
                          Divider(),
                          SizedBox(
                            height: 15.h,
                          ),
                          Row(
                            children: [
                              Text(
                                'TOTAL',
                                style: descriptionTextOrangeMedium12,
                              ),
                              Spacer(),
                              Text(
                                AppGlobalConfig.convertToIdr(
                                    this.nota?.totalHarga ?? 0, 2),
                                style: descriptionTextOrangeMedium12,
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 34.h,
                  ),
                  Text(
                    'Informasi Pengambilan',
                    style: descriptionTextBlack12,
                  ),
                  SizedBox(
                    height: 12.h,
                  ),
                  Container(
                    // height: 90.h,
                    width: double.infinity,
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r)),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 14.h, horizontal: 14.w),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.place_outlined,
                                  color: black,
                                  size: 14,
                                ),
                                SizedBox(
                                  width: 3.w,
                                ),
                                Text(
                                  widget.argumentsPassed?.bisnis
                                          ?.alamatBisnis ??
                                      'alamatNull',
                                  style: descriptionTextBlack12,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  color: black,
                                  size: 14,
                                ),
                                SizedBox(
                                  width: 3.w,
                                ),
                                Text(
                                  DateFormat('h:mma').format(DateTime.parse(this
                                          .widget
                                          .argumentsPassed
                                          ?.bisnis
                                          ?.jamAmbilAwal)) +
                                      ' - ' +
                                      DateFormat('h:mma').format(DateTime.parse(
                                          this
                                              .widget
                                              .argumentsPassed
                                              ?.bisnis
                                              ?.jamAmbilAkhir)),
                                  style: descriptionTextBlack12,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 60.h,
                  ),
                  Container(
                    width: double.infinity,
                    child: Column(
                      children: [
                        Text(
                          'DIAMBIL PADA',
                          style: descriptionTextBlack14,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 5.h,
                        ),
                        Text(
                          DateFormat('dd-MM-yyyy').format(DateTime.parse(
                                  this.nota?.tanggalPengambilan)) +
                              ', ' +
                              DateFormat('h:mma').format(DateTime.parse(
                                  this.nota?.tanggalPengambilan)),
                          style: descriptionTextBlack14,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 60.h,
                        ),
                        if (this.nota.ratingBisnis == 0 &&
                            this.nota.statusKomplain == 0) ...[
                          Column(
                            children: [
                              ButtonTemplate('BERI PENILAIAN', lightOrange,
                                  onPressed: beriPenilaianPressed),
                              SizedBox(
                                height: 10.h,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Memiliki kendala? ',
                                    style: descriptionTextGrey12,
                                  ),
                                  TextButtonTemplate(
                                      'Ajukan komplain', darkGrey,
                                      onPressed: ajukanKomplainPressed)
                                ],
                              )
                            ],
                          )
                        ] else if (this.nota.ratingBisnis == 0 &&
                                this.nota.statusKomplain == 1 ||
                            this.nota.statusKomplain == 11) ...[
                          Text(
                            'Terdapat pengajuan komplain. Informasi lebih lanjut akan diberitahukan melalui email yang sudah terdaftar',
                            style: descriptionTextBlack12,
                            textAlign: TextAlign.center,
                          )
                        ] else if (this.nota.ratingBisnis == 0 &&
                            this.nota.statusKomplain == 2) ...[
                          ButtonTemplate('BERI PENILAIAN', lightOrange,
                              onPressed: beriPenilaianPressed),
                        ] else ...[
                          Text('')
                        ],
                      ],
                    ),
                  )
                ],
              )),
        ),
      ),
    );
  }
}
