import 'dart:convert';
import 'dart:io';

import 'package:eatme_mobileapp/api/bisniskuliner_api.dart';
import 'package:eatme_mobileapp/api/detailbundle_api.dart';
import 'package:eatme_mobileapp/api/favorite_api.dart';
import 'package:eatme_mobileapp/api/menu_api.dart';
import 'package:eatme_mobileapp/api/pemilikbisniskuliner_api.dart';
import 'package:eatme_mobileapp/api/user_api.dart';
import 'package:eatme_mobileapp/appGlobalConfig.dart';
import 'package:eatme_mobileapp/main.dart';
import 'package:eatme_mobileapp/models/bisniskuliner.dart';
import 'package:eatme_mobileapp/models/detailbundle.dart';
import 'package:eatme_mobileapp/models/menus.dart';
import 'package:eatme_mobileapp/template/Buttons/button_template.dart';
import 'package:eatme_mobileapp/template/Buttons/iconbutton_template.dart';
import 'package:eatme_mobileapp/template/Buttons/textbutton_template.dart';
import 'package:eatme_mobileapp/template/Cards/biscarddetailbundle_template.dart';
import 'package:eatme_mobileapp/template/Cards/biscardmenu_template.dart';
import 'package:eatme_mobileapp/template/largeTextField_template.dart';
import 'package:eatme_mobileapp/template/textField_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../theme.dart';

class BisDetailBundlePage extends StatefulWidget {
  @override
  State<BisDetailBundlePage> createState() => _BisDetailBundlePageState();

  final ArgumentsDetailBundle argumentsPassed;
  const BisDetailBundlePage(this.argumentsPassed);
}

class _BisDetailBundlePageState extends State<BisDetailBundlePage> {
  List<DetailBundle> listDetailBundle = [];

  Menus menu;
  TextEditingController namaMenuController = new TextEditingController();
  TextEditingController hargaDiskonController = new TextEditingController();
  TextEditingController hargaAsliController = new TextEditingController();
  TextEditingController deskripsiController = new TextEditingController();

  TextEditingController isiBundleController = new TextEditingController();
  TextEditingController deskripsiBundleController = new TextEditingController();
  String namaBisnis;

