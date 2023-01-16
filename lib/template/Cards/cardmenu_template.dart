import 'dart:convert';

import 'package:eatme_mobileapp/api/menu_api.dart';
import 'package:eatme_mobileapp/api/nota_api.dart';
import 'package:eatme_mobileapp/api/order_api.dart';
import 'package:eatme_mobileapp/cutomer_pages/Beranda/cart_page.dart';
import 'package:eatme_mobileapp/cutomer_pages/Beranda/checkout_page.dart';
import 'package:eatme_mobileapp/cutomer_pages/Beranda/detailbundle_page.dart';
import 'package:eatme_mobileapp/main.dart';
import 'package:eatme_mobileapp/models/menus.dart';
import 'package:eatme_mobileapp/models/order.dart';
import 'package:eatme_mobileapp/template/Buttons/button_template.dart';
import 'package:eatme_mobileapp/template/Buttons/iconbutton_template.dart';
import 'package:eatme_mobileapp/template/largeTextField_template.dart';
import 'package:eatme_mobileapp/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../appGlobalConfig.dart';

// ignore: must_be_immutable
class CardMenuTemplate extends StatefulWidget {
  Menus menu;
  String namaBisnis;
  final VoidCallback initExploreDetail;

  @override
  _CardMenuTemplateState createState() =>
      _CardMenuTemplateState(this.menu, this.namaBisnis);

  CardMenuTemplate(this.menu, this.namaBisnis, this.initExploreDetail);
}

class _CardMenuTemplateState extends State<CardMenuTemplate> {
  Menus menu;
  int makananCounter = 1;
  String namaBisnis;

  List<Orders> listOrder = [];
  TextEditingController catatanController = new TextEditingController();

  _CardMenuTemplateState(this.menu, this.namaBisnis);

  void closeBottomSheet() {
    if (!mounted) return;
    setState(() {
      makananCounter = 1;
      catatanController.text = '';
    });
    Navigator.pop(context);
  }

