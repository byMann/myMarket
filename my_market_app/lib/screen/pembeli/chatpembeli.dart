import 'package:flutter/material.dart';

class ChatPembeli extends StatefulWidget {
  const ChatPembeli({super.key});

  @override
  _ChatPembeliScreenState createState() => _ChatPembeliScreenState();
}

class _ChatPembeliScreenState extends State<ChatPembeli> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ini Chat Pembeli")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Ini Chat Pembeli")
          ],
        ),
      ),
    );
  }
}
