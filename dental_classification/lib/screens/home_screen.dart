import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  HomeScreen({super.key});

  void _logout(BuildContext context) async {
    await _authService.logout();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  void _goToAddPatient(BuildContext context) {
    Navigator.pushNamed(context, '/add_patient');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_user, size: 48, color: Colors.green),
                const SizedBox(height: 18),
                const Text(
                  'Welcome! You are logged in.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Your dashboard will show project results here.',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _goToAddPatient(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  child: const Text('Add New Patient'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
