import 'package:flutter/material.dart';
import 'package:my_market_app/helper/cart.dart';
import 'package:my_market_app/class/produk.dart';
import 'package:my_market_app/helper/user_helper.dart';
import 'package:my_market_app/screen/pembeli/akuncust.dart';
import 'package:my_market_app/screen/daftarchat.dart';
import 'package:my_market_app/screen/pembeli/detailproduk.dart';
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
  List<Map<String, dynamic>> kategoris = [];
  String? selectedKategoriId;
  String _emailuser = "";

  List<Produk> Ps = [];
  final dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    baca_data();
    loadKategori();
    loadUserData();

  }

  void loadUserData() async {
    _emailuser = await getUserEmail();
    setState(() {});
  }

  void loadKategori() async {
    final response = await http.get(
      Uri.parse("https://ubaya.xyz/flutter/160422065/project/listcategory.php"),
    );
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        setState(() {
          kategoris = List<Map<String, dynamic>>.from(json['data']);
          if (kategoris.isNotEmpty) {
            selectedKategoriId = kategoris[0]['id'].toString();
          }
          baca_data();
        });
      }
    }
  }

  void baca_data() async {
    try {
      final response = await http.post(
        Uri.parse(
          "https://ubaya.xyz/flutter/160422065/project/listproduct.php",
        ),
        body: {'kategori_id': selectedKategoriId ?? '0'},
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

  void addCart(int produkId, String nama, int harga) async {
    try {
      final response = await http.post(
        Uri.parse("https://ubaya.xyz/flutter/160422065/project/cekstok.php"),
        body: {'produk_id': produkId.toString()},
      );

      final json = jsonDecode(response.body);
      print("DEBUG response JSON: $json");

      if (json['result'] == 'success') {
        int stokTersedia = int.parse(json['stok'].toString());
        var existingItem = await dbHelper.getCartItem(produkId);
        int jumlahLokal =
            int.tryParse(existingItem?['jumlah'].toString() ?? '0') ?? 0;

        if (jumlahLokal < stokTersedia) {
          Map<String, dynamic> row = {
            'produk_id': produkId,
            'nama': nama,
            'jumlah': 1,
            'harga': harga,
          };
          await dbHelper.addCart(row);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sukses menambah produk')),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Stok tidak mencukupi')));
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Produk tidak ditemukan')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi error: $e')));
    }
  }

  Widget buildListProduk() {
    return ListView(
      padding: const EdgeInsets.all(10),
      children: [
        Text("Filter berdasarkan kategori:"),
        DropdownButton<String>(
          value: selectedKategoriId,
          hint: Text("Pilih Kategori"),
          isExpanded: true,
          items:
              kategoris.map((kat) {
                return DropdownMenuItem<String>(
                  value: kat['id'].toString(),
                  child: Text(kat['nama']),
                );
              }).toList(),
          onChanged: (newVal) {
            setState(() {
              selectedKategoriId = newVal;
            });
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
                    leading: Image.network(
                      'https://ubaya.xyz/flutter/160422065/project/images/produk/${produk.id}.jpg',
                      height: 200,
                    ),
                    // : const Icon(Icons.shopping_bag),
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
                            onPressed:
                                () => addCart(
                                  produk.id,
                                  produk.nama,
                                  produk.harga,
                                ),
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
      const Daftarchat(),
      const AkunCust(),
    ];

    final List<String> _titles = ["Beranda", "Chat", "Akun"];

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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Akun"),
        ],
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(_emailuser),
            accountEmail: Text('Role: Pembeli'),
            // currentAccountPicture: CircleAvatar(
            //   backgroundImage: NetworkImage("https://i.pravatar.cc/150"),
            // ),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text("Cart"),
            onTap: () => Navigator.pushNamed(context, "cart"),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
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
