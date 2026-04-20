import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/firebase_auth_service.dart';
import '../api/api_client.dart';
import '../screens/dashboard_screen.dart';


class OtpScreen extends StatefulWidget {
  final String mobileNumber;

  const OtpScreen({super.key, required this.mobileNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();

  final AuthService _authService = AuthService();
  final FirebaseAuthService _firebaseService = FirebaseAuthService();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _verifyOtp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final otp = _otpController.text.trim();

    try {
      // STEP 1: Firebase OTP Verification
      final success = await _firebaseService.verifyOtp(
        otp,
        widget.mobileNumber,
      );

      if (!success) {
        setState(() {
          _errorMessage = "Invalid OTP";
          _isLoading = false;
        });
        return;
      }

      // STEP 2: Backend OTP Verification
      final backendSuccess = await _authService.verifyOtp(
        widget.mobileNumber,
        otp,
      );

      if (!backendSuccess) {
        setState(() {
          _errorMessage = "Login failed";
          _isLoading = false;
        });
        return;
      }

      // STEP 3: Get current user
      final user = await _authService.getCurrentUser();

      if (!mounted) return;

      if (user == null || user['role'] == null) {
        Navigator.pushReplacementNamed(context, '/welcome');
        return;
      }

      final role = (user['role'] as String).toLowerCase();
      final userId = user['id'];

      final api = ApiClient();

      // STEP 4: Role-based navigation

      if (role == 'doctor') {
        final profile = await api.getDoctorProfile(userId);

        if (!mounted) return;

        if (profile == null) {
          Navigator.pushReplacementNamed(context, '/doctor_registration');
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => DashboardScreen(role: 'doctor'),
            ),
          );
        }

      } else if (role == 'patient') {
        final profile = await api.getPatientProfile(userId);

        if (!mounted) return;

        if (profile == null) {
          Navigator.pushReplacementNamed(context, '/patient_registration');
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => DashboardScreen(role: 'patient'),
            ),
          );
        }

      } else if (role == 'lab') {
        final profile = await api.getLabProfile(userId);

        if (!mounted) return;

        if (profile == null) {
          Navigator.pushReplacementNamed(context, '/lab_registration');
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => DashboardScreen(role: 'lab'),
            ),
          );
        }

      } else if (role == 'admin') {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DashboardScreen(role: 'admin'),
          ),
        );

      } else {
        if (!mounted) return;

        Navigator.pushReplacementNamed(context, '/welcome');
      }

    } catch (e) {
      setState(() {
        _errorMessage = "Login failed: $e";
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter OTP")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("OTP sent to ${widget.mobileNumber}"),
            const SizedBox(height: 20),

            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Enter OTP",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Verify OTP"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}