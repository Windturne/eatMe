import 'dart:convert';
import 'dart:io';

import 'package:eatme_mobileapp/api/komplain_api.dart';
import 'package:eatme_mobileapp/main.dart';
import 'package:eatme_mobileapp/template/Buttons/button_template.dart';
import 'package:eatme_mobileapp/template/Buttons/iconbutton_template.dart';
import 'package:eatme_mobileapp/template/Buttons/textbutton_template.dart';
import 'package:eatme_mobileapp/template/largeTextField_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../appGlobalConfig.dart';
import '../../theme.dart';

class KomplainPage extends StatefulWidget {
  @override
  _KomplainPageState createState() => _KomplainPageState();

  final ArgumentsKomplain argumentsPassed;
  KomplainPage(this.argumentsPassed);
}

class _KomplainPageState extends State<KomplainPage> {
  TextEditingController komplainController = new TextEditingController();
  File image;
  final picker = ImagePicker();
  int idUser;

  @override
  void initState() {
    super.initState();

    init();
  }

  Future init() async {
    print('[INIT] BisCardKonfirmasi Page');

    //Get User's EWallet
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int idUser = prefs.getInt('idUser');

    if (!mounted) return;

    setState(() {
      this.idUser = idUser;
    });
  }

  void backButtonPressed() {
    Navigator.pop(context);
  }

  Future tambahkanGambarPressed() async {
    var pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      if (!mounted) return;
      setState(() {
        this.image = File(pickedImage.path);
        print('imagePath: ' + this.image.toString());
      });
    }
  }

  Future submitPressed() async {
    //Loading setelah tekan tombol
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.style(message: 'Loading...');
    progressDialog.show();

    if (komplainController.text.isEmpty) {
      Alert(
          style: AlertStyle(
              descStyle: descriptionTextBlack12,
              isCloseButton: false,
              titleStyle: titlePage),
          context: context,
          title: "Pengajuan Komplain Gagal",
          desc:
              "Mohon masukkan penjelasan komplain beserta foto yang mendukung (jika ada)",
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
    } else {
      Map<String, String> body = {
        'id_nota': widget.argumentsPassed.idNota.toString(),
        'deskripsi_komplain': komplainController.text.toString(),
        'sender': widget.argumentsPassed.sender.toString()
      };

      if (this.image != null) {
        var response = await KomplainApi.addKomplain(body, this.image.path);
        if (response) {
          print('Save gambar komplain berhasil');
        } else {
          Alert(
              style: AlertStyle(
                  descStyle: descriptionTextBlack12,
                  isCloseButton: false,
                  titleStyle: titlePage),
              context: context,
              title: "Pengajuan Komplain Gagal",
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
        final urlFormKomplain = AppGlobalConfig.getUrlApi() + 'komplain';
        final response = await http.post(Uri.parse(urlFormKomplain),
            headers: {
              "Content-Type": "application/json; charset=utf-8",
            },
            body: json.encode({
              'id_nota': widget.argumentsPassed.idNota.toString(),
              'deskripsi_komplain': komplainController.text.toString(),
              'sender': widget.argumentsPassed.sender.toString()
            }));

        if (response.statusCode == 200) {
          print(response.body);
        }
      }

      //Update tabel nota (status_komplain = 1)
      final response = await http.put(
          Uri.parse(AppGlobalConfig.getUrlApi() +
              'nota/' +
              widget.argumentsPassed.idNota.toString()),
          body: {
            'status_komplain': '1',
          },
          headers: {
            'Accept': 'application/json'
          });

      if (response.statusCode == 200) {
        print(response.body);
      }

      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text(
                  'Komplain Diterima',
                  style: titlePage,
                  textAlign: TextAlign.center,
                ),
                content: Text(
                  'Administrator akan menghubungi melalui email yang sudah terdaftar pada akun ini',
                  style: descriptionTextBlack12,
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        // int count = 0;
                        // Navigator.of(context).popUntil((_) => count++ >= 3);
                        // Navigator.pop(context);
                        Navigator.pushReplacementNamed(
                            context, '/_CustomerBottomNav');

                        // Navigator.pushReplacementNamed(context, '/_CustomerBottomNav');
                      },
                      child: Text(
                        'OK',
                        style: descriptionTextOrangeMedium12,
                      ))
                ],
              ));
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
                  Container(
                    width: double.infinity,
                    child: Text(
                      'Pengajuan Komplain',
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
                      'NOTA (ID: ' +
                          widget.argumentsPassed.idNota.toString() +
                          ')',
                      style: descriptionTextBlack14,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: 40.h,
                  ),
                  LargeTextFieldTemplate('komplain', false, komplainController),
                  SizedBox(
                    height: 10.h,
                  ),
                  TextButtonTemplate('Tambahkan gambar', lightOrange,
                      onPressed: tambahkanGambarPressed),
                  SizedBox(
                    height: 5.h,
                  ),
                  this.image == null
                      ? Text(
                          'Tidak ada gambar yang dipilih',
                          style: descriptionTextGrey12,
                        )
                      : Image.file(
                          this.image,
                          height: 80,
                          width: 80,
                        ),
                  SizedBox(
                    height: 100.h,
                  ),
                  ButtonTemplate('SUBMIT', lightOrange,
                      onPressed: submitPressed),
                  SizedBox(
                    height: 10.h,
                  ),
                  Container(
                    width: double.infinity,
                    child: Text(
                      '*Komplain akan ditangani oleh administrator eatMe!*',
                      style: descriptionTextGrey12,
                    ),
                  )
                ],
              )),
        ),
      ),
    );
  }
}
