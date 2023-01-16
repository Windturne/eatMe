import 'dart:math';

import 'package:eatme_mobileapp/api/detailbundle_api.dart';
import 'package:eatme_mobileapp/api/menu_api.dart';
import 'package:eatme_mobileapp/api/nota_api.dart';
import 'package:eatme_mobileapp/api/order_api.dart';
import 'package:eatme_mobileapp/appGlobalConfig.dart';
import 'package:eatme_mobileapp/main.dart';
import 'package:eatme_mobileapp/models/detailbundle.dart';
import 'package:eatme_mobileapp/models/menus.dart';
import 'package:eatme_mobileapp/models/nota.dart';
import 'package:eatme_mobileapp/models/order.dart';
import 'package:eatme_mobileapp/template/Buttons/button_template.dart';
import 'package:eatme_mobileapp/template/Buttons/iconbutton_template.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../../theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

class KonfirmasiPesananPage extends StatefulWidget {
  @override
  _KonfirmasiPesananPageState createState() => _KonfirmasiPesananPageState();

  final ArgumentsStatusPesanan argumentsPassed;
  KonfirmasiPesananPage(this.argumentsPassed);
}

class _KonfirmasiPesananPageState extends State<KonfirmasiPesananPage> {
  List<Orders> listOrder = [];
  List<Menus> listMenu = [];
  List<DetailBundle> listBundle = [];
  Menus menu;
  DetailBundle bundle;

  @override
  void initState() {
    super.initState();

    init();
  }

  Future init() async {
    print('[INIT] BisCardKonfirmasi Page');

    final order =
        await OrderApi.getOrdersByIdNota(widget.argumentsPassed.idNota);

    final menus = await MenusApi.getAllMenus();

    final bundles = await DetailBundleApi.getAllBundle();

    if (!mounted) return;

    setState(() {
      this.listOrder = order;
      this.listMenu = menus;
      this.listBundle = bundles;
    });
  }

  void backButtonPressed() {
    Navigator.pop(context);
  }

  int randomNumbers() {
    Random rand = new Random();
    return rand.nextInt(90000) + 10000;
  }

  Future konfirmasiPesananPressed() async {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                'Konfirmasi Pesanan',
                style: titlePage,
                textAlign: TextAlign.center,
              ),
              content: Text(
                'Konfirmasi pesanan? Pesanan yang sudah dikonfirmasi tidak bisa dibatalkan',
                style: descriptionTextBlack12,
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'TIDAK',
                      style: titleCard,
                    )),
                TextButton(
                    onPressed: () async {
                      updateStatusNota(1);
                    },
                    child: Text(
                      'YA',
                      style: descriptionTextOrangeMedium12,
                    ))
              ],
            ));
  }

  Future updateStatusNota(int statusPesanan) async {
    //Loading setelah tekan tombol
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.style(message: 'Loading...');
    progressDialog.show();

    //Cek apakah nota masih ada
    final listCekNota =
        await NotaApi.getNotaByIdNota(widget.argumentsPassed.idNota);
    if (listCekNota.length != 0) {
      if (statusPesanan == 1) {
        //Generate PIN
        //Ambil field PIN di database, masukkan ke set (supaya tdk dobel)
        List<Nota> nota = await NotaApi.getAllPinCodes();
        Set<int> allPinCodes = Set();

        if (nota.length != 0) {
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
                Uri.parse(AppGlobalConfig.getUrlApi() +
                    'nota/' +
                    widget.argumentsPassed.idNota.toString()),
                body: {
                  'pin_pengambilan': pinCode.toString(),
                  'status_nota': 1.toString()
                },
                headers: {
                  'Accept': 'application/json'
                });

            print(response.body);

            progressDialog.hide();
            Navigator.pop(context);
            showDialogTerkonfirmasi();
          }
        }

        //Update status order (kosongi cart)
        final order =
            await OrderApi.getOrdersByIdNota(widget.argumentsPassed.idNota);
        for (int i = 0; i < order.length; i++) {
          final response = await http.put(
              Uri.parse(AppGlobalConfig.getUrlApi() +
                  'order/' +
                  order[i].id.toString()),
              body: {'status_order': 3.toString()},
              headers: {'Accept': 'application/json'});

          print(response.body);
        }
      } else {
        //Update Status Nota
        final response = await http.put(
            Uri.parse(AppGlobalConfig.getUrlApi() +
                'nota/' +
                widget.argumentsPassed.idNota.toString()),
            body: {'status_nota': '-1'},
            headers: {'Accept': 'application/json'});
        progressDialog.hide();

        print(response.body);
      }
    } else {
      Alert(
          style: AlertStyle(
              descStyle: descriptionTextBlack12,
              isCloseButton: false,
              titleStyle: titlePage),
          context: context,
          title: "Konfirmasi Pesanan Gagal",
          desc: "Konsumen membatalkan pemesanan",
          type: AlertType.error,
          buttons: [
            DialogButton(
                color: lightOrange,
                child: Text('OK', style: buttonText),
                onPressed: () {
                  progressDialog.hide();
                  // int count = 0;
                  // Navigator.of(context).popUntil((_) => count++ >= 3);
                  Navigator.pushReplacementNamed(
                      context, '/_BusinessBottomNav');
                })
          ]).show();
    }
  }

  showDialogTerkonfirmasi() {
    showDialog(
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
                      widget.argumentsPassed.initBisPesananPage();
                    },
                    child: Text(
                      'OK',
                      style: titleCard,
                    )),
              ],
            ));
  }

  tolakPesananPressed() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                'Tolak Pesanan',
                style: titlePage,
                textAlign: TextAlign.center,
              ),
              content: Text(
                'Tolak pesanan?',
                style: descriptionTextBlack12,
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'TIDAK',
                      style: titleCard,
                    )),
                TextButton(
                    onPressed: () async {
                      updateStatusNota(-1);
                      // int count = 0;
                      // Navigator.of(context).popUntil((_) => count++ >= 2);
                      Navigator.pushReplacementNamed(
                          context, '/_BusinessBottomNav');
                    },
                    child: Text(
                      'YA',
                      style: descriptionTextOrangeMedium12,
                    ))
              ],
            ));
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
                  Container(
                    width: double.infinity,
                    child: Text(
                      // 'NOTA (ID: ' +
                      //     widget.argumentsPassed.idNota.toString() +
                      //     ')',
                      'Pesanan',
                      style: titlePage,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  Container(
                    width: double.infinity,
                    child: Text(
                      widget.argumentsPassed.namaUser,
                      style: subtitlePage,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: 40.h,
                  ),
                  Text(
                    'Pesanan',
                    style: descriptionTextBlack12,
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
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
                              itemCount: this.listOrder.length,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                print(this.listOrder.length);
                                final order = this.listOrder[index];

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

                                print('Nama makanan: ' + this.menu.namaMakanan);

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
                                                  menu.hargaMakanan, 2) ??
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
                                    widget.argumentsPassed.totalHarga, 2),
                                style: descriptionTextOrangeMedium12,
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 100.h,
                  ),
                  ButtonTemplate('KONFIRMASI PESANAN', lightOrange,
                      onPressed: konfirmasiPesananPressed),
                  SizedBox(
                    height: 15.h,
                  ),
                  ButtonTemplate('TOLAK PESANAN', darkGrey,
                      onPressed: tolakPesananPressed),
                ],
              )),
        ),
      ),
    );
  }
}
