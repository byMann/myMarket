import 'package:flutter/material.dart';

class ProdukPenjual extends StatefulWidget {
  const ProdukPenjual({super.key});

  @override
  _ProdukPenjualScreenState createState() => _ProdukPenjualScreenState();
}

class _ProdukPenjualScreenState extends State<ProdukPenjual> {

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
          children: [
            Text("Ini Produk Saya")
          ],
        ),
      ),
    );
  }
}
