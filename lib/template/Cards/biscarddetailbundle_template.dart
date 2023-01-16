import 'dart:io';

import 'package:eatme_mobileapp/api/bisniskuliner_api.dart';
import 'package:eatme_mobileapp/api/favorite_api.dart';
import 'package:eatme_mobileapp/api/menu_api.dart';
import 'package:eatme_mobileapp/api/user_api.dart';
import 'package:eatme_mobileapp/business_pages/Beranda/bisberanda_page.dart';
import 'package:eatme_mobileapp/business_pages/Beranda/bisdetailbundle_page.dart';
import 'package:eatme_mobileapp/main.dart';
import 'package:eatme_mobileapp/models/detailbundle.dart';
import 'package:eatme_mobileapp/models/menus.dart';
import 'package:eatme_mobileapp/template/Buttons/button_template.dart';
import 'package:eatme_mobileapp/template/Buttons/iconbutton_template.dart';
import 'package:eatme_mobileapp/template/Buttons/textbutton_template.dart';
import 'package:eatme_mobileapp/template/largeTextField_template.dart';
import 'package:eatme_mobileapp/template/textField_template.dart';
import 'package:eatme_mobileapp/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:http/http.dart' as http;

import '../../appGlobalConfig.dart';

// ignore: must_be_immutable
class BisCardDetailBundleTemplate extends StatefulWidget {
  DetailBundle bundle;
  final VoidCallback initDetailBundlePage;

  @override
  _BisCardDetailBundleTemplateState createState() =>
      _BisCardDetailBundleTemplateState(this.bundle);

  BisCardDetailBundleTemplate(this.bundle, this.initDetailBundlePage);
}

