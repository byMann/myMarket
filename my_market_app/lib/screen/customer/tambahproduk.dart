import 'package:flutter/material.dart';

class TambahProduk extends StatefulWidget {
  const TambahProduk({super.key});

  @override
  _TambahProdukScreenState createState() => _TambahProdukScreenState();
}

class _TambahProdukScreenState extends State<TambahProduk> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Produk")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Ini TambahProduk")
          ],
        ),
      ),
    );
  }
}
