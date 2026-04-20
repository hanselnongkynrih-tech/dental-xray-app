import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class DashboardScreen extends StatefulWidget {
  final String role;

  const DashboardScreen({super.key, required this.role});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.role;

    return Scaffold(
      backgroundColor: AppColors.background,

      // 🔹 Drawer
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
              color: AppColors.primary,
              child: Text(
                "${role.toUpperCase()} PANEL",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            _drawerItem(Icons.person, "Profile", () {
              Navigator.pop(context);

              if (role == 'doctor') {
                Navigator.pushNamed(context, '/doctor_profile');
              } else if (role == 'patient') {
                Navigator.pushNamed(context, '/patient_profile');
              } else if (role == 'lab') {
                Navigator.pushNamed(context, '/lab_profile');
              }
            }),

            const Divider(),

            _drawerItem(Icons.logout, "Logout", _logout,
                color: Colors.red),
          ],
        ),
      ),

      // 🔹 AppBar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          role == 'doctor'
              ? 'Doctor Dashboard'
              : role == 'patient'
              ? 'Patient Dashboard'
              : role == 'lab'
              ? 'Lab Dashboard'
              : 'Admin Dashboard',
          style: TextStyle(color: AppColors.primary),
        ),
      ),

      // 🔹 BODY (MAIN PART)
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: _buildCards(role),
        ),
      ),
    );
  }

  // 🔥 ROLE-BASED CARDS
  List<Widget> _buildCards(String role) {
    if (role == 'doctor') {
      return [
        _card(Icons.people, "Patients", () {}),
        _card(Icons.image, "X-rays", () {}),
        _card(Icons.medical_services, "Diagnose", () {}),
      ];
    } else if (role == 'patient') {
      return [
        _card(Icons.upload, "Upload X-ray", () {}),
        _card(Icons.history, "My Reports", () {}),
        _card(Icons.image, "My Images", () {}),
      ];
    } else if (role == 'lab') {
      return [
        _card(Icons.science, "Requests", () {}),
        _card(Icons.upload_file, "Upload Results", () {}),
        _card(Icons.history, "Reports", () {}),
      ];
    } else {
      return [
        _card(Icons.people, "Manage Users", () {}),
        _card(Icons.image, "All Images", () {}),
      ];
    }
  }

  // 🔹 CARD UI (same style everywhere)
  Widget _card(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.05),
              blurRadius: 10,
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: AppColors.primary),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
      IconData icon, String title, VoidCallback onTap,
      {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.primary),
      title: Text(title),
      onTap: onTap,
    );
  }
}