import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:my_market_app/class/pesan.dart';
import 'package:my_market_app/class/produk.dart';
import 'package:my_market_app/helper/user_helper.dart';

class ChatRoom extends StatefulWidget {
  final int produkID;

  final String emailPenjual;

  const ChatRoom({
    super.key,
    required this.produkID,
    required this.emailPenjual,
  });

  @override
  State<ChatRoom> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoom> {
  List<Pesan> pesanList = [];
  final TextEditingController _pesanController = TextEditingController();
  String senderId = "";
  String namaPenjual = "";
  int? produkId;
  Produk? _p;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    setState(() {
      isLoading = true;
    });

    senderId = await getUserId();
    namaPenjual = widget.emailPenjual;

    await Future.wait([bacaPesan(), detailproduk()]);

    setState(() {
      isLoading = false;
    });
  }

  Future<void> detailproduk() async {
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

  Future<void> bacaPesan() async {
    try {
      final response = await http.post(
        Uri.parse("https://ubaya.xyz/flutter/160422065/project/cekpesan.php"),
        body: {
          'sender_id': senderId,
          'receiver_id': senderId,
          'email_receiver': widget.emailPenjual,
          'email_sender': widget.emailPenjual,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        if (json['result'] == 'success' && json['data'] != null) {
          setState(() {
            pesanList = List<Pesan>.from(
              (json['data'] as List).map((item) => Pesan.fromJson(item)),
            );
            produkId = pesanList[0].produkId;
            print("produknya punya id: $produkId");
          });
        } else {
          setState(() {
            pesanList = [];
          });
        }
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> kirimPesan() async {
    if (_pesanController.text.isEmpty) return;

    final response = await http.post(
      Uri.parse("https://ubaya.xyz/flutter/160422065/project/kirimpesan.php"),
      body: {
        'sender_id': senderId,
        'receiver_email': widget.emailPenjual,
        'konten': _pesanController.text,
        'produk_id': widget.produkID.toString(),
      },
    );
    print("Response body: ${response.body}");
    print("sender_id: $senderId");
    print("email_sender: ${widget.emailPenjual}");
    print("pesan: ${_pesanController.text}");
    print("produk_id: ${widget.produkID.toString()}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        setState(() {
          bacaPesan();
          _pesanController.clear();
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengirim pesan')));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengirim pesan')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("Loading...")),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text("$namaPenjual")),
      body: Column(
        children: [
          // Detail Produk
          Card(
            margin: EdgeInsets.all(12),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(
                          "https://ubaya.xyz/flutter/160422065/project/images/produk/$produkId.jpg",
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  // Detail produk
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _p!.nama.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          NumberFormat.currency(
                            locale: 'id_ID',
                            symbol: 'Rp ',
                            decimalDigits: 0,
                          ).format(_p!.harga),
                          style: const TextStyle(fontSize: 20),
                        ),
                        Text("Stok: ${_p!.stok.toString()}"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Daftar Chat
          Expanded(
            child: ListView.builder(
              itemCount: pesanList.length,
              itemBuilder: (context, index) {
                final pesan = pesanList[index];
                final isMyMessage = pesan.senderId.toString() == senderId;

                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Row(
                    mainAxisAlignment:
                        isMyMessage
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                    children: [
                      if (!isMyMessage)
                        CircleAvatar(
                          radius: 16,
                          child: Icon(Icons.person, size: 16),
                        ),
                      SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isMyMessage
                                    ? Colors.green[200]
                                    : Colors.grey[300],
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                              bottomLeft:
                                  isMyMessage
                                      ? Radius.circular(16)
                                      : Radius.circular(0),
                              bottomRight:
                                  isMyMessage
                                      ? Radius.circular(0)
                                      : Radius.circular(16),
                            ),
                          ),
                          child: Text(
                            pesan.konten,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      if (isMyMessage) SizedBox(width: 8),
                    ],
                  ),
                );
              },
            ),
          ),

          // Input Chat
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _pesanController,
                    decoration: InputDecoration(
                      labelText: 'Ketik pesan...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(icon: Icon(Icons.send), onPressed: kirimPesan),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
