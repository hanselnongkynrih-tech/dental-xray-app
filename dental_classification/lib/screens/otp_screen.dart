import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/firebase_auth_service.dart';

class OtpScreen extends StatefulWidget {
  final String mobileNumber;
  final String role;

  const OtpScreen({super.key, required this.mobileNumber, required this.role});

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

      /// STEP 2: Backend OTP Verification
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

      // 🔥 THIS IS THE KEY PART TO ADD/UPDATE:
      // If backend verification is successful, use the role passed from Login
      if (mounted) {
        _navigateToDashboard(widget.role);
      }

    } catch (e) {
      setState(() {
        _errorMessage = "Login failed: $e";
        _isLoading = false;
      });
    }
  }

  void _navigateToDashboard(String role) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/dashboard',
          (route) => false, // This clears the navigation history
      arguments: role,
    );
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