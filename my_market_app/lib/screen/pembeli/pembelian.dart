import 'package:flutter/material.dart';

class Pembelian extends StatefulWidget {
  const Pembelian({super.key});

  @override
  _PembelianScreenState createState() => _PembelianScreenState();
}

class _PembelianScreenState extends State<Pembelian> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pembelian")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Ini Pembelian")
          ],
        ),
      ),
    );
  }
}
