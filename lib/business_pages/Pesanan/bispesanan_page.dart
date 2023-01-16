import 'package:eatme_mobileapp/api/nota_api.dart';
import 'package:eatme_mobileapp/models/nota.dart';
import 'package:eatme_mobileapp/template/Cards/biscarddiambil_template.dart';
import 'package:eatme_mobileapp/template/Cards/biscardkonfirmasi_templat.dart';
import 'package:eatme_mobileapp/template/Cards/biscardselesai_template.dart';
import 'package:flutter/material.dart';
import 'package:eatme_mobileapp/theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BisPesananPage extends StatefulWidget {
  @override
  _BisPesananPageState createState() => _BisPesananPageState();
}

class _BisPesananPageState extends State<BisPesananPage> {
  String dropDownValue = 'Perlu konfirmasi';
  List<Nota> listNota = [];
  int idBisnis;

  @override
  void initState() {
    super.initState();

    init();
  }

  Future init() async {
    print('[INIT] Pesanan Page');

    //Get id Bisnis
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final idBisnis = prefs.getInt('idBisnisLoggedIn');

    if (!mounted) return;
    setState(() {
      this.listNota = [];
    });

    if (dropDownValue == 'Perlu konfirmasi') {
      print('konfirmasi');
      final nota = await NotaApi.getNotaByIdBisnis(idBisnis, 0);
      if (!mounted) return;
      setState(() {
        this.listNota = nota;
      });
    } else if (dropDownValue == 'Siap diambil') {
      print('diambil');
      final nota = await NotaApi.getNotaByIdBisnis(idBisnis, 1);
      if (!mounted) return;
      setState(() {
        this.listNota = nota;
      });
    } else {
      print('selesai');
      final nota = await NotaApi.getNotaByIdBisnis(idBisnis, 2);
      if (!mounted) return;
      setState(() {
        this.listNota = nota.reversed.toList();
      });
    }

    if (!mounted) return;

    setState(() {
      this.idBisnis = idBisnis;
    });
  }

  // Future dropDownOnpressed(value) async {
  //   setState(() {
  //     dropDownValue = value;
  //   });

  //   if (value == 'Perlu konfirmasi') {
  //     final nota = await NotaApi.getNotaByIdBisnis(idBisnis, 0);
  //     setState(() {
  //       this.listNota = nota;
  //     });
  //   } else if (value == 'Siap diambil') {
  //     final nota = await NotaApi.getNotaByIdBisnis(idBisnis, 1);
  //     setState(() {
  //       this.listNota = nota;
  //     });
  //   } else {
  //     final nota = await NotaApi.getNotaByIdBisnis(idBisnis, 2);
  //     setState(() {
  //       this.listNota = nota;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, //supaya textField ngga ketutup keyboard
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 50.h,
                ),
                Text(
                  'Daftar Pesanan',
                  style: titlePage,
                ),
                SizedBox(
                  height: 10,
                ),
                DropdownButton(
                  value: dropDownValue,
                  items: [
                    DropdownMenuItem(
                      child: Text(
                        'Perlu konfirmasi',
                        style: descriptionTextGrey12,
                      ),
                      value: 'Perlu konfirmasi',
                    ),
                    DropdownMenuItem(
                      child: Text(
                        'Siap diambil',
                        style: descriptionTextGrey12,
                      ),
                      value: 'Siap diambil',
                    ),
                    DropdownMenuItem(
                      child: Text(
                        'Pesanan selesai',
                        style: descriptionTextGrey12,
                      ),
                      value: 'Pesanan selesai',
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      dropDownValue = value;
                    });
                    init();
                  },
                  icon: Icon(
                    Icons.arrow_drop_down_rounded,
                    color: darkGrey,
                  ),
                ),
                SizedBox(
                  height: 40.h,
                ),
                listNota?.length == 0
                    ? Text('Belum Ada Pesanan',
                        style: descriptionTextBlack12,
                        textAlign: TextAlign.center)
                    : ListView.builder(
                        itemCount: listNota.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          print(listNota.length);
                          final nota = listNota[index];
                          // final idUser = listNota[index].idUser;

                          if (dropDownValue == 'Perlu konfirmasi') {
                            return Column(
                              children: [
                                buildKonfirmasi(nota),
                                SizedBox(
                                  height: 20.h,
                                )
                              ],
                            );
                          } else if (dropDownValue == 'Siap diambil') {
                            return Column(
                              children: [
                                buildDiambil(nota),
                                SizedBox(
                                  height: 20.h,
                                )
                              ],
                            );
                          } else {
                            return Column(
                              children: [
                                buildSelesai(nota),
                                SizedBox(
                                  height: 20.h,
                                )
                              ],
                            );
                          }
                        }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildKonfirmasi(Nota nota) => BisCardKonfirmasi(
      nota.id, nota.idUser, nota.totalItem, nota.totalHarga, init);

  Widget buildDiambil(Nota nota) => BisCardDiambil(
      nota.id, nota.idUser, nota.totalItem, nota.totalHarga, init);

  Widget buildSelesai(Nota nota) => BisCardSelesai(
      nota.id, nota.idUser, nota.totalItem, nota.totalHarga, init);
}
