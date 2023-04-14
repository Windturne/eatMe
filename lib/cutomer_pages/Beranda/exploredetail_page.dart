import 'dart:convert';

import 'package:eatme_mobileapp/api/favorite_api.dart';
import 'package:eatme_mobileapp/api/menu_api.dart';
import 'package:eatme_mobileapp/appGlobalConfig.dart';
import 'package:eatme_mobileapp/cutomer_pages/Beranda/cart_page.dart';
import 'package:eatme_mobileapp/models/bisniskuliner.dart';
import 'package:eatme_mobileapp/models/favorite.dart';
import 'package:eatme_mobileapp/models/menus.dart';
import 'package:eatme_mobileapp/template/Cards/cardmenu_template.dart';
import 'package:eatme_mobileapp/template/Buttons/iconbutton_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:badges/badges.dart' as badges;

import '../../theme.dart';

class ExploreDetailPage extends StatefulWidget {
  @override
  _ExploreDetailPageState createState() => _ExploreDetailPageState();

  final BisnisKuliner bisnisKuliner;
  const ExploreDetailPage(this.bisnisKuliner);
}

class _ExploreDetailPageState extends State<ExploreDetailPage> {
  List<Menus> menus = [];
  List<Favorite> listFavorite = [];
  bool toggle = false;
  int idUser;
  int cartLength;

  @override
  void initState() {
    super.initState();

    init();
  }

  Future init() async {
    print('[INIT] ExploreDetail Page');
    final menus = await MenusApi.getMenusForCustomer(widget.bisnisKuliner.id);
    final favorite = await FavoriteApi.getFavorite();

    //Get User ID
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('idUser');

    //Get cart length
    final length = prefs.getInt('cartLength');

    //Cek tombol favorite nyala/tidak
    final userFavorite = await FavoriteApi.getFavoriteByIdBisnisAndUser(
        widget.bisnisKuliner.id, id);

    if (userFavorite.length != 0) {
      setState(() {
        this.toggle = true;
      });
    } else {
      setState(() {
        this.toggle = false;
      });
    }

    if (!mounted) return;

    setState(() {
      this.menus = menus;
      this.listFavorite = favorite;
      this.idUser = id;
      this.cartLength = length;
    });
  }

  void backButtonPressed() {
    Navigator.pop(context);
  }

  void cartPressed() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => CartPage()));
    // print("idBisnisKuliner = " + widget.idBisnisKuliner.toString());
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
                  IconButtonTemplate(black, Icons.arrow_back,
                      onPressed: backButtonPressed),
                  SizedBox(
                    height: 23.h,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.bisnisKuliner.fotoProfil == null
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
                                    widget.bisnisKuliner.fotoProfil,
                                width: 100.w,
                                height: 100.h,
                                fit: BoxFit.cover,
                              ),
                            ),
                      SizedBox(
                        width: 15.w,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppGlobalConfig.titleCase(
                                widget.bisnisKuliner.namaBisnis),
                            style: titlePage,
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.place_outlined,
                                size: 14,
                                color: darkGrey,
                              ),
                              SizedBox(
                                width: 3.w,
                              ),
                              Container(
                                // color: darkGrey,
                                width: 160.w,
                                child: Text(
                                  widget.bisnisKuliner.alamatBisnis,
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
                                Icons.phone_outlined,
                                size: 14,
                                color: darkGrey,
                              ),
                              SizedBox(
                                width: 3.w,
                              ),
                              Text(
                                widget.bisnisKuliner.noTelp ?? 'telpNull',
                                style: descriptionTextGrey12,
                              ),
                            ],
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
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: darkOrange,
                                    size: 12,
                                    // textDirection: TextDirection.ltr,
                                  ),
                                  SizedBox(
                                    width: 2.w,
                                  ),
                                  Text(
                                    widget.bisnisKuliner.ratingBisnis
                                                .toString() ==
                                            null
                                        ? '0.0'
                                        : widget.bisnisKuliner.ratingBisnis
                                            .toStringAsFixed(1),
                                    style: descriptionTextGrey12,
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () => cartPressed(),
                            child: badges.Badge(
                              badgeContent: Text(
                                cartLength.toString(),
                                style: TextStyle(color: white),
                              ),
                              child: Icon(Icons.shopping_bag_outlined),
                            ),
                          ),
                          SizedBox(
                            height: 50.h,
                          ),
                          // IconButtonTemplate(
                          //     darkOrange, Icons.favorite_border_outlined,
                          //     onPressed: favoritPressed)
                          TextButton.icon(
                            icon: toggle == true
                                ? Icon(
                                    Icons.favorite,
                                    color: darkOrange,
                                    size: 24,
                                  )
                                : Icon(
                                    Icons.favorite_outline,
                                    color: darkOrange,
                                    size: 24,
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
                                final favorites =
                                    await FavoriteApi.getFavorite();
                                int idFavorite;
                                for (int i = 0; i < favorites.length; i++) {
                                  if (favorites[i].idBisnisKuliner ==
                                          widget.bisnisKuliner.id &&
                                      favorites[i].idUser == idUser) {
                                    idFavorite = favorites[i].id;
                                  }
                                }

                                print('ID FAVORIT: ' + idFavorite.toString());

                                //Delete ID Favorite dari database
                                String urlApiFavorite =
                                    AppGlobalConfig.getUrlApi() +
                                        'favorite/' +
                                        idFavorite.toString();
                                var response = await http
                                    .delete(Uri.parse(urlApiFavorite));
                                if (!mounted) return;

                                setState(() {
                                  this.toggle = !this.toggle;
                                });

                                return json.decode(response.body);
                              } else if (toggle == false) {
                                //Favorite
                                print(toggle);
                                print("FAVORITE");
                                print("ID USER:" + idUser.toString());
                                print("ID BISNIS:" +
                                    widget.bisnisKuliner.id.toString());

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
                                      'id_bisnis_kuliner':
                                          widget.bisnisKuliner.id
                                    }));
                                print(response.body);
                                if (!mounted) return;
                                setState(() {
                                  this.toggle = !this.toggle;
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
                      )
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
                    'Jam Pengambilan Hari Ini',
                    style: descriptionTextBlack12,
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                      ),
                      SizedBox(
                        width: 5.w,
                      ),
                      Text(
                        DateFormat('h:mma').format(DateTime.parse(
                                widget.bisnisKuliner.jamAmbilAwal)) +
                            ' - ' +
                            DateFormat('h:mma').format(DateTime.parse(
                                widget.bisnisKuliner.jamAmbilAkhir)),
                        style: descriptionTextBlack12,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30.h,
                  ),
                  if (menus?.length == 0 &&
                      widget.bisnisKuliner?.statusBisnis == 1) ...[
                    Text(
                      'Tidak ada menu',
                      style: descriptionTextBlack12,
                    )
                  ] else if (widget.bisnisKuliner?.statusBisnis == 0) ...[
                    Text(
                      'Bisnis Kuliner Tutup',
                      style: descriptionTextBlack12,
                    )
                  ] else ...[
                    ListView.builder(
                        itemCount: menus.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          print(menus.length);
                          final menu = menus[index];

                          // return Text(bisniskuliner.namaBisnis);
                          return Column(
                            children: [
                              buildMenus(menu),
                              SizedBox(
                                height: 20.h,
                              )
                            ],
                          );
                        }),
                  ]
                ],
              )),
        ),
      ),
    );
  }

  Widget buildMenus(Menus menu) =>
      CardMenuTemplate(menu, widget.bisnisKuliner.namaBisnis, init);
}
