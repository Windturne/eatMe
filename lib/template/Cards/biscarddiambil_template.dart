import 'package:eatme_mobileapp/api/nota_api.dart';
import 'package:eatme_mobileapp/api/user_api.dart';
import 'package:eatme_mobileapp/business_pages/Pesanan/siapdiambil_page.dart';
import 'package:eatme_mobileapp/main.dart';
import 'package:eatme_mobileapp/models/nota.dart';
import 'package:eatme_mobileapp/template/Buttons/textbutton_template.dart';
import 'package:flutter/material.dart';
import 'package:eatme_mobileapp/theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class BisCardDiambil extends StatefulWidget {
  int idNota;
  int idUser;
  int totalItem;
  int totalHarga;
  final VoidCallback initBisPesananPage;

  @override
  _BisCardDiambilState createState() => _BisCardDiambilState(
      this.idNota, this.idUser, this.totalItem, this.totalHarga);
  BisCardDiambil(this.idNota, this.idUser, this.totalItem, this.totalHarga,
      this.initBisPesananPage);
}

class _BisCardDiambilState extends State<BisCardDiambil> {
  int idNota;
  int idUser;
  int totalItem;
  int totalHarga;
  String namaUser;
  Nota nota;

  _BisCardDiambilState(
      this.idNota, this.idUser, this.totalItem, this.totalHarga);

  TextEditingController pinController = TextEditingController();
  double ratingStars = 0;

  @override
  void initState() {
    super.initState();

    init();
  }

  Future init() async {
    print('[INIT] BisCardDiambil Page');

    final user = await UserApi.getUserById(idUser);
    final namaUser = user[0].name;

    final nota = await NotaApi.getNotaByIdNota(idNota);

    if (!mounted) return;

    setState(() {
      this.namaUser = namaUser;
      this.nota = nota[0];
    });
  }

  void lihatDetailPressed() {
    var argumentsPassed = new ArgumentsStatusPesanan(
        widget.idNota, totalHarga, namaUser, widget.initBisPesananPage);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SiapDiambilPage(argumentsPassed)));
  }

  // void selesaiPressed() {
  //   showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //             title: Text(
  //               'Selesaikan Pesanan',
  //               style: titlePage,
  //               textAlign: TextAlign.center,
  //             ),
  //             content: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Text(
  //                   'Masukkan PIN pengambilan',
  //                   style: descriptionTextBlack14,
  //                   textAlign: TextAlign.center,
  //                 ),
  //                 SizedBox(
  //                   height: 20.h,
  //                 ),
  //                 PinCodeFields(
  //                   length: 5,
  //                   controller: pinController,
  //                 )
  //               ],
  //             ),
  //             actions: [
  //               TextButton(
  //                   onPressed: () {
  //                     Navigator.pop(context);
  //                     submitPin();
  //                   },
  //                   child: Text(
  //                     'SUBMIT',
  //                     style: descriptionTextOrangeMedium12,
  //                   ))
  //             ],
  //           ));
  // }

  // Future submitPin() async {
  //   if (pinController.text == nota.pinPengambilan.toString()) {
  //     //Update Status Nota dan tanggal pengambilan
  //     final response = await http.put(
  //         Uri.parse(
  //             AppGlobalConfig.getUrlApi() + 'nota/' + this.idNota.toString()),
  //         body: {
  //           'status_nota': 2.toString(),
  //           'tanggal_pengambilan': DateTime.now().toString()
  //         },
  //         headers: {
  //           'Accept': 'application/json'
  //         });

  //     print(response.body);

  //     await showDialog(
  //         context: context,
  //         builder: (context) => AlertDialog(
  //               title: Text(
  //                 'Transaksi selesai',
  //                 style: titlePage,
  //                 textAlign: TextAlign.center,
  //               ),
  //               content: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Text(
  //                     'NOTA (ID: ' + this.idNota.toString() + ')',
  //                     style: descriptionTextBlack14,
  //                     textAlign: TextAlign.center,
  //                   ),
  //                   SizedBox(
  //                     height: 20.h,
  //                   ),
  //                   Text(
  //                     'Diambil pada:',
  //                     style: descriptionTextBlack12,
  //                   ),
  //                   Text(
  //                     DateFormat('dd-MM-yyyy').format(DateTime.now()) +
  //                         ', ' +
  //                         DateFormat('h:mma').format(DateTime.now()),
  //                     style: descriptionTextBlack12,
  //                   ),
  //                   SizedBox(
  //                     height: 10.h,
  //                   ),
  //                   Text(
  //                     'Silakan beri rating user pada tab "pesanan selesai"',
  //                     style: descriptionTextOrange12,
  //                     textAlign: TextAlign.center,
  //                   )
  //                 ],
  //               ),
  //               actions: [
  //                 TextButton(
  //                     onPressed: () {
  //                       Navigator.pop(context);
  //                       widget.initBisPesananPage();
  //                     },
  //                     child: Text(
  //                       'OK',
  //                       style: descriptionTextOrangeMedium12,
  //                     ))
  //               ],
  //             ));
  //   } else {
  //     showDialog(
  //         context: context,
  //         builder: (context) => AlertDialog(
  //               title: Text(
  //                 'Transaksi Gagal',
  //                 style: titlePage,
  //                 textAlign: TextAlign.center,
  //               ),
  //               content: Text(
  //                 'PIN yang dimasukkan tidak sesuai, mohon di cek kembali',
  //                 style: descriptionTextBlack12,
  //               ),
  //               actions: [
  //                 TextButton(
  //                     onPressed: () {
  //                       Navigator.pop(context);
  //                     },
  //                     child: Text(
  //                       'OK',
  //                       style: titleCard,
  //                     )),
  //               ],
  //             ));
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Card(
        elevation: 5,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                child: Text(
                  '',
                  style: descriptionTextBlack10,
                  textAlign: TextAlign.end,
                ),
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'NOTA (ID: ' + idNota.toString() + ')',
                            style: titleCard,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                      Text(
                        namaUser ?? 'namaUserNull',
                        style: descriptionTextBlack12,
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                      Text(
                        totalItem.toString() + ' item(s)',
                        style: descriptionTextBlack12,
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      TextButtonTemplate('Lihat detail', lightOrange,
                          onPressed: lihatDetailPressed)
                    ],
                  ),
                  Spacer(),
                  // SizedBox(
                  //   width: 100.w,
                  //   child: ElevatedButton(
                  //       child: Text(
                  //         'SELESAI',
                  //         style: TextStyle(
                  //             fontSize: 12.sp,
                  //             color: white,
                  //             fontWeight: FontWeight.w700),
                  //       ),
                  //       style: ElevatedButton.styleFrom(
                  //           primary: lightOrange,
                  //           shape: RoundedRectangleBorder(
                  //               borderRadius: BorderRadius.circular(20.r)),
                  //           padding: EdgeInsets.symmetric(vertical: 10.h)),
                  //       onPressed: selesaiPressed),
                  // )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
