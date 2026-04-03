import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _goToLogin(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _goToRegister(BuildContext context) {
    Navigator.pushNamed(context, '/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Toothly',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Smart dental records for doctors, patients and labs.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Center(
                  child: Container(
                    width: 300,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 12,
                          offset: Offset(0, 6),
                          spreadRadius: -4,
                          color: Colors.black26,
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.medical_services,
                            size: 56, color: Colors.blue),
                        SizedBox(height: 16),
                        Text(
                          'All your dental files in one place.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 12),
                        Text(
                          '• Doctors: view patients & lab reports\n'
                              '• Patients: upload X-rays\n'
                              '• Labs: upload reports & images',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _goToLogin(context),
                  child: const Text('Login'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _goToRegister(context),
                  child: const Text('Register'),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Doctor • Patient • Lab',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
