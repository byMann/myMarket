import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Pembelian extends StatelessWidget {
  final double totalHarga;

  const Pembelian({super.key, required this.totalHarga});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');

    return Scaffold(
      appBar: AppBar(title: const Text('Simulasi Pembayaran')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terima kasih atas pembelian Anda!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Total yang harus dibayar:',
                style: TextStyle(fontSize: 16)),
            Text(
              currencyFormat.format(totalHarga),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Pembayaran Berhasil'),
                      content: const Text('Simulasi pembayaran selesai.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.popUntil(context, (route) => route.isFirst);
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Bayar Sekarang'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
