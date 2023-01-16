import 'dart:async';

import 'package:eatme_mobileapp/api/bisniskuliner_api.dart';
import 'package:eatme_mobileapp/api/favorite_api.dart';
import 'package:eatme_mobileapp/api/order_api.dart';
import 'package:eatme_mobileapp/api/user_api.dart';
import 'package:eatme_mobileapp/appGlobalConfig.dart';
import 'package:eatme_mobileapp/cutomer_pages/Beranda/cart_page.dart';
import 'package:eatme_mobileapp/models/bisniskuliner.dart';
import 'package:eatme_mobileapp/models/favorite.dart';
import 'package:eatme_mobileapp/notifications.dart';
import 'package:eatme_mobileapp/template/Cards/cardbussiness_template.dart';
import 'package:flutter/material.dart';
import 'package:eatme_mobileapp/theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:badges/badges.dart';
import 'package:http/http.dart' as http;

class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  TextEditingController searchFieldController = new TextEditingController();

  List<BisnisKuliner> listBisnisKuliner = [];
  List<Favorite> listFavorite = [];
  String searchQuery = '';
  Timer debouncer;
  String namaUser = '';
  int idUser = 0;
  int cartLength = 0;
  bool search = true;

  @override
  void initState() {
    super.initState();

    init();
  }

  @override
  void dispose() {
    debouncer?.cancel();
    super.dispose();
  }

  void debounce(
    VoidCallback callback, {
    Duration duration = const Duration(milliseconds: 1000),
  }) {
    if (debouncer != null) {
      debouncer.cancel();
    }

    debouncer = Timer(duration, callback);
  }

  Future init() async {
    print('[INIT] Explore_Page');

    //Get User's Name
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('idUser');
    final nama = prefs.getString('namaUser');

    print('searchQuery: ' + searchQuery);

    final bisniskuliner = await BisnisKulinerApi.getBisnisKuliner(searchQuery);
    final favorite = await FavoriteApi.getFavorite();
    final order = await OrderApi.getOrders(id, 0);

    //Set cart items length
    if (order.length != 0) {
      prefs.setInt('cartLength', order.length);
    } else {
      prefs.setInt('cartLength', 0);
    }

    if (bisniskuliner.length == 0) {
      search = false;
    }

    //Delete all checkout (avoid bugs)
    await OrderApi.getOrders(id, 1).then((value) async {
      if (value.length != 0) {
        for (int i = 0; i < value.length; i++) {
          var response = await http.delete(Uri.parse(
              AppGlobalConfig.getUrlApi() + 'order/' + value[i].id.toString()));
          if (response.statusCode == 200) {
            print('Checkout berhasil dihapus');
          }
        }
      }
    });

    if (!mounted) return;

    setState(() {
      this.listBisnisKuliner = bisniskuliner;
      this.listFavorite = favorite;
      this.idUser = id;
      this.namaUser = nama;
      this.cartLength = order.length;
    });

    //Scheduled Notification if 'makanan_diselamatkan' > 0
    print('idUser:' + this.idUser.toString());
    final users = await UserApi.getUserById(this.idUser);
    print(users[0].name);

    if (users[0].makananDiselamatkan > 0) {
      print('makanan diselamatkan:' + users[0].makananDiselamatkan.toString());
      var notificationSchedule =
          new NotificationWeekAndTime(4, TimeOfDay(hour: 7, minute: 45));
      await savedFoodReminder(notificationSchedule);
    }
  }

  // void filterKategoriPressed() {
  //   print("filter kategori");
  // }

  void cartPressed() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => CartPage()));
  }

  Future searchBisnisKuliner(String searchQuery) async => debounce(() async {
        setState(() {
          this.listBisnisKuliner = [];
          this.search = true;
        });

        final listBisnisKulinerr =
            await BisnisKulinerApi.getBisnisKuliner(searchQuery);

        if (!mounted) return;

        setState(() {
          this.searchQuery = searchQuery;
          this.listBisnisKuliner = listBisnisKulinerr;
        });

        print('List Bisnis Kuliner');
        if (this.listBisnisKuliner.isEmpty) {
        } else {
          print(this.listBisnisKuliner[0].namaBisnis);
        }
      });

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
                Row(
                  children: [
                    Text(
                      "Halo, " + this.namaUser ?? 'Loading...',
                      style: titlePage,
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () => cartPressed(),
                      child: Badge(
                        badgeContent: Text(
                          cartLength.toString(),
                          style: TextStyle(color: white),
                        ),
                        child: Icon(Icons.shopping_bag_outlined),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5.h,
                ),
                Text(
                  "Mau makan apa hari ini? #DibuangSayang",
                  style: descriptionTextGrey12,
                ),
                SizedBox(
                  height: 40.h,
                ),
                buildSearchField(),
                // SizedBox(
                //   height: 10.h,
                // ),
                // OutlinedButtonTemplate(
                //     darkGrey, Icons.filter_alt, 'filter berdasarkan kategori',
                //     onPressed: filterKategoriPressed),
                SizedBox(
                  height: 50.h,
                ),
                // FutureBuilder(
                //   future: getBisnisKuliner(),
                //   builder: (context, snapshot) {
                //     if (snapshot.hasData) {
                //       print('snapshot: ' + snapshot.data);
                //       return ListView.builder(
                //           itemCount: snapshot.data['data'].length,
                //           shrinkWrap: true,
                //           physics: NeverScrollableScrollPhysics(),
                //           itemBuilder: (context, index) {
                //             return Text('Halo');
                //             // if (dataRetrieved[index]['status_validasi'] == 1) {
                //             //   return Text("HALO");
                //             // } else {
                //             //   return null;
                //             // }
                //           });
                //     } else {
                //       return CircularProgressIndicator();
                //     }
                //   },
                // ),

                if (listBisnisKuliner.length != 0) ...[
                  ListView.builder(
                      itemCount: listBisnisKuliner.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        // print('Length bisnis kuliner: ' +
                        //     listBisnisKuliner.length.toString());

                        final bisniskuliner = listBisnisKuliner[index];
                        print('bisniskuliner widget: ' +
                            bisniskuliner.namaBisnis);
                        final favorites = listFavorite;
                        bool toggle = false;

                        for (int i = 0; i < favorites.length; i++) {
                          if (favorites[i].idBisnisKuliner ==
                                  bisniskuliner.id &&
                              favorites[i].idUser == idUser) {
                            toggle = true;
                          }
                        }

                        // print('ID bisnis kuliner (explore page): ' +
                        //     bisniskuliner.id.toString());

                        // return Text(bisniskuliner.namaBisnis);
                        return Column(
                          children: [
                            CardBussinessTemplate(bisniskuliner, toggle),
                            SizedBox(
                              height: 20.h,
                            )
                          ],
                        );
                      })
                ] else if (this.listBisnisKuliner.length == 0 &&
                    this.search == false) ...[
                  Text(
                    'Maaf, tidak ada bisnis kuliner yang buka saat ini',
                    style: descriptionTextBlack12,
                  ),
                ] else ...[
                  Text(
                    'Loading...',
                    style: descriptionTextBlack12,
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget buildBisnisKuliner(BisnisKuliner bisniskuliner, bool toggle) =>
  //     CardBussinessTemplate(bisniskuliner, toggle);

  Widget buildSearchField() => TextField(
        controller: searchFieldController,
        style: TextStyle(
            fontSize: 12.sp, fontWeight: FontWeight.w400, color: black),
        decoration: InputDecoration(
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: lightGrey, width: 1.w)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: lightGrey, width: 1.w)),
            filled: false,
            hintText: 'Cari bisnis kuliner...',
            hintStyle: TextStyle(
                fontSize: 14.sp, fontWeight: FontWeight.w400, color: darkGrey),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 15.w, vertical: 7.h)),
        onChanged: searchBisnisKuliner,
      );
}
