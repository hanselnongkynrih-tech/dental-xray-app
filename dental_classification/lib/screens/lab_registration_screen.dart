import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/auth_service.dart';
import '../utils/constants.dart';

class LabRegistrationScreen extends StatefulWidget {
  const LabRegistrationScreen({super.key});

  @override
  State<LabRegistrationScreen> createState() =>
      _LabRegistrationScreenState();
}

class _LabRegistrationScreenState extends State<LabRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final _labNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _labTypeController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _labAddressController = TextEditingController();
  final _cityStateController = TextEditingController();
  final _licenseController = TextEditingController();
  final _gstController = TextEditingController();
  final _bankHolderController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _ifscController = TextEditingController();
  final _upiController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _labNameController.dispose();
    _ownerNameController.dispose();
    _labTypeController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _labAddressController.dispose();
    _cityStateController.dispose();
    _licenseController.dispose();
    _gstController.dispose();
    _bankHolderController.dispose();
    _bankAccountController.dispose();
    _ifscController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _authService.getCurrentUser();
      if (user == null || user['id'] == null) {
        throw Exception('Could not find logged-in user');
      }
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Missing auth token, please login again');
      }

      final body = {
        'user_id': user['id'],
        'lab_name': _labNameController.text.trim().isEmpty
            ? null
            : _labNameController.text.trim(),
        'owner_name': _ownerNameController.text.trim().isEmpty
            ? null
            : _ownerNameController.text.trim(),
        'lab_type': _labTypeController.text.trim().isEmpty
            ? null
            : _labTypeController.text.trim(),
        'mobile_number': _mobileController.text.trim().isEmpty
            ? null
            : _mobileController.text.trim(),
        'email': _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        'lab_address': _labAddressController.text.trim().isEmpty
            ? null
            : _labAddressController.text.trim(),
        'city_state': _cityStateController.text.trim().isEmpty
            ? null
            : _cityStateController.text.trim(),
        // skipping working_hours, maps pin, photos, services, logistics etc
        'license_number': _licenseController.text.trim().isEmpty
            ? null
            : _licenseController.text.trim(),
        'gst_number': _gstController.text.trim().isEmpty
            ? null
            : _gstController.text.trim(),
        'bank_account_holder': _bankHolderController.text.trim().isEmpty
            ? null
            : _bankHolderController.text.trim(),
        'bank_account_number': _bankAccountController.text.trim().isEmpty
            ? null
            : _bankAccountController.text.trim(),
        'bank_ifsc_code': _ifscController.text.trim().isEmpty
            ? null
            : _ifscController.text.trim(),
        'upi_id': _upiController.text.trim().isEmpty
            ? null
            : _upiController.text.trim(),
        'maps_location_pin': null,
        'working_hours': null,
        'registration_certificate_path': null,
        'lab_photo_path': null,
        'services_offered': null,
        'order_handling': null,
        'report_handling': null,
        'logistics': null,
        'settlement_frequency': null,
      };

      final response = await http.post(
        Uri.parse('${Constants.apiBaseUrl}/lab/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
            'Server error: ${response.statusCode} ${response.body}');
      }

      final userId = user['id'];
      await _authService.setProfileComplete('lab', userId);

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Lab profile saved. Please login again.'),
        ),
      );
      navigator.pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      setState(() {
        _errorMessage = 'Registration failed: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const Text(
                    'Complete your lab profile',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'These details are stored in the backend and visible to doctors.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
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
                  TextFormField(
                    controller: _labNameController,
                    decoration: const InputDecoration(
                      labelText: 'Lab Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: _required,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _ownerNameController,
                    decoration: const InputDecoration(
                      labelText: 'Owner Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _labTypeController,
                    decoration: const InputDecoration(
                      labelText: 'Lab Type',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _mobileController,
                    decoration: const InputDecoration(
                      labelText: 'Mobile Number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _labAddressController,
                    decoration: const InputDecoration(
                      labelText: 'Lab Address',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _cityStateController,
                    decoration: const InputDecoration(
                      labelText: 'City / State',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _licenseController,
                    decoration: const InputDecoration(
                      labelText: 'License Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _gstController,
                    decoration: const InputDecoration(
                      labelText: 'GST Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Bank Details',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _bankHolderController,
                    decoration: const InputDecoration(
                      labelText: 'Account Holder Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _bankAccountController,
                    decoration: const InputDecoration(
                      labelText: 'Account Number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _ifscController,
                    decoration: const InputDecoration(
                      labelText: 'IFSC Code',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _upiController,
                    decoration: const InputDecoration(
                      labelText: 'UPI ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text('Save & Logout'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
