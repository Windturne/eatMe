import 'dart:convert';

import 'package:eatme_mobileapp/api/favorite_api.dart';
import 'package:eatme_mobileapp/cutomer_pages/Beranda/exploredetail_page.dart';
import 'package:eatme_mobileapp/models/bisniskuliner.dart';
import 'package:eatme_mobileapp/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../appGlobalConfig.dart';

// ignore: must_be_immutable
class CardFavoritTemplate extends StatefulWidget {
  BisnisKuliner objBisnisKuliner;
  final VoidCallback initFavoritPage;

  @override
  _CardFavoritTemplateState createState() =>
      _CardFavoritTemplateState(this.objBisnisKuliner);

  CardFavoritTemplate(this.objBisnisKuliner, this.initFavoritPage);
}

class _CardFavoritTemplateState extends State<CardFavoritTemplate> {
  BisnisKuliner objBisnisKuliner;

  int idFavorite;

  _CardFavoritTemplateState(this.objBisnisKuliner);

  // @override
  // void initState() {
  //   super.initState();

  //   init();
  // }

  // Future init() async {
  //   print('[INIT] Card Favorit Page');

  //   if (!mounted) return;

  //   setState(() {});
  // }

  void deletePressed() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                'Hapus Restoran Favorit',
                style: titlePage,
                textAlign: TextAlign.center,
              ),
              content: Text(
                'Apakah anda yakin ingin menghapus restoran ' +
                    this.objBisnisKuliner.namaBisnis +
                    '?',
                style: descriptionTextBlack12,
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'TIDAK',
                      style: titleCard,
                    )),
                TextButton(
                    onPressed: () async {
                      //Loading setelah tekan tombol
                      // ProgressDialog progressDialog = ProgressDialog(context);
                      // progressDialog.style(message: 'Loading...');
                      // progressDialog.show();
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      var idUser = prefs.getInt('idUser');
                      //Ambil ID Favorite dengan ID bisnis & ID user
                      final favorites = await FavoriteApi.getFavorite();
                      for (int i = 0; i < favorites.length; i++) {
                        if (favorites[i].idBisnisKuliner ==
                                objBisnisKuliner.id &&
                            favorites[i].idUser == idUser) {
                          this.idFavorite = favorites[i].id;
                        }
                      }

                      print('ID FAVORIT: ' + this.idFavorite.toString());

                      //Delete ID Favorite dari database
                      String urlApiFavorite = AppGlobalConfig.getUrlApi() +
                          'favorite/' +
                          this.idFavorite.toString();
                      var response =
                          await http.delete(Uri.parse(urlApiFavorite));

                      // progressDialog.hide();
                      // int count = 0;
                      // Navigator.of(context).popUntil((_) => count++ >= 1);
                      Navigator.pop(context);
                      widget.initFavoritPage();
                      // Navigator.pushReplacementNamed(context, '/_FavoritPage');
                      return json.decode(response.body);
                    },
                    child: Text(
                      'YA',
                      style: descriptionTextOrangeMedium12,
                    ))
              ],
            ));
  }

  void cardPressed() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ExploreDetailPage(objBisnisKuliner)));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: cardPressed,
      child: Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        elevation: 5,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              this.objBisnisKuliner.fotoProfil == null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(5.r),
                      child: Image.asset(
                        'assets/images/business.jpg',
                        height: 91.h,
                        width: 91.w,
                        fit: BoxFit.cover,
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(5.r),
                      child: Image.network(
                        AppGlobalConfig.getUrlStorage() +
                            this.objBisnisKuliner.fotoProfil,
                        height: 91.h,
                        width: 91.w,
                        fit: BoxFit.cover,
                      ),
                    ),
              SizedBox(
                width: 15.w,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          objBisnisKuliner.namaBisnis ?? 'namaBisnisNull',
                          style: titleCard,
                        ),
                        SizedBox(
                          width: 43.w,
                        ),
                        Spacer(),
                        TextButton.icon(
                          icon: Icon(
                            Icons.delete_outline,
                            color: darkOrange,
                            size: 20,
                          ),
                          label: Text(''),
                          onPressed: deletePressed,
                          style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    Text(
                      objBisnisKuliner.kategoriMakanan ?? 'kategoriNull',
                      style: descriptionTextGrey12,
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    Container(
                      height: 25.h,
                      width: 42.w,
                      decoration: BoxDecoration(
                          border: Border.all(color: lightGrey),
                          borderRadius: BorderRadius.circular(5.r)),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 2.h, horizontal: 2.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.star,
                              size: 12,
                              color: darkOrange,
                              textDirection: TextDirection.ltr,
                            ),
                            SizedBox(
                              width: 2.w,
                            ),
                            Text(
                              objBisnisKuliner.ratingBisnis != null
                                  ? objBisnisKuliner.ratingBisnis
                                      .toStringAsFixed(1)
                                  : '0.0',
                              style: descriptionTextGrey12,
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    //Alamat
                    Row(
                      children: [
                        Icon(
                          Icons.place_outlined,
                          size: 12,
                          color: darkGrey,
                        ),
                        SizedBox(
                          width: 1.w,
                        ),
                        Text(
                          objBisnisKuliner.alamatBisnis ?? 'alamatNull',
                          style: descriptionTextGrey10,
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
