import 'package:eatme_mobileapp/api/detailbundle_api.dart';
import 'package:eatme_mobileapp/api/menu_api.dart';
import 'package:eatme_mobileapp/api/nota_api.dart';
import 'package:eatme_mobileapp/models/detailbundle.dart';
import 'package:eatme_mobileapp/models/menus.dart';
import 'package:eatme_mobileapp/models/nota.dart';
import 'package:eatme_mobileapp/template/Buttons/iconbutton_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../appGlobalConfig.dart';
import '../../main.dart';
import '../../theme.dart';

class PesananTerkonfirmasiPage extends StatefulWidget {
  @override
  _PesananTerkonfirmasiPageState createState() =>
      _PesananTerkonfirmasiPageState();

  final ArgumentsPesananTerkonfirmasi argumentsPassed;
  PesananTerkonfirmasiPage(this.argumentsPassed);
}

class _PesananTerkonfirmasiPageState extends State<PesananTerkonfirmasiPage> {
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

    //Get Detail Bundle
    final bundles = await DetailBundleApi.getAllBundle();

    //Get Nota
    final nota =
        await NotaApi.getNotaByIdNota(this.widget.argumentsPassed.idNota);

    if (!mounted) return;

    setState(() {
      this.listMenu = menus;
      this.listBundle = bundles;
      this.nota = nota[0];
    });
  }

  void closePagePressed() {
    Navigator.pushReplacementNamed(context, '/_CustomerBottomNav');
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
                            ')' ??
                        'idNotaNull' + ')',
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
                                print(widget.argumentsPassed.listOrder.length);
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
                                AppGlobalConfig.convertToIdr(
                                        this.nota?.totalHarga ?? 0, 2) ??
                                    'totalHargaNull',
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
                                widget.argumentsPassed?.bisnis?.alamatBisnis ??
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
                  SizedBox(
                    height: 60.h,
                  ),
                  Container(
                    width: double.infinity,
                    child: Column(
                      children: [
                        Text(
                          'PIN PENGAMBILAN',
                          style: descriptionTextBlack14,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 5.h,
                        ),
                        Text(
                          this.nota?.pinPengambilan.toString() ?? 'pinNull',
                          style: textPIN,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Text(
                          '*Tunjukkan nota dan berikan PIN pada saat pengambilan pesanan*',
                          style: descriptionTextBlack12,
                          textAlign: TextAlign.center,
                        ),
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
