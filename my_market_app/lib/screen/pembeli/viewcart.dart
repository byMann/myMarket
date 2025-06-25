import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_market_app/helper/cart.dart';
import 'package:my_market_app/helper/user_helper.dart';
import 'package:intl/intl.dart';
import 'package:my_market_app/helper/user_helper.dart' as user_helper;


class ViewCart extends StatefulWidget {
  const ViewCart({super.key});

  @override
  State<ViewCart> createState() => _ViewCartState();
}

class _ViewCartState extends State<ViewCart> {
  final dbHelper = DatabaseHelper.instance;
  List? _rsCart;

  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');

  Future<String> _bacaData() async {
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
    int jumlah = _rsCart?[index]['jumlah'] ?? 0;
    int harga = _rsCart?[index]['harga'] ?? 0;
    int total = jumlah * harga;

    return Column(
      children: <Widget>[
        Text(_rsCart?[index]['nama'] ?? '-'),
        Text('jumlah = $jumlah'),
        Text('harga satuan = ${currencyFormat.format(harga)}'),
        Text('total = ${currencyFormat.format(total)}'),
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                dbHelper
                    .kurangJumlah(_rsCart?[index]['produk_id'])
                    .then((value) => _bacaData());
              },
              child: Text("-"),
            ),
            ElevatedButton(
              onPressed: () {
                dbHelper
                    .tambahJumlah(_rsCart?[index]['produk_id'])
                    .then((value) => _bacaData());
              },
              child: Text("+"),
            ),
          ],
        ),
        Divider(),
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
      int jumlah = item['jumlah'];
      int harga = item['harga']; 

      int totalHarga = jumlah * harga;

      items += "$produkId,$jumlah,$totalHarga|";
    });

    String activeUser = await user_helper.getUserId(); // return user_id

    final response = await http.post(
      Uri.parse("https://ubaya.xyz/flutter/160422065/project/checkout.php"),
      body: {'user_id': activeUser, 'items': items},
    );

    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Sukses Checkout')));
        dbHelper.emptyCart().then((value) => _bacaData());
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${json['message']}')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal terhubung ke server')),
      );
    }
  }
}
