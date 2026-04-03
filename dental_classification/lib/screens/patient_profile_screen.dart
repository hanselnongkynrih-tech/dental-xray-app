import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/auth_service.dart';
import '../utils/constants.dart';

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  State<PatientProfileScreen> createState() =>
      _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  final AuthService _authService = AuthService();

  bool _loading = true;
  Map<String, dynamic>? _profile;
  String? _errorMessage;

  Future<void> _logout() async {
    final navigator = Navigator.of(context);
    await _authService.logout();
    if (!mounted) return;
    navigator.pushNamedAndRemoveUntil('/welcome', (route) => false);
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final user = await _authService.getCurrentUser();
      if (user == null || user['id'] == null) {
        throw Exception('Could not get logged-in user');
      }
      final token = await _authService.getToken();
      if (token == null) throw Exception('Missing token');

      final response = await http.get(
        Uri.parse(
            '${Constants.apiBaseUrl}/patient/profile/${user['id']}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 404) {
        setState(() {
          _profile = null;
          _loading = false;
        });
        return;
      }

      if (response.statusCode != 200) {
        throw Exception(
            'Server error: ${response.statusCode} ${response.body}');
      }

      final data =
      jsonDecode(response.body) as Map<String, dynamic>;

      setState(() {
        _profile = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profile: $e';
        _loading = false;
      });
    }
  }

  Widget _buildProfileDetails() {
    if (_profile == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'No patient profile found.',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please complete your patient registration.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(
                    context, '/patient_registration');
              },
              child: const Text('Complete Patient Registration'),
            ),
          ),
        ],
      );
    }

    final p = _profile!;
    String orDash(dynamic v) =>
        (v == null || (v is String && v.trim().isEmpty))
            ? '-'
            : v.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Patient Details',
          style:
          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _ProfileRow(label: 'Age', value: orDash(p['age'])),
        _ProfileRow(label: 'Gender', value: orDash(p['gender'])),
        _ProfileRow(label: 'Address', value: orDash(p['address'])),
        _ProfileRow(label: 'Consent', value: orDash(p['consent'])),
        const SizedBox(height: 24),
        Card(
          child: ListTile(
            leading: const Icon(Icons.cloud_upload),
            title: const Text('Manage X-ray files'),
            subtitle: const Text(
                'Upload dental X-rays for your doctor.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, '/patient_dashboard');
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProfile,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style:
                        const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            _buildProfileDetails(),
          ],
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(
                  fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
