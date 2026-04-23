import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'patient_upload_screen.dart';
import '../api/api_client.dart';
import 'login_screen.dart';

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  State<PatientDashboardScreen> createState() =>
      _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  Map<String, dynamic>? dashboardData;

  @override
  void initState() {
    super.initState();
    fetchDashboard();
  }

  Future<void> fetchDashboard() async {
    try {
      final data = await ApiClient().getPatientDashboard();
      if (!mounted) return;
      setState(() {
        dashboardData = data;
      });
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  // ✅ CLEAN LOGOUT (NO CONTEXT PARAM)
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (dashboardData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      drawer: _buildDrawer(context),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          "Patient Dashboard",
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: _logout, // ✅ FIXED
          ),
          const SizedBox(width: 10),
        ],
      ),

      body: Row(
        children: [
          if (MediaQuery.of(context).size.width > 800)
            SizedBox(
              width: 250,
              child: _buildSidebarContent(context),
            ),

          Expanded(
            child: Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  _welcomeCard(),
                  const SizedBox(height: 20),
                  _quickOverview(),
                  const SizedBox(height: 20),
                  _recentActivity(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────── DRAWER ─────────
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: _buildSidebarContent(context),
    );
  }

  // ───────── SIDEBAR ─────────
  Widget _buildSidebarContent(BuildContext context) {
    final name = dashboardData?['name'] ?? "Patient";

    return Container(
      color: Colors.white,
      child: ListView(
        children: [
          Container(
            color: Colors.blue,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text(
                    name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(name,
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
                const Text("Patient",
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),

          _menuItem(Icons.dashboard, "Dashboard", context),

          const Divider(),

          _menuItem(Icons.straighten, "Straightening Teeth (Braces)", context),
          _menuItem(Icons.child_care, "Pediatric Dentistry", context),
          _menuItem(Icons.healing, "Gum Specialist (Periodontist)", context),
          _menuItem(Icons.medical_services, "Root Canal Specialist", context),
          _menuItem(Icons.build, "Restoration (Dentist)", context),
          _menuItem(Icons.science, "Oral & Maxillofacial Pathology", context),
          _menuItem(Icons.biotech, "Oral & Maxillofacial Radiology", context),

          const Divider(),

          _menuItem(Icons.image, "My Images", context),

          _menuItem(Icons.upload, "Upload X-ray", context, onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PatientUploadScreen(),
              ),
            );
          }),

          _menuItem(Icons.description, "My Reports", context),
          _menuItem(Icons.person, "Profile", context),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout",
                style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _logout(); // ✅ FIXED
            },
          ),
        ],
      ),
    );
  }

  Widget _menuItem(
      IconData icon,
      String title,
      BuildContext context, {
        VoidCallback? onTap,
      }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        if (onTap != null) onTap();
      },
    );
  }

  // ───────── WELCOME CARD ─────────
  Widget _welcomeCard() {
    return Container(
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
                const Text("Welcome back,",
                    style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 5),

                Text(
                  dashboardData?['name'] ?? "",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Manage your dental health and appointments easily.",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const Icon(Icons.health_and_safety,
              color: Colors.white, size: 60),
        ],
      ),
    );
  }

  // ───────── QUICK OVERVIEW ─────────
  Widget _quickOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick Overview",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            _StatCard(
              "Images",
              "${dashboardData?['images'] ?? 0}",
              Icons.image,
              Colors.blue,
            ),
            _StatCard(
              "Reports",
              "${dashboardData?['reports'] ?? 0}",
              Icons.description,
              Colors.green,
            ),
            _StatCard(
              "Appointments",
              "${dashboardData?['appointments'] ?? 0}",
              Icons.calendar_today,
              Colors.orange,
            ),
          ],
        ),
      ],
    );
  }

  // ───────── RECENT ACTIVITY ─────────
  Widget _recentActivity() {
    final activities = dashboardData?['recent_activity'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recent Activity",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: activities.isEmpty
                ? [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text("No activity yet"),
              )
            ]
                : activities.map<Widget>((item) {
              return Column(
                children: [
                  _ActivityTile(
                    item['title'],
                    "",
                    item['time'],
                  ),
                  const Divider(),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ───────── STAT CARD ─────────
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard(this.title, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color),
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

// ───────── ACTIVITY TILE ─────────
class _ActivityTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;

  const _ActivityTile(this.title, this.subtitle, this.time);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Color(0xFFE3F2FD),
        child: Icon(Icons.arrow_upward, color: Colors.blue),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Text(time, style: const TextStyle(fontSize: 12)),
    );
  }
}