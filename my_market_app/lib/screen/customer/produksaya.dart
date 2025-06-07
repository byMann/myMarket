import 'package:flutter/material.dart';

class ProdukSaya extends StatefulWidget {
  const ProdukSaya({super.key});

  @override
  _ProdukSayaScreenState createState() => _ProdukSayaScreenState();
}

class _ProdukSayaScreenState extends State<ProdukSaya> {

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
