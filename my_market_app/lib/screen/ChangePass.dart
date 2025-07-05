import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Halaman Change Password + toggle show/hide icon di setiap field
class ChangePass extends StatefulWidget {
  const ChangePass({Key? key}) : super(key: key);

  @override
  State<ChangePass> createState() => _ChangePassState();
}

class _ChangePassState extends State<ChangePass> {
  final _formKey = GlobalKey<FormState>();

  final _oldPwdCtrl = TextEditingController();
  final _newPwdCtrl = TextEditingController();
  final _confirmPwdCtrl = TextEditingController();

  bool _isSaving = false;
  String? _errorMsg;
  String? _userId;

  // visibilitas password
  bool _showOld = false;
  bool _showNew = false;
  bool _showConfirm = false;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _userId = prefs.getString('user_id'));
  }

  @override
  void dispose() {
    _oldPwdCtrl.dispose();
    _newPwdCtrl.dispose();
    _confirmPwdCtrl.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    if (_newPwdCtrl.text != _confirmPwdCtrl.text) {
      setState(() => _errorMsg = 'Password baru dan konfirmasi tidak sama');
      return;
    }
    if (_userId == null) {
      setState(() => _errorMsg = 'User tidak ditemukan. Silakan login ulang.');
      return;
    }
    if (_newPwdCtrl.text == _oldPwdCtrl.text) {
      setState(
        () => _errorMsg = 'Password baru tidak boleh sama dengan password lama',
      );
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMsg = null;
    });

    try {
      final response = await http.post(
        Uri.parse('https://ubaya.xyz/flutter/160422150/project/changePass.php'),
        body: jsonEncode({
          'user_id': _userId,
          'old_password': _oldPwdCtrl.text,
          'new_password': _newPwdCtrl.text,
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['result'] == 'success') {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password berhasil diubah')),
          );
          Navigator.pop(context);
        } else {
          setState(
            () => _errorMsg = json['message'] ?? 'Gagal mengganti password',
          );
        }
      } else {
        setState(() => _errorMsg = 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _errorMsg = 'Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
    required FormFieldValidator<String> validator,
    IconData prefixIcon = Icons.lock,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
        ),
      ),
      obscureText: obscure,
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ubah Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPasswordField(
                label: 'Password Lama',
                controller: _oldPwdCtrl,
                obscure: !_showOld,
                onToggle: () => setState(() => _showOld = !_showOld),
                validator:
                    (v) =>
                        (v == null || v.isEmpty)
                            ? 'Masukkan password lama'
                            : null,
                prefixIcon: Icons.lock_outline,
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                label: 'Password Baru',
                controller: _newPwdCtrl,
                obscure: !_showNew,
                onToggle: () => setState(() => _showNew = !_showNew),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Masukkan password baru';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                label: 'Konfirmasi Password Baru',
                controller: _confirmPwdCtrl,
                obscure: !_showConfirm,
                onToggle: () => setState(() => _showConfirm = !_showConfirm),
                validator:
                    (v) =>
                        (v == null || v.isEmpty)
                            ? 'Ulangi password baru'
                            : null,
              ),
              if (_errorMsg != null) ...[
                const SizedBox(height: 12),
                Text(_errorMsg!, style: const TextStyle(color: Colors.red)),
              ],
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _changePassword,
                icon:
                    _isSaving
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.save),
                label: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
