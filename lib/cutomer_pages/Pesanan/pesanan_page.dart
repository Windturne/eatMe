import 'package:eatme_mobileapp/api/nota_api.dart';
import 'package:eatme_mobileapp/models/nota.dart';
import 'package:eatme_mobileapp/template/Cards/cardpesananselesai_template.dart';
import 'package:eatme_mobileapp/template/Cards/cardsedangberjalan_template.dart';
import 'package:flutter/material.dart';
import 'package:eatme_mobileapp/theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PesananPage extends StatefulWidget {
  @override
  _PesananPageState createState() => _PesananPageState();
}

class _PesananPageState extends State<PesananPage> {
  String dropDownValue = 'Sedang berjalan';
  List<Nota> listNota = [];
  int idUser;

  @override
  void initState() {
    super.initState();

    init();
  }

  Future init() async {
    print('[INIT] Pesanan Page');

    //Get id User
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final idUser = prefs.getInt('idUser');
    if (!mounted) return;
    setState(() {
      this.listNota = [];
    });

    if (dropDownValue == 'Sedang berjalan') {
      print('sedang berjalan');
      final nota = await NotaApi.getNotaByIdUser(idUser, 1);

      if (!mounted) return;
      setState(() {
        this.listNota = nota.reversed.toList();
      });
    } else {
      print('pesanan selesai');
      final nota = await NotaApi.getNotaByIdUser(idUser, 2);

      if (!mounted) return;
      setState(() {
        this.listNota = nota.reversed.toList();
      });
    }

    print('LENGTH LIST NOTA: ' + this.listNota.length.toString());
    // print('NOTA ID: ' + listNota[0].id.toString());
    // print('NOTA ID BISNIS: ' + listNota[0].idBisnis.toString());

    if (!mounted) return;

    setState(() {
      this.idUser = idUser;
    });
  }

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
                        'Sedang berjalan',
                        style: descriptionTextGrey12,
                      ),
                      value: 'Sedang berjalan',
                    ),
                    DropdownMenuItem(
                      child: Text(
                        'Pesanan selesai',
                        style: descriptionTextGrey12,
                      ),
                      value: 'Pesanan selesai',
                    )
                  ],
                  onChanged: (value) {
                    if (!mounted) return;
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
                listNota.length == 0
                    ? Text('Belum Ada Pesanan',
                        style: descriptionTextBlack12,
                        textAlign: TextAlign.center)
                    : ListView.builder(
                        itemCount: listNota.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final nota = listNota[index];

                          if (dropDownValue == 'Sedang berjalan') {
                            return Column(
                              children: [
                                buildSedangBerjalan(nota),
                                SizedBox(
                                  height: 20.h,
                                )
                              ],
                            );
                          } else {
                            return Column(
                              children: [
                                buildPesananSelesai(nota),
                                SizedBox(
                                  height: 20.h,
                                )
                              ],
                            );
                          }
                        }),
                // CardSedangBerjalanTemplate(),
                // SizedBox(
                //   height: 20.h,
                // ),
                // CardPesananSelesai()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSedangBerjalan(Nota nota) =>
      CardSedangBerjalanTemplate(nota.id, nota.idBisnis);

  Widget buildPesananSelesai(Nota nota) =>
      CardPesananSelesai(nota.id, nota.idBisnis);
}
