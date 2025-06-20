import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_market_app/class/produk.dart';
import 'package:my_market_app/screen/penjual/editproduk.dart';
import 'package:intl/intl.dart';

class DetailProduk extends StatefulWidget {
  final int produkID;

  const DetailProduk({super.key, required this.produkID});

  @override
  State<DetailProduk> createState() => _DetailProdukScreenState();
}

class _DetailProdukScreenState extends State<DetailProduk> {
  Produk? _p;

  @override
  void initState() {
    super.initState();
    bacaData();
  }

  Future<void> bacaData() async {
    try {
      final response = await http.post(
        Uri.parse(
          "https://ubaya.xyz/flutter/160422065/project/detailproduct.php",
        ),
        body: {'id': widget.produkID.toString()},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        setState(() {
          _p = Produk.fromJson(json['data']);
        });
      } else {
        throw Exception("Failed to load product");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> deleteData() async {
    final response = await http.post(
      Uri.parse(
        "https://ubaya.xyz/flutter/160422065/project/deleteproduct.php",
      ),
      body: {'id': widget.produkID.toString()},
    );

    if (response.statusCode == 200) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sukses Menghapus Produk')));
      Navigator.pushReplacementNamed(context, 'produk');
    } else {
      throw Exception('Failed to delete product');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Produk")),
      body:
          _p == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_p!.gambar != null && _p!.gambar.isNotEmpty)
                      Image.network(_p!.gambar, height: 200),
                    const SizedBox(height: 10),
                    Text(
                      _p!.nama,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(_p!.deskripsi, style: const TextStyle(fontSize: 16)),
                    Text(
                      NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(_p!.harga),
                      style: const TextStyle(fontSize: 20),
                    ),
                    Text(
                      "Stok : " + _p!.stok.toString(),
                      style: const TextStyle(fontSize: 12),
                    ),

                    const SizedBox(height: 10),
                    const Text("Kategori:", style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 5),
                    if (_p!.kategori != null && _p!.kategori!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            _p!.kategori!.map<Widget>((kat) {
                              return Text("- ${kat['nama']}");
                            }).toList(),
                      )
                    else
                      const Text("Belum ada kategori"),
                    const SizedBox(height: 20),
                    // pindah ke penjual
                    // ElevatedButton(
                    //   onPressed: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder:
                    //             (_) => EditProduk(produkID: widget.produkID),
                    //       ),
                    //     );
                    //   },
                    //   child: const Text("Edit"),
                    // ),
                    // const SizedBox(height: 10),
                    // ElevatedButton(
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Colors.red,
                    //   ),
                    //   onPressed: () => deleteData(),
                    //   child: const Text("Hapus Produk"),
                    // ),
                  ],
                ),
              ),
    );
  }
}
