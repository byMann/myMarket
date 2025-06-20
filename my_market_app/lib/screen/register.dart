import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_market_app/screen/login.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<Register> {
  String _error_register = "";
  String? _selected_role;
  bool _eyePassword = true;
  bool _eyePassword2 = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repPasswordController = TextEditingController();

  void doRegister() async {
    String email = _emailController.text;
    String password = _passwordController.text;
    String repPassword = _repPasswordController.text;

    if (email.isEmpty || password.isEmpty || repPassword.isEmpty || _selected_role == null) {
      setState(() {
        _error_register = "Semua field wajib diisi.";
      });
      return;
    }

    if (password != repPassword) {
      setState(() {
        _error_register = "Password dan konfirmasi tidak sama.";
      });
      return;
    }

    final response = await http.post(
      Uri.parse("https://ubaya.xyz/flutter/160422065/project/register.php"),
      body: {'email': email, 'password': password, 'role': _selected_role},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);

      if (json['result'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sukses membuat akun')),
        );

        // reset input
        _emailController.clear();
        _passwordController.clear();
        _repPasswordController.clear();
        setState(() {
          _selected_role = null;
          _error_register = "";
        });

        // ke login
        Future.delayed(Duration(milliseconds: 500), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Login()),
          );
        });
      } else {
        setState(() {
          _error_register = "Registrasi gagal. Silakan coba lagi.";
        });
      }
    } else {
      setState(() {
        _error_register = "Gagal menghubungi server. [${response.statusCode}]";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: Text('Register')),
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
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Email',
                          hintText: 'email@example.com',
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: _eyePassword,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Password',
                          hintText: 'Enter secure password',
                          suffixIcon: IconButton(
                            icon: Icon(_eyePassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _eyePassword = !_eyePassword;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: TextField(
                        controller: _repPasswordController,
                        obscureText: _eyePassword2,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Repeat Password',
                          hintText: 'Repeat your password',
                          suffixIcon: IconButton(
                            icon: Icon(_eyePassword2
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _eyePassword2 = !_eyePassword2;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: DropdownButtonFormField<String>(
                        value: _selected_role,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Role',
                        ),
                        isExpanded: true,
                        items: ['penjual', 'customer'].map((role) {
                          return DropdownMenuItem<String>(
                            value: role,
                            child: Text(role),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selected_role = value!;
                          });
                        },
                      ),
                    ),
                    if (_error_register.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          _error_register,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: doRegister,
                          child: Text(
                            'Register',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => Login()),
                          );
                        },
                        child: Text("Sudah punya akun? Login"),
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
