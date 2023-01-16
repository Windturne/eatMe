import 'dart:io';

import 'package:eatme_mobileapp/api/formvalidasi_api.dart';
import 'package:eatme_mobileapp/template/Buttons/button_template.dart';
import 'package:eatme_mobileapp/template/Buttons/iconbutton_template.dart';
import 'package:eatme_mobileapp/template/Buttons/textbutton_template.dart';
import 'package:eatme_mobileapp/template/textField_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../appGlobalConfig.dart';
import '../theme.dart';
import 'package:http/http.dart' as http;

class DaftarBisnisPage extends StatefulWidget {
  @override
  _DaftarBisnisPageState createState() => _DaftarBisnisPageState();
}

class _DaftarBisnisPageState extends State<DaftarBisnisPage> {
  TextEditingController namaBisnisController = new TextEditingController();
  TextEditingController alamatController = new TextEditingController();
  TextEditingController namaPemilikController = new TextEditingController();
  TextEditingController alamatPemilikController = new TextEditingController();
  TextEditingController noTelpPemilikController = new TextEditingController();
  TextEditingController emailPemilikController = new TextEditingController();
  TextEditingController noKtpPemilikController = new TextEditingController();
  TextEditingController noRekController = new TextEditingController();
  TextEditingController namaRekController = new TextEditingController();
  TextEditingController namaBankController = new TextEditingController();

  File imageFotoKTP;
  File imageFotoSelfieKTP;
  final picker = ImagePicker();

  void initState() {
    super.initState();

    init();
  }

  Future init() async {
    setState(() {});
  }

  void backButtonPressed() {
    Navigator.pop(context);
  }

