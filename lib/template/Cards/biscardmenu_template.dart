import 'dart:io';

import 'package:eatme_mobileapp/api/bisniskuliner_api.dart';
import 'package:eatme_mobileapp/api/favorite_api.dart';
import 'package:eatme_mobileapp/api/menu_api.dart';
import 'package:eatme_mobileapp/api/user_api.dart';
import 'package:eatme_mobileapp/business_pages/Beranda/bisberanda_page.dart';
import 'package:eatme_mobileapp/business_pages/Beranda/bisdetailbundle_page.dart';
import 'package:eatme_mobileapp/main.dart';
import 'package:eatme_mobileapp/models/menus.dart';
import 'package:eatme_mobileapp/template/Buttons/button_template.dart';
import 'package:eatme_mobileapp/template/Buttons/iconbutton_template.dart';
import 'package:eatme_mobileapp/template/Buttons/textbutton_template.dart';
import 'package:eatme_mobileapp/template/largeTextField_template.dart';
import 'package:eatme_mobileapp/template/textField_template.dart';
import 'package:eatme_mobileapp/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:http/http.dart' as http;

import '../../appGlobalConfig.dart';

// ignore: must_be_immutable
class BisCardMenuTemplate extends StatefulWidget {
  Menus menu;
  final VoidCallback initBisPage;

  @override
  _BisCardMenuTemplateState createState() =>
      _BisCardMenuTemplateState(this.menu);

  BisCardMenuTemplate(this.menu, this.initBisPage);
}

class _BisCardMenuTemplateState extends State<BisCardMenuTemplate> {
  Menus menu;
  TextEditingController namaMenuController = new TextEditingController();
  TextEditingController hargaDiskonController = new TextEditingController();
  TextEditingController hargaAsliController = new TextEditingController();
  TextEditingController deskripsiController = new TextEditingController();
  String namaBisnis;

  File image;
  String imageFromDatabase;
  final picker = ImagePicker();

  _BisCardMenuTemplateState(this.menu);

  final BisBerandaPage bisBeranda = new BisBerandaPage();

  @override
  void initState() {
    super.initState();

    init();
  }

  Future init() async {
    print('[INIT] Bisnis Card Menu Template');

    final bisnis =
        await BisnisKulinerApi.getBisnisKulinerById(this.menu.idBisnisKuliner);

    if (!mounted) return;

    setState(() {
      this.namaBisnis = bisnis[0].namaBisnis;
    });

    if (this.menu.fotoMenu != null) {
      if (!mounted) return;
      setState(() {
        this.imageFromDatabase =
            AppGlobalConfig.getUrlStorage() + this.menu.fotoMenu;
      });
    }

    // print('ImageFromDatabase: ' + this.imageFromDatabase);
    // print('Image: ' + this.image.path);
  }

  void closeBottomSheet() {
    Navigator.pop(context);
  }

  void hapusMenuPressed() {
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
                      Navigator.pop(context);
                      widget.initBisPage();
                    },
                    child: Text(
                      'YA',
                      style: descriptionTextOrangeMedium12,
                    ))
              ],
            ));
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
                    Navigator.of(context).popUntil((_) => count++ >= 2);
                    widget.initBisPage();
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
                    Navigator.of(context).popUntil((_) => count++ >= 2);
                    widget.initBisPage();
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
    widget.initBisPage();
  }

  void lihatDetailBundlePressed() {
    var argumentsPassed =
        new ArgumentsDetailBundle(this.menu, this.widget.initBisPage);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BisDetailBundlePage(argumentsPassed)));
  }

  void editMenuPressed() {
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
                    Row(
                      children: [
                        Container(
                          width: 120.w,
                          child: Text(
                            this.menu.namaMakanan ?? 'namaMakananNull',
                            maxLines: 2,
                            style: titleCard,
                          ),
                        ),
                        Spacer(),
                        Switch(
                          value: this.menu.makananTersedia == 1 ? true : false,
                          onChanged: (value) async {
                            if (!mounted) return;
                            setState(() {
                              this.menu.makananTersedia = value == true ? 1 : 0;
                              print(this.menu.makananTersedia);
                            });

                            if (value) {
                              List<String> tokenIds = [];

                              //Notify user who subscribed
                              final favorites =
                                  await FavoriteApi.getFavoriteByIdBisnis(
                                      widget.menu.idBisnisKuliner);

                              for (int i = 0; i < favorites.length; i++) {
                                final users = await UserApi.getUserById(
                                    favorites[i].idUser);
                                if (users[0].tokenNotifikasi != 'null') {
                                  print("User: " + users[0].id.toString());
                                  tokenIds.add(users[0].tokenNotifikasi);
                                }
                              }

                              String contents = 'Menu ' +
                                  AppGlobalConfig.titleCase(
                                      this.menu.namaMakanan) +
                                  ' dari restoran favoritmu sekarang tersedia!';
                              String heading =
                                  AppGlobalConfig.titleCase(this.namaBisnis);

                              await AppGlobalConfig.sendPushNotification(
                                  tokenIds, contents, heading);
                              print('setelah send notif');
                            }

                            final response = await http.put(
                                Uri.parse(AppGlobalConfig.getUrlApi() +
                                    'menus/' +
                                    this.menu.id.toString()),
                                body: {
                                  'makanan_tersedia':
                                      this.menu.makananTersedia.toString(),
                                },
                                headers: {
                                  'Accept': 'application/json'
                                });

                            print(response.body);
                          },
                          activeTrackColor: lightOrange,
                          activeColor: darkOrange,
                        )
                      ],
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    Row(
                      children: [
                        Text(
                          AppGlobalConfig.convertToIdr(
                                  this.menu.hargaMakanan, 2) ??
                              'hargaMakananNull',
                          style: descriptionTextOrange12,
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        Text(
                          AppGlobalConfig.convertToIdr(
                                  this.menu.hargaSebelumDiskon, 2) ??
                              'hargaMakananNull',
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
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    menu.isBundle == 0
                        ? Row(
                            children: [
                              TextButtonTemplate('Edit Menu', lightOrange,
                                  onPressed: editMenuPressed),
                              SizedBox(
                                width: 10.w,
                              ),
                              TextButtonTemplate('Hapus Menu', red,
                                  onPressed: hapusMenuPressed),
                            ],
                          )
                        : TextButtonTemplate('Lihat Detail Bundle', lightOrange,
                            onPressed: lihatDetailBundlePressed),
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
