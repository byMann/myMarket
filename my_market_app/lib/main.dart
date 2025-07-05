import 'package:flutter/material.dart';
import 'package:my_market_app/helper/user_helper.dart' as user_helper;
import 'package:my_market_app/screen/ChangePass.dart';
import 'package:my_market_app/screen/InfoAkun.dart';
import 'package:my_market_app/screen/pembeli/akuncust.dart';
import 'package:my_market_app/screen/pembeli/viewcart.dart';
import 'package:my_market_app/screen/penjual/tambahproduk.dart';

// Auth
import 'package:my_market_app/screen/login.dart';
import 'package:my_market_app/screen/register.dart';

// Pembeli
import 'package:my_market_app/screen/pembeli/homecustomer.dart';

// Penjual
import 'package:my_market_app/screen/penjual/homepenjual.dart';
import 'package:my_market_app/screen/penjual/produkpenjual.dart';
import 'package:my_market_app/screen/penjual/akunpenjual.dart';

import 'package:my_market_app/screen/daftarchat.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool isLoggedIn = await user_helper.isLoggedIn();
  String role = await user_helper.getUserRole();

  Widget homeWidget;
  if (!isLoggedIn) {
    homeWidget = Login();
  } else if (role == "penjual") {
    homeWidget = const HomePenjual();
  } else {
    homeWidget = const HomeCustomer();
  }

  runApp(MyApp(homeWidget: homeWidget));
}

class MyApp extends StatelessWidget {
  final Widget homeWidget;
  const MyApp({super.key, required this.homeWidget});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'myMarket App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: homeWidget,
      routes: {
        // Auth
        'login': (context) => Login(),
        'register': (context) => const Register(),

        // Pembeli
        'homecustomer': (context) => const HomeCustomer(),
        'akunpembeli': (context) => const AkunCust(),
        'cart': (context) => const ViewCart(),

        // Penjual
        'homepenjual': (context) => const HomePenjual(),
        'produk_penjual': (context) => const ProdukPenjual(),
        'akunpenjual': (context) => const AkunPenjual(),
        'tambahproduk': (context) => const TambahProduk(),

        'daftarchat': (context) => const Daftarchat(),
        'info-akun': (context) => const InfoAkun(),
        'change-password': (context) => const ChangePass(),
      },
    );
  }
}
