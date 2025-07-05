import 'package:flutter/material.dart';
import 'package:my_market_app/helper/user_helper.dart';
import 'package:my_market_app/screen/daftarchat.dart';
import 'package:my_market_app/screen/penjual/akunpenjual.dart';
import 'package:my_market_app/screen/penjual/produkpenjual.dart';

class HomePenjual extends StatefulWidget {
  const HomePenjual({super.key});

  @override
  State<HomePenjual> createState() => _HomePenjualState();
}

class _HomePenjualState extends State<HomePenjual> {
  int _currentIndex = 0;
  String _emailuser = "";

  final List<Widget> _screens = [ProdukPenjual(), Daftarchat(), AkunPenjual()];

  final List<String> _titles = ["Produk Saya", "Chat", "Akun"];

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void loadUserData() async {
    _emailuser = await getUserEmail();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_currentIndex])),
      drawer: _buildDrawer(context),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: "Produk",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Akun"),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "tambahproduk");
        },
        backgroundColor: Colors.purple,
        child: Icon(Icons.add),
        foregroundColor: Colors.white,
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(_emailuser),
            accountEmail: Text('Role: Penjual'),
            // currentAccountPicture: CircleAvatar(
            //   backgroundImage: NetworkImage("https://i.pravatar.cc/150"),
            // ),
          ),
          ExpansionTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            children: [
              ListTile(
                title: Text('Account Information'),
                onTap: () {
                  Navigator.pushNamed(context, 'info-akun');
                },
              ),
              ListTile(
                title: Text('Change Password'),
                onTap: () {
                  Navigator.pushNamed(context, 'change-password');
                },
              ),
            ],
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text("Logout"),
            onTap: () async {
              await clearSession();
              Navigator.pushReplacementNamed(context, 'login');
            },
          ),
        ],
      ),
    );
  }
}
