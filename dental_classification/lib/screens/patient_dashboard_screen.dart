import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'patient_profile_screen.dart';
import 'patient_upload_screen.dart'; // we will create this

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  State<PatientDashboardScreen> createState() =>
      _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  final AuthService _authService = AuthService();

  Future<void> _logout() async {
    final navigator = Navigator.of(context);
    await _authService.logout();
    if (!mounted) return;
    navigator.pushNamedAndRemoveUntil('/welcome', (route) => false);
  }

  Widget _dashboardCard(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 42, color: Colors.blue),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _dashboardCard(Icons.upload, "Upload X-ray", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PatientUploadScreen(),
                ),
              );
            }),

            _dashboardCard(Icons.history, "My Reports", () {
              // future screen
            }),

            _dashboardCard(Icons.image, "My Images", () {
              // future screen
            }),

            _dashboardCard(Icons.person, "Profile", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PatientProfileScreen(),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}