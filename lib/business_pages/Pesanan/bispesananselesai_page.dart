import 'package:eatme_mobileapp/api/detailbundle_api.dart';
import 'package:eatme_mobileapp/api/menu_api.dart';
import 'package:eatme_mobileapp/api/nota_api.dart';
import 'package:eatme_mobileapp/api/order_api.dart';
import 'package:eatme_mobileapp/api/user_api.dart';
import 'package:eatme_mobileapp/appGlobalConfig.dart';
import 'package:eatme_mobileapp/cutomer_pages/Pesanan/komplain_page.dart';
import 'package:eatme_mobileapp/models/detailbundle.dart';
import 'package:eatme_mobileapp/models/menus.dart';
import 'package:eatme_mobileapp/models/nota.dart';
import 'package:eatme_mobileapp/models/order.dart';
import 'package:eatme_mobileapp/models/user.dart';
import 'package:eatme_mobileapp/template/Buttons/button_template.dart';
import 'package:eatme_mobileapp/template/Buttons/iconbutton_template.dart';
import 'package:eatme_mobileapp/template/Buttons/textbutton_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';
import '../../main.dart';
import '../../theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

class BisPesananSelesaiPage extends StatefulWidget {
  @override
  _BisPesananSelesaiPageState createState() => _BisPesananSelesaiPageState();

  final ArgumentsBisPesananSelesai argumentsPassed;
  BisPesananSelesaiPage(this.argumentsPassed);
}

class _BisPesananSelesaiPageState extends State<BisPesananSelesaiPage> {
  List<Orders> listOrder = [];
  List<Menus> listMenu = [];
  List<DetailBundle> listBundle = [];
  Menus menu;
  DetailBundle bundle;
  Nota nota;
  double ratingStars = 0;

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

  void konfirmasiPesananPressed() {
    Navigator.pop(context);
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
                'Beri Penilaian Kepada Konsumen',
                style: titlePage,
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.argumentsPassed.namaUser,
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

  Future submitRating() async {
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.style(message: 'Loading...');
    progressDialog.show();
    //ADD rating user ke tabel nota
    final response = await http.put(
        Uri.parse(
            AppGlobalConfig.getUrlApi() + 'nota/' + this.nota.id.toString()),
        body: {
          'rating_user': ratingStars.toString(),
        },
        headers: {
          'Accept': 'application/json'
        });

    if (response.statusCode == 200) {
      print(response.body);
    }

    //EDIT rata2 rating di id user
    final listUser = await UserApi.getUserById(this.nota.idUser);
    User user = listUser[0];

    if (user.ratingUser == 0) {
      final response = await http.put(
          Uri.parse(AppGlobalConfig.getUrlApi() + 'user/' + user.id.toString()),
          body: {
            'rating_user': ratingStars.toString(),
          },
          headers: {
            'Accept': 'application/json'
          });

      if (response.statusCode == 200) {
        print(response.body);
      }
      progressDialog.hide();
    } else {
      double sumAll = 0;
      final listRating = await NotaApi.getRataRataUser(user.id);
      for (int i = 0; i < listRating.length; i++) {
        sumAll += listRating[i].ratingUser;
      }
      final ratingMean = sumAll / listRating.length;

      final response = await http.put(
          Uri.parse(AppGlobalConfig.getUrlApi() + 'user/' + user.id.toString()),
          body: {
            'rating_user': ratingMean.toString(),
          },
          headers: {
            'Accept': 'application/json'
          });

      if (response.statusCode == 200) {
        print(response.body);
      }
    }

    int count = 0;
    Navigator.of(context).popUntil((_) => count++ >= 2);
    progressDialog.hide();
  }

  void ajukanKomplainPressed() {
    var argumentsPassed = new ArgumentsKomplain(this.nota.id, 'bisnis');
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
                    height: 60.h,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      'DIAMBIL PADA',
                      style: descriptionTextBlack14,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      DateFormat('dd-MM-yyyy').format(
                              DateTime.parse(this.nota?.tanggalPengambilan)) +
                          ', ' +
                          DateFormat('h:mma').format(
                              DateTime.parse(this.nota?.tanggalPengambilan)),
                      style: descriptionTextBlack14,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: 60.h,
                  ),
                  //Belum kasih rating & tidak ada komplain
                  if (this.nota.ratingUser == 0 &&
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
                            TextButtonTemplate('Ajukan komplain', darkGrey,
                                onPressed: ajukanKomplainPressed)
                          ],
                        )
                      ],
                    )
                  ]
                  //Belum kasih rating dan komplain masih dalam proses
                  else if (this.nota.ratingUser == 0 &&
                          this.nota.statusKomplain == 1 ||
                      this.nota.statusKomplain == 11) ...[
                    Text(
                      'Terdapat pengajuan komplain. Informasi lebih lanjut akan diberitahukan melalui email yang sudah terdaftar',
                      style: descriptionTextBlack12,
                      textAlign: TextAlign.center,
                    )
                  ]
                  //Belum kasih rating dan komplain sudah selesai
                  else if (this.nota.ratingUser == 0 &&
                      this.nota.statusKomplain == 2) ...[
                    ButtonTemplate('BERI PENILAIAN', lightOrange,
                        onPressed: beriPenilaianPressed),
                  ] else ...[
                    Text('')
                  ],
                ],
              )),
        ),
      ),
    );
  }
}