  File image;
  String imageFromDatabase;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    init();
  }

  Future init() async {
    //Ambil detail bundle berdasarkan id menu
    final bundleMenus =
        await DetailBundleApi.getBundleByIdMenu(widget.argumentsPassed.menu.id);

    for (int i = 0; i < bundleMenus.length; i++) {
      print(bundleMenus[i].isiMenu);
    }

    if (!mounted) return;

    setState(() {
      this.listDetailBundle = bundleMenus;
      this.menu = this.widget.argumentsPassed.menu;
    });
  }

  void backButtonPressed() {
    Navigator.pop(context);
  }

  void addIsiBundlePressed() {
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
                        borderRadius: BorderRadius.circular(10.r),
                        color: white),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 30.w, vertical: 30.h),
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
                          Container(
                            width: double.infinity,
                            child: Text(
                              'Tambah Item',
                              style: titlePage,
                              textAlign: TextAlign.center,
                            ),
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
                          ButtonTemplate('TAMBAH ITEM', lightOrange,
                              onPressed: tambahItemBundlePressed)
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        });
  }

  Future tambahItemBundlePressed() async {
    //Loading setelah tekan tombol
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.style(message: 'Loading...');
    progressDialog.show();

    String urlApiMenu = AppGlobalConfig.getUrlApi() + 'bundle';

    final response = await http.post(Uri.parse(urlApiMenu),
        headers: {
          "Content-Type": "application/json; charset=utf-8",
        },
        body: json.encode({
          'id_menu': this.widget.argumentsPassed.menu.id.toString(),
          'isi_bundle': isiBundleController.text,
          'deskripsi': deskripsiController.text,
        }));

    if (response.statusCode == 200) {
      print(response.body);

      isiBundleController.text = '';
      deskripsiBundleController.text = '';

      progressDialog.hide();
      Navigator.pop(context);
      init();
    } else {
      print('Tambah Menu Gagal');
      Alert(
          style: AlertStyle(
              descStyle: descriptionTextBlack12,
              isCloseButton: false,
              titleStyle: titlePage),
          context: context,
          title: "Tambah Menu Gagal",
          desc: "Terjadi kendala",
          type: AlertType.error,
          buttons: [
            DialogButton(
                color: lightOrange,
                child: Text('OK', style: buttonText),
                onPressed: () {
                  int count = 0;
                  Navigator.of(context).popUntil((_) => count++ >= 2);
                })
          ]).show();
    }
  }

  void closeBottomSheet() {
    Navigator.pop(context);
  }

  void editBundlePressed() {
    namaMenuController.text = this.menu.namaMakanan;
    hargaDiskonController.text = this.menu.hargaMakanan.toString();
    hargaAsliController.text = this.menu.hargaSebelumDiskon.toString();
    deskripsiController.text = this.menu.deskripsiMakanan;

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
                          'Edit Menu',
                          style: titlePage,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 45.h,
                        ),
                        TextFieldTemplate(
                            'nama menu', false, false, namaMenuController),
                        SizedBox(
                          height: 20.h,
                        ),
                        TextFieldTemplate('harga setelah diskon', false, true,
                            hargaDiskonController),
                        SizedBox(
                          height: 20.h,
                        ),
                        TextFieldTemplate('harga sebelum diskon', false, true,
                            hargaAsliController),
                        SizedBox(
                          height: 20.h,
                        ),
                        LargeTextFieldTemplate(
                            'deskripsi', false, deskripsiController),
                        SizedBox(
                          height: 20.h,
                        ),
                        Row(
                          children: [
                            Text(
                              'Foto menu: ',
                              style: descriptionTextGrey12,
                            ),
                            TextButtonTemplate('ubah gambar', lightOrange,
                                onPressed: () => ubahGambarPressed(mystate))
                          ],
                        ),
                        SizedBox(
                          height: 5.h,
                        ),

                        if (this.imageFromDatabase == null &&
                            this.image == null) ...[
                          Text(
                            'Tidak ada gambar yang dipilih',
                            style: descriptionTextGrey12,
                          )
                        ] else if (this.imageFromDatabase == null &&
                            this.image.path != null) ...[
                          Image.file(
                            File(this.image.path),
                            height: 80,
                            width: 80,
                          ),
                        ] else ...[
                          Image.network(
                            this.imageFromDatabase,
                            height: 80,
                            width: 80,
                          ),
                        ],

                        // Container(
                        //   child:
                        //   this.imageFromDatabase == null && this.image == null
                        //       ? Text(
                        //           'Tidak ada gambar yang dipilih',
                        //           style: descriptionTextGrey12,
                        //         )
                        //       : Image.network(
                        //           'http://10.0.2.2:8000/storage/' +
                        //               this.menu.fotoMenu,
                        //           height: 80,
                        //           width: 80,
                        //         ),
                        // ),
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

  Future ubahGambarPressed(StateSetter mystate) async {
    mystate(() {
      this.imageFromDatabase = null;
    });
    var pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      mystate(() {
        this.image = File(pickedImage.path);
        print('imagePath: ' + image.toString());
      });
    }
  }

  Future simpanPressed() async {
    //Loading setelah tekan tombol
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.style(message: 'Loading...');
    progressDialog.show();

    if (namaMenuController.text.isEmpty ||
        hargaDiskonController.text.isEmpty ||
        hargaAsliController.text.isEmpty) {
      Alert(
          style: AlertStyle(
              descStyle: descriptionTextBlack12,
              isCloseButton: false,
              titleStyle: titlePage),
          context: context,
          title: "Ubah Profil Gagal",
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
    } else if (this.image == null) {
      print("Image null -> not edited");
      final response = await http.put(
          Uri.parse(
              AppGlobalConfig.getUrlApi() + 'menus/' + this.menu.id.toString()),
          body: {
            'id_bisnis_kuliner': this.menu.idBisnisKuliner.toString(),
            'nama_makanan': namaMenuController.text.toString(),
            'harga_makanan': hargaDiskonController.text.toString(),
            'harga_sebelum_diskon': hargaAsliController.text.toString(),
            'deskripsi_makanan': deskripsiController.text.toString(),
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
            title: "Ubah Menu Berhasil",
            desc: "Menu berhasil diubah",
            type: AlertType.success,
            buttons: [
              DialogButton(
                  color: lightOrange,
                  child: Text('OK', style: buttonText),
                  onPressed: () async {
                    progressDialog.hide();
                    int count = 0;
                    Navigator.of(context).popUntil((_) => count++ >= 3);
                    this.widget.argumentsPassed.init();
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
    } else {
      print("Image not null -> edited");
      Map<String, String> body = {
        'id_bisnis_kuliner': this.menu.idBisnisKuliner.toString(),
        'nama_makanan': namaMenuController.text,
        'harga_makanan': hargaDiskonController.text,
        'harga_sebelum_diskon': hargaAsliController.text,
        'deskripsi_makanan': deskripsiController.text,
      };
      var response =
          await MenusApi.editMenu(this.menu.id, body, this.image.path);

      if (response) {
        Alert(
            style: AlertStyle(
                descStyle: descriptionTextBlack12,
                isCloseButton: false,
                titleStyle: titlePage),
            context: context,
            title: "Ubah Menu Berhasil",
            desc: "Menu berhasil diubah",
            type: AlertType.success,
            buttons: [
              DialogButton(
                  color: lightOrange,
                  child: Text('OK', style: buttonText),
                  onPressed: () async {
                    progressDialog.hide();
                    int count = 0;
                    Navigator.of(context).popUntil((_) => count++ >= 3);
                    this.widget.argumentsPassed.init();
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
    this.widget.argumentsPassed.init();
  }

  void hapusBundlePressed() {
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
                          'menus/' +
                          this.menu.id.toString();
                      final response = await http.delete(Uri.parse(urlMenu));

                      print(response.body);

                      progressDialog.hide();
                      int count = 0;
                      Navigator.of(context).popUntil((_) => count++ >= 2);
                      // Navigator.pop(context);
                      this.widget.argumentsPassed.init();
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
                  SizedBox(
                    height: 23.h,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      this.widget.argumentsPassed.menu?.fotoMenu?.isEmpty ??
                              true
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
                                AppGlobalConfig.getUrlStorage() +
                                    this.widget.argumentsPassed.menu.fotoMenu,
                                // errorBuilder: (BuildContext context,
                                //     Object exception, StackTrace stackTrace) {
                                //   return Text('Your error widget...');
                                // },
                                height: 91.h,
                                width: 91.w,
                                fit: BoxFit.cover,
                              ),
                            ),
                      SizedBox(
                        width: 20.w,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppGlobalConfig.titleCase(this
                                    .widget
                                    .argumentsPassed
                                    .menu
                                    ?.namaMakanan) ??
                                'namaMakananNull',
                            style: titlePage,
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          Row(
                            children: [
                              Text(
                                AppGlobalConfig.convertToIdr(
                                    this
                                        .widget
                                        .argumentsPassed
                                        .menu
                                        .hargaMakanan,
                                    2),
                                style: descriptionTextOrange12,
                              ),
                              SizedBox(
                                width: 10.w,
                              ),
                              Text(
                                AppGlobalConfig.convertToIdr(
                                    this
                                        .widget
                                        .argumentsPassed
                                        .menu
                                        .hargaSebelumDiskon,
                                    2),
                                style: strikeTroughText,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          Text(
                            this
                                    .widget
                                    .argumentsPassed
                                    .menu
                                    ?.deskripsiMakanan ??
                                'Tidak ada deskripsi',
                            style: descriptionTextGrey12,
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          Row(
                            children: [
                              TextButtonTemplate('Edit Bundle', lightOrange,
                                  onPressed: editBundlePressed),
                              SizedBox(
                                width: 10.w,
                              ),
                              TextButtonTemplate('Hapus Bundle', red,
                                  onPressed: hapusBundlePressed),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 23.h,
                  ),
                  Divider(
                    color: darkGrey,
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  Row(
                    children: [
                      Text(
                        'Item Bundle',
                        style: descriptionTextBlack14,
                      ),
                      Spacer(),
                      IconButtonTemplate(darkOrange, Icons.add_circle_outlined,
                          onPressed: addIsiBundlePressed)
                    ],
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  if (this.listDetailBundle?.length == 0) ...[
                    Container(
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 100.h,
                          ),
                          Text(
                            'Belum ada item bundle',
                            style: descriptionTextBlack12,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  ] else ...[
                    ListView.builder(
                        itemCount: this.listDetailBundle.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          print('listDetailBundle: ' +
                              this.listDetailBundle.length.toString());
                          final itemBundle = this.listDetailBundle[index];

                          // return Text(bisniskuliner.namaBisnis);
                          return Column(
                            children: [
                              buildBundle(itemBundle),
                              SizedBox(
                                height: 20.h,
                              )
                            ],
                          );
                        }),
                  ],
                ],
              )),
        ),
      ),
    );
  }

  Widget buildBundle(DetailBundle bundle) =>
      BisCardDetailBundleTemplate(bundle, init);
}
