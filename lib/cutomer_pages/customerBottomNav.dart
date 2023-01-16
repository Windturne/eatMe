import 'package:eatme_mobileapp/cutomer_pages/Beranda/explore_page.dart';
import 'package:eatme_mobileapp/cutomer_pages/favorit_page.dart';
import 'package:eatme_mobileapp/cutomer_pages/Pesanan/pesanan_page.dart';
import 'package:eatme_mobileapp/cutomer_pages/Profil/profil_page.dart';
import 'package:eatme_mobileapp/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomerBottomNav extends StatefulWidget {
  @override
  _CustomerBottomNavState createState() => _CustomerBottomNavState();
}

class _CustomerBottomNavState extends State<CustomerBottomNav> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    ExplorePage(),
    PesananPage(),
    FavoritPage(),
    ProfilPage(),
  ];

  void onTappedBar(int index) {
    if (!mounted) return;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: _children[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          onTap: onTappedBar,
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: lightOrange,
          selectedFontSize: 14.sp,
          unselectedFontSize: 12.sp,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
            BottomNavigationBarItem(
                icon: Icon(Icons.description), label: 'Pesanan'),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite), label: 'Favorit'),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_circle), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}
