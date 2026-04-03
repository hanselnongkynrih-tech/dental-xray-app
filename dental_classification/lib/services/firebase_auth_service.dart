import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _verificationId;

  // SEND OTP
  Future<void> sendOtp({
    required String phoneNumber,
    required Function() onCodeSent,
    required Function(String) onError,
  }) async {
    // 🔥 DEV MODE (NO FIREBASE CALL)
    await Future.delayed(const Duration(milliseconds: 500));

    _verificationId = "dev_mode"; // fake id

    onCodeSent();
  }

  // VERIFY OTP
  /*Future<bool> verifyOtp(String otp) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      await _auth.signInWithCredential(credential);
      return true;
    } catch (e) {
      return false;
    }
  }*/

  Future<bool> verifyOtp(String otp, String phoneNumber) async {
    // 🔥 DEV MODE (MULTIPLE OTP SUPPORT)

    // Admin number
    if (phoneNumber.contains("9999999999") && otp == "456789") {
      return true;
    }

    // Other users
    if (otp == "123456") {
      return true;
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      await _auth.signInWithCredential(credential);
      return true;
    } catch (e) {
      return false;
    }
  }

}