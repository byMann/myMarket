import 'package:flutter/material.dart';

class DetailProduk extends StatefulWidget {
  const DetailProduk({super.key});

  @override
  _DetailProdukScreenState createState() => _DetailProdukScreenState();
}

class _DetailProdukScreenState extends State<DetailProduk> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("Produk Saya")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text("Ini Detail Produk")],
        ),
      ),
    );
  }
}
