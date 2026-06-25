import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  //final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String input = _usernameController.text.trim();

// 🔥 backend version (NO +91)
    String backendPhone = input.replaceAll("+91", "");


    final password = _passwordController.text;

    try {
      final authService = AuthService();

      final response = await authService.login(backendPhone, password);

      //DEBUG
      debugPrint("BACKEND RESPONSE: $response"); // 👈 ADD HERE

      if (response == null || !response.containsKey("access_token")) {
        setState(() {
          _errorMessage = "Invalid mobile number or password";
          _isLoading = false;
        });
        return;
      }
      debugPrint("LOGIN RESPONSE = $response");

      // 🔥 AFTER BACKEND SUCCESS → SEND FIREBASE OTP
      final String userRole =
          response['role'] ?? 'patient';

      final prefs =
      await SharedPreferences.getInstance();

      await prefs.setString(
        "role",
        userRole,
      );

      if (!mounted) return;

      final user =
      await authService.getCurrentUser();

      if (user == null) {
        return;
      }

      final int userId = user['id'];

      if (userRole == "doctor") {

        final exists =
        await authService.doctorProfileExists(
            userId);

        if (exists) {

          if (!mounted) return;

          Navigator.pushReplacementNamed(
            context,
            '/doctor_dashboard',
          );

        } else {

          if (!mounted) return;

          Navigator.pushReplacementNamed(
            context,
            '/doctor_registration',
          );
        }
      }

      else if (userRole == "patient") {

        final exists =
        await authService.patientProfileExists(
            userId);

        if (exists) {

          if (!mounted) return;

          Navigator.pushReplacementNamed(
            context,
            '/patient_dashboard',
          );

        } else {

          if (!mounted) return;

          Navigator.pushReplacementNamed(
            context,
            '/patient_registration',
          );
        }
      }

      else if (userRole == "lab") {

        final exists =
        await authService.labProfileExists(
            userId);

        if (exists) {

          if (!mounted) return;

          Navigator.pushReplacementNamed(
            context,
            '/lab_dashboard',
          );

        } else {

          if (!mounted) return;

          Navigator.pushReplacementNamed(
            context,
            '/lab_registration',
          );
        }
      }

      else {

        if (!mounted) return;

        Navigator.pushReplacementNamed(
          context,
          '/admin_dashboard',
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Login failed: $e";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

      // ================= OLD BACKEND LOGIN (COMMENTED) =================
      /*
      final password = _passwordController.text;

      final response = await _authService.login(username, password);

      if (response == null || !response.containsKey("mobile_number")) {
        setState(() {
          _errorMessage = "Invalid mobile number or password";
          _isLoading = false;
        });
        return;
      }

      Navigator.pushNamed(
        context,
        '/otp',
        arguments: response["mobile_number"],
      );
      */

      // ================= NEW FIREBASE OTP =================


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Login"),
      ),

      body: Center(

        child: SingleChildScrollView(

          padding: const EdgeInsets.all(24),

          child: Card(

            elevation: 6,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),

            child: Padding(

              padding: const EdgeInsets.all(24),

              child: Form(

                key: _formKey,

                child: Column(

                  mainAxisSize: MainAxisSize.min,

                  children: [

                    const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextFormField(

                      controller: _usernameController,
                      keyboardType: TextInputType.phone,

                      decoration: const InputDecoration(
                        labelText: "Mobile Number",
                        prefixIcon: Icon(Icons.phone),
                      ),

                      validator: (value) {

                        if (value == null || value.isEmpty) {
                          return "Enter mobile number";
                        }

                        if (value.length != 10) {
                          return "Enter valid mobile number";
                        }

                        return null;
                      },

                    ),

                    const SizedBox(height: 16),

                    // ================= PASSWORD FIELD (OPTIONAL NOW) =================
                    TextFormField(

                      controller: _passwordController,
                      obscureText: true,

                      decoration: const InputDecoration(
                        labelText: "Password",
                        prefixIcon: Icon(Icons.lock),
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

                        onPressed: _isLoading ? null : _submit,

                        child: _isLoading
                            ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                            : const Text("Login"),

                      ),

                    ),

                    const SizedBox(height: 10),

                    TextButton(

                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },

                      child: const Text("Create Account"),

                    ),

                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}