import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_market_app/class/produk.dart';
import 'package:my_market_app/helper/user_helper.dart';
import 'package:my_market_app/screen/chatroom.dart';

class Daftarchat extends StatefulWidget {
  const Daftarchat({super.key});

  @override
  State<Daftarchat> createState() => _DaftarchatState();
}

class _DaftarchatState extends State<Daftarchat> {
  String senderId = "";
  List<Map<String, dynamic>> uniqueChats = [];
  bool isLoading = true;
  int? produkId;
  Produk? _p;

  @override
  void initState() {
    super.initState();
    loadChatRooms();
  }

  Future<void> loadChatRooms() async {
    senderId = await getUserId();

    try {
      final response = await http.post(
        Uri.parse(
          "https://ubaya.xyz/flutter/160422065/project/ceksemuapesan.php",
        ),
        body: {'sender_id': senderId},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        if (json['result'] == 'success') {
          List data = json['data'];
          Map<String, Map<String, dynamic>> seenReceivers = {};

          for (var item in data) {
            final receiverId = item['receiver_id'].toString();
            final emailReceiver = item['email_receiver'];
            final produkId = item['produks_id'];

            if (!seenReceivers.containsKey(receiverId)) {
              // Ambil detail produk langsung di sini
              final produkDetail = await http.post(
                Uri.parse(
                  "https://ubaya.xyz/flutter/160422065/project/detailproduct.php",
                ),
                body: {'id': produkId.toString()},
              );

              if (produkDetail.statusCode == 200) {
                final produkJson = jsonDecode(produkDetail.body);
                final produk = Produk.fromJson(produkJson['data']);

                seenReceivers[receiverId] = {
                  'receiver_id': receiverId,
                  'email_receiver': emailReceiver,
                  'produk_id': produkId,
                  'produk': produk,
                };
              }
            }
          }

          setState(() {
            uniqueChats = seenReceivers.values.toList();
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: ListView.builder(
        itemCount: uniqueChats.length,
        itemBuilder: (context, index) {
          final chat = uniqueChats[index];
          return ListTile(
            leading: Icon(Icons.chat),
            title: Text("${chat['email_receiver']}"),
            subtitle: Text("Produk: ${(chat['produk'] as Produk).nama}"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ChatRoom(
                        produkID: int.parse(chat['produk_id'].toString()),
                        emailPenjual: chat['email_receiver'],
                      ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
