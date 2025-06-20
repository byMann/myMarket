import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_market_app/screen/pembeli/homecustomer.dart';
import 'package:my_market_app/screen/penjual/homepenjual.dart';
import 'package:my_market_app/screen/register.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'myMarket app',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Login(),
    );
  }
}

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  String _email = "";
  String _password = "";
  String _error_login = "";
  String? _selected_role;
  bool _eyePassword = true;

  void doLogin() async {
    final response = await http.post(
      Uri.parse("https://ubaya.xyz/flutter/160422065/project/login.php"),
      body: {'email': _email, 'password': _password},
    );

    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        final prefs = await SharedPreferences.getInstance();
        prefs.setInt("id", json['id']);
        prefs.setString("email", json['email']);
        prefs.setString("role", json['role']);
        prefs.setBool("is_logged_in", true);

        if (json['role'] == 'penjual') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePenjual()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeCustomer()),
          );
        }
      } else {
        setState(() {
          _error_login = "Username atau password salah.";
        });
      }
    } else {
      throw Exception('Gagal menghubungi API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: Text('Login')),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 1),
                  color: Colors.white,
                  boxShadow: [BoxShadow(blurRadius: 2)],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Username',
                          hintText: 'email@example.com',
                        ),
                        onChanged: (email) {
                          _email = email;
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: TextField(
                        obscureText: _eyePassword,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Password',
                          hintText: 'Enter secure password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _eyePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _eyePassword = !_eyePassword;
                              });
                            },
                          ),
                        ),
                        onChanged: (passw) {
                          _password = passw;
                        },
                      ),
                    ),
                    if (_error_login != "")
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          _error_login,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            doLogin();
                          },
                          child: Text('Login', style: TextStyle(fontSize: 20)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Register()),
                          );
                        },
                        child: Text("Belum punya akun? Daftar di sini"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
