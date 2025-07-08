import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_market_app/helper/cart.dart';
import 'package:intl/intl.dart';
import 'package:my_market_app/helper/user_helper.dart' as user_helper;
import 'package:my_market_app/screen/pembeli/list-pembelian.dart';
import 'package:my_market_app/screen/pembeli/pembelian.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';


class ViewCart extends StatefulWidget {
  const ViewCart({super.key});

  @override
  State<ViewCart> createState() => _ViewCartState();
}

class _ViewCartState extends State<ViewCart> {
  final dbHelper = DatabaseHelper.instance;
  List? _rsCart;
  String? userId;
  Set<int> selectedProdukIds = {};
  MidtransSDK? _midtrans;
  bool isMidtransReady = false;
  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');

  Future<String> _bacaData() async {
    userId = (await user_helper.getUserId())!;

    _rsCart = (await dbHelper.viewCart())!;
    setState(() {});

    if (_rsCart == null) {
      throw Exception('Failed to load data');
    } else {
      return "sukses";
    }
  }

  void initSDK() async {
    try {
      await dotenv.load();
      print(dotenv.env['MIDTRANS_MERCHANT_BASE_URL']);
      _midtrans = await MidtransSDK.init(
        config: MidtransConfig(
          clientKey: dotenv.env['MIDTRANS_CLIENT_KEY'] ?? "",
          // merchantBaseUrl: dotenv.env['MIDTRANS_MERCHANT_BASE_URL'] ?? "",
          merchantBaseUrl: "https://golang-midtrans.canonflow.my.id/midtrans/",
          enableLog: true,
          colorTheme: ColorTheme(
            // colorPrimary: Theme.of(context).colorScheme.primary,
            // colorPrimaryDark: Theme.of(context).colorScheme.primary,
            // colorSecondary: Theme.of(context).colorScheme.secondary,
            colorPrimary: Colors.blueGrey,
            colorPrimaryDark: Colors.blueGrey,
            colorSecondary: Colors.black26
          ),
        ),
      );
    } catch(e) {
      print("ERROR INIT SDK: " + e.toString());
    }
    print("SETUP MIDTRANS DONE");
    setState(() {
      isMidtransReady = true;
    });

    _midtrans!.setTransactionFinishedCallback((result) {
      print(result.transactionId);
      print(result.status);
      print(result.message);
      print(result.paymentType);

      dbHelper.emptySelectedCart(selectedProdukIds).then((value) {
        selectedProdukIds.clear();
        _bacaData();
        // Navigator.pushAndRemoveUntil(
        //   context,
        //   MaterialPageRoute(builder: (context) => ListPembelian()),
        //   ModalRoute.withName("/homecustomer")
        // );
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/homecustomer',
              (route) => false,
        );
        Future.delayed(Duration.zero, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ListPembelian()),
          );
        });
      });
    });
  }

  String generateOrderId() {
    final now = DateTime.now();
    final random = Random();
    final randomNumber = random.nextInt(100000);
    return 'ORD-${now.microsecondsSinceEpoch}-$randomNumber';
  }

  Future<void> startMidtransPayment(String snapToken) async {
    print("MASUK KE FUNCTION PAYMENT");
    print(snapToken);
    try {
      _midtrans!.startPaymentUiFlow(
        token: snapToken,
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _bacaData();
    print("SETUP MIDTRANS BEGIN");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initSDK();
    });
    // initSDK();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initSDK(); // Safe here
  }

  @override
  void dispose() {
    _midtrans?.removeTransactionFinishedCallback();
    super.dispose();
  }

  Widget _itemCart(index) {
    int produkId = _rsCart?[index]['produk_id'];
    int jumlah = _rsCart?[index]['jumlah'] ?? 0;
    int harga = _rsCart?[index]['harga'] ?? 0;
    int total = jumlah * harga;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CheckboxListTile(
          value: selectedProdukIds.contains(produkId),
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                selectedProdukIds.add(produkId);
              } else {
                selectedProdukIds.remove(produkId);
              }
            });
          },
          title: Text(_rsCart?[index]['nama'] ?? '-'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('jumlah = $jumlah'),
              Text('harga satuan = ${currencyFormat.format(harga)}'),
              Text('total = ${currencyFormat.format(total)}'),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      dbHelper.kurangJumlah(produkId).then((value) => _bacaData());
                    },
                    child: const Text("-"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      dbHelper.tambahJumlah(produkId).then((value) => _bacaData());
                    },
                    child: const Text("+"),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: 500,
              child:
                  _rsCart != null
                      ? ListView.builder(
                        itemCount: _rsCart?.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          return _itemCart(index);
                        },
                      )
                      : Text('keranjang masih kosong'),
            ),
            Text("userId: ${userId.toString()}"),
            ElevatedButton(
              onPressed: () async {
                _submit();
              },
              child: Text("Checkout"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!isMidtransReady || _midtrans == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Midtrans belum siap. Coba beberapa saat lagi.')),
      );
      return;
    }
    int total = 0;
    String items = "";
    _rsCart = await dbHelper.viewCart();
    if (selectedProdukIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal 1 produk untuk checkout')),
      );
      return;
    }

    _rsCart?.forEach((item) {
      int produkId = item['produk_id'];
      if (selectedProdukIds.contains(produkId)) {
        int jumlah = item['jumlah'];
        int harga = item['harga'];
        total += jumlah * harga;
        items += "$produkId,$jumlah,$total|";
      }
    });

    print(total);

    // ===== Request ke service snap token =====
    String snapTokenServiceUrl = "https://golang-midtrans.canonflow.my.id/midtrans/create-snap-token";
    String orderId = generateOrderId();
    String email = await user_helper.getUserEmail();

    final response = await http.post(
      Uri.parse(snapTokenServiceUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'order_id': orderId,
        'amount': total,
        'email': email
      }),
    );

    // ===== Ambil Snap Token =====
    String? snapToken = null;
    if (response.statusCode == 200) {
      final snapTokenRespone = jsonDecode(response.body);
      snapToken = snapTokenRespone["data"]["snap_token"];
      print("SNAP TOKEN: $snapToken");
    } else {
      final errorResponse = jsonDecode(response.body);
      print('Failed to get snap token. Status: ${response.statusCode}');
      print('Response: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Snap Token Error: ${errorResponse["data"]}')),
      );
    }

    // ===== Mulai pembayaran =====
    // Simpan di DB, trus bayar

    final checkoutResponse = await http.post(
      Uri.parse("https://ubaya.xyz/flutter/160422065/project/checkout.php"),
      body: {
        'user_id': userId,
        'items': items,
        'snap_token': snapToken,
        'order_id': orderId
      },
    );

    if (checkoutResponse.statusCode == 200) {
      Map json = jsonDecode(checkoutResponse.body);
      if (json['result'] == 'success') {
        // double _totalHarga = _hitungTotalHargaCheckout();
        // dbHelper.emptyCart().then((value) {
        //   _bacaData();
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => Pembelian(
        //         totalHarga: _totalHarga,
        //       ),
        //     ),
        //   );
        // });
        // _midtrans?.startPaymentUiFlow(
        //   token: snapToken,
        // );
        print("START PAYMENT");
        print(snapToken);
        startMidtransPayment(snapToken!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${json['message']}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal terhubung ke server')),
      );
    }
  }
  double _hitungTotalHargaCheckout() {
    double total = 0;
    _rsCart?.forEach((item) {
      if (selectedProdukIds.contains(item['produk_id'])) {
        int jumlah = item['jumlah'] ?? 0;
        int harga = item['harga'] ?? 0;
        print("Produk ID: ${item['produk_id']}");
        print("Jumlah: $jumlah");
        print("Harga: $harga");

        total += jumlah * harga;
        print("Total Sementara: $total");
      }
    });
    return total;
  }

}
