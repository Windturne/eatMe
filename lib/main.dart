import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:eatme_mobileapp/business_pages/Beranda/bisberanda_page.dart';
import 'package:eatme_mobileapp/business_pages/Beranda/bisdetailbundle_page.dart';
import 'package:eatme_mobileapp/business_pages/Pendapatan/pendapatan_page.dart';
import 'package:eatme_mobileapp/business_pages/Pesanan/bispesanan_page.dart';
import 'package:eatme_mobileapp/business_pages/Pesanan/bispesananselesai_page.dart';
import 'package:eatme_mobileapp/business_pages/Pesanan/konfirmasipesanan_page.dart';
import 'package:eatme_mobileapp/business_pages/Pesanan/siapdiambil_page.dart';
import 'package:eatme_mobileapp/business_pages/Profil/bisprofil_page.dart';
import 'package:eatme_mobileapp/business_pages/Profil/kontakalamat_page.dart';
import 'package:eatme_mobileapp/business_pages/Profil/profilbisnis_page.dart';
import 'package:eatme_mobileapp/business_pages/Profil/rekeningpendapatan_page.dart';
import 'package:eatme_mobileapp/business_pages/belumvalidasi_page.dart';
import 'package:eatme_mobileapp/business_pages/businessBottomNav.dart';
import 'package:eatme_mobileapp/business_pages/daftarbisnis_page.dart';
import 'package:eatme_mobileapp/cutomer_pages/Beranda/cart_page.dart';
import 'package:eatme_mobileapp/cutomer_pages/Beranda/checkout_page.dart';
import 'package:eatme_mobileapp/cutomer_pages/Beranda/exploredetail_page.dart';
import 'package:eatme_mobileapp/cutomer_pages/Pesanan/komplain_page.dart';
import 'package:eatme_mobileapp/cutomer_pages/Pesanan/pesananTerkonfirmasi_page.dart';
import 'package:eatme_mobileapp/cutomer_pages/Pesanan/pesananSelesai_page.dart';
import 'package:eatme_mobileapp/cutomer_pages/Profil/ewallet_page.dart';
import 'package:eatme_mobileapp/cutomer_pages/Profil/gantipassword_page.dart';
import 'package:eatme_mobileapp/cutomer_pages/Profil/isisaldo_page.dart';
import 'package:eatme_mobileapp/cutomer_pages/Profil/kontak_page.dart';
import 'package:eatme_mobileapp/cutomer_pages/Profil/ubahprofil_page.dart';
import 'package:eatme_mobileapp/cutomer_pages/customerBottomNav.dart';
import 'package:eatme_mobileapp/cutomer_pages/Beranda/explore_page.dart';
import 'package:eatme_mobileapp/cutomer_pages/favorit_page.dart';
import 'package:eatme_mobileapp/cutomer_pages/Pesanan/pesanan_page.dart';
import 'package:eatme_mobileapp/cutomer_pages/Profil/profil_page.dart';
import 'package:eatme_mobileapp/main_pages/lupapassword_page.dart';
import 'package:eatme_mobileapp/main_pages/register_page.dart';
import 'package:eatme_mobileapp/models/bisniskuliner.dart';
import 'package:eatme_mobileapp/models/menus.dart';
import 'package:eatme_mobileapp/models/order.dart';
import 'package:eatme_mobileapp/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_pages/login_page.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

class ArgumentsCheckout {
  List<Orders> listOrder;
  String namaBisnis;

  ArgumentsCheckout(this.listOrder, this.namaBisnis);
}

class ArgumentsPesananTerkonfirmasi {
  List<Orders> listOrder;
  BisnisKuliner bisnis;
  int idNota;

  ArgumentsPesananTerkonfirmasi(this.listOrder, this.bisnis, this.idNota);
}

class ArgumentsPesananSelesai {
  List<Orders> listOrder;
  BisnisKuliner bisnis;
  int idNota;

  ArgumentsPesananSelesai(this.listOrder, this.bisnis, this.idNota);
}

class ArgumentsProfile {
  BisnisKuliner objBisnisKuliner;
  VoidCallback init;

  ArgumentsProfile(this.objBisnisKuliner, this.init);
}

class ArgumentsStatusPesanan {
  int idNota;
  int totalHarga;
  String namaUser;
  VoidCallback initBisPesananPage;

  ArgumentsStatusPesanan(
      this.idNota, this.totalHarga, this.namaUser, this.initBisPesananPage);
}

class ArgumentsBisPesananSelesai {
  int idNota;
  int totalHarga;
  String namaUser;

  ArgumentsBisPesananSelesai(this.idNota, this.totalHarga, this.namaUser);
}

class ArgumentsKomplain {
  int idNota;
  String sender;

  ArgumentsKomplain(this.idNota, this.sender);
}

class ArgumentsDetailBundle {
  Menus menu;
  VoidCallback init;

  ArgumentsDetailBundle(this.menu, this.init);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //One Signal Push Notification Initialization
  OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
  OneSignal.shared.setAppId("46dd1a17-7a49-44e2-bbd8-04b1c052b8dc");
  OneSignal.shared.setNotificationWillShowInForegroundHandler(
      (OSNotificationReceivedEvent event) {
    event.complete(event.notification);
  });

