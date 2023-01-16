import 'dart:convert';
import 'dart:io';

import 'package:eatme_mobileapp/api/bisniskuliner_api.dart';
import 'package:eatme_mobileapp/api/favorite_api.dart';
import 'package:eatme_mobileapp/api/menu_api.dart';
import 'package:eatme_mobileapp/api/pemilikbisniskuliner_api.dart';
import 'package:eatme_mobileapp/api/user_api.dart';
import 'package:eatme_mobileapp/appGlobalConfig.dart';
import 'package:eatme_mobileapp/models/bisniskuliner.dart';
import 'package:eatme_mobileapp/models/menus.dart';
import 'package:eatme_mobileapp/template/Buttons/button_template.dart';
import 'package:eatme_mobileapp/template/Buttons/iconbutton_template.dart';
import 'package:eatme_mobileapp/template/Buttons/textbutton_template.dart';
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

class BisBerandaPage extends StatefulWidget {
  @override
  _BisBerandaPageState createState() => _BisBerandaPageState();
}

class _BisBerandaPageState extends State<BisBerandaPage> {
  String selectedTimeFirst = '9:00 AM';
  String selectedTimeSecond = '10:00 AM';
  TextEditingController namaMenuController = new TextEditingController();
  TextEditingController hargaDiskonController = new TextEditingController();
  TextEditingController hargaAsliController = new TextEditingController();
  TextEditingController deskripsiController = new TextEditingController();
  bool isRoleSwitched = false;

  BisnisKuliner objBisnisKuliner;
  List<Menus> listMenu;

