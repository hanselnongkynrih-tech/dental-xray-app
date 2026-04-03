import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/auth_service.dart';
import '../utils/constants.dart';

class PatientRegistrationScreen extends StatefulWidget {
  const PatientRegistrationScreen({super.key});

  @override
  State<PatientRegistrationScreen> createState() =>
      _PatientRegistrationScreenState();
}

class _PatientRegistrationScreenState
    extends State<PatientRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final _ageController = TextEditingController();
  final _addressController = TextEditingController();

  String? _selectedGender; // 'Male', 'Female', 'Other'
  bool _consentGiven = false;

  // doctor selection
  List<Map<String, dynamic>> _doctors = [];
  int? _selectedDoctorId;

  bool _isLoading = false;
  bool _loadingDoctors = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  @override
  void dispose() {
    _ageController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String? _validateAge(String? value) {
    if (value == null || value.isEmpty) return 'Enter age';
    final age = int.tryParse(value);
    if (age == null || age <= 0) return 'Enter valid age';
    return null;
  }

  String? _validateGender(String? value) {
    if (value == null || value.isEmpty) return 'Select gender';
    return null;
  }

  String? _validateDoctor(int? value) {
    if (value == null) return 'Select doctor';
    return null;
  }

  Future<void> _loadDoctors() async {
    setState(() {
      _loadingDoctors = true;
      _errorMessage = null;
    });

    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Missing auth token, please login again');
      }

      final response = await http.get(
        Uri.parse('${Constants.apiBaseUrl}/users/doctors'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to load doctors: ${response.statusCode} ${response.body}');
      }

      final decoded = jsonDecode(response.body) as List<dynamic>;
      setState(() {
        _doctors = decoded.cast<Map<String, dynamic>>();
        _loadingDoctors = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load doctors: $e';
        _loadingDoctors = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_consentGiven) {
      setState(() {
        _errorMessage = 'Please accept the consent checkbox to continue.';
      });
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() {
      _isLoading = true;
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

      int? age;
      if (_ageController.text.trim().isNotEmpty) {
        age = int.tryParse(_ageController.text.trim());
      }

      final body = {
        'user_id': user['id'],
        'doctor_user_id': _selectedDoctorId,
        'age': age,
        'gender': _selectedGender,
        'address': _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : null,
        'profile_picture_path': null,
        'clinical_profile': null,
        'consent': _consentGiven ? 'Yes' : null,
      };

      final response = await http.post(
        Uri.parse('${Constants.apiBaseUrl}/patient/profile'),
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
      await _authService.setProfileComplete('patient', userId);

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Patient profile saved. Please login again.'),
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

  @override
  Widget build(BuildContext context) {
    String? doctorValidator(String? _) => _validateDoctor(_selectedDoctorId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Registration'),
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
                    'Complete your patient profile',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Choose your doctor and fill your basic details.',
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
                    controller: _ageController,
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: _validateAge,
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    initialValue: _selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Male',
                        child: Text('Male'),
                      ),
                      DropdownMenuItem(
                        value: 'Female',
                        child: Text('Female'),
                      ),
                      DropdownMenuItem(
                        value: 'Other',
                        child: Text('Other'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                    validator: _validateGender,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),

                  _loadingDoctors
                      ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: CircularProgressIndicator(),
                    ),
                  )
                      : DropdownButtonFormField<String>(
                    initialValue: _selectedDoctorId?.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Select Doctor',
                      border: OutlineInputBorder(),
                    ),
                    items: _doctors
                        .map(
                          (doc) => DropdownMenuItem<String>(
                        value: doc['id'].toString(),
                        child: Text(
                          doc['full_name'] ??
                              'Doctor ${doc['id']}',
                        ),
                      ),
                    )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDoctorId =
                        value != null ? int.parse(value) : null;
                      });
                    },
                    validator: doctorValidator,
                  ),
                  const SizedBox(height: 12),

                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _consentGiven,
                    onChanged: (value) {
                      setState(() {
                        _consentGiven = value ?? false;
                      });
                    },
                    title: const Text(
                      'I consent to sharing my dental information and X-rays with my doctor.',
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
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
