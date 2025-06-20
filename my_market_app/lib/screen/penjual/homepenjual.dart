import 'package:flutter/material.dart';

class HomePenjual extends StatelessWidget {
  const HomePenjual({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Ini Home Penjual")
          ],
        ),
      ),
    );
  }
}
