import 'package:flutter/material.dart';
import 'package:my_market_app/class/cart.dart';
import 'package:my_market_app/class/produk.dart';
import 'package:my_market_app/screen/pembeli/akuncust.dart';
import 'package:my_market_app/screen/pembeli/chatpembeli.dart';
import 'package:my_market_app/screen/pembeli/detailproduk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';


class HomeCustomer extends StatefulWidget {
  const HomeCustomer({super.key});

  @override
  State<HomeCustomer> createState() => _HomeCustomerState();
}

class _HomeCustomerState extends State<HomeCustomer> {
  int _currentIndex = 0;
  String _txtcari = "";
  List<Produk> Ps = [];
  final dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    baca_data();
  }

  void baca_data() async {
    try {
      final response = await http.post(
        Uri.parse(
          "https://ubaya.xyz/flutter/160422065/project/listproduct.php",
        ),
        body: {'cari': _txtcari},
      );
      if (response.statusCode == 200) {
        Map json = jsonDecode(response.body);
        Ps.clear();
        if (json['result'] == 'success') {
          for (var item in json['data']) {
            Ps.add(Produk.fromJson(item));
          }
        }
        setState(() {});
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  void addCart(int produkId, String title) async {
    Map<String, dynamic> row = {
      'produk_id': produkId,
      'title': title,
      'jumlah': 1,
    };
    await dbHelper.addCart(row);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Sukses menambah produk')));
  }

  Widget buildListProduk() {
    return ListView(
      padding: const EdgeInsets.all(10),
      children: [
        TextFormField(
          decoration: const InputDecoration(
            icon: Icon(Icons.search),
            labelText: 'Cari Produk',
          ),
          onFieldSubmitted: (value) {
            _txtcari = value;
            baca_data();
          },
        ),
        const SizedBox(height: 10),
        Ps.isNotEmpty
            ? ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: Ps.length,
              itemBuilder: (context, index) {
                final produk = Ps[index];
                return Card(
                  child: ListTile(
                    leading:
                        produk.gambar != ""
                            ? Image.network(
                              produk.gambar,
                              width: 50,
                              height: 50,
                            )
                            : const Icon(Icons.shopping_bag),
                    title: Text(produk.nama),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(produk.deskripsi),
                        Text(
                          NumberFormat.currency(
                            locale: 'id_ID',
                            symbol: 'Rp ',
                            decimalDigits: 0,
                          ).format(produk.harga),
                          style: const TextStyle(fontSize: 16),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () => addCart(produk.id, produk.nama),
                            child: const Text("Add to Cart"),
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => DetailProduk(produkID: produk.id),
                        ),
                      );
                    },
                  ),
                );
              },
            )
            : const Center(child: Text("Data tidak tersedia")),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      buildListProduk(),
      const ChatPembeli(),
      const AkunCust(),
    ];

    final List<String> _titles = ["Beranda", "Chat", "Akun"];

    return Scaffold(
      appBar: AppBar(title: Text(_titles[_currentIndex])),
      drawer: _buildDrawer(context),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Akun"),
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
              'Customer',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text("Pembelian"),
            onTap: () => Navigator.pushNamed(context, "pembelian"),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () => doLogout(),
          ),
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
