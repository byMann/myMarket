import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class InfoAkun extends StatefulWidget {
  const InfoAkun({super.key});

  @override
  State<InfoAkun> createState() => _InfoAkunState();
}

class _InfoAkunState extends State<InfoAkun> {
  late Future<Map<String, String>> _infoFuture;

  @override
  void initState() {
    super.initState();
    _infoFuture = _fetchInfo();
  }

  Future<Map<String, String>> _fetchInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    print('debug userId: $userId'); // ⬅ lihat di debug console

    final response = await http.post(
      Uri.parse('https://ubaya.xyz/flutter/160422150/project/infoAkun.php'),
      body: {'user_id': userId},
    );

    if (response.statusCode != 200) {
      throw 'Server error: ${response.statusCode}';
    }
    final json = jsonDecode(response.body);
    if (json['result'] != 'success') throw json['message'];

    return {
      'Email': json['email'],
      'Role': json['role'],
      'Dibuat Pada': json['created_at'],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Info Akun')),
      body: FutureBuilder<Map<String, String>>(
        future: _infoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final data = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children:
                data.entries
                    .map(
                      (e) =>
                          ListTile(title: Text(e.key), subtitle: Text(e.value)),
                    )
                    .toList(),
          );
        },
      ),
    );
  }
}
