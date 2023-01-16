import 'package:eatme_mobileapp/api/pendapatan_api.dart';
import 'package:eatme_mobileapp/appGlobalConfig.dart';
import 'package:eatme_mobileapp/models/pendapatan.dart';
import 'package:eatme_mobileapp/template/Cards/biscardpendapatan_template.dart';
import 'package:flutter/material.dart';
import 'package:eatme_mobileapp/theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PendapatanPage extends StatefulWidget {
  @override
  _PendapatanPageState createState() => _PendapatanPageState();
}

class _PendapatanPageState extends State<PendapatanPage> {
  String dropDownValue = 'Perlu konfirmasi';
  DateTime datetime = DateTime.now();
  final DateFormat formatter = DateFormat('dd-MM-yyyy');
  int idBisnis;
  List<Pendapatan> listPendapatan = [];
  int totalPendapatan;

  @override
  void initState() {
    super.initState();

    init();
  }

  Future init() async {
    print('[INIT] Pendapatan Page');

    //Get Bisnis ID
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final idBisnis = prefs.getInt('idBisnisLoggedIn');

    final pendapatan = await PendapatanApi.getPendapatanByTanggal(
        formatter.format(datetime), idBisnis);

    int totalPendapatanTmp = 0;
    if (pendapatan != null) {
      for (int i = 0; i < pendapatan.length; i++) {
        totalPendapatanTmp += pendapatan[i].pendapatanBersih;
      }
    }

    if (!mounted) return;

    setState(() {
      this.listPendapatan = pendapatan;
      this.totalPendapatan = totalPendapatanTmp;
    });
  }

  void calendarPressed() {}

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
                  'Daftar Pendapatan',
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
                                initialDate: datetime,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100))
                            .then((date) {
                          if (date != null) {
                            print('date null');
                            if (!mounted) return;
                            setState(() {
                              listPendapatan = [];
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
                  height: 40,
                ),
                Text(
                  'Total Pendapatan Bersih: Rp ' +
                      AppGlobalConfig.convertToIdr(
                          this.totalPendapatan ?? 0, 2),
                  style: titleCard,
                ),
                SizedBox(
                  height: 5.h,
                ),
                listPendapatan.length == 0
                    ? Text('Belum Ada Pendapatan',
                        style: descriptionTextBlack12,
                        textAlign: TextAlign.center)
                    : ListView.builder(
                        itemCount: listPendapatan.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          print(listPendapatan.length);
                          final pendapatan = listPendapatan[index];

                          // return Text(bisniskuliner.namaBisnis);
                          return Column(
                            children: [
                              buildPendapatan(pendapatan),
                              SizedBox(
                                height: 20.h,
                              )
                            ],
                          );
                        }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPendapatan(Pendapatan pendapatan) => BisCardPendapatanTemplate(
      pendapatan.idNota,
      pendapatan.totalHarga,
      pendapatan.komisi,
      pendapatan.pendapatanBersih,
      pendapatan.tanggalPendapatan);
}
