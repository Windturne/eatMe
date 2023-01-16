import 'dart:io';

import 'package:eatme_mobileapp/api/transaksiEwallet_api.dart';
import 'package:eatme_mobileapp/template/Buttons/button_template.dart';
import 'package:eatme_mobileapp/template/Buttons/iconbutton_template.dart';
import 'package:eatme_mobileapp/template/Buttons/textbutton_template.dart';
import 'package:eatme_mobileapp/template/textField_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme.dart';

class IsiSaldoPage extends StatefulWidget {
  @override
  _IsiSaldoPageState createState() => _IsiSaldoPageState();

  final VoidCallback initEwalletPage;
  IsiSaldoPage(this.initEwalletPage);
}

class _IsiSaldoPageState extends State<IsiSaldoPage> {
  TextEditingController jumlahSaldoController = new TextEditingController();
  List<String> caraIsiSaldo = [
    '1. Salin ID unik yang tertera',
    '2. Transfer ke rekening BCA: 0102199314 (an Jessica Clarensia)',
    '3. Cantumkan "Isi saldo #ID_UNIK" pada berita acara',
    '4. Upload bukti transfer pada aplikasi',
    '5. Menunggu konfirmasi dari administrator',
    '6. Saldo e-wallet akan terisi'
  ];
  int idUser;
  File image;
  final picker = ImagePicker();

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

  Future uploadPressed() async {
    var pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        image = File(pickedImage.path);
        print('imagePath: ' + image.toString());
      });
    }
  }

  Future isiSaldoPressed() async {
    //Loading setelah tekan tombol
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.style(message: 'Loading...');
    progressDialog.show();
    if (this.image == null || jumlahSaldoController.text.isEmpty) {
      Alert(
          style: AlertStyle(
              descStyle: descriptionTextBlack12,
              isCloseButton: false,
              titleStyle: titlePage),
          context: context,
          title: "Isi Saldo Gagal",
          desc: "Mohon masukkan jumlah saldo dan upload bukti transfer",
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
      Map<String, String> body = {
        'id_user': this.idUser.toString(),
        'tipe_transaksi': 'topup',
        'jumlah_transaksi': jumlahSaldoController.text.toString(),
        'status_topup': '0',
        'tanggal_transaksi': DateTime.now().toString()
      };
      var response =
          await TransaksiEwalletApi.addTransaksi(body, this.image.path);

      if (response) {
        if (!mounted) return;
        setState(() {
          this.image = null;
        });

        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text(
                    'Pengisian Saldo Sedang Diproses',
                    style: titlePage,
                    textAlign: TextAlign.center,
                  ),
                  content: Text(
                    'Administrator akan mengecek dan mengkonfirmasi pembayaran. Setelah terkonfirmasi, dana akan ditambahkan ke e-wallet.',
                    style: descriptionTextBlack12,
                  ),
                  actions: [
                    TextButton(
                        onPressed: () {
                          progressDialog.hide();
                          widget.initEwalletPage();
                          int count = 0;
                          Navigator.of(context).popUntil((_) => count++ >= 2);
                        },
                        child: Text(
                          'OK',
                          style: descriptionTextOrangeMedium12,
                        ))
                  ],
                ));
      } else {
        Alert(
            style: AlertStyle(
                descStyle: descriptionTextBlack12,
                isCloseButton: false,
                titleStyle: titlePage),
            context: context,
            title: "Isi Saldo Gagal",
            desc: "Terjadi kendala",
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
                    'Pengisian Saldo E-Wallet',
                    style: titlePage,
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  Text(
                    'ID Unik : ' + idUser.toString(),
                    style: descriptionTextOrangeMedium12,
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  ListView.builder(
                      itemCount: caraIsiSaldo.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return new Text(
                          caraIsiSaldo[index],
                          style: descriptionTextBlack12,
                        );
                      }),
                  SizedBox(
                    height: 30.h,
                  ),
                  Text(
                    'Jumlah Saldo Top-Up',
                    style: descriptionTextGrey12,
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  TextFieldTemplate(
                      '100000', false, true, jumlahSaldoController),
                  SizedBox(
                    height: 10.h,
                  ),
                  TextButtonTemplate('Upload bukti transfer', lightOrange,
                      onPressed: uploadPressed),
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
                  ButtonTemplate('ISI SALDO', lightOrange,
                      onPressed: isiSaldoPressed)
                ],
              )),
        ),
      ),
    );
  }
}