  Future daftarBisnisPressed() async {
    if (namaBisnisController.text.isEmpty ||
        alamatController.text.isEmpty ||
        namaPemilikController.text.isEmpty ||
        noKtpPemilikController.text.isEmpty ||
        alamatPemilikController.text.isEmpty ||
        noTelpPemilikController.text.isEmpty ||
        emailPemilikController.text.isEmpty ||
        imageFotoKTP == null ||
        imageFotoSelfieKTP == null ||
        noRekController.text.isEmpty ||
        namaRekController.text.isEmpty ||
        namaBankController.text.isEmpty) {
      Alert(
          style: AlertStyle(
              descStyle: descriptionTextBlack12,
              isCloseButton: false,
              titleStyle: titlePage),
          context: context,
          title: "Daftar Bisnis Gagal",
          desc: "Data tidak lengkap",
          type: AlertType.error,
          buttons: [
            DialogButton(
                color: lightOrange,
                child: Text('OK', style: buttonText),
                onPressed: () => Navigator.pop(context))
          ]).show();
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final idUser = prefs.getInt('idUser');

      Map<String, String> body = {
        'id_user': idUser.toString(),
        'nama_bisnis': namaBisnisController.text.toString(),
        'alamat_bisnis': alamatController.text.toString(),
        'nama_pemilik': namaPemilikController.text.toString(),
        'no_ktp': noKtpPemilikController.text.toString(),
        'alamat_pemilik': alamatPemilikController.text.toString(),
        'no_telp_pemilik': noTelpPemilikController.text.toString(),
        'email_pemilik': emailPemilikController.text.toString(),
        'no_rekening': noRekController.text.toString(),
        'nama_rekening': namaRekController.text.toString(),
        'bank_rekening': namaBankController.text.toString()
      };
      var response = await FormValidasiApi.addFormValidasi(
          body, this.imageFotoKTP.path, this.imageFotoSelfieKTP.path);
      if (response) {
        print('Add Form Berhasil');
        namaBisnisController.text = '';
        alamatController.text = '';
        namaPemilikController.text = '';
        noKtpPemilikController.text = '';
        alamatPemilikController.text = '';
        noTelpPemilikController.text = '';
        noRekController.text = '';
        namaRekController.text = '';
        namaBankController.text = '';

        this.imageFotoKTP = null;
        this.imageFotoSelfieKTP = null;

        //Ganti status_bisnis di tabel user ke kode 1 (menunggu kabar dari admin)
        final response = await http.put(
            Uri.parse(
                AppGlobalConfig.getUrlApi() + 'user/' + idUser.toString()),
            body: {
              'status_bisnis': 1.toString(),
            },
            headers: {
              'Accept': 'application/json'
            });

        if (response.statusCode == 200) {
          print(response.body);
        }

        // Navigator.pop(context);
        // Navigator.pushReplacementNamed(context, '/_BelumValidasiPage');

        Alert(
            style: AlertStyle(
                descStyle: descriptionTextBlack12,
                isCloseButton: false,
                titleStyle: titlePage),
            context: context,
            title: "Form Berhasil Dikirimkan",
            desc:
                "Administrator akan mengecek kelengkapan dan kevalidan data. Mohon tunggu respon dari administrator melalui email maksimal 2x24 jam.",
            type: AlertType.success,
            buttons: [
              DialogButton(
                  color: lightOrange,
                  child: Text('OK', style: buttonText),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(
                        context, '/_BelumValidasiPage');
                  })
            ]).show();
      } else {
        print('Add Form Gagal');
      }
    }
  }

  Future fotoKTP() async {
    var pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      if (!mounted) return;
      setState(() {
        this.imageFotoKTP = File(pickedImage.path);
        print('imagePath: ' + this.imageFotoKTP.toString());
      });
    }
  }

  Future fotoSelfieKTP() async {
    var pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      if (!mounted) return;
      setState(() {
        this.imageFotoSelfieKTP = File(pickedImage.path);
        print('imagePath: ' + this.imageFotoSelfieKTP.toString());
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
                    'Form Pendaftaran Bisnis Kuliner',
                    style: titlePage,
                  ),
                  SizedBox(
                    height: 40.h,
                  ),
                  Text(
                    'INFORMASI UMUM',
                    style: descriptionTextBlack12,
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Text(
                    'Nama Bisnis Kuliner',
                    style: descriptionTextGrey12,
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  TextFieldTemplate(
                      'Golden Taco', false, false, namaBisnisController),
                  SizedBox(
                    height: 10.h,
                  ),
                  Text(
                    'Alamat Lengkap Bisnis Kuliner',
                    style: descriptionTextGrey12,
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  TextFieldTemplate(
                      'Jl. Bayam no.123, Surabaya, Jawa Timur 12355',
                      false,
                      false,
                      alamatController),
                  SizedBox(
                    height: 40.h,
                  ),
                  Text(
                    'IDENTITAS PEMILIK',
                    style: descriptionTextBlack12,
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Text(
                    'Nama Lengkap',
                    style: descriptionTextGrey12,
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  TextFieldTemplate(
                      'Jane Doe', false, false, namaPemilikController),
                  SizedBox(
                    height: 10.h,
                  ),
                  Text(
                    'Nomor KTP',
                    style: descriptionTextGrey12,
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  TextFieldTemplate(
                      '123456789', false, true, noKtpPemilikController),
                  SizedBox(
                    height: 10.h,
                  ),
                  Text(
                    'Alamat Domisili',
                    style: descriptionTextGrey12,
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  TextFieldTemplate(
                      'Jl. Brokoli no.123, Surabaya, Jawa Timur 12355',
                      false,
                      false,
                      alamatPemilikController),
                  SizedBox(
                    height: 10.h,
                  ),
                  Text(
                    'Nomor Telepon',
                    style: descriptionTextGrey12,
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  TextFieldTemplate(
                      '08123456789', false, true, noTelpPemilikController),
                  SizedBox(
                    height: 10.h,
                  ),
                  Text(
                    'Email (Untuk Pengiriman Rincian Pendapatan)',
                    style: descriptionTextGrey12,
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  TextFieldTemplate('janedoe@gmail.com', false, false,
                      emailPemilikController),
                  SizedBox(
                    height: 10.h,
                  ),
                  Row(
                    children: [
                      Text(
                        'Foto KTP: ',
                        style: descriptionTextGrey12,
                      ),
                      this.imageFotoKTP == null
                          ? TextButtonTemplate('tambah gambar', lightOrange,
                              onPressed: () => fotoKTP())
                          : TextButtonTemplate('edit gambar', lightOrange,
                              onPressed: () => fotoKTP())
                    ],
                  ),
                  Container(
                    child: this.imageFotoKTP == null
                        ? Text(
                            'Tidak ada gambar yang dipilih',
                            style: descriptionTextGrey12,
                          )
                        : Image.file(
                            this.imageFotoKTP,
                            height: 80,
                            width: 80,
                          ),
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  Row(
                    children: [
                      Text(
                        'Foto Selfie dengan KTP: ',
                        style: descriptionTextGrey12,
                      ),
                      this.imageFotoSelfieKTP == null
                          ? TextButtonTemplate('tambah gambar', lightOrange,
                              onPressed: () => fotoSelfieKTP())
                          : TextButtonTemplate('edit gambar', lightOrange,
                              onPressed: () => fotoSelfieKTP())
                    ],
                  ),
                  Container(
                    child: this.imageFotoSelfieKTP == null
                        ? Text(
                            'Tidak ada gambar yang dipilih',
                            style: descriptionTextGrey12,
                          )
                        : Image.file(
                            this.imageFotoSelfieKTP,
                            height: 80,
                            width: 80,
                          ),
                  ),
                  SizedBox(
                    height: 40.h,
                  ),
                  Text(
                    'INFORMASI REKENING PEMILIK ',
                    style: descriptionTextBlack12,
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Text(
                    'Nomor Rekening',
                    style: descriptionTextGrey12,
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  TextFieldTemplate('123456789', false, true, noRekController),
                  SizedBox(
                    height: 10.h,
                  ),
                  Text(
                    'Nama Rekening',
                    style: descriptionTextGrey12,
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  TextFieldTemplate(
                      'Jane Doe', false, false, namaRekController),
                  SizedBox(
                    height: 10.h,
                  ),
                  Text(
                    'Nama Bank',
                    style: descriptionTextGrey12,
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  TextFieldTemplate('BCA', false, false, namaBankController),
                  SizedBox(
                    height: 40.h,
                  ),
                  ButtonTemplate('DAFTAR', lightOrange,
                      onPressed: daftarBisnisPressed),
                  SizedBox(
                    height: 30.h,
                  )
                ],
              )),
        ),
      ),
    );
  }
}
