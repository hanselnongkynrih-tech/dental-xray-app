import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/auth_service.dart';
import '../utils/constants.dart';

class DoctorRegistrationScreen extends StatefulWidget {
  const DoctorRegistrationScreen({super.key});

  @override
  State<DoctorRegistrationScreen> createState() =>
      _DoctorRegistrationScreenState();
}

class _DoctorRegistrationScreenState extends State<DoctorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  // Basic info
  final _clinicNameController = TextEditingController();
  final _clinicAddressController = TextEditingController();
  final _specializationController = TextEditingController();
  final _yearsExpController = TextEditingController();
  final _dciRegNoController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _feeOnlineController = TextEditingController();
  final _feeOfflineController = TextEditingController();

  // Bank details
  final _bankHolderController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _ifscController = TextEditingController();
  final _upiController = TextEditingController();

  // Online consultation checkbox
  bool _onlineConsultation = false;

  // Services multi-select
  final List<String> _serviceOptions = const [
    'Check-up & Consultation',
    'Cleaning / Scaling',
    'Fillings',
    'Root Canal Treatment',
    'Tooth Extraction',
    'Crowns & Bridges',
    'Braces / Orthodontics',
    'Dental Implants',
    'Teeth Whitening',
  ];
  final Set<String> _selectedServices = {};

  // Availability per day
  final List<_DayAvailability> _availability = [
    _DayAvailability('Mon'),
    _DayAvailability('Tue'),
    _DayAvailability('Wed'),
    _DayAvailability('Thu'),
    _DayAvailability('Fri'),
    _DayAvailability('Sat'),
    _DayAvailability('Sun'),
  ];

  // ===============================
  // 🔥 ADD THIS (NEW VARIABLES)
  // ===============================
  String? selectedQualification;
  String? selectedSpecialization;

  final List<String> qualifications = ["BDS", "MDS"];

  final List<String> bdsSpecializations = [
    "Implantology",
    "Aesthetic & Cosmetic Dentistry",
    "Laser Dentistry",
    "Rotary Endodontics",
    "Forensic Odontology",
  ];

  final List<String> mdsSpecializations = [
    "Prosthodontics and Crown & Bridge",
    "Periodontology",
    "Oral & Maxillofacial Surgery",
    "Conservative Dentistry & Endodontics",
    "Orthodontics & Dentofacial Orthopaedics",
    "Oral Pathology & Microbiology",
    "Public Health Dentistry",
    "Pediatric & Preventive Dentistry",
    "Oral Medicine & Radiology",
  ];

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _clinicNameController.dispose();
    _clinicAddressController.dispose();
    _specializationController.dispose();
    _yearsExpController.dispose();
    _dciRegNoController.dispose();
    _qualificationController.dispose();
    _feeOnlineController.dispose();
    _feeOfflineController.dispose();
    _bankHolderController.dispose();
    _bankAccountController.dispose();
    _ifscController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  /*String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;*/

  String _timeOfDayToString(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m'; // 24h HH:mm
  }

  Future<void> _pickTime(int index, bool isStart) async {
    final current = isStart
        ? _availability[index].start ?? const TimeOfDay(hour: 9, minute: 0)
        : _availability[index].end ?? const TimeOfDay(hour: 17, minute: 0);

    final picked = await showTimePicker(
      context: context,
      initialTime: current,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _availability[index].start = picked;
        } else {
          _availability[index].end = picked;
        }
      });
    }
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

      int? yearsExp;
      if (_yearsExpController.text.trim().isNotEmpty) {
        yearsExp = int.tryParse(_yearsExpController.text.trim());
      }

      double? feeOnline;
      if (_feeOnlineController.text.trim().isNotEmpty) {
        feeOnline = double.tryParse(_feeOnlineController.text.trim());
      }

      double? feeOffline;
      if (_feeOfflineController.text.trim().isNotEmpty) {
        feeOffline = double.tryParse(_feeOfflineController.text.trim());
      }

      final availabilityList = _availability
          .where((d) => d.enabled && d.start != null && d.end != null)
          .map((d) => {
        'day': d.day,
        'start_time': _timeOfDayToString(d.start!),
        'end_time': _timeOfDayToString(d.end!),
      })
          .toList();

      final servicesList =
      _selectedServices.isEmpty ? null : _selectedServices.toList();

      final body = {
        'user_id': user['id'],
        'clinic_name': _clinicNameController.text.trim().isEmpty
            ? null
            : _clinicNameController.text.trim(),
        'clinic_address': _clinicAddressController.text.trim().isEmpty
            ? null
            : _clinicAddressController.text.trim(),
        // ===============================
        // 🔥 USE DROPDOWN VALUES
        // ===============================
        'specialization': selectedSpecialization,
        'qualification': selectedQualification,
        'years_of_experience': yearsExp,
        'dci_registration_number':
        _dciRegNoController.text.trim().isEmpty
            ? null
            : _dciRegNoController.text.trim(),

        'consultation_fee_online': feeOnline,
        'consultation_fee_offline': feeOffline,
        'dci_certificate_path': null,
        'govt_id_path': null,
        'clinic_image_path': null,
        'availability':
        availabilityList.isEmpty ? null : availabilityList,
        'online_consultation': _onlineConsultation ? 'Yes' : null,
        'services': servicesList,
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
      };

      final response = await http.post(
        Uri.parse('${Constants.apiBaseUrl}/doctor/profile'),
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
      await _authService.setProfileComplete('doctor', userId);

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Doctor profile saved. Please login again.'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Registration'),
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
                    'Complete your doctor profile',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'These details are stored in the backend and shown in your profile.',
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

                  // ===============================
                  // 🔥 FIX CLINIC NAME (READ ONLY)
                  // ===============================
                  TextFormField(
                    initialValue: "Dental Care Clinic",
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Clinic Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _clinicAddressController,
                    decoration: const InputDecoration(
                      labelText: 'Clinic Address',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  // ===============================
                  // 🔥 DYNAMIC SPECIALIZATION DROPDOWN
                  // ===============================
                  DropdownButtonFormField<String>(
                    initialValue: selectedSpecialization,
                    decoration: const InputDecoration(
                      labelText: 'Specialization',
                      border: OutlineInputBorder(),
                    ),
                    items: (selectedQualification == "BDS"
                        ? bdsSpecializations
                        : selectedQualification == "MDS"
                        ? mdsSpecializations
                        : <String>[]) // 🔥 IMPORTANT FIX
                        .map<DropdownMenuItem<String>>((spec) {
                      return DropdownMenuItem<String>(
                        value: spec,
                        child: Text(spec),
                      );
                    }).toList(),
                    onChanged: selectedQualification == null
                        ? null
                        : (value) {
                      setState(() {
                        selectedSpecialization = value;
                      });
                    },
                  ),

                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _yearsExpController,
                    decoration: const InputDecoration(
                      labelText: 'Years of Experience',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _dciRegNoController,
                    decoration: const InputDecoration(
                      labelText: 'DCI Registration Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // ===============================
                  // 🔥 QUALIFICATION DROPDOWN
                  // ===============================
                  DropdownButtonFormField<String>(
                    initialValue: selectedQualification,
                    decoration: const InputDecoration(
                      labelText: 'Qualification',
                      border: OutlineInputBorder(),
                    ),
                    items: qualifications.map((q) {
                      return DropdownMenuItem(
                        value: q,
                        child: Text(q),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedQualification = value;
                        selectedSpecialization = null; // reset specialization
                      });
                    },
                  ),

                  const SizedBox(height: 12),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _feeOnlineController,
                          decoration: const InputDecoration(
                            labelText: 'Online Fee',
                            prefixText: '₹ ',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType:
                          const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _feeOfflineController,
                          decoration: const InputDecoration(
                            labelText: 'Clinic Fee',
                            prefixText: '₹ ',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType:
                          const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  CheckboxListTile(
                    value: _onlineConsultation,
                    onChanged: (value) {
                      setState(() {
                        _onlineConsultation = value ?? false;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'I offer online consultation (video / phone).',
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const SizedBox(height: 12),

                  const Text(
                    'Availability (optional)',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Enable days and choose start/end time.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(
                    _availability.length,
                        (index) {
                      final day = _availability[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: Row(
                            children: [
                              Switch(
                                value: day.enabled,
                                onChanged: (value) {
                                  setState(() {
                                    day.enabled = value;
                                  });
                                },
                              ),
                              SizedBox(
                                width: 40,
                                child: Text(
                                  day.day,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextButton(
                                  onPressed: day.enabled
                                      ? () => _pickTime(
                                      index, true)
                                      : null,
                                  child: Text(
                                    day.start == null
                                        ? 'Start'
                                        : _timeOfDayToString(
                                        day.start!),
                                  ),
                                ),
                              ),
                              const Text('–'),
                              Expanded(
                                child: TextButton(
                                  onPressed: day.enabled
                                      ? () => _pickTime(
                                      index, false)
                                      : null,
                                  child: Text(
                                    day.end == null
                                        ? 'End'
                                        : _timeOfDayToString(
                                        day.end!),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Services Offered (optional)',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Select all services you provide.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  ..._serviceOptions.map(
                        (service) => CheckboxListTile(
                      value: _selectedServices.contains(service),
                      onChanged: (value) {
                        setState(() {
                          if (value ?? false) {
                            _selectedServices.add(service);
                          } else {
                            _selectedServices.remove(service);
                          }
                        });
                      },
                      title: Text(service),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity:
                      ListTileControlAffinity.leading,
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Bank Details (for settlement)',
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

class _DayAvailability {
  final String day;
  bool enabled = false;
  TimeOfDay? start;
  TimeOfDay? end;

  _DayAvailability(this.day);
}
