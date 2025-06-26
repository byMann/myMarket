import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_market_app/helper/cart.dart';
import 'package:intl/intl.dart';
import 'package:my_market_app/helper/user_helper.dart' as user_helper;
import 'package:my_market_app/screen/pembeli/pembelian.dart';


class ViewCart extends StatefulWidget {
  const ViewCart({super.key});

  @override
  State<ViewCart> createState() => _ViewCartState();
}

class _ViewCartState extends State<ViewCart> {
  final dbHelper = DatabaseHelper.instance;
  List? _rsCart;
  String? userId;
  Set<int> selectedProdukIds = {};
  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');

  Future<String> _bacaData() async {
    userId = (await user_helper.getUserId())!;

    _rsCart = (await dbHelper.viewCart())!;
    setState(() {});

    if (_rsCart == null) {
      throw Exception('Failed to load data');
    } else {
      return "sukses";
    }
  }

  @override
  void initState() {
    _bacaData();
  }

  Widget _itemCart(index) {
    int produkId = _rsCart?[index]['produk_id'];
    int jumlah = _rsCart?[index]['jumlah'] ?? 0;
    int harga = _rsCart?[index]['harga'] ?? 0;
    int total = jumlah * harga;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CheckboxListTile(
          value: selectedProdukIds.contains(produkId),
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                selectedProdukIds.add(produkId);
              } else {
                selectedProdukIds.remove(produkId);
              }
            });
          },
          title: Text(_rsCart?[index]['nama'] ?? '-'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('jumlah = $jumlah'),
              Text('harga satuan = ${currencyFormat.format(harga)}'),
              Text('total = ${currencyFormat.format(total)}'),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      dbHelper.kurangJumlah(produkId).then((value) => _bacaData());
                    },
                    child: const Text("-"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      dbHelper.tambahJumlah(produkId).then((value) => _bacaData());
                    },
                    child: const Text("+"),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: 300,
              child:
                  _rsCart != null
                      ? ListView.builder(
                        itemCount: _rsCart?.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          return _itemCart(index);
                        },
                      )
                      : Text('keranjang masih kosong'),
            ),
            Text("userId: ${userId.toString()}"),
            ElevatedButton(
              onPressed: () {
                _submit();
              },
              child: Text("Checkout"),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    _rsCart = await dbHelper.viewCart();
    String items = "";

    _rsCart?.forEach((item) {
      int produkId = item['produk_id'];
      if (selectedProdukIds.contains(produkId)) {
        int jumlah = item['jumlah'];
        int harga = item['harga'];
        int totalHarga = jumlah * harga;
        items += "$produkId,$jumlah,$totalHarga|";
      }
    });

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal 1 produk untuk checkout')),
      );
      return;
    }

    final response = await http.post(
      Uri.parse("https://ubaya.xyz/flutter/160422065/project/checkout.php"),
      body: {'user_id': userId, 'items': items},
    );

    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        double _totalHarga = _hitungTotalHargaCheckout();
        dbHelper.emptyCart().then((value) {
          _bacaData();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Pembelian(
                totalHarga: _totalHarga,
              ),
            ),
          );
        });

        dbHelper.emptySelectedCart(selectedProdukIds).then((value) {
          selectedProdukIds.clear();
          _bacaData();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${json['message']}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal terhubung ke server')),
      );
    }
  }
  double _hitungTotalHargaCheckout() {
    double total = 0;
    _rsCart?.forEach((item) {
      if (selectedProdukIds.contains(item['produk_id'])) {
        int jumlah = item['jumlah'] ?? 0;
        int harga = item['harga'] ?? 0;
        print("Produk ID: ${item['produk_id']}");
        print("Jumlah: $jumlah");
        print("Harga: $harga");

        total += jumlah * harga;
        print("Total Sementara: $total");
      }
    });
    return total;
  }

}
