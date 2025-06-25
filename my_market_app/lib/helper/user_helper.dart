import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveUserSession({
  required String userId,
  required String role,
}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('is_logged_in', true);
  await prefs.setString('user_id', userId);
  await prefs.setString('role', role);
}

Future<String> getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('user_id') ?? "";
}

Future<String> getUserRole() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('role') ?? "";
}

Future<bool> isLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('is_logged_in') ?? false;
}

Future<void> clearSession() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear(); 
}