  //Awesome Notification Initialization
  AwesomeNotifications().initialize('resource://drawable/notification_icon', [
    // NotificationChannel(
    //   channelKey: 'basic_channel',
    //   channelName: 'Basic Notifications',
    //   defaultColor: lightOrange,
    //   importance: NotificationImportance.High,
    //   channelShowBadge: false,
    //   channelDescription: '',
    // ),
    NotificationChannel(
      channelKey: 'scheduled_notification',
      channelName: 'Scheduled Notifications',
      defaultColor: lightOrange,
      importance: NotificationImportance.High,
      channelShowBadge: false,
      channelDescription: '',
    )
  ]);

  //Cek login state
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var idUser = prefs.getInt('idUser');
  var roleUser = prefs.getBool('roleUser'); //false = customer; true = business
  print('sharedPreferences idUser : ' + idUser.toString());
  print('sharedPreferences roleUser : ' + roleUser.toString());

  final MyApp myApp = MyApp(
    initialRouteParam: idUser == null
        ? '/_LoginPage'
        : roleUser == false
            ? '/_CustomerBottomNav'
            : '/_BusinessBottomNav',
  );

  print('INITIAL ROUTE MYAPP:' + myApp.initialRouteParam);

  await AndroidAlarmManager.initialize();
  //Run App
  runApp(myApp);
}

class MyApp extends StatelessWidget {
  final String initialRouteParam;

  MyApp({this.initialRouteParam});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: () => MaterialApp(
        initialRoute: initialRouteParam,
        // home: LoginPage(),
        routes: <String, WidgetBuilder>{
          '/_LoginPage': (context) => LoginPage(),
          '/_RegisterPage': (context) => RegisterPage(),
          '/_LupaPasswordPage': (context) => LupaPasswordPage(),
          '/_CustomerBottomNav': (context) => CustomerBottomNav(),
          '/_ExplorePage': (context) => ExplorePage(),
          '/_DetailBundlePage': (context) => BisDetailBundlePage(
              ModalRoute.of(context).settings.arguments
                  as ArgumentsDetailBundle),
          '/_PesananPage': (context) => PesananPage(),
          '/_FavoritPage': (context) => FavoritPage(),
          '/_ProfilPage': (context) => ProfilPage(),
          '/_ExploreDetailPage': (context) => ExploreDetailPage(
              ModalRoute.of(context).settings.arguments as BisnisKuliner),
          '/_CartPage': (context) => CartPage(),
          '/_CheckoutPage': (context) => CheckoutPage(
              ModalRoute.of(context).settings.arguments as ArgumentsCheckout),
          '/_PesananTerkonfirmasiPage': (context) => PesananTerkonfirmasiPage(
              ModalRoute.of(context).settings.arguments
                  as ArgumentsPesananTerkonfirmasi),
          '/_PesananSelesaiPage': (context) => PesananSelesaiPage(
              ModalRoute.of(context).settings.arguments
                  as ArgumentsPesananSelesai),
          '/_KomplainPage': (context) => KomplainPage(
              ModalRoute.of(context).settings.arguments as ArgumentsKomplain),
          '/_UbahProfilPage': (context) => UbahProfilPage(),
          '/_GantiPasswordPage': (context) => GantiPasswordPage(),
          '/_EwalletPage': (context) => EwalletPage(),
          '/_IsiSaldoPage': (context) => IsiSaldoPage(
              ModalRoute.of(context).settings.arguments as VoidCallback),
          '/_KontakPage': (context) => KontakPage(),

          //HALAMAN BISNIS
          '/_BelumValidasiPage': (context) => BelumValidasiPage(),
          '/_DaftarBisnisPage': (context) => DaftarBisnisPage(),
          '/_BusinessBottomNav': (context) => BusinessBottomNav(),
          '/_BisBerandaPage': (context) => BisBerandaPage(),
          '/_BisDetailBundlePage': (context) => BisDetailBundlePage(
              ModalRoute.of(context).settings.arguments
                  as ArgumentsDetailBundle),
          '/_BisPesananPage': (context) => BisPesananPage(),
          '/_PendapatanPage': (context) => PendapatanPage(),
          '/_BisProfilPage': (context) => BisProfilPage(),
          '_KonfirmasiPesananPage': (context) => KonfirmasiPesananPage(
              ModalRoute.of(context).settings.arguments
                  as ArgumentsStatusPesanan),
          '_SiapDiambilPage': (context) => SiapDiambilPage(
              ModalRoute.of(context).settings.arguments
                  as ArgumentsStatusPesanan),
          '_BisPesananSelesai': (context) => BisPesananSelesaiPage(
              ModalRoute.of(context).settings.arguments
                  as ArgumentsBisPesananSelesai),
          '_KontakAlamatPage': (context) => KontakAlamatPage(
              ModalRoute.of(context).settings.arguments as BisnisKuliner),
          '_RekeningPendapatan': (context) => RekeningPendapatanPage(
              ModalRoute.of(context).settings.arguments as BisnisKuliner),
          '_ProfilBisnisPage': (context) => ProfilBisnisPage(
              ModalRoute.of(context).settings.arguments as ArgumentsProfile),
        },
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Poppins'),
      ),
      designSize: const Size(414, 896),
      // minTextAdapt: true,
      // splitScreenMode: true,
    );
  }
}
