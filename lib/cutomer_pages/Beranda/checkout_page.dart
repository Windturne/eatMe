import 'dart:async';
import 'dart:convert';

import 'package:eatme_mobileapp/api/bisniskuliner_api.dart';
import 'package:eatme_mobileapp/api/detailbundle_api.dart';
import 'package:eatme_mobileapp/api/menu_api.dart';
import 'package:eatme_mobileapp/api/nota_api.dart';
import 'package:eatme_mobileapp/api/order_api.dart';
import 'package:eatme_mobileapp/api/pemilikbisniskuliner_api.dart';
import 'package:eatme_mobileapp/api/user_api.dart';
import 'package:eatme_mobileapp/appGlobalConfig.dart';
import 'package:eatme_mobileapp/cutomer_pages/Pesanan/pesananTerkonfirmasi_page.dart';
import 'package:eatme_mobileapp/main.dart';
import 'package:eatme_mobileapp/models/bisniskuliner.dart';
import 'package:eatme_mobileapp/models/detailbundle.dart';
import 'package:eatme_mobileapp/models/menus.dart';
import 'package:eatme_mobileapp/template/Buttons/button_template.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

class CheckoutPage extends StatefulWidget {
  @override
  _CheckoutPageState createState() => _CheckoutPageState();

  final ArgumentsCheckout argumentsPassed;
  const CheckoutPage(this.argumentsPassed);
}

class _CheckoutPageState extends State<CheckoutPage> {
  List<Menus> listMenu = [];
  List<DetailBundle> listBundle = [];
  List<BisnisKuliner> listBisnis = [];
  int total = 0;
  int saldoEwallet = 0;
  Menus menu;
  DetailBundle bundle;
  int idUser = 0;
  int idNota = 0;

  Timer timer;
  int seconds = 0;
  bool isSheetOpen = false;
  Function sheetSetState;

