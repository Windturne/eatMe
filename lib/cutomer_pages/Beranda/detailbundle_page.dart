import 'dart:convert';
import 'dart:io';

import 'package:eatme_mobileapp/api/bisniskuliner_api.dart';
import 'package:eatme_mobileapp/api/detailbundle_api.dart';
import 'package:eatme_mobileapp/api/favorite_api.dart';
import 'package:eatme_mobileapp/api/menu_api.dart';
import 'package:eatme_mobileapp/api/pemilikbisniskuliner_api.dart';
import 'package:eatme_mobileapp/api/user_api.dart';
import 'package:eatme_mobileapp/appGlobalConfig.dart';
import 'package:eatme_mobileapp/main.dart';
import 'package:eatme_mobileapp/models/bisniskuliner.dart';
import 'package:eatme_mobileapp/models/detailbundle.dart';
import 'package:eatme_mobileapp/models/menus.dart';
import 'package:eatme_mobileapp/template/Buttons/button_template.dart';
import 'package:eatme_mobileapp/template/Buttons/iconbutton_template.dart';
import 'package:eatme_mobileapp/template/Buttons/textbutton_template.dart';
import 'package:eatme_mobileapp/template/Cards/biscarddetailbundle_template.dart';
import 'package:eatme_mobileapp/template/Cards/biscardmenu_template.dart';
import 'package:eatme_mobileapp/template/Cards/carddetailbundle_template.dart';
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

class DetailBundlePage extends StatefulWidget {
  @override
  State<DetailBundlePage> createState() => _DetailBundlePageState();

  final ArgumentsDetailBundle argumentsPassed;
  const DetailBundlePage(this.argumentsPassed);
}

class _DetailBundlePageState extends State<DetailBundlePage> {
  List<DetailBundle> listDetailBundle = [];
  Menus menu;

  @override
  void initState() {
    super.initState();

    init();
  }

  Future init() async {
    //Ambil detail bundle berdasarkan id menu
    final bundleMenus =
        await DetailBundleApi.getBundleByIdMenu(widget.argumentsPassed.menu.id);

    for (int i = 0; i < bundleMenus.length; i++) {
      print(bundleMenus[i].isiMenu);
    }

    if (!mounted) return;

    setState(() {
      this.listDetailBundle = bundleMenus;
      this.menu = this.widget.argumentsPassed.menu;
    });
  }

  void backButtonPressed() {
    Navigator.pop(context);
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
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 30.h,
                  ),
                  IconButtonTemplate(black, Icons.arrow_back_ios_rounded,
                      onPressed: backButtonPressed),
                  SizedBox(
                    height: 23.h,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      this.widget.argumentsPassed.menu?.fotoMenu?.isEmpty ??
                              true
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(5.r),
                              child: Image.asset(
                                'assets/images/food_placeholder2.png',
                                height: 91.h,
                                width: 91.w,
                                fit: BoxFit.cover,
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(5.r),
                              child: Image.network(
                                AppGlobalConfig.getUrlStorage() +
                                    this.widget.argumentsPassed.menu.fotoMenu,
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
                        width: 20.w,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppGlobalConfig.titleCase(this
                                    .widget
                                    .argumentsPassed
                                    .menu
                                    ?.namaMakanan) ??
                                'namaMakananNull',
                            style: titlePage,
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          Row(
                            children: [
                              Text(
                                AppGlobalConfig.convertToIdr(
                                    this
                                        .widget
                                        .argumentsPassed
                                        .menu
                                        .hargaMakanan,
                                    2),
                                style: descriptionTextOrange12,
                              ),
                              SizedBox(
                                width: 10.w,
                              ),
                              Text(
                                AppGlobalConfig.convertToIdr(
                                    this
                                        .widget
                                        .argumentsPassed
                                        .menu
                                        .hargaSebelumDiskon,
                                    2),
                                style: strikeTroughText,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          Text(
                            this
                                    .widget
                                    .argumentsPassed
                                    .menu
                                    ?.deskripsiMakanan ??
                                'Tidak ada deskripsi',
                            style: descriptionTextGrey12,
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
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
                    'Item Bundle',
                    style: descriptionTextBlack14,
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  if (this.listDetailBundle?.length == 0) ...[
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
                            'Belum ada item bundle',
                            style: descriptionTextBlack12,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  ] else ...[
                    ListView.builder(
                        itemCount: this.listDetailBundle.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          print('listDetailBundle: ' +
                              this.listDetailBundle.length.toString());
                          final itemBundle = this.listDetailBundle[index];

                          print('itemBundle: ${itemBundle.isiMenu}');

                          // return Text(bisniskuliner.namaBisnis);
                          return Column(
                            children: [
                              buildBundle(this.widget.argumentsPassed.menu, itemBundle),
                              SizedBox(
                                height: 20.h,
                              )
                            ],
                          );
                        }),
                  ],
                ],
              )),
        ),
      ),
    );
  }

  Widget buildBundle( Menus menu, DetailBundle bundle) =>
      CardDetailBundleTemplate(menu, bundle, init);
}
