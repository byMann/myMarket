import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_market_app/class/pembelian.dart';
import 'package:my_market_app/helper/cart.dart';
import 'package:intl/intl.dart';
import 'package:my_market_app/helper/user_helper.dart' as user_helper;
import 'package:url_launcher/url_launcher.dart';

class ListPembelian extends StatefulWidget {
  const ListPembelian({super.key});

  @override
  State<ListPembelian> createState() => _ListPembelianState();
}

class _ListPembelianState extends State<ListPembelian> {
  List<Pembelian> listPembelian = [];

  void loadOrders() async {
    try {
      final idPengguna = await user_helper.getUserId();
      final response = await http.post(
        Uri.parse(
          "https://ubaya.xyz/flutter/160422065/project/listpembelian.php",
        ),
        body: {
          'id_pengguna': idPengguna.toString()
        },
      );
      if (response.statusCode == 200) {
        Map json = jsonDecode(response.body);
        if (json['result'] == 'success') {
          setState(() {
            listPembelian.clear();
            for (var item in json['data']) {
              listPembelian.add(Pembelian.fromJson(item));
            }
          });
        }
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      print("ERROR LAUNCH");
      throw 'Could not launch $url';
    }
  }

  Widget itemPembelian(List<Pembelian> pembelians) {
    return ListView.builder(
      itemCount: pembelians.length,
      itemBuilder: (context, index) {
        final pembelian = pembelians[index];

        return Card(
          margin: const EdgeInsets.all(10),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            child: ListTile(
              title: Text('ID: ${pembelian.id} - Status: ${pembelian.status}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: 'Rp ',
                    decimalDigits: 0,
                  ).format(pembelian.total)),
                  Text('Tanggal: ${pembelian.tanggal}'),
                  if (pembelian.payment_type != null)
                    Text('Metode: ${pembelian.payment_type}'),
                  const SizedBox(height: 8),
                  if (pembelian.status == 'failed')
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Call your createSnapToken() function here
                        print('Create Snap Token for ID ${pembelian.id}');
                      },
                      child: const Text('Ulangi Pembayaran'),
                    ),
                  if (pembelian.status == 'pending')
                    ElevatedButton(
                      onPressed: () async {
                        // TODO: Call your payNow() function here
                        print('Pay Now for ID ${pembelian.id}');
                        await _launchUrl("https://app.sandbox.midtrans.com/snap/v4/redirection/" + pembelian.snap_token!);
                      },
                      child: const Text('Bayar Sekarang'),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("List Pembelian")),
      body: SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        loadOrders();
                      },
                      child: Text("Refresh")
                    )
                  ]
                ),
                SizedBox(height: 18),
                Container(
                  height: 700,
                  child: itemPembelian(listPembelian),
                )
              ],
            )
        ),
      ),
    );
  }
}