  Future checkoutPressed(int idMenu, int jumlahMakanan) async {
    //Loading setelah tekan tombol
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.style(message: 'Loading...');
    progressDialog.show();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final idUser = prefs.getInt('idUser');

    //Cek apakah menu tersedia
    final menu = await MenusApi.getMenusByIdMenu(widget.menu.id);
    if (menu[0]?.makananTersedia == 0) {
      print('Menu Tidak Tersedia');
      Alert(
          style: AlertStyle(
              descStyle: descriptionTextBlack12,
              isCloseButton: false,
              titleStyle: titlePage),
          context: context,
          title: "Checkout Gagal",
          desc: "Menu " + widget.menu.namaMakanan + " sedang tidak tersedia",
          type: AlertType.error,
          buttons: [
            DialogButton(
                color: lightOrange,
                child: Text('OK', style: buttonText),
                onPressed: () {
                  progressDialog.hide();
                  int count = 0;
                  Navigator.of(context).popUntil((_) => count++ >= 3);
                })
          ]).show();
    } else {
      print('Menu Tersedia');
      //Cek apakah user masih ada transaksi berjalan
      final listNotaUser = await NotaApi.getNotaByIdUser(idUser, 1);
      if (listNotaUser.length > 0) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text(
                    'Checkout Gagal',
                    style: titlePage,
                    textAlign: TextAlign.center,
                  ),
                  content: Text(
                    'Anda memiliki transaksi yang sedang berlangsung, mohon selesaikan terlebih dahulu',
                    style: descriptionTextBlack12,
                  ),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'OK',
                          style: titleCard,
                        )),
                  ],
                ));
      } else {
        //Set ID bisnis Cart
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt('idBisnisCart', this.menu.idBisnisKuliner);

        //Panggil API
        final response =
            await http.post(Uri.parse(AppGlobalConfig.getUrlApi() + 'order'),
                headers: {
                  "Content-Type": "application/json; charset=utf-8",
                },
                body: json.encode({
                  'id_user': idUser.toString(),
                  'id_bisnis_kuliner': this.menu.idBisnisKuliner.toString(),
                  'id_menu': idMenu.toString(),
                  'jumlah_makanan': jumlahMakanan.toString(),
                  'catatan_makanan': catatanController.text.toString(),
                  'status_order': 1
                }));
        print(response.body);

        if (response.statusCode == 200) {
          final listOrderArgs = await OrderApi.getOrders(idUser, 1);
          print('listOrderArgs Length: ' + listOrderArgs.length.toString());

          var argumentsPassed =
              new ArgumentsCheckout(listOrderArgs, namaBisnis);

          Navigator.pop(context);
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) => CheckoutPage(argumentsPassed)));
          // Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => CheckoutPage(argumentsPassed)));
        } else {
          print('something went wrong');
        }
      }
    }
  }

  Future tambahKeranjangPressed(int idMenu, int jumlahMakanan) async {
    print('Masuk tambahKeranjangPressed');

    //Loading setelah tekan tombol
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.style(message: 'Loading...');
    progressDialog.show();

    //Cek apakah menu tersedia
    final menu = await MenusApi.getMenusByIdMenu(widget.menu.id);

    if (menu[0]?.makananTersedia == 0) {
      Alert(
          style: AlertStyle(
              descStyle: descriptionTextBlack12,
              isCloseButton: false,
              titleStyle: titlePage),
          context: context,
          title: "Checkout Gagal",
          desc: "Menu " + widget.menu.namaMakanan + " sedang tidak tersedia",
          type: AlertType.error,
          buttons: [
            DialogButton(
                color: lightOrange,
                child: Text('OK', style: buttonText),
                onPressed: () {
                  progressDialog.hide();
                  int count = 0;
                  Navigator.of(context).popUntil((_) => count++ >= 3);
                })
          ]).show();
    } else {
      //Get id user
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int idUser = prefs.getInt('idUser');

      //Get list order
      listOrder = await OrderApi.getOrders(idUser, 0);

      //Cek apakah di cart ada menu dari bisnis lain
      int idBisnisCart = prefs.getInt('idBisnisCart');

      if (idBisnisCart == null) {
        print('Masuk if 1');
        print('Masuk else (call api)');
        //Panggil API
        final response =
            await http.post(Uri.parse(AppGlobalConfig.getUrlApi() + 'order'),
                headers: {
                  "Content-Type": "application/json; charset=utf-8",
                },
                body: json.encode({
                  'id_user': idUser.toString(),
                  'id_bisnis_kuliner': this.menu.idBisnisKuliner.toString(),
                  'id_menu': idMenu.toString(),
                  'jumlah_makanan': jumlahMakanan.toString(),
                  'catatan_makanan': catatanController.text.toString()
                }));
        print(response.body);

        if (response.statusCode == 200) {
          final length = prefs.getInt('cartLength');
          prefs.setInt('cartLength', length + 1);
          prefs.setInt('idBisnisCart', this.menu.idBisnisKuliner);

          widget.initExploreDetail();
          Navigator.pop(context);
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => CartPage()));
        } else {
          print('something went wrong');
        }
      } else if (idBisnisCart == this.menu.idBisnisKuliner) {
        print('idBisnisCart Sesuai');

        //Cek apakah menu sudah ada didalam cart (bukan item bundle)
        bool alreadyInCart = false;
        for (int i = 0; i < listOrder.length; i++) {
          if (listOrder[i].idMenu == this.menu.id) {
            print('Menu already in cart');
            alreadyInCart = true;
          }
        } //for

        if (alreadyInCart == true) {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: Text(
                      'Menu Sudah Ada di Keranjang',
                      style: titlePage,
                      textAlign: TextAlign.center,
                    ),
                    content: Text(
                      'Lihat keranjang?',
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
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CartPage()));
                          },
                          child: Text(
                            'YA',
                            style: descriptionTextOrangeMedium12,
                          ))
                    ],
                  ));
        } else {
          print('Masuk else (call api)');
          //Panggil API
          final response =
              await http.post(Uri.parse(AppGlobalConfig.getUrlApi() + 'order'),
                  headers: {
                    "Content-Type": "application/json; charset=utf-8",
                  },
                  body: json.encode({
                    'id_user': idUser.toString(),
                    'id_bisnis_kuliner': this.menu.idBisnisKuliner.toString(),
                    'id_menu': idMenu.toString(),
                    'jumlah_makanan': jumlahMakanan.toString(),
                    'catatan_makanan': catatanController.text.toString()
                  }));
          print(response.body);

          if (response.statusCode == 200) {
            final length = prefs.getInt('cartLength');
            prefs.setInt('cartLength', length + 1);
            prefs.setInt('idBisnisCart', this.menu.idBisnisKuliner);

            Navigator.pop(context);
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => CartPage()));
          } else {
            print('something went wrong');
          }
        }
      } else {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text(
                    'Tambah Keranjang Gagal',
                    style: titlePage,
                    textAlign: TextAlign.center,
                  ),
                  content: Text(
                    'Kamu memiliki pesanan dari bisnis kuliner lain. Hapus keranjang terlebih dahulu',
                    style: descriptionTextBlack12,
                  ),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'BATALKAN',
                          style: titleCard,
                        )),
                    TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CartPage()));
                        },
                        child: Text(
                          'LIHAT KERANJANG',
                          style: descriptionTextOrangeMedium12,
                        ))
                  ],
                ));
      }

      if (!mounted) return;

      setState(() {
        makananCounter = 1;
        catatanController.text = '';
      });
    }
  }

  void cardPressed() {
    // Navigator.push(
    //     context, MaterialPageRoute(builder: (context) => ExploreDetailPage()));

    //Check apakah menu bundle atau tidak
    if (this.menu.isBundle == 0) {
      showModalBottomSheet(
          isDismissible: false,
          isScrollControlled: true,
          context: context,
          builder: (context) {
            // makananCounter = 1;
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter mystate) {
                return SingleChildScrollView(
                  child: Container(
                    color: Color(0xFF737373),
                    child: Container(
                      height: 750.h,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          color: white),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 30.w, vertical: 30.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: double.infinity,
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: IconButtonTemplate(
                                    black, Icons.cancel_outlined,
                                    onPressed: closeBottomSheet),
                              ),
                            ),
                            SizedBox(
                              height: 13.h,
                            ),
                            Text(
                              AppGlobalConfig.titleCase(this.menu.namaMakanan),
                              style: titlePage,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: 3.h,
                            ),
                            Container(
                              width: 300.w,
                              height: 42.h,
                              child: Text(
                                this.menu.deskripsiMakanan ??
                                    'Tidak ada deskripsi',
                                textAlign: TextAlign.center,
                                maxLines: 5,
                                style: descriptionTextGrey12,
                              ),
                            ),
                            SizedBox(
                              height: 15.h,
                            ),
                            Text(
                              AppGlobalConfig.convertToIdr(
                                  this.menu.hargaMakanan, 2),
                              style: descriptionTextOrange12,
                            ),
                            SizedBox(
                              height: 3.h,
                            ),
                            Text(
                              AppGlobalConfig.convertToIdr(
                                  this.menu.hargaSebelumDiskon, 2),
                              style: strikeTroughText,
                            ),
                            SizedBox(
                              height: 25.h,
                            ),
                            Divider(),
                            SizedBox(
                              height: 25.h,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButtonTemplate(
                                    darkOrange, Icons.remove_circle,
                                    onPressed: () => {
                                          if (this.makananCounter > 1)
                                            {
                                              mystate(() {
                                                this.makananCounter -= 1;
                                                print(makananCounter);
                                              })
                                            }
                                        }),
                                SizedBox(
                                  width: 50.w,
                                ),
                                Text(
                                  makananCounter.toString(),
                                  style: titlePage,
                                ),
                                SizedBox(
                                  width: 50.w,
                                ),
                                IconButtonTemplate(darkOrange, Icons.add_circle,
                                    onPressed: () => {
                                          mystate(() {
                                            this.makananCounter += 1;
                                            print(makananCounter);
                                          })
                                        })
                              ],
                            ),
                            SizedBox(
                              height: 30.h,
                            ),
                            LargeTextFieldTemplate(
                                'catatan...', false, catatanController),
                            SizedBox(
                              height: 40.h,
                            ),
                            ButtonTemplate('CHECKOUT', lightOrange,
                                onPressed: () => checkoutPressed(
                                    this.menu.id, makananCounter)),
                            SizedBox(
                              height: 5.h,
                            ),
                            ButtonTemplate('TAMBAH KE KERANJANG', darkGrey,
                                onPressed: () => tambahKeranjangPressed(
                                    this.menu.id, makananCounter)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              // child:
            );
          });
    } else {
      var argumentsPassed =
          new ArgumentsDetailBundle(this.menu, this.widget.initExploreDetail);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DetailBundlePage(argumentsPassed)));
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
          padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
          child: Row(
            children: [
              this.menu.fotoMenu == null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(5.r),
                      child: Image.asset(
                        'assets/images/food_placeholder2.png',
                        height: 91.h,
                        width: 91.w,
                        fit: BoxFit.cover,
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(5.r),
                      child: Image.network(
                        AppGlobalConfig.getUrlStorage() + this.menu.fotoMenu,
                        height: 91.h,
                        width: 91.w,
                        fit: BoxFit.cover,
                      ),
                    ),
              SizedBox(
                width: 15.w,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppGlobalConfig.titleCase(this.menu.namaMakanan),
                      style: titleCard,
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    Row(
                      children: [
                        Text(
                          AppGlobalConfig.convertToIdr(
                              this.menu.hargaMakanan, 2),
                          style: descriptionTextOrange12,
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        Text(
                          AppGlobalConfig.convertToIdr(
                              this.menu.hargaSebelumDiskon, 2),
                          style: strikeTroughText,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    Text(
                      this.menu.deskripsiMakanan ?? 'Tidak ada deskripsi',
                      style: descriptionTextGrey12,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
