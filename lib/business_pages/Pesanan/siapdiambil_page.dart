import 'dart:async';

import 'package:eatme_mobileapp/api/detailbundle_api.dart';
import 'package:eatme_mobileapp/api/menu_api.dart';
import 'package:eatme_mobileapp/api/nota_api.dart';
import 'package:eatme_mobileapp/api/order_api.dart';
import 'package:eatme_mobileapp/api/user_api.dart';
import 'package:eatme_mobileapp/appGlobalConfig.dart';
import 'package:eatme_mobileapp/models/detailbundle.dart';
import 'package:eatme_mobileapp/models/menus.dart';
import 'package:eatme_mobileapp/models/nota.dart';
import 'package:eatme_mobileapp/models/order.dart';
import 'package:eatme_mobileapp/template/Buttons/button_template.dart';
import 'package:eatme_mobileapp/template/Buttons/iconbutton_template.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';
import '../../main.dart';
import '../../theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_pin_code_fields/flutter_pin_code_fields.dart';
import 'package:http/http.dart' as http;

class SiapDiambilPage extends StatefulWidget {
  @override
  _SiapDiambilPageState createState() => _SiapDiambilPageState();

  final ArgumentsStatusPesanan argumentsPassed;
  SiapDiambilPage(this.argumentsPassed);
}

