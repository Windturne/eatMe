import 'package:eatme_mobileapp/api/transaksiEwallet_api.dart';
import 'package:eatme_mobileapp/api/user_api.dart';
import 'package:eatme_mobileapp/cutomer_pages/Profil/isisaldo_page.dart';
import 'package:eatme_mobileapp/models/transaksi.dart';
import 'package:eatme_mobileapp/template/Buttons/iconbutton_template.dart';
import 'package:eatme_mobileapp/template/Buttons/textbutton_template.dart';
import 'package:eatme_mobileapp/template/Cards/cardewallet_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../appGlobalConfig.dart';
import '../../theme.dart';

class EwalletPage extends StatefulWidget {
  @override
  _EwalletPageState createState() => _EwalletPageState();
}

class _EwalletPageState extends State<EwalletPage> {
  TextEditingController pwLamaController = new TextEditingController();
  TextEditingController pwBaruController = new TextEditingController();
  TextEditingController konfirmasiPwController = new TextEditingController();
  int saldoEwallet = 0;

  DateTime datetime = DateTime.now();
  final DateFormat formatter = DateFormat('dd-MM-yyyy');
  List<Transaksi> listTransaksi = [];

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

    final user = await UserApi.getUserById(idUser);
    final saldo = user[0].saldoEwallet;

    //Get Transaksi Ewallet
    final transaksi = await TransaksiEwalletApi.getTransaksiByTanggal(
        formatter.format(datetime), idUser);

    if (!mounted) return;

    setState(() {
      this.saldoEwallet = saldo;
      this.listTransaksi = transaksi.reversed.toList();
    });
  }

  void backButtonPressed() {
    Navigator.pop(context);
  }

  void isiSaldoPressed() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => IsiSaldoPage(init)));
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
                    'E-Wallet',
                    style: titlePage,
                  ),
                  SizedBox(
                    height: 40.h,
                  ),
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r)),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 15.h, horizontal: 15.w),
                      child: Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            color: black,
                            size: 20,
                          ),
                          SizedBox(
                            width: 15.w,
                          ),
                          Text(
                            AppGlobalConfig.convertToIdr(this.saldoEwallet, 2),
                            style: titleCard,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  TextButtonTemplate('Isi saldo e-wallet', lightOrange,
                      onPressed: isiSaldoPressed),
                  SizedBox(
                    height: 40.h,
                  ),
                  Text(
                    'Riwayat Transaksi E-Wallet',
                    style: titlePage,
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        datetime == null
                            ? formatter.format(DateTime.now())
                            : formatter.format(datetime),
                        style: descriptionTextBlack14,
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      TextButton.icon(
                        icon: Icon(
                          Icons.calendar_today_outlined,
                          color: black,
                          size: 20,
                        ),
                        label: Text(''),
                        onPressed: () {
                          showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100))
                              .then((date) {
                            if (!mounted) return;
                            if (date != null) {
                              print('date null');
                              if (!mounted) return;
                              setState(() {
                                datetime = date;
                              });
                            }
                            init();
                          });
                        },
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  listTransaksi.length == 0
                      ? Text('Belum Ada Transaksi',
                          style: descriptionTextBlack12,
                          textAlign: TextAlign.center)
                      : ListView.builder(
                          itemCount: listTransaksi.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            print(listTransaksi.length);
                            final transaksi = listTransaksi[index];

                            // return Text(bisniskuliner.namaBisnis);
                            return Column(
                              children: [
                                buildTransaksi(transaksi),
                                SizedBox(
                                  height: 20.h,
                                )
                              ],
                            );
                          }),
                  // CardEwalletTemplate(
                  //     'Top-up saldo', 'Rp 50.000', 'Sedang diproses'),
                  // SizedBox(
                  //   height: 20.h,
                  // ),
                  // CardEwalletTemplate(
                  //     'Top-up saldo', 'Rp 50.000', 'Dana berhasil ditambahkan'),
                  // SizedBox(
                  //   height: 20.h,
                  // ),
                  // CardEwalletTemplate('Pengurangan saldo transaksi',
                  //     'Rp 50.000', 'Mangkokku Rice Bowl'),
                ],
              )),
        ),
      ),
    );
  }

  Widget buildTransaksi(Transaksi transaksi) => CardEwalletTemplate(transaksi);
}
