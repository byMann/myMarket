import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_market_app/class/produk.dart';
import 'package:my_market_app/helper/user_helper.dart';

class ProdukPenjual extends StatefulWidget {
  const ProdukPenjual({super.key});

  @override
  _ProdukPenjualScreenState createState() => _ProdukPenjualScreenState();
}

class _ProdukPenjualScreenState extends State<ProdukPenjual> {
  
  List<Produk> Produks = [];
  String _txtcari = '';

  Future<String> fetchData() async {
    final response = await http.post(
      Uri.parse("https://ubaya.xyz/flutter/160422065/project/listproduct.php"),
      body: {'cari':_txtcari ,'user_id': checkUser()},
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  bacaData() {
    Future<String> data = fetchData();
    data.then((value) {
      Map json = jsonDecode(value);
      if (json['result'] == 'success') {
        for (var item in json['data']) {
          Produk prd = Produk.fromJson(item);
          Produks.add(prd);
        }
      } else {
        Produks.clear();
      }
      setState(() {});
    });
  }

  Widget DaftarProduk(Products) {
    if (Products != null) {
      return ListView.builder(
        itemCount: Products.length,
        itemBuilder: (BuildContext ctxt, int index) {
          // return Text(PopMovs[index].title.toString());
          return Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  // leading: const Icon(Icons.movie, size: 30),
                  leading: Image.network(Products[index].gambar),
                  // title: Text(PopMovs[index].title),
                  title: GestureDetector(
                    child: Text(Produks[index].nama),
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder:
                      //         (context) => DetailPop(movieID: PMs[index].id),
                      //   ),
                      // );
                    },
                  ),
                  // subtitle: Text(PopMovs[index].overview),
                  subtitle: Column(
                    children: [
                      Text(Produks[index].deskripsi),
                      Text("Rp. " + Produks[index].harga.toString()),
                      Text("Stok: " + Produks[index].stok.toString()),
                      // ElevatedButton(
                      //   onPressed: () {
                      //     addCart(PMs[index].id, PMs[index].title);
                      //   },
                      //   child: Text("Add to cart"),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      return const CircularProgressIndicator();
    }
  }

  @override
  void initState() {
    super.initState();
    bacaData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("Produk Saya")),
      body: ListView(
        children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(
              icon: Icon(Icons.search),
              labelText: 'Mencari Produk:',
            ),
            onFieldSubmitted: (value) {
              _txtcari = value;
              Produks.clear();
              bacaData();
            },
          ),
          Container(
            height: MediaQuery.of(context).size.height - 200,
            child:
                Produks.length > 0
                    ? DaftarProduk(Produks)
                    : Text('tidak ada data'),
          ),
        ],
      ),
    );
  }
}
