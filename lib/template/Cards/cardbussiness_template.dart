import 'dart:convert';

import 'package:eatme_mobileapp/api/favorite_api.dart';
import 'package:eatme_mobileapp/models/bisniskuliner.dart';
import 'package:eatme_mobileapp/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../appGlobalConfig.dart';

// ignore: must_be_immutable
class CardBussinessTemplate extends StatefulWidget {
  // Function onTap;
  BisnisKuliner bisnisKuliner;
  bool toggle;

  @override
  _CardBussinessTemplateState createState() =>
      _CardBussinessTemplateState(this.bisnisKuliner, this.toggle);

  CardBussinessTemplate(this.bisnisKuliner, this.toggle);
}

class _CardBussinessTemplateState extends State<CardBussinessTemplate> {
  // Function onTap;
  BisnisKuliner bisnisKuliner;
  bool toggle;
  int idFavorite;

  _CardBussinessTemplateState(this.bisnisKuliner, this.toggle);

  cardPressed(BisnisKuliner bisnisKuliner) async {
    print('cardPressed');

    Navigator.pushNamed(context, '/_ExploreDetailPage',
        arguments: bisnisKuliner);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => cardPressed(bisnisKuliner),
      child: Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        elevation: 5,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              this.bisnisKuliner.fotoProfil == null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(5.r),
                      child: Image.asset(
                        'assets/images/business.jpg',
                        width: 100.w,
                        height: 100.h,
                        fit: BoxFit.cover,
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(5.r),
                      child: Image.network(
                        AppGlobalConfig.getUrlStorage() +
                            this.bisnisKuliner.fotoProfil,
                        width: 100.w,
                        height: 100.h,
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
                          this.bisnisKuliner.namaBisnis,
                          style: titleCard,
                        ),
                        Spacer(),
                        TextButton.icon(
                          icon: toggle == true
                              ? Icon(
                                  Icons.favorite,
                                  color: darkOrange,
                                  size: 16,
                                )
                              : Icon(
                                  Icons.favorite_outline,
                                  color: darkOrange,
                                  size: 16,
                                ),
                          label: Text(''),
                          onPressed: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            var idUser = prefs.getInt('idUser');

                            if (toggle == true) {
                              //Unfavorite
                              print("UNFAVORITE");

                              //Ambil ID Favorite dengan ID bisnis & ID user
                              final favorites = await FavoriteApi.getFavorite();
                              for (int i = 0; i < favorites.length; i++) {
                                if (favorites[i].idBisnisKuliner ==
                                        this.bisnisKuliner.id &&
                                    favorites[i].idUser == idUser) {
                                  this.idFavorite = favorites[i].id;
                                }
                              }

                              print(
                                  'ID FAVORIT: ' + this.idFavorite.toString());

                              //Delete ID Favorite dari database
                              String urlApiFavorite =
                                  AppGlobalConfig.getUrlApi() +
                                      'favorite/' +
                                      this.idFavorite.toString();
                              var response =
                                  await http.delete(Uri.parse(urlApiFavorite));

                              if (!mounted) return;
                              setState(() {
                                toggle = !toggle;
                              });

                              return json.decode(response.body);
                            } else {
                              //Favorite
                              print("FAVORITE");
                              print("ID USER:" + idUser.toString());
                              print("ID BISNIS:" +
                                  this.bisnisKuliner.id.toString());

                              //Add bisnis kuliner to database
                              String urlApiFavorite =
                                  AppGlobalConfig.getUrlApi() + 'favorite';
                              final response = await http.post(
                                  Uri.parse(urlApiFavorite),
                                  headers: {
                                    "Content-Type":
                                        "application/json; charset=utf-8",
                                  },
                                  body: json.encode({
                                    'id_user': idUser,
                                    'id_bisnis_kuliner': this.bisnisKuliner.id
                                  }));
                              print(response.body);

                              if (!mounted) return;
                              setState(() {
                                toggle = !toggle;
                              });

                              return json.decode(response.body);
                            }
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
                      height: 5.h,
                    ),
                    Text(
                      this.bisnisKuliner.kategoriMakanan,
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
                              // textDirection: TextDirection.ltr,
                            ),
                            SizedBox(
                              width: 2.w,
                            ),
                            Text(
                              this.bisnisKuliner.ratingBisnis.toString() !=
                                      0.toString()
                                  ? double.parse(this
                                          .bisnisKuliner
                                          .ratingBisnis
                                          .toString())
                                      .toStringAsFixed(1)
                                  : '0.0',
                              style: descriptionTextGrey12,
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    //Alamat & Jam Buka
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.place_outlined,
                          size: 14,
                          color: darkGrey,
                        ),
                        SizedBox(
                          width: 2.w,
                        ),
                        Container(
                          // color: darkGrey,
                          width: 180.w,
                          child: Text(
                            this.bisnisKuliner.alamatBisnis,
                            style: descriptionTextGrey12,
                            maxLines: 2,
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_outlined,
                          size: 14,
                          color: darkGrey,
                        ),
                        SizedBox(
                          width: 2.w,
                        ),
                        Text(
                            DateFormat('hh:mm').format(DateTime.parse(
                                    this.bisnisKuliner.jamAmbilAwal)) +
                                ' - ' +
                                DateFormat('hh:mm').format(DateTime.parse(
                                    this.bisnisKuliner.jamAmbilAkhir)),
                            style: descriptionTextGrey12),
                      ],
                    )
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
