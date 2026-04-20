import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();

  // STEP 1: Password login (sends OTP)
  Future<Map<String, dynamic>?> login(
      String username, String password) async {
    final url = Uri.parse('${Constants.apiBaseUrl}/auth/login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return null;
  }

  // STEP 2: Verify OTP and store JWT
  Future<bool> verifyOtp(String mobileNumber, String otp) async {
    final url = Uri.parse('${Constants.apiBaseUrl}/auth/verify-otp');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "mobile_number": mobileNumber,
        "otp": otp,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      await _storage.write(
        key: 'jwt_token',
        value: data['access_token'],
      );

      return true;
    }

    return false;
  }

  Future<String?> getToken() async =>
      _storage.read(key: 'jwt_token');

  // ================= NEW: SAVE TOKEN =================
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  Future<void> logout() async =>
      _storage.delete(key: 'jwt_token');

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final token = await getToken();
    if (token == null) return null;

    final url = Uri.parse('${Constants.apiBaseUrl}/users/me');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return null;
  }

  // ---------- Profile completeness helpers ----------

  Future<void> setProfileComplete(String role, int userId) async {
    final key = '${role}_profile_complete_$userId';
    await _storage.write(key: key, value: 'true');
  }

  Future<bool> isProfileComplete(String role, int userId) async {
    final key = '${role}_profile_complete_$userId';
    final value = await _storage.read(key: key);
    return value == 'true';
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}