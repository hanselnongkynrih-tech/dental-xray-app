import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../services/auth_service.dart';
import '../utils/constants.dart';
import 'dart:io';

class ApiClient {
  final AuthService _authService = AuthService();

  // 🔐 Build headers with token
  Future<Map<String, String>> _buildHeaders() async {
    final token = await _authService.getToken();

    //print("TOKEN FROM STORAGE: $token"); // 🔥 ADD THIS

    final headers = {
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // ===========================
  // 🔹 AUTH / USER
  // ===========================

  Future<http.Response> registerUser(Map<String, dynamic> data) async {
    final url = Uri.parse('${Constants.apiBaseUrl}/users/');

    return http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final headers = await _buildHeaders();
    final url = Uri.parse('${Constants.apiBaseUrl}/users/me');

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return null;
  }

  // ===========================
  // 🔹 PROFILES
  // ===========================

  Future<http.Response> createPatientProfile(Map<String, dynamic> data) async {
    final headers = await _buildHeaders();
    final url = Uri.parse('${Constants.apiBaseUrl}/patient/profile');

    return http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );
  }

  Future<http.Response> createDoctorProfile(Map<String, dynamic> data) async {
    final headers = await _buildHeaders();
    final url = Uri.parse('${Constants.apiBaseUrl}/doctor/profile');

    return http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );
  }

  Future<http.Response> createLabProfile(Map<String, dynamic> data) async {
    final headers = await _buildHeaders();
    final url = Uri.parse('${Constants.apiBaseUrl}/lab/profile');

    debugPrint('POST -> $url');
    debugPrint('Payload -> $data');

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );

    debugPrint('Response: ${response.statusCode}');
    debugPrint('Body: ${response.body}');

    return response;
  }

  Future<Map<String, dynamic>?> getDoctorProfile(int userId) async {
    final headers = await _buildHeaders();
    final url = Uri.parse('${Constants.apiBaseUrl}/doctor/profile/$userId');

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return null;
  }

  Future<Map<String, dynamic>?> getPatientProfile(int userId) async {
    final headers = await _buildHeaders();
    final url = Uri.parse('${Constants.apiBaseUrl}/patient/profile/$userId');

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) return decoded;

        if (decoded is List && decoded.isNotEmpty) {
          return Map<String, dynamic>.from(decoded.first);
        }
      } catch (_) {}
    }

    return null;
  }

  Future<Map<String, dynamic>?> getLabProfile(int userId) async {
    final headers = await _buildHeaders();
    final url = Uri.parse('${Constants.apiBaseUrl}/lab/profile/$userId');

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) return decoded;

        if (decoded is List && decoded.isNotEmpty) {
          return Map<String, dynamic>.from(decoded.first);
        }
      } catch (_) {}
    }

    return null;
  }

  // ===========================
  // 🔹 RESULTS
  // ===========================

  Future<void> uploadResults({
    required int imageId,
    required File file,
  }) async {
    final token = await _authService.getToken();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${Constants.apiBaseUrl}/lab-results/upload'),
    );

    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // ✅ matches backend Form
    request.fields['image_id'] = imageId.toString();

    // ✅ matches backend File
    request.files.add(
      await http.MultipartFile.fromPath(
        'file', // 🔥 MUST BE EXACT
        file.path,
      ),
    );

    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception("Upload failed");
    }
  }

  Future<http.Response> getUserResults(int userId) async {
    final headers = await _buildHeaders();
    final url = Uri.parse('${Constants.apiBaseUrl}/results/$userId');

    return http.get(url, headers: headers);
  }

  // ===========================
  // 🔹 DOCTOR FEATURES
  // ===========================

  // 🧑‍⚕️ Get patients assigned to doctor
  Future<List<dynamic>> getDoctorPatients(int doctorId) async {
    final headers = await _buildHeaders();

    final url = Uri.parse('${Constants.apiBaseUrl}/lab-results/doctor/$doctorId');

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load patients');
    }
  }

  // 🖼️ Get doctor images (X-rays)
  Future<List<dynamic>> getDoctorImages(int doctorId) async {
    final headers = await _buildHeaders();

    final url = Uri.parse('${Constants.apiBaseUrl}/images/doctor/$doctorId');

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load doctor images');
    }
  }

  Future<void> sendToLab({
    required int imageId,
    required int labUserId,
  }) async {
    final headers = await _buildHeaders();

    final url = Uri.parse(
      '${Constants.apiBaseUrl}/images/send-to-lab?image_id=$imageId&lab_user_id=$labUserId',
    );

    final response = await http.post(url, headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to send to lab');
    }
  }

  Future<List<dynamic>> getLabs() async {
    final headers = await _buildHeaders();

    final url = Uri.parse('${Constants.apiBaseUrl}/images/labs');

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load labs');
    }
  }

  Future<List<dynamic>> getLabImages(int labId) async {
    final headers = await _buildHeaders();

    final url = Uri.parse('${Constants.apiBaseUrl}/images/lab/$labId');

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load lab images');
    }
  }

  Future<List<dynamic>> getDoctorResults(int doctorId) async {
    final headers = await _buildHeaders();

    final url = Uri.parse('${Constants.apiBaseUrl}/lab-results/doctor-results/$doctorId');

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load lab results');
    }
  }

  Future<Map<String, dynamic>> getPatientDashboard() async {
    final headers = await _buildHeaders(); // ✅ uses stored token

    final response = await http.get(
      Uri.parse("${Constants.apiBaseUrl}/patient/dashboard"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }  else if (response.statusCode == 401) {
          throw Exception("Session expired");
    } else {
      throw Exception("Failed to load dashboard");
    }
  }

  // ===========================
  // 🔹 APPOINTMENTS
  // ===========================

  // ➕ Create appointment
  Future<void> createAppointment({
    required String date,
    required String time,
    required int doctorId,
  }) async {
    final headers = await _buildHeaders();

    final response = await http.post(
      Uri.parse("${Constants.apiBaseUrl}/appointments/create"),
      headers: headers,
      body: jsonEncode({
        "date": date,
        "time": time,
        "doctor_id": doctorId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to create appointment");
    }
  }

  // 📥 Get my appointments
  Future<List<dynamic>> getMyAppointments() async {
    final headers = await _buildHeaders();

    final response = await http.get(
      Uri.parse("${Constants.apiBaseUrl}/appointments/my"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load appointments");
    }
  }

  Future<List<dynamic>> getDoctors() async {
    final headers = await _buildHeaders();

    final response = await http.get(
      Uri.parse("${Constants.apiBaseUrl}/users/doctors"), // ✅ CORRECT
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load doctors");
    }
  }

  Future<List<dynamic>> getDoctorAppointments() async {
    final headers = await _buildHeaders();

    final response = await http.get(
      Uri.parse("${Constants.apiBaseUrl}/appointments/doctor"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load doctor appointments");
    }
  }


}
