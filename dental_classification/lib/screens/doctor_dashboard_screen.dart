import 'package:flutter/material.dart';
import '../services/auth_service.dart';

import '../utils/constants.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../api/api_client.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() =>
      _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {

  String doctorName = "";
  bool isLoading = true;

  int patients = 0;
  int cases = 0;
  int reports = 0;
  int appointments = 0;

  @override
  void initState() {
    super.initState();
    loadDoctor();
    loadDashboard();
    loadAppointments(); // 🔥 ADD THIS
  }

  Future<void> loadDoctor() async {
    final user = await AuthService().getCurrentUser();

    if (user != null) {
      setState(() {
        doctorName = user['full_name'] ?? "";
        isLoading = false;
      });
    }
  }

  Future<void> loadAppointments() async {
    try {
      final data = await ApiClient().getDoctorAppointments();
      setState(() {
        appointments = data.length;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> loadDashboard() async {
    try {
      final token = await AuthService().getToken();

      final response = await http.get(
        Uri.parse("${Constants.apiBaseUrl}/doctor/dashboard"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          patients = data['patients'] ?? 0;
          cases = data['cases'] ?? 0;
          reports = data['reports'] ?? 0;
        });
      } else {
        debugPrint("Dashboard failed: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Dashboard error: $e");
    }
  }

  // 🔥 LOGOUT
  Future<void> _logout() async {
    await AuthService().logout();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/welcome',
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // ✅ DRAWER ADDED
      drawer: _buildDrawer(context),

      appBar: AppBar(
        title: const Text("Doctor Dashboard"),

        // ✅ MENU BUTTON
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),

      // ✅ CLEAN BODY (NO ACTION BUTTONS)
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // 🔷 WELCOME CARD
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2F6BFF), Color(0xFF4A8CFF)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLoading ? "Loading..." : "Welcome Dr. $doctorName",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 5),
                      const  Text(
                        "Manage Patients & Diagnoses",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.medical_services,
                    color: Colors.white, size: 50),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 🔷 STATS
          Row(
            children: [
              _StatCard("Patients", "$patients", Icons.people),
              _StatCard("Cases", "$cases", Icons.medical_services),
              _StatCard("Reports", "$reports", Icons.description),
              _StatCard("Appointments", "$appointments", Icons.calendar_today),
            ],
          ),
        ],
      ),
    );
  }

  // =============================
  // 🔷 DRAWER
  // =============================
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [

          // 🔷 HEADER
          Container(
            color: Colors.blue,
            padding: const EdgeInsets.all(20),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.blue),
                ),
                SizedBox(height: 10),
                Text("Doctor",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                Text("Dashboard",
                    style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),

          // 🔷 MENU ITEMS
          _drawerItem(Icons.dashboard, "Dashboard", () {
            Navigator.pop(context);
          }),

          _drawerItem(Icons.people, "View Patients", () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/doctor_patients');
          }),

          _drawerItem(Icons.image, "View X-rays", () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/doctor_images');
          }),

          _drawerItem(Icons.medical_services, "Diagnose Case", () {
            Navigator.pop(context);
          }),

          _drawerItem(Icons.person, "Profile", () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/doctor_profile');
          }),

          const Divider(),

          _drawerItem(Icons.logout, "Logout", () {
            Navigator.pop(context);
            _logout();
          }, color: Colors.red),
        ],
      ),
    );
  }

  // =============================
  // 🔷 DRAWER ITEM
  // =============================
  Widget _drawerItem(
      IconData icon,
      String title,
      VoidCallback onTap, {
        Color color = Colors.black,
      }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      onTap: onTap,
    );
  }
}

// =============================
// 🔷 STAT CARD
// =============================
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard(this.title, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: Colors.blue),
              const SizedBox(height: 10),
              Text(value,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}