import 'dart:convert';

import 'package:eatme_mobileapp/api/bisniskuliner_api.dart';
import 'package:eatme_mobileapp/api/detailbundle_api.dart';
import 'package:eatme_mobileapp/api/menu_api.dart';
import 'package:eatme_mobileapp/api/nota_api.dart';
import 'package:eatme_mobileapp/api/order_api.dart';
import 'package:eatme_mobileapp/appGlobalConfig.dart';
import 'package:eatme_mobileapp/cutomer_pages/Beranda/checkout_page.dart';
import 'package:eatme_mobileapp/main.dart';
import 'package:eatme_mobileapp/models/detailbundle.dart';
import 'package:eatme_mobileapp/models/menus.dart';
import 'package:eatme_mobileapp/models/order.dart';
import 'package:eatme_mobileapp/template/Buttons/button_template.dart';
import 'package:eatme_mobileapp/template/Buttons/iconbutton_template.dart';
import 'package:eatme_mobileapp/template/largeTextField_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../theme.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  TextEditingController catatanController = new TextEditingController();

  List<Orders> listOrders = [];
  List<Menus> listMenu = [];
  List<DetailBundle> listBundle = [];
  // List<BisnisKuliner> listBisnisKuliner = [];
  int idUser;
  String namaBisnis;
  int makananCounter;

  @override
  void initState() {
    super.initState();

    init();
  }

  Future init() async {
    print('[INIT] Cart Page');
    //Get User ID
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('idUser');

    final orders = await OrderApi.getOrders(id, 0);
    final menus = await MenusApi.getAllMenus();
    final bundles = await DetailBundleApi.getAllBundle();

    if (orders.length != 0) {
      final idMenu = orders[0].idMenu;
      int idBisnis;
      for (int i = 0; i < menus.length; i++) {
        if (idMenu == menus[i].id) {
          idBisnis = menus[i].idBisnisKuliner;
        }
      }
      final bisnisKuliner =
          await BisnisKulinerApi.getBisnisKulinerById(idBisnis);
      if (!mounted) return;
      setState(() {
        this.namaBisnis = bisnisKuliner[0].namaBisnis;
      });
    }

    if (!mounted) return;

    setState(() {
      this.listOrders = orders;
      this.listMenu = menus;
      this.listBundle = bundles;
      this.idUser = id;
    });
  }

  void backButtonPressed() {
    Navigator.pop(context);
  }

  Future checkoutPressed() async {
    //Loading setelah tekan tombol
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.style(message: 'Loading...');
    progressDialog.show();

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
      var argumentsPassed = new ArgumentsCheckout(this.listOrders, namaBisnis);

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => CheckoutPage(argumentsPassed)));
    }
  }

  Future simpanPressed(int idOrder, int jumlahMakanan) async {
    final response = await http.put(
        Uri.parse(AppGlobalConfig.getUrlApi() + 'order/' + idOrder.toString()),
        body: {
          'jumlah_makanan': jumlahMakanan.toString(),
          'catatan_makanan': catatanController.text,
        },
        headers: {
          'Accept': 'application/json'
        });

    if (response.statusCode == 200) {
      Navigator.pop(context);
    } else {
      Alert(
          style: AlertStyle(
              descStyle: descriptionTextBlack12,
              isCloseButton: false,
              titleStyle: titlePage),
          context: context,
          title: "Ubah Profil Gagal",
          desc: "Terjadi kesalahan",
          type: AlertType.error,
          buttons: [
            DialogButton(
                color: lightOrange,
                child: Text('OK', style: buttonText),
                onPressed: () => Navigator.pushReplacementNamed(
                    context, '/_CustomerBottomNav'))
          ]).show();
    }
  }

  void deletePressed(int idOrder) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                'Hapus Makanan',
                style: titlePage,
                textAlign: TextAlign.center,
              ),
              content: Text(
                'Apakah anda yakin ingin menghapus makanan dari keranjang?',
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
                      //Loading setelah tekan tombol
                      ProgressDialog progressDialog = ProgressDialog(context);
                      progressDialog.style(message: 'Loading...');
                      progressDialog.show();
                      //Delete ID Favorite dari database
                      String urlApiFavorite = AppGlobalConfig.getUrlApi() +
                          'order/' +
                          idOrder.toString();
                      var response =
                          await http.delete(Uri.parse(urlApiFavorite));

                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      final length = prefs.getInt('cartLength');
                      prefs.setInt('cartLength', length - 1);

                      //Delete sharedPreference idBisnis jika cartLength = 0
                      if (prefs.getInt('cartLength') == 0) {
                        prefs.remove('idBisnisCart');
                      }

                      int count = 0;
                      Navigator.of(context).popUntil((_) => count++ >= 2);
                      init();
                      return json.decode(response.body);
                    },
                    child: Text(
                      'YA',
                      style: descriptionTextOrangeMedium12,
                    ))
              ],
            ));
    print('delete cart item');
  }

  void closeBottomSheet() {
    Navigator.pop(context);
  }

  cardPressed(Orders order, String namaMenu, String deskripsiMenu,
      int hargaMenu, int hargaAwal) async {
    if (!mounted) return;
    // Set catatanController
    setState(() {
      catatanController.text = order.catatanMakanan;
    });

    await showModalBottomSheet(
        isDismissible: false,
        isScrollControlled: true,
        context: context,
        builder: (context) {
          makananCounter = order.jumlahMakanan;
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter mystate) {
              return Container(
                color: Color(0xFF737373),
                child: Container(
                  height: 750.h,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r), color: white),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.w, vertical: 30.h),
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
                          AppGlobalConfig.titleCase(namaMenu),
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
                            deskripsiMenu ?? 'Tidak ada deskripsi',
                            textAlign: TextAlign.center,
                            maxLines: 5,
                            style: descriptionTextGrey12,
                          ),
                        ),
                        SizedBox(
                          height: 15.h,
                        ),
                        Text(
                          AppGlobalConfig.convertToIdr(hargaMenu, 2),
                          style: descriptionTextOrange12,
                        ),
                        SizedBox(
                          height: 3.h,
                        ),
                        Text(
                          AppGlobalConfig.convertToIdr(hargaAwal, 2),
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
                            IconButtonTemplate(darkOrange, Icons.remove_circle,
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
                        ButtonTemplate('SIMPAN', lightOrange,
                            onPressed: () =>
                                simpanPressed(order.id, makananCounter)),
                        SizedBox(
                          height: 5.h,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            // child:
          );
        });

    init();
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
                  IconButtonTemplate(black, Icons.arrow_back,
                      onPressed: backButtonPressed),
                  SizedBox(
                    height: 23.h,
                  ),
                  Text(
                    'Keranjang Saya',
                    style: titlePage,
                  ),
                  SizedBox(
                    height: 50.h,
                  ),
                  Text(
                    namaBisnis ?? 'Belum ada pesanan',
                    style: descriptionTextBlack14,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  ListView.builder(
                      itemCount: listOrders.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final order = listOrders[index];
                        String namaMenu;
                        String deskripsiMenu;
                        int hargaMenu;
                        int hargaAwal;

                        for (int i = 0; i < listMenu.length; i++) {
                          if (listMenu[i].id == order.idMenu &&
                              listMenu[i].isBundle == 0) {
                            namaMenu = listMenu[i].namaMakanan;
                            deskripsiMenu = listMenu[i].deskripsiMakanan;
                            hargaMenu = listMenu[i].hargaMakanan;
                            hargaAwal = listMenu[i].hargaSebelumDiskon;
                          } else {
                            //Ambil detail bundle
                            for (int j = 0; j < listBundle.length; j++) {
                              if (listBundle[j].id == order.idDetailBundle) {
                                namaMenu = '[BUNDLE] ' + listBundle[j].isiMenu;
                                deskripsiMenu = listBundle[j].deskripsi;
                                hargaMenu = listMenu[i].hargaMakanan;
                                hargaAwal = listMenu[i].hargaSebelumDiskon;
                              }
                            }
                          }
                        }

                        return GestureDetector(
                          onTap: () => cardPressed(order, namaMenu,
                              deskripsiMenu, hargaMenu, hargaAwal),
                          // onTap: cardPressed,
                          child: Card(
                            child: ListTile(
                              leading: Text(
                                order.jumlahMakanan.toString() + 'x' ??
                                    'jumlahMakananNull',
                                style: titlePage,
                              ),
                              title: Text(
                                AppGlobalConfig.titleCase(namaMenu) ??
                                    'namaMenuNull',
                                style: titleCard,
                              ),
                              subtitle: Text(
                                order.catatanMakanan ?? 'Tidak ada catatan',
                                style: descriptionTextGrey12,
                              ),
                              trailing: TextButton.icon(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: darkOrange,
                                  size: 20,
                                ),
                                label: Text(''),
                                onPressed: () => deletePressed(order.id),
                                style: TextButton.styleFrom(
                                  minimumSize: Size.zero,
                                  padding: EdgeInsets.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                  SizedBox(
                    height: 100,
                  ),
                  listOrders.length == 0
                      ? Text('')
                      : ButtonTemplate("CHECKOUT", lightOrange,
                          onPressed: checkoutPressed),
                ],
              )),
        ),
      ),
    );
  }
}
