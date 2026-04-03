import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/auth_service.dart';
import '../utils/constants.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
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
            '${Constants.apiBaseUrl}/doctor/profile/${user['id']}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 404) {
        // no profile yet
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
            'No doctor profile found.',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please complete your doctor registration so that your details are stored with your account.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(
                    context, '/doctor_registration');
              },
              child: const Text('Complete Doctor Registration'),
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
          'Doctor Details',
          style:
          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _ProfileRow(label: 'Clinic Name', value: orDash(p['clinic_name'])),
        _ProfileRow(
            label: 'Clinic Address',
            value: orDash(p['clinic_address'])),
        _ProfileRow(
            label: 'Specialization',
            value: orDash(p['specialization'])),
        _ProfileRow(
            label: 'Experience (years)',
            value: orDash(p['years_of_experience'])),
        _ProfileRow(
            label: 'DCI Reg. Number',
            value: orDash(p['dci_registration_number'])),
        _ProfileRow(
            label: 'Qualification',
            value: orDash(p['qualification'])),
        _ProfileRow(
            label: 'Consultation Fee (Online)',
            value: orDash(p['consultation_fee_online'])),
        _ProfileRow(
            label: 'Consultation Fee (Clinic)',
            value: orDash(p['consultation_fee_offline'])),
        _ProfileRow(
            label: 'Online Consultation',
            value: orDash(p['online_consultation'])),
        const SizedBox(height: 16),
        const Text(
          'Bank Details',
          style:
          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        _ProfileRow(
            label: 'Account Holder',
            value: orDash(p['bank_account_holder'])),
        _ProfileRow(
            label: 'Account Number',
            value: orDash(p['bank_account_number'])),
        _ProfileRow(
            label: 'IFSC Code',
            value: orDash(p['bank_ifsc_code'])),
        _ProfileRow(label: 'UPI ID', value: orDash(p['upi_id'])),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/doctor_dashboard');
            },
            child: const Text('Open Doctor Dashboard'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Profile'),
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