  File image;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    init();
  }

  // @override
  // void dispose() {
  //   super.dispose();
  // }

  Future init() async {
    print('[INIT] Bisnis Beranda Page');
    this.listMenu = [];

    //Get User's Id
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final idUser = prefs.getInt('idUser');
    print('idUser: ' + idUser.toString());

    //Ambil ID pemilik bisnis kuliner dengan user ID yang login
    final pemilikbisniskuliner =
        await PemilikBisnisKulinerApi.getPemilikBisnisKulinerByIdUser(idUser);
    // int idPemilikBisnisKuliner;
    // for (int i = 0; i < pemilikbisniskuliner.length; i++) {
    //   if (idUser == pemilikbisniskuliner[i].idUser) {
    //     idPemilikBisnisKuliner = pemilikbisniskuliner[i].id;
    //   }
    // }

    //Ambil bisnis kuliner dengan ID Pemilik Bisnis Kuliner yang sudah didapat
    final bisniskuliner = await BisnisKulinerApi.getBisnisKulinerByIdPemilik(
        pemilikbisniskuliner[0].id);
    // BisnisKuliner tmpBisnisKuliner;
    // for (int i = 0; i < bisniskuliner.length; i++) {
    //   if (idPemilikBisnisKuliner == bisniskuliner[i].idPemilikBisnis) {
    //     tmpBisnisKuliner = bisniskuliner[i];
    //   }
    // }

    prefs.setInt('idBisnisLoggedIn', bisniskuliner[0]?.id);

    //Get menu dari bisnis kuliner yang sudah didapat
    final menus = await MenusApi.getMenusForBusiness(bisniskuliner[0]?.id);

    // print('tmpBisnisKulinerNama: ' + tmpBisnisKuliner.namaBisnis);

    //Set string jam ambil
    String jamAmbilAwal = DateFormat('h:mma')
        .format(DateTime.parse(bisniskuliner[0]?.jamAmbilAwal));
    String jamAmbilAkhir = DateFormat('h:mma')
        .format(DateTime.parse(bisniskuliner[0]?.jamAmbilAkhir));

    if (!mounted) return;

    setState(() {
      this.objBisnisKuliner = bisniskuliner[0];
      this.selectedTimeFirst = jamAmbilAwal;
      this.selectedTimeSecond = jamAmbilAkhir;
      this.listMenu = menus;
    });
  }

  void closeBottomSheet() {
    if (!mounted) return;
    setState(() {
      image = null;
    });
    Navigator.pop(context);
  }

  Future tambahGambarPressed(StateSetter mystate) async {
    var pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      mystate(() {
        image = File(pickedImage.path);
        print('imagePath: ' + image.toString());
      });
    }
  }

  Future tambahMenuPressed() async {
    //Loading setelah tekan tombol
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.style(message: 'Loading...');
    progressDialog.show();

    String urlApiMenu = AppGlobalConfig.getUrlApi() + 'menus';

    if (image != null) {
      print('Image not null');
      Map<String, String> body = {
        'id_bisnis_kuliner': objBisnisKuliner.id.toString(),
        'isBundle': this.isRoleSwitched == true ? '1' : '0',
        'nama_makanan': namaMenuController.text,
        'harga_makanan': hargaDiskonController.text,
        'harga_sebelum_diskon': hargaAsliController.text,
        'makanan_tersedia': 1.toString(),
        'deskripsi_makanan': deskripsiController.text,
      };
      var response = await MenusApi.addMenu(body, image.path);

      if (response) {
        print('Add Menu Berhasil');

        List<String> tokenIds = [];
        //Notify user who subscribed
        final favorites =
            await FavoriteApi.getFavoriteByIdBisnis(objBisnisKuliner.id);
        for (int i = 0; i < favorites.length; i++) {
          print("Favorite ID User: " + favorites[i].idUser.toString());
          final users = await UserApi.getUserById(favorites[i].idUser);
          tokenIds.add(users[0].tokenNotifikasi);
        }
        for (int i = 0; i < tokenIds.length; i++) {
          print('Token Id:' + tokenIds[i]);
        }

        String contents = 'Cek menu baru dari ' +
            AppGlobalConfig.titleCase(this.objBisnisKuliner?.namaBisnis) +
            ' sekarang';
        String heading = 'Menu Baru dari Restoran Favoritmu!';

        await AppGlobalConfig.sendPushNotification(tokenIds, contents, heading);
        print('setelah send notif');

        namaMenuController.text = '';
        hargaDiskonController.text = '';
        hargaAsliController.text = '';
        deskripsiController.text = '';
        image = null;

        progressDialog.hide();
        Navigator.pop(context);
        init();
      } else {
        print('Add Menu Gagal');
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
    } else {
      print('Image null');
      final response = await http.post(Uri.parse(urlApiMenu),
          headers: {
            "Content-Type": "application/json; charset=utf-8",
          },
          body: json.encode({
            'id_bisnis_kuliner': objBisnisKuliner.id,
            'isBundle': this.isRoleSwitched == true ? '1' : '0',
            'nama_makanan': namaMenuController.text,
            'harga_makanan': int.parse(hargaDiskonController.text),
            'harga_sebelum_diskon': int.parse(hargaAsliController.text),
            'makanan_tersedia': 1.toString(),
            'deskripsi_makanan': deskripsiController.text,
          }));

      if (response.statusCode == 200) {
        print(response.body);

        List<String> tokenIds = [];
        //Notify user who subscribed
        final favorites =
            await FavoriteApi.getFavoriteByIdBisnis(objBisnisKuliner.id);
        for (int i = 0; i < favorites.length; i++) {
          print("Favorite ID User: " + favorites[i].idUser.toString());
          final users = await UserApi.getUserById(favorites[i].idUser);
          tokenIds.add(users[0].tokenNotifikasi);
        }
        for (int i = 0; i < tokenIds.length; i++) {
          print('Token Id:' + tokenIds[i]);
        }

        String contents = 'Cek menu baru dari ' +
            AppGlobalConfig.titleCase(this.objBisnisKuliner?.namaBisnis) +
            ' sekarang';
        String heading = 'Menu Baru dari Restoran Favoritmu!';

        await AppGlobalConfig.sendPushNotification(tokenIds, contents, heading);
        print('setelah send notif');

        namaMenuController.text = '';
        hargaDiskonController.text = '';
        hargaAsliController.text = '';
        deskripsiController.text = '';

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
  }

  void addMenuPressed() {
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
                              'Tambah Menu',
                              style: titlePage,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            height: 45.h,
                          ),
                          Row(
                            children: [
                              Text(
                                "Atur sebagai menu bundle (paket)",
                                style: descriptionTextBlack12,
                              ),
                              Switch(
                                value: isRoleSwitched,
                                onChanged: (value) {
                                  if (!mounted) return;
                                  mystate(() {
                                    isRoleSwitched = value;
                                    print(isRoleSwitched);
                                  });
                                },
                                activeTrackColor: lightOrange,
                                activeColor: darkOrange,
                              )
                            ],
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
                              TextButtonTemplate('tambah gambar', lightOrange,
                                  onPressed: () => tambahGambarPressed(mystate))
                            ],
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          Container(
                            child: image == null
                                ? Text(
                                    'Tidak ada gambar yang dipilih',
                                    style: descriptionTextGrey12,
                                  )
                                : Image.file(
                                    image,
                                    height: 80,
                                    width: 80,
                                  ),
                          ),
                          SizedBox(
                            height: 80.h,
                          ),
                          ButtonTemplate('TAMBAH MENU', lightOrange,
                              onPressed: tambahMenuPressed)
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

  Future<void> openTimePickerFirst(BuildContext context) async {
    final TimeOfDay time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        initialEntryMode: TimePickerEntryMode.input);

    if (time != null) {
      //Ambil tanggal hari ini & gabung dengan time
      final now = DateTime.now();
      final DateTime inputDate =
          DateTime(now.year, now.month, now.day, time.hour, time.minute);

      //Update database dengan timepicker yang sudah dipilih
      final response = await http.put(
          Uri.parse(AppGlobalConfig.getUrlApi() +
              'bisniskuliner/' +
              objBisnisKuliner.id.toString()),
          body: {
            'jam_ambil_awal': inputDate.toString(),
          },
          headers: {
            'Accept': 'application/json'
          });

      print(response.body);

      print('masuk if');
      print(time.format(context));
      if (!mounted) return;
      setState(() {
        selectedTimeFirst = time.format(context);
      });
    }
  }

  Future<void> openTimePickerSecond(BuildContext context) async {
    final TimeOfDay time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        initialEntryMode: TimePickerEntryMode.input);

    if (time != null) {
      //Ambil tanggal hari ini & gabung dengan time
      final now = DateTime.now();
      final DateTime inputDate =
          DateTime(now.year, now.month, now.day, time.hour, time.minute);

      //Update database dengan timepicker yang sudah dipilih
      final response = await http.put(
          Uri.parse(AppGlobalConfig.getUrlApi() +
              'bisniskuliner/' +
              objBisnisKuliner.id.toString()),
          body: {
            'jam_ambil_akhir': inputDate.toString(),
          },
          headers: {
            'Accept': 'application/json'
          });

      print(response.body);

      print('masuk if');
      print(time.format(context));
      if (!mounted) return;
      setState(() {
        selectedTimeSecond = time.format(context);
      });
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
                    height: 80.h,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      this.objBisnisKuliner?.fotoProfil?.isEmpty ?? true
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(5.r),
                              child: Image.asset(
                                'assets/images/business.jpg',
                                height: 91.h,
                                width: 91.w,
                                fit: BoxFit.cover,
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(5.r),
                              child: Image.network(
                                AppGlobalConfig.getUrlStorage() +
                                    this.objBisnisKuliner.fotoProfil,
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
                        width: 15.w,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppGlobalConfig.titleCase(
                                    this.objBisnisKuliner?.namaBisnis) ??
                                'namaBisnisNull',
                            style: titlePage,
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.place_outlined,
                                size: 14,
                                color: darkGrey,
                              ),
                              SizedBox(
                                width: 3.w,
                              ),
                              Text(
                                this.objBisnisKuliner?.alamatBisnis ??
                                    'alamatNull',
                                style: descriptionTextGrey12,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.phone_outlined,
                                size: 14,
                                color: darkGrey,
                              ),
                              SizedBox(
                                width: 3.w,
                              ),
                              Text(
                                this.objBisnisKuliner?.noTelp ?? 'noTelpNull',
                                style: descriptionTextGrey12,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          Container(
                            height: 25.h,
                            width: 42.w,
                            decoration: BoxDecoration(
                                border: Border.all(color: lightGrey),
                                borderRadius: BorderRadius.circular(5.r)),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 2.h, horizontal: 2.w),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: darkOrange,
                                    size: 12,
                                    // textDirection: TextDirection.ltr,
                                  ),
                                  SizedBox(
                                    width: 2.w,
                                  ),
                                  Text(
                                    this.objBisnisKuliner?.ratingBisnis ==
                                                null ||
                                            this
                                                    .objBisnisKuliner
                                                    ?.ratingBisnis ==
                                                0
                                        ? '0.0'
                                        : this
                                            .objBisnisKuliner
                                            ?.ratingBisnis
                                            ?.toStringAsFixed(1),
                                    style: descriptionTextGrey12,
                                  )
                                ],
                              ),
                            ),
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
                  Text(
                    'Jam Pengambilan Hari Ini',
                    style: descriptionTextBlack12,
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                      ),
                      SizedBox(
                        width: 5.w,
                      ),
                      TextButton(
                          child: Text(selectedTimeFirst ?? 'timeNull',
                              style: TextStyle(
                                  color: darkOrange,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12.w,
                                  decoration: TextDecoration.underline)),
                          style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            openTimePickerFirst(context);
                          }),
                      SizedBox(
                        width: 5.w,
                      ),
                      Text(
                        '-',
                        style: descriptionTextBlack12,
                      ),
                      SizedBox(
                        width: 5.w,
                      ),
                      TextButton(
                          child: Text(selectedTimeSecond ?? 'timeSecondNull',
                              style: TextStyle(
                                  color: darkOrange,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12.w,
                                  decoration: TextDecoration.underline)),
                          style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            openTimePickerSecond(context);
                          }),
                    ],
                  ),
                  SizedBox(
                    height: 30.h,
                  ),
                  Row(
                    children: [
                      Text(
                        'Menu',
                        style: descriptionTextBlack14,
                      ),
                      Spacer(),
                      IconButtonTemplate(darkOrange, Icons.add_circle_outlined,
                          onPressed: addMenuPressed)
                    ],
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  if (this.objBisnisKuliner?.statusBisnis == 0) ...[
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
                            'Bisnis Kuliner Tutup',
                            style: descriptionTextBlack12,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          Text(
                            'Pergi ke tab profil untuk membuka bisnis kuliner',
                            style: descriptionTextGrey12,
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    )
                  ] else ...[
                    if (listMenu.length == 0) ...[
                      Text('Belum Ada Menu',
                          style: descriptionTextBlack12,
                          textAlign: TextAlign.center),
                    ] else ...[
                      ListView.builder(
                          itemCount: listMenu.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            print(listMenu.length);
                            final menu = listMenu[index];

                            // return Text(bisniskuliner.namaBisnis);
                            return Column(
                              children: [
                                buildMenus(menu),
                                SizedBox(
                                  height: 20.h,
                                )
                              ],
                            );
                          }),
                    ]
                  ],
                ],
              )),
        ),
      ),
    );
  }

  Widget buildMenus(Menus menu) => BisCardMenuTemplate(menu, init);
}