class _SiapDiambilPageState extends State<SiapDiambilPage> {
  TextEditingController pinController = TextEditingController();
  List<Orders> listOrder = [];
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
    // pinController.dispose();
    super.dispose();
  }

  Future init() async {
    print('[INIT] BisCardKonfirmasi Page');

    final order =
        await OrderApi.getOrdersByIdNota(widget.argumentsPassed.idNota);

    final menus = await MenusApi.getAllMenus();

    final bundles = await DetailBundleApi.getAllBundle();

    final nota = await NotaApi.getNotaByIdNota(widget.argumentsPassed.idNota);

    if (!mounted) return;

    setState(() {
      this.listOrder = order;
      this.listMenu = menus;
      this.listBundle = bundles;
      this.nota = nota[0];
    });
  }

  void backButtonPressed() {
    Navigator.pop(context);
  }

  void selesaikanPesananPressed() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                'Selesaikan Pesanan',
                style: titlePage,
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Masukkan PIN pengambilan',
                    style: descriptionTextBlack14,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  PinCodeFields(
                    length: 5,
                    controller: pinController,
                  )
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      submitPin();
                    },
                    child: Text(
                      'SUBMIT',
                      style: descriptionTextOrangeMedium12,
                    ))
              ],
            ));
  }

  // Future startTimer() async {
  //   //Start timer untuk rating otomatis setelah 3 jam -> untuk user dan bisnis kuliner
  //   timer = Timer.periodic(Duration(seconds: 1), (_) async {
  //     print('MASUK TIMER');

  //     //Detik masih jalan
  //     if (seconds > 0) {
  //       if (!mounted) return;
  //       setState(() {
  //         this.seconds--;
  //       });
  //     } else {
  //       final newNota = await NotaApi.getNotaByIdNota(this.nota.id);

  //       //Cek apakah user sudah kasih rating
  //       if (newNota[0].ratingBisnis == 0) {
  //         //ADD rating bisnis ke tabel nota
  //         final response = await http.put(
  //             Uri.parse(AppGlobalConfig.getUrlApi() +
  //                 'nota/' +
  //                 this.nota.id.toString()),
  //             body: {
  //               'rating_bisnis': '5',
  //             },
  //             headers: {
  //               'Accept': 'application/json'
  //             });

  //         if (response.statusCode == 200) {
  //           print(response.body);
  //         }

  //         //EDIT rata2 rating di id bisnis kuliner
  //         final bisnis =
  //             await BisnisKulinerApi.getBisnisKulinerById(this.nota.idBisnis);
  //         if (bisnis[0].ratingBisnis == 0) {
  //           final response = await http.put(
  //               Uri.parse(AppGlobalConfig.getUrlApi() +
  //                   'bisniskuliner/' +
  //                   bisnis[0].id.toString()),
  //               body: {
  //                 'rating_bisnis': '5',
  //               },
  //               headers: {
  //                 'Accept': 'application/json'
  //               });

  //           if (response.statusCode == 200) {
  //             print(response.body);
  //           }
  //         } else {
  //           double sumAll = 0;
  //           final listRating = await NotaApi.getRataRataBisnis(bisnis[0].id);
  //           for (int i = 0; i < listRating.length; i++) {
  //             sumAll += listRating[i].ratingBisnis;
  //           }
  //           final ratingMean = sumAll / listRating.length;

  //           final response = await http.put(
  //               Uri.parse(AppGlobalConfig.getUrlApi() +
  //                   'bisniskuliner/' +
  //                   bisnis[0].id.toString()),
  //               body: {
  //                 'rating_bisnis': ratingMean.toString(),
  //               },
  //               headers: {
  //                 'Accept': 'application/json'
  //               });

  //           if (response.statusCode == 200) {
  //             print(response.body);
  //           }
  //         }
  //       } //if user

  //       //Cek apakah bisnis sudah kasih rating
  //       if (newNota[0].ratingUser == 0) {
  //         //ADD rating user ke tabel nota
  //         final response = await http.put(
  //             Uri.parse(AppGlobalConfig.getUrlApi() +
  //                 'nota/' +
  //                 this.nota.id.toString()),
  //             body: {
  //               'rating_user': '5',
  //             },
  //             headers: {
  //               'Accept': 'application/json'
  //             });

  //         if (response.statusCode == 200) {
  //           print(response.body);
  //         }

  //         //EDIT rata2 rating di id user
  //         final user = await UserApi.getUserById(this.nota.idUser);
  //         if (user[0].ratingUser == 0) {
  //           final response = await http.put(
  //               Uri.parse(AppGlobalConfig.getUrlApi() +
  //                   'user/' +
  //                   user[0].id.toString()),
  //               body: {
  //                 'rating_user': '5',
  //               },
  //               headers: {
  //                 'Accept': 'application/json'
  //               });

  //           if (response.statusCode == 200) {
  //             print(response.body);
  //           }
  //         } else {
  //           double sumAll = 0;
  //           final listRating = await NotaApi.getRataRataUser(user[0].id);
  //           for (int i = 0; i < listRating.length; i++) {
  //             sumAll += listRating[i].ratingUser;
  //           }
  //           final ratingMean = sumAll / listRating.length;

  //           final response = await http.put(
  //               Uri.parse(AppGlobalConfig.getUrlApi() +
  //                   'user/' +
  //                   user[0].id.toString()),
  //               body: {
  //                 'rating_user': ratingMean.toString(),
  //               },
  //               headers: {
  //                 'Accept': 'application/json'
  //               });

  //           if (response.statusCode == 200) {
  //             print(response.body);
  //           }
  //         }
  //       }

  //       //Stop timer
  //       timer.cancel();
  //     }
  //     print('DETIK RATING: ' + this.seconds.toString());
  //   });
  // }

  Future submitPin() async {
    //Loading setelah tekan tombol
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.style(message: 'Loading...');
    progressDialog.show();
    if (pinController.text == nota.pinPengambilan.toString()) {
      //start timer untuk ratin

      //Update Status Nota dan tanggal pengambilan
      final response = await http.put(
          Uri.parse(AppGlobalConfig.getUrlApi() +
              'nota/' +
              widget.argumentsPassed.idNota.toString()),
          body: {
            'status_nota': 2.toString(),
            'tanggal_pengambilan': DateTime.now().toString()
          },
          headers: {
            'Accept': 'application/json'
          });

      if (response.statusCode == 200) {
        print(response);
      }

      //Tambahkan makanan diselamatkan ke id user
      final user = await UserApi.getUserById(this.nota.idUser);
      final makananDiselamatkan = user[0].makananDiselamatkan + 1;
      final response2 = await http.put(
          Uri.parse(AppGlobalConfig.getUrlApi() +
              'user/' +
              this.nota.idUser.toString()),
          body: {
            'makanan_diselamatkan': makananDiselamatkan.toString(),
          },
          headers: {
            'Accept': 'application/json'
          });

      if (response2.statusCode == 200) {
        print(response2);
      }

      //Tambahkan transaksi e-wallet
      final response3 = await http
          .post(Uri.parse(AppGlobalConfig.getUrlApi() + 'transaksi'), body: {
        'id_user': this.nota.idUser.toString(),
        'id_bisnis_kuliner': this.nota.idBisnis.toString(),
        'id_nota': this.nota.id.toString(),
        'jumlah_transaksi': this.nota.totalHarga.toString(),
        'tipe_transaksi': 'pembelian',
      }, headers: {
        'Accept': 'application/json'
      });
      if (response3.statusCode == 200) {
        print(response3);
      }

      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text(
                  'Transaksi selesai',
                  style: titlePage,
                  textAlign: TextAlign.center,
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'NOTA (ID: ' +
                          widget.argumentsPassed.idNota.toString() +
                          ')',
                      style: descriptionTextBlack14,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    Text(
                      'Diambil pada:',
                      style: descriptionTextBlack12,
                    ),
                    Text(
                      DateFormat('dd-MM-yyyy').format(DateTime.now()) +
                          ', ' +
                          DateFormat('h:mma').format(DateTime.now()),
                      style: descriptionTextBlack12,
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    Text(
                      'Silakan beri rating user pada tab "pesanan selesai"',
                      style: descriptionTextOrange12,
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        progressDialog.hide();
                        int count = 0;
                        Navigator.of(context).popUntil((_) => count++ >= 2);
                        widget.argumentsPassed.initBisPesananPage();
                        print('Sebelum appGlobalConfig StartTimer');
                        AppGlobalConfig.startTimer(this.nota);
                      },
                      child: Text(
                        'OK',
                        style: descriptionTextOrangeMedium12,
                      ))
                ],
              ));
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text(
                  'Transaksi Gagal',
                  style: titlePage,
                  textAlign: TextAlign.center,
                ),
                content: Text(
                  'PIN yang dimasukkan tidak sesuai, mohon di cek kembali',
                  style: descriptionTextBlack12,
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        progressDialog.hide();
                        int count = 0;
                        Navigator.of(context).popUntil((_) => count++ >= 2);
                      },
                      child: Text(
                        'OK',
                        style: titleCard,
                      )),
                ],
              ));
    }
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
                      'NOTA (ID: ' +
                          widget.argumentsPassed.idNota.toString() +
                          ')',
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
                                              menu.hargaMakanan, 2),
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
                  ButtonTemplate('SELESAIKAN PESANAN', lightOrange,
                      onPressed: selesaikanPesananPressed)
                ],
              )),
        ),
      ),
    );
  }
}
