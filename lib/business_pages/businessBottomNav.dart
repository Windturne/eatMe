import 'package:eatme_mobileapp/business_pages/Beranda/bisberanda_page.dart';
import 'package:eatme_mobileapp/business_pages/Pendapatan/pendapatan_page.dart';
import 'package:eatme_mobileapp/business_pages/Pesanan/bispesanan_page.dart';
import 'package:eatme_mobileapp/business_pages/Profil/bisprofil_page.dart';
import 'package:eatme_mobileapp/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BusinessBottomNav extends StatefulWidget {
  @override
  _BusinessBottomNavState createState() => _BusinessBottomNavState();
}

class _BusinessBottomNavState extends State<BusinessBottomNav> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    BisBerandaPage(),
    BisPesananPage(),
    PendapatanPage(),
    BisProfilPage(),
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
                icon: Icon(Icons.attach_money), label: 'Pendapatan'),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_circle), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}
