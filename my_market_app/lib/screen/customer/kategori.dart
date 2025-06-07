import 'package:flutter/material.dart';

class Kategori extends StatefulWidget {
  const Kategori({super.key});

  @override
  _KategoriScreenState createState() => _KategoriScreenState();
}

class _KategoriScreenState extends State<Kategori> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kategori")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Ini Kategori")
          ],
        ),
      ),
    );
  }
}