  @override
  void initState() {
    super.initState();

    init();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future init() async {
    print('[INIT] Checkout Page');

    //Get Menus
    final menus = await MenusApi.getAllMenus();

    //Get Detail Bundle
    final bundles = await DetailBundleApi.getAllBundle();

    int totalTmp = 0;

    for (int i = 0; i < widget.argumentsPassed.listOrder.length; i++) {
      for (int j = 0; j < menus.length; j++) {
        if (widget.argumentsPassed.listOrder[i].idMenu == menus[j].id) {
          totalTmp += widget.argumentsPassed.listOrder[i].jumlahMakanan *
              menus[j].hargaMakanan;
        }
      }
    }

    //Get Saldo E-Wallet
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final idUser = prefs.getInt('idUser');
    print('IDUSER:' + idUser.toString());
    final user = await UserApi.getUserById(idUser);
    final saldo = user[0].saldoEwallet;

    //Get Bisnis Kuliner
    final idBisnis = prefs.getInt('idBisnisCart');
    print('ONCART:' + idBisnis.toString());
    final bisniskuliner = await BisnisKulinerApi.getBisnisKulinerById(idBisnis);

    print('list order length: ' +
        widget.argumentsPassed.listOrder.length.toString());

    if (!mounted) return;

    setState(() {
      this.listMenu = menus;
      this.listBundle = bundles;
      this.listBisnis = bisniskuliner;
      this.total = totalTmp;
      this.saldoEwallet = saldo;
      this.idUser = idUser;
    });

    print('List Bisnis: ' + this.listBisnis[0].namaBisnis);
  }

  void backButtonPressed() {
    Navigator.pop(context);
  }

  String formatTime(int seconds) {
    print('Format time seconds: ' + seconds.toString());
    return '${(Duration(seconds: seconds))}'.split('.')[0].padLeft(8, '0');
  }

  startTimer() {
    this.seconds = 180;
    var fiveSeconds = 5;
    timer = Timer.periodic(Duration(seconds: 1), (_) async {
      if (seconds > 0) {
        if (!mounted) return;

        if (isSheetOpen) {
          sheetSetState(() {
            seconds--;
          });
        } else {
          seconds--;
        }

        fiveSeconds -= 1;
      } else {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text(
                    'Pesanan Dibatalkan',
                    style: titlePage,
                    textAlign: TextAlign.center,
                  ),
                  content: Text(
                    'Tidak ada respon dari bisnis kuliner sehingga pesanan dibatalkan otomatis',
                    style: descriptionTextBlack12,
                  ),
                  actions: [
                    TextButton(
                        onPressed: () {
                          int count = 0;
                          Navigator.of(context).popUntil((_) => count++ >= 3);
                          Navigator.pushReplacementNamed(
                              context, '/_CustomerBottomNav');
                        },
                        child: Text(
                          'OK',
                          style: titleCard,
                        )),
                  ],
                ));
        stopTimer(true);
      }

      //Panggil API setiap 5 detik
      if (fiveSeconds == 0) {
        fiveSeconds = 5;
        // Get statusNota
        final nota = await NotaApi.getNotaByIdNota(idNota);
        final statusNota = nota[0].statusNota;
        print('status nota = ' + statusNota.toString());

        if (statusNota == 1) {
          print('statusNota 1');

          //Potong saldo E-Wallet
          final response = await http.put(
              Uri.parse(
                  AppGlobalConfig.getUrlApi() + 'user/' + idUser.toString()),
              body: {
                'saldo_ewallet': (saldoEwallet - total).toString(),
              },
              headers: {
                'Accept': 'application/json'
              });

          if (response.statusCode == 200) {
            print('Potong saldo berhasil');
            print(response.body);
          } else {
            print('potong saldo gagal');
          }

          var argumentsPassed = new ArgumentsPesananTerkonfirmasi(
              widget.argumentsPassed.listOrder,
              this.listBisnis[0],
              this.idNota);
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      PesananTerkonfirmasiPage(argumentsPassed)));
          stopTimer(false);
        } else if (statusNota == -1) {
          print('pesanan ditolak');
          stopTimer(true);
          Alert(
              style: AlertStyle(
                  descStyle: descriptionTextBlack12,
                  isCloseButton: false,
                  titleStyle: titlePage),
              context: context,
              title: "Pesanan Ditolak",
              desc: "Maaf, pesanan anda ditolak oleh pemilik bisnis kuliner",
              type: AlertType.error,
              buttons: [
                DialogButton(
                    color: lightOrange,
                    child: Text('OK', style: buttonText),
                    onPressed: () {
                      int count = 0;
                      Navigator.of(context).popUntil((_) => count++ >= 3);
                      Navigator.pushReplacementNamed(
                          context, '/_CustomerBottomNav');
                    })
              ]).show();
        }
      }
      print('MyGlobalTimer: ' + seconds.toString());
    });
  }

  Future stopTimer(bool delete) async {
    //Cancel timer
    timer.cancel();

    if (delete) {
      //Delete nota
      String urlApiNota =
          AppGlobalConfig.getUrlApi() + 'nota/' + this.idNota.toString();
      var response = await http.delete(Uri.parse(urlApiNota));
      print(response.body);
    }
  }

  Future pesanSekarangPressed() async {
    //Loading setelah tekan tombol
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.style(message: 'Loading...');
    await progressDialog.show();

    if (this.saldoEwallet >= this.total) {
      print('Masuk saldo e-wallet mencukupi');

      //Kirim notifikasi ke bisnis kuliner
      print('listBisnis: ' + this.listBisnis[0]?.idPemilikBisnis?.toString());
      final pemilikBisnis =
          await PemilikBisnisKulinerApi.getPemilikBisnisKulinerById(
              this.listBisnis[0]?.idPemilikBisnis);
      print('pemilikBisnis: ' + pemilikBisnis[0]?.idUser?.toString());
      final user = await UserApi.getUserById(pemilikBisnis[0]?.idUser);
      print('user:' + user[0]?.tokenNotifikasi);
      List<String> tokenIds = [];

      if (user[0]?.tokenNotifikasi != 'null') {
        tokenIds.add(user[0]?.tokenNotifikasi);
        print('tokenNotifikasi: ' + user[0]?.tokenNotifikasi);
      }

      String contents =
          'Segera konfirmasi pesananmu atau pesanan akan dibatalkan otomatis';
      String heading = 'Pesanan baru diterima!';

      await AppGlobalConfig.sendPushNotification(tokenIds, contents, heading);
      print('setelah send notif checkout');

      //Create Nota baru dengan statusNota = 0 (menunggu konfirmasi)
      String urlApiNota = AppGlobalConfig.getUrlApi() + 'nota';
      final response = await http.post(Uri.parse(urlApiNota),
          headers: {
            "Content-Type": "application/json; charset=utf-8",
          },
          body: json.encode({
            'id_user': idUser.toString(),
            'id_bisnis_kuliner':
                widget.argumentsPassed.listOrder[0].idBisnisKuliner.toString(),
            'total_item': widget.argumentsPassed.listOrder.length.toString(),
            'total_harga': this.total.toString(),
          }));

      if (response.statusCode == 200) {
        print(response.body);
        //Add ID nota ke listOrder
        var snapshot = json.decode(response.body);
        int idNotaTemp = snapshot['data']['id'];
        if (!mounted) return;
        setState(() {
          this.idNota = idNotaTemp;
        });
        print('idNotaTemp: ' + idNotaTemp.toString());

        for (int i = 0; i < widget.argumentsPassed.listOrder.length; i++) {
          final response = await http.put(
              Uri.parse(AppGlobalConfig.getUrlApi() +
                  'order/' +
                  widget.argumentsPassed.listOrder[i].id.toString()),
              body: {
                'id_nota': idNotaTemp.toString(),
              },
              headers: {
                'Accept': 'application/json'
              });

          print(response.body);
        }
      }

      isSheetOpen = true;

      //Start timer untuk menunggu konfirmasi bisnis kuliner
      startTimer();
      await showModalBottomSheet(
          enableDrag: false,
          isDismissible: false,
          isScrollControlled: true,
          context: context,
          builder: (context) {
            return new WillPopScope(
              onWillPop: () async => false,
              child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                this.sheetSetState = setState;
                return Container(
                  color: Color(0xFF737373),
                  child: Container(
                    // height: 750.h,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        color: white),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 30.w, vertical: 30.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 40.h,
                            ),
                            Text(
                              'Menunggu Konfirmasi Restoran',
                              style: titlePage,
                            ),
                            SizedBox(
                              height: 3.h,
                            ),
                            Text(
                              'Mohon untuk tidak mentutup aplikasi (maksimal 3 menit atau batal otomatis)',
                              style: descriptionTextBlack14,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: 3.h,
                            ),
                            Text(
                              formatTime(seconds),
                              style: descriptionTextBlack14,
                            ),
                            SizedBox(
                              height: 40.h,
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
                                        itemCount: widget
                                            .argumentsPassed.listOrder.length,
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          print(widget.argumentsPassed.listOrder
                                              .length);
                                          final order = widget
                                              .argumentsPassed.listOrder[index];

                                          if (order.idDetailBundle == null) {
                                            for (int i = 0;
                                                i < listMenu.length;
                                                i++) {
                                              if (order.idMenu ==
                                                  listMenu[i].id) {
                                                this.menu = listMenu[i];
                                              }
                                            }
                                          } else {
                                            //Ambil Menu
                                            for (int i = 0;
                                                i < listMenu.length;
                                                i++) {
                                              if (order.idMenu ==
                                                  listMenu[i].id) {
                                                this.menu = listMenu[i];
                                              }
                                            }

                                            //Ambil bundle
                                            for (int i = 0;
                                                i < listBundle.length;
                                                i++) {
                                              if (order.idDetailBundle ==
                                                  listBundle[i].id) {
                                                this.bundle = listBundle[i];
                                              }
                                            }
                                          }

                                          // print('Nama makanan: ' +
                                          //     this.menu.namaMakanan);

                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    width: 210.w,
                                                    child:
                                                        order.idDetailBundle ==
                                                                null
                                                            ? Text(
                                                                order.jumlahMakanan
                                                                            .toString() +
                                                                        'x ' +
                                                                        menu?.namaMakanan ??
                                                                    'namaMakananNull',
                                                                style:
                                                                    descriptionTextBlack12,
                                                              )
                                                            : Text(
                                                                order.jumlahMakanan
                                                                            .toString() +
                                                                        'x ' +
                                                                        '[BUNDLE] ' +
                                                                        bundle
                                                                            ?.isiMenu ??
                                                                    'namaMakananNull',
                                                                style:
                                                                    descriptionTextBlack12,
                                                              ),
                                                  ),
                                                  Spacer(),
                                                  Text(
                                                    AppGlobalConfig.convertToIdr(
                                                            menu?.hargaMakanan,
                                                            2) ??
                                                        'hargaMakananNull',
                                                    style:
                                                        descriptionTextBlack12,
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
                                              this.total, 2),
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
                            Container(
                              width: double.infinity,
                              child: Text(
                                'Informasi Pengambilan',
                                style: descriptionTextBlack12,
                                textAlign: TextAlign.justify,
                              ),
                            ),
                            SizedBox(
                              height: 12.h,
                            ),
                            Card(
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
                                          this.listBisnis[0].alamatBisnis ??
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
                                          DateFormat('h:mma').format(
                                                  DateTime.parse(this
                                                      .listBisnis[0]
                                                      .jamAmbilAwal)) +
                                              ' - ' +
                                              DateFormat('h:mma').format(
                                                  DateTime.parse(this
                                                      .listBisnis[0]
                                                      .jamAmbilAkhir)),
                                          style: descriptionTextBlack12,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 100.h),

                            ButtonTemplate('BATALKAN PESANAN', darkGrey,
                                onPressed: batalkanPesananTimerPressed)
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          }).then((value) {
        //Sheet closed

        this.isSheetOpen = false;
      });
    } else {
      print('Masuk saldo tidak mencukupi');
      //Hapus order
      //Get ID user
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int idUser = prefs.getInt('idUser');

      //Pilih (status_order = 1)
      int idOrderCheckout;
      for (int i = 0; i < widget.argumentsPassed.listOrder.length; i++) {
        if (widget.argumentsPassed.listOrder[i].statusOrder == 1 &&
            widget.argumentsPassed.listOrder[i].idUser == idUser) {
          idOrderCheckout = widget.argumentsPassed.listOrder[i].id;
        }
      }

      if (idOrderCheckout != null) {
        //Delete from database
        var response = OrderApi.deleteOrders(idOrderCheckout);
        print(response);
      }

      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text(
                  'Saldo Tidak Mencukupi',
                  style: titlePage,
                  textAlign: TextAlign.center,
                ),
                content: Text(
                  'Maaf, saldo anda tidak cukup untuk melakukan transaksi. Silakan melakukan top up E-Wallet pada menu profil',
                  style: descriptionTextBlack12,
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        int count = 0;
                        Navigator.of(context).popUntil((_) => count++ >= 2);
                        Navigator.pushReplacementNamed(
                            context, '/_CustomerBottomNav');
                      },
                      child: Text(
                        'OK',
                        style: titleCard,
                      )),
                ],
              ));
    }
  }

  Future batalkanPesananPressed() async {
    //Loading setelah tekan tombol
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.style(message: 'Loading...');
    progressDialog.show();

    //Get ID user
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int idUser = prefs.getInt('idUser');

    //Pilih (status_order = 1)
    int idOrderCheckout;
    for (int i = 0; i < widget.argumentsPassed.listOrder.length; i++) {
      if (widget.argumentsPassed.listOrder[i].statusOrder == 1 &&
          widget.argumentsPassed.listOrder[i].idUser == idUser) {
        idOrderCheckout = widget.argumentsPassed.listOrder[i].id;
      }
    }

    if (idOrderCheckout != null) {
      print('idOsrderCheckout: ' + idOrderCheckout.toString());
      //Delete from database
      var response = OrderApi.deleteOrders(idOrderCheckout);
      print(response);
    }

    Navigator.pushReplacementNamed(context, '/_CustomerBottomNav');
  }

  Future batalkanPesananTimerPressed() async {
    stopTimer(true);
    // int count = 0;
    // Navigator.of(context).popUntil((_) => count++ >= 3);
    Navigator.pushReplacementNamed(context, '/_CustomerBottomNav');
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
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
                    // IconButtonTemplate(black, Icons.arrow_back_ios_rounded,
                    //     onPressed: backButtonPressed),
                    Container(
                      width: double.infinity,
                      child: Text(
                        widget.argumentsPassed.namaBisnis ?? 'namaBisnisNull',
                        style: titlePage,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: 40.h,
                    ),
                    Divider(),
                    SizedBox(
                      height: 25.h,
                    ),
                    Text(
                      'Ringkasan Pesanan',
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
                          children: [
                            ListView.builder(
                                itemCount:
                                    widget.argumentsPassed?.listOrder?.length,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  // print(widget.argumentsPassed.listOrder.length);
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
                                    for (int i = 0;
                                        i < listBundle.length;
                                        i++) {
                                      if (order.idDetailBundle ==
                                          listBundle[i].id) {
                                        this.bundle = listBundle[i];
                                      }
                                    }
                                  }

                                  // print('Nama makanan: ' + this.menu.namaMakanan);

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                    style:
                                                        descriptionTextBlack12,
                                                  )
                                                : Text(
                                                    order.jumlahMakanan
                                                                .toString() +
                                                            'x ' +
                                                            '[BUNDLE] ' +
                                                            bundle?.isiMenu ??
                                                        'namaMakananNull',
                                                    style:
                                                        descriptionTextBlack12,
                                                  ),
                                          ),
                                          Spacer(),
                                          Text(
                                            AppGlobalConfig.convertToIdr(
                                                    menu?.hargaMakanan, 2) ??
                                                'hargaMakananNull',
                                            style: descriptionTextBlack12,
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 3.h,
                                      ),
                                      Text(
                                        order?.catatanMakanan ??
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
                                  AppGlobalConfig.convertToIdr(this.total, 2),
                                  style: descriptionTextOrangeMedium12,
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 35.h,
                    ),
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r)),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 14.h, horizontal: 14.w),
                        child: Row(
                          children: [
                            Text(
                              'E-Wallet',
                              style: titleCard,
                            ),
                            SizedBox(
                              width: 26.w,
                            ),
                            Text(
                              AppGlobalConfig.convertToIdr(
                                  this.saldoEwallet, 2),
                              style: descriptionTextBlack12,
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 100.h,
                    ),
                    ButtonTemplate('PESAN SEKARANG', lightOrange,
                        onPressed: pesanSekarangPressed),
                    SizedBox(
                      height: 15.h,
                    ),
                    ButtonTemplate('BATALKAN PESANAN', darkGrey,
                        onPressed: batalkanPesananPressed),
                    // Text(seconds.toString()),
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
