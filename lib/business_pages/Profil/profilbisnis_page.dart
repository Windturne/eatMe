import 'dart:io';

import 'package:eatme_mobileapp/api/bisniskuliner_api.dart';
import 'package:eatme_mobileapp/appGlobalConfig.dart';
import 'package:eatme_mobileapp/main.dart';
import 'package:eatme_mobileapp/template/Buttons/button_template.dart';
import 'package:eatme_mobileapp/template/Buttons/iconbutton_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';

import '../../theme.dart';

// ignore: must_be_immutable
class ProfilBisnisPage extends StatefulWidget {
  @override
  _ProfilBisnisPageState createState() => _ProfilBisnisPageState();

  // BisnisKuliner objBisnisKuliner;
  // final VoidCallback initBisProfil;
  ArgumentsProfile argumentsPassed;
  ProfilBisnisPage(this.argumentsPassed);
}

class _ProfilBisnisPageState extends State<ProfilBisnisPage> {
  String dropDownValue;
  File image;
  String imageFromDatabase;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    init();
  }

  Future init() async {
    print('[INIT] Bisnis Profil Page');

    if (widget.argumentsPassed.objBisnisKuliner.fotoProfil != null) {
      setState(() {
        this.imageFromDatabase = AppGlobalConfig.getUrlStorage() +
            widget.argumentsPassed.objBisnisKuliner.fotoProfil;
      });
    }

    if (!mounted) return;

    setState(() {
      this.dropDownValue =
          widget.argumentsPassed.objBisnisKuliner.kategoriMakanan;
    });
  }

  void backButtonPressed() {
    Navigator.pop(context);
  }

  Future simpanPressed() async {
    // final response = await http.put(
    //     Uri.parse(AppGlobalConfig.getUrlApi() +
    //         'bisniskuliner/' +
    //         widget.argumentsPassed.objBisnisKuliner.id.toString()),
    //     body: {
    //       'kategori_makanan': dropDownValue.toString(),
    //       'foto_profil': this.image.path.toString()
    //     },
    //     headers: {
    //       'Accept': 'application/json'
    //     });

    // print(response.body);
    // Navigator.pop(context);
    // widget.argumentsPassed.init();

    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.style(message: 'Loading...');
    progressDialog.show();

    if (this.image == null) {
      print("Image null -> not edited");
      final response = await http.put(
          Uri.parse(AppGlobalConfig.getUrlApi() +
              'bisniskuliner/' +
              widget.argumentsPassed.objBisnisKuliner.id.toString()),
          body: {
            'kategori_makanan': dropDownValue.toString(),
          },
          headers: {
            'Accept': 'application/json'
          });

      if (response.statusCode == 200) {
        print(response.body);
        progressDialog.hide();
        Navigator.pop(context);
        widget.argumentsPassed.init();
      }
    } else {
      print("Image not null -> edited");
      Map<String, String> body = {
        'id_pemilik_bisnis_kuliner':
            widget.argumentsPassed.objBisnisKuliner.idPemilikBisnis.toString(),
        'nama_bisnis':
            widget.argumentsPassed.objBisnisKuliner.namaBisnis.toString(),
        'alamat_bisnis':
            widget.argumentsPassed.objBisnisKuliner.alamatBisnis.toString(),
        'no_telp': widget.argumentsPassed.objBisnisKuliner.noTelp.toString(),
        'kategori_makanan': dropDownValue.toString(),
        'jam_ambil_awal':
            widget.argumentsPassed.objBisnisKuliner.jamAmbilAwal.toString(),
        'jam_ambil_akhir':
            widget.argumentsPassed.objBisnisKuliner.jamAmbilAkhir.toString(),
        'status_validasi':
            widget.argumentsPassed.objBisnisKuliner.statusValidasi.toString(),
        'status_bisnis':
            widget.argumentsPassed.objBisnisKuliner.statusBisnis.toString(),
        'rating_bisnis':
            widget.argumentsPassed.objBisnisKuliner.ratingBisnis.toString()
      };
      var response = await BisnisKulinerApi.editBisnisKuliner(
          widget.argumentsPassed.objBisnisKuliner.id, body, this.image.path);

      if (response) {
        print(response);
        progressDialog.hide();
        Navigator.pop(context);
        widget.argumentsPassed.init();
      }
    }
  }

  Future fotoPressed() async {
    setState(() {
      this.imageFromDatabase = null;
    });
    var pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      if (!mounted) return;
      setState(() {
        this.image = File(pickedImage.path);
        print('imagePath: ' + image.toString());
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
                    height: 30.h,
                  ),
                  IconButtonTemplate(black, Icons.arrow_back_ios_rounded,
                      onPressed: backButtonPressed),
                  SizedBox(
                    height: 23.h,
                  ),
                  Text(
                    'Profil Bisnis',
                    style: titlePage,
                  ),
                  SizedBox(
                    height: 40.h,
                  ),
                  Text(
                    'Foto Profil',
                    style: descriptionTextBlack12,
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  if (this.imageFromDatabase == null && this.image == null) ...[
                    GestureDetector(
                        onTap: fotoPressed,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: Image.asset(
                            'assets/images/business.jpg',
                            fit: BoxFit.cover,
                            width: 91.w,
                            height: 91.h,
                          ),
                        )),
                  ] else if (this.imageFromDatabase == null &&
                      this.image.path != null) ...[
                    GestureDetector(
                        onTap: fotoPressed,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: Image.file(
                            File(this.image.path),
                            fit: BoxFit.cover,
                            width: 91.w,
                            height: 91.h,
                          ),
                        )),
                  ] else ...[
                    GestureDetector(
                        onTap: fotoPressed,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: Image.network(
                            this.imageFromDatabase,
                            fit: BoxFit.cover,
                            width: 91.w,
                            height: 91.h,
                          ),
                        )),
                  ],
                  SizedBox(
                    height: 20.h,
                  ),
                  Text(
                    'Kategori Makanan',
                    style: descriptionTextBlack12,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  DropdownButton(
                    value: dropDownValue,
                    items: [
                      DropdownMenuItem(
                        child: Text(
                          'Nasi',
                          style: descriptionTextGrey12,
                        ),
                        value: 'Nasi',
                      ),
                      DropdownMenuItem(
                        child: Text(
                          'Makanan ringan',
                          style: descriptionTextGrey12,
                        ),
                        value: 'Makanan ringan',
                      ),
                      DropdownMenuItem(
                        child: Text(
                          'Roti/Kue',
                          style: descriptionTextGrey12,
                        ),
                        value: 'Roti/Kue',
                      ),
                      DropdownMenuItem(
                        child: Text(
                          'Seafood',
                          style: descriptionTextGrey12,
                        ),
                        value: 'Seafood',
                      ),
                      DropdownMenuItem(
                        child: Text(
                          'Chinese food',
                          style: descriptionTextGrey12,
                        ),
                        value: 'Chinese food',
                      ),
                      DropdownMenuItem(
                        child: Text(
                          'Korean food',
                          style: descriptionTextGrey12,
                        ),
                        value: 'Korean food',
                      ),
                      DropdownMenuItem(
                        child: Text(
                          'Japanese food',
                          style: descriptionTextGrey12,
                        ),
                        value: 'Japanese food',
                      ),
                      DropdownMenuItem(
                        child: Text(
                          'Western food',
                          style: descriptionTextGrey12,
                        ),
                        value: 'Western food',
                      ),
                      DropdownMenuItem(
                        child: Text(
                          'Minuman',
                          style: descriptionTextGrey12,
                        ),
                        value: 'Minuman',
                      ),
                      DropdownMenuItem(
                        child: Text(
                          'Makanan penutup',
                          style: descriptionTextGrey12,
                        ),
                        value: 'Makanan penutup',
                      ),
                    ],
                    onChanged: (value) async {
                      if (!mounted) return;
                      setState(() {
                        dropDownValue = value;
                      });
                    },
                    icon: Icon(
                      Icons.arrow_drop_down_rounded,
                      color: darkGrey,
                    ),
                  ),
                  SizedBox(
                    height: 80.h,
                  ),
                  ButtonTemplate('SIMPAN', lightOrange,
                      onPressed: simpanPressed)
                ],
              )),
        ),
      ),
    );
  }
}
