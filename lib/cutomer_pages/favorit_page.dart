import 'package:eatme_mobileapp/api/bisniskuliner_api.dart';
import 'package:eatme_mobileapp/api/favorite_api.dart';
import 'package:eatme_mobileapp/models/bisniskuliner.dart';
import 'package:eatme_mobileapp/models/favorite.dart';
import 'package:eatme_mobileapp/template/Cards/cardfavorit_template.dart';
import 'package:flutter/material.dart';
import 'package:eatme_mobileapp/theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritPage extends StatefulWidget {
  @override
  _FavoritPageState createState() => _FavoritPageState();
}

class _FavoritPageState extends State<FavoritPage> {
  List<BisnisKuliner> listBisnisKulinerFilter = [];
  BisnisKuliner bisnisKulinerObject;
  int idUser;
  int idBisnis;
  // int favoriteCounter = 0;

  @override
  void initState() {
    super.initState();

    init();
  }

  Future init() async {
    final favorites = await FavoriteApi.getFavorite();
    final bisniskuliner = await BisnisKulinerApi.getAllBisnisKuliner();

    //Get User's ID
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final idUserTmp = prefs.getInt('idUser');

    //Masukkan ke list yang ada idUser
    List<Favorite> tmpFav = [];
    for (int i = 0; i < favorites.length; i++) {
      if (favorites[i].idUser == idUserTmp) {
        tmpFav.add(favorites[i]);
      }
    }

    //Filter bisnis kuliner yang ada di list favorit
    List<BisnisKuliner> tmpBisnis = [];
    for (int i = 0; i < tmpFav.length; i++) {
      for (int j = 0; j < bisniskuliner.length; j++) {
        if (tmpFav[i].idBisnisKuliner == bisniskuliner[j].id) {
          tmpBisnis.add(bisniskuliner[j]);
        }
      }
    }

    if (!mounted) return;

    setState(() {
      this.listBisnisKulinerFilter = tmpBisnis;
      this.idUser = idUserTmp;
      // this.favoriteCounter = counter;
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
                  height: 80.h,
                ),
                Text(
                  "Restoran Favorit",
                  style: titlePage,
                ),
                SizedBox(
                  height: 3.h,
                ),
                Text(
                  "Dapatkan notifikasi saat ada penawaran dari restoran",
                  style: descriptionTextBlack12,
                ),
                SizedBox(
                  height: 40.h,
                ),
                this.listBisnisKulinerFilter.length == 0
                    ? Text(
                        'Belum ada bisnis kuliner favorit',
                        style: descriptionTextBlack12,
                      )
                    : ListView.builder(
                        itemCount: this.listBisnisKulinerFilter.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          print('Length list favorite: ' +
                              this.listBisnisKulinerFilter.length.toString());

                          final favorite = listBisnisKulinerFilter[index];

                          return Column(
                            children: [
                              buildFavorite(favorite),
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

  Widget buildFavorite(BisnisKuliner bisniskuliner) =>
      CardFavoritTemplate(bisniskuliner, init);
}
