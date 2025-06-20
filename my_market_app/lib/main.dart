import 'package:flutter/material.dart';
import 'package:my_market_app/screen/pembeli/akuncust.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Auth
import 'package:my_market_app/screen/login.dart';
import 'package:my_market_app/screen/register.dart';

// Pembeli
import 'package:my_market_app/screen/pembeli/homecustomer.dart';
import 'package:my_market_app/screen/pembeli/detailproduk.dart';
import 'package:my_market_app/screen/pembeli/pembelian.dart';
import 'package:my_market_app/screen/pembeli/chatpembeli.dart';

// Penjual
import 'package:my_market_app/screen/penjual/homepenjual.dart';
import 'package:my_market_app/screen/penjual/produkpenjual.dart';
import 'package:my_market_app/screen/penjual/kategoripenjual.dart';
import 'package:my_market_app/screen/penjual/akunpenjual.dart';
import 'package:my_market_app/screen/penjual/chatpenjual.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  bool isLoggedIn = prefs.getBool("is_logged_in") ?? false;
  String role = prefs.getString("role") ?? "";

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
        'pembelian': (context) => const Pembelian(),
        'chatpembeli': (context) => const ChatPembeli(),

        // Penjual
        'homepenjual': (context) => const HomePenjual(),
        'produk_penjual': (context) => const ProdukPenjual(),
        'kategori_penjual': (context) => const KategoriPenjual(),
        'akunpenjual': (context) => const AkunPenjual(),
        'chatpenjual': (context) => const ChatPenjual(),
      },
    );
  }
}
