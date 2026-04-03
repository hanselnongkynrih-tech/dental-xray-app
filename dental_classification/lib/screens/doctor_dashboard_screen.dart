import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'doctor_images_screen.dart';
import 'doctor_patients_screen.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
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
        title: const Text("Doctor Dashboard"),
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
            _dashboardCard(Icons.people, "Patients", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DoctorPatientsScreen(),
                ),
              );
            }),

            _dashboardCard(Icons.medical_services, "Diagnoses", () {}),

            _dashboardCard(Icons.image, "X-ray Images", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DoctorImagesScreen(),
                ),
              );
            }),

            _dashboardCard(Icons.person, "Profile", () {
              Navigator.pushNamed(context, '/doctor_profile');
            }),
          ],
        ),
      ),
    );
  }
}