class _BisCardDetailBundleTemplateState
    extends State<BisCardDetailBundleTemplate> {
  DetailBundle bundle;
  TextEditingController isiBundleController = new TextEditingController();
  TextEditingController deskripsiBundleController = new TextEditingController();

  _BisCardDetailBundleTemplateState(this.bundle);

  final BisBerandaPage bisBeranda = new BisBerandaPage();

  @override
  void initState() {
    super.initState();

    init();
  }

  void init() {
    print('INIT BISCARD DETAIL BUNDLE');
    print('cardTemplate id: ${this.bundle.id}');
    print('cardTemplate idMenu: ${this.bundle.idMenu}');
    print('cardTemplate isiMenu: ${this.bundle.isiMenu}');
    print('cardTemplate deskripsi: ${this.bundle.deskripsi}');
  }

  // Future init() async {
  //   print('[INIT] Bisnis Card Menu Template');

  //   final bisnis =
  //       await BisnisKulinerApi.getBisnisKulinerById(this.menu.idBisnisKuliner);

  //   if (!mounted) return;

  //   setState(() {
  //     this.namaBisnis = bisnis[0].namaBisnis;
  //   });

  //   if (this.menu.fotoMenu != null) {
  //     if (!mounted) return;
  //     setState(() {
  //       this.imageFromDatabase =
  //           AppGlobalConfig.getUrlStorage() + this.menu.fotoMenu;
  //     });
  //   }

  //   // print('ImageFromDatabase: ' + this.imageFromDatabase);
  //   // print('Image: ' + this.image.path);
  // }

  void closeBottomSheet() {
    Navigator.pop(context);
  }

  void hapusItemPressed() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                'Hapus Menu',
                style: titlePage,
                textAlign: TextAlign.center,
              ),
              content: Text(
                'Apakah anda yakin ingin menghapus menu ini?',
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
                      final urlMenu = AppGlobalConfig.getUrlApi() +
                          'bundle/' +
                          this.bundle.id.toString();
                      final response = await http.delete(Uri.parse(urlMenu));

                      print(response.body);

                      progressDialog.hide();
                      Navigator.pop(context);
                      this.widget.initDetailBundlePage();
                    },
                    child: Text(
                      'YA',
                      style: descriptionTextOrangeMedium12,
                    ))
              ],
            ));
  }

  Future simpanPressed() async {
    //Loading setelah tekan tombol
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.style(message: 'Loading...');
    progressDialog.show();

    if (isiBundleController.text.isEmpty) {
      Alert(
          style: AlertStyle(
              descStyle: descriptionTextBlack12,
              isCloseButton: false,
              titleStyle: titlePage),
          context: context,
          title: "Ubah Item Bundle Gagal",
          desc: "Data tidak lengkap",
          type: AlertType.error,
          buttons: [
            DialogButton(
                color: lightOrange,
                child: Text('OK', style: buttonText),
                onPressed: () {
                  progressDialog.hide();
                  Navigator.pop(context);
                })
          ]).show();
    } else {
      print("Edit Item Bundle");
      final response = await http.put(
          Uri.parse(AppGlobalConfig.getUrlApi() +
              'bundle/' +
              this.bundle.id.toString()),
          body: {
            'id_menu': this.bundle.idMenu.toString(),
            'isi_bundle': isiBundleController.text.toString(),
            'deskripsi': deskripsiBundleController.text.toString(),
          },
          headers: {
            'Accept': 'application/json'
          });

      if (response.statusCode == 200) {
        print(response.body);
        Alert(
            style: AlertStyle(
                descStyle: descriptionTextBlack12,
                isCloseButton: false,
                titleStyle: titlePage),
            context: context,
            title: "Ubah Item Bundle Berhasil",
            desc: "Item berhasil diubah",
            type: AlertType.success,
            buttons: [
              DialogButton(
                  color: lightOrange,
                  child: Text('OK', style: buttonText),
                  onPressed: () async {
                    progressDialog.hide();
                    int count = 0;
                    Navigator.of(context).popUntil((_) => count++ >= 2);
                    widget.initDetailBundlePage();
                  })
            ]).show();
      } else {
        Alert(
            style: AlertStyle(
                descStyle: descriptionTextBlack12,
                isCloseButton: false,
                titleStyle: titlePage),
            context: context,
            title: "Ubah Menu Gagal",
            desc: "Terjadi kesalahan",
            type: AlertType.error,
            buttons: [
              DialogButton(
                  color: lightOrange,
                  child: Text('OK', style: buttonText),
                  onPressed: () {
                    progressDialog.hide();
                    Navigator.pop(context);
                  })
            ]).show();
      }
    }
    widget.initDetailBundlePage();
  }

  void editItemPressed() {
    isiBundleController.text = this.bundle.isiMenu;
    deskripsiBundleController.text = this.bundle.deskripsi;

    showModalBottomSheet(
        isDismissible: false,
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter mystate) {
            return SingleChildScrollView(
              child: Container(
                color: Color(0xFF737373),
                child: Container(
                  // height: 800.h,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r), color: white),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.w, vertical: 30.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                          'Edit Item Bundle',
                          style: titlePage,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 45.h,
                        ),
                        TextFieldTemplate(
                            'Isi bundle (ex: 1x roti sisir, 2x roti coklat)',
                            false,
                            false,
                            isiBundleController),
                        SizedBox(
                          height: 20.h,
                        ),
                        LargeTextFieldTemplate(
                            'deskripsi', false, deskripsiBundleController),
                        SizedBox(
                          height: 80.h,
                        ),
                        ButtonTemplate('SIMPAN', lightOrange,
                            onPressed: simpanPressed)
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Card(
        elevation: 5,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                // width: 120.w,
                child: Text(
                  this.bundle.isiMenu ?? 'isiMenuNull',
                  maxLines: 2,
                  style: titleCard,
                ),
              ),
              SizedBox(
                height: 5.h,
              ),
              Text(
                this.bundle.deskripsi ?? 'Tidak ada deskripsi',
                style: descriptionTextGrey12,
                maxLines: 2,
              ),
              SizedBox(
                height: 10.h,
              ),
              Row(
                children: [
                  TextButtonTemplate('Edit Item', lightOrange,
                      onPressed: editItemPressed),
                  SizedBox(
                    width: 10.w,
                  ),
                  TextButtonTemplate('Hapus Item', red,
                      onPressed: hapusItemPressed),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
