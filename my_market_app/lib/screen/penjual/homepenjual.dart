import 'package:flutter/material.dart';
import 'package:my_market_app/screen/penjual/akunpenjual.dart';
import 'package:my_market_app/screen/penjual/chatpenjual.dart';
import 'package:my_market_app/screen/penjual/kategoripenjual.dart';
import 'package:my_market_app/screen/penjual/produkpenjual.dart';
import 'package:my_market_app/screen/penjual/tambahproduk.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePenjual extends StatefulWidget {
  const HomePenjual({super.key});

  @override
  State<HomePenjual> createState() => _HomePenjualState();
}

class _HomePenjualState extends State<HomePenjual> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    ProdukPenjual(),
    KategoriPenjual(),
    AkunPenjual(),
    ChatPenjual(),
    TambahProduk()
  ];

  final List<String> _titles = ["Produk Saya", "Kategori", "Akun", "Chat", "Tambah Produk"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_currentIndex])),
      drawer: _buildDrawer(context),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: "Produk",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: "Kategori",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Akun"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
        ],
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.deepPurple),
            child: Text(
              'Penjual',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            title: Text("Tambah Produk"),
            onTap: () => Navigator.pushNamed(context, "tambahproduk"),
          ),
          ListTile(
            title: Text("Chat"),
            onTap: () => Navigator.pushNamed(context, "chatpenjual"),
          ),
          ListTile(title: Text("Logout"), onTap: () => doLogout()),
        ],
      ),
    );
  }

  void doLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, 'login');
  }
}
