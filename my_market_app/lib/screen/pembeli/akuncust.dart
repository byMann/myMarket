import 'package:flutter/material.dart';

class AkunCust extends StatefulWidget {
  const AkunCust({super.key});

  @override
  _AkunCustScreenState createState() => _AkunCustScreenState();
}

class _AkunCustScreenState extends State<AkunCust> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Ini Akun Cust")
          ],
        ),
      ),
    );
  }
}
