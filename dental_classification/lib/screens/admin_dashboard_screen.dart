import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/auth_service.dart';
import '../utils/constants.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {

  final AuthService _authService = AuthService();

  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> images = [];

  bool isLoadingUsers = true;
  bool isLoadingImages = true;

  String selectedPage = ""; // 🔥 NOTHING selected initially

  @override
  void initState() {
    super.initState();
    fetchUsers();
    fetchImages();
  }

  // =========================
  // FETCH USERS
  // =========================
  Future<void> fetchUsers() async {
    final token = await _authService.getToken();

    final response = await http.get(
      Uri.parse('${Constants.apiBaseUrl}/users/all'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      setState(() {
        users = data.cast<Map<String, dynamic>>();
        isLoadingUsers = false;
      });
    }
  }

  // =========================
  // FETCH IMAGES
  // =========================
  Future<void> fetchImages() async {
    final token = await _authService.getToken();

    final response = await http.get(
      Uri.parse('${Constants.apiBaseUrl}/images/all'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      setState(() {
        images = data.cast<Map<String, dynamic>>();
        isLoadingImages = false;
      });
    }
  }

  // =========================
  // DELETE USER
  // =========================
  Future<void> deleteUser(int id) async {
    final token = await _authService.getToken();

    await http.delete(
      Uri.parse('${Constants.apiBaseUrl}/users/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    fetchUsers();
  }

  // =========================
  // UPDATE ROLE
  // =========================
  Future<void> updateRole(int id, String role) async {
    final token = await _authService.getToken();

    await http.put(
      Uri.parse('${Constants.apiBaseUrl}/users/$id?role=$role'),
      headers: {'Authorization': 'Bearer $token'},
    );

    fetchUsers();
  }

  // =========================
  // DELETE IMAGE
  // =========================
  Future<void> deleteImage(int id) async {
    final token = await _authService.getToken();

    await http.delete(
      Uri.parse('${Constants.apiBaseUrl}/images/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    fetchImages();
  }

  // =========================
  // BUILD
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // 🔷 DRAWER
      drawer: _buildDrawer(context),

      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),

      body: Column(
        children: [

          // 🔷 HEADER
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2F6BFF), Color(0xFF4A8CFF)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Welcome Admin",
                          style: TextStyle(color: Colors.white70)),
                      SizedBox(height: 5),
                      Text(
                        "System Control Panel",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.admin_panel_settings,
                    color: Colors.white, size: 50),
              ],
            ),
          ),

          // 🔷 STATS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _StatCard("Users", users.length.toString(), Icons.people),
                _StatCard("Images", images.length.toString(), Icons.image),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 🔷 CONTENT AREA
          Expanded(
            child: selectedPage == "users"
                ? _buildUsers()
                : selectedPage == "images"
                ? _buildImages()
                : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.dashboard,
                      size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "Select Users or Images from menu",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // DRAWER
  // =========================
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [

          Container(
            color: Colors.blue,
            padding: const EdgeInsets.all(20),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.admin_panel_settings,
                    color: Colors.white, size: 40),
                SizedBox(height: 10),
                Text("Admin",
                    style: TextStyle(color: Colors.white, fontSize: 18)),
                Text("Dashboard",
                    style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),

          _drawerItem(Icons.people, "Users", () {
            Navigator.pop(context);
            setState(() => selectedPage = "users");
          }),

          _drawerItem(Icons.image, "Images", () {
            Navigator.pop(context);
            setState(() => selectedPage = "images");
          }),

          const Divider(),

          // 🔥 SAFE LOGOUT
          _drawerItem(Icons.logout, "Logout", () async {
            Navigator.pop(context);

            final navigator = Navigator.of(context);

            await _authService.logout();

            if (!mounted) return;

            navigator.pushNamedAndRemoveUntil(
                '/welcome', (route) => false);
          }, color: Colors.red),
        ],
      ),
    );
  }

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

  // =========================
  // USERS VIEW
  // =========================
  Widget _buildUsers() {
    if (isLoadingUsers) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      children: users.map((user) {
        return Card(
          margin: const EdgeInsets.all(10),
          child: ListTile(
            title: Text(user['full_name']),
            subtitle: Text("${user['mobile_number']} • ${user['role']}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [

                PopupMenuButton<String>(
                  icon: const Icon(Icons.edit),
                  onSelected: (value) => updateRole(user['id'], value),
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: "patient", child: Text("Patient")),
                    PopupMenuItem(value: "doctor", child: Text("Doctor")),
                    PopupMenuItem(value: "lab", child: Text("Lab")),
                    PopupMenuItem(value: "admin", child: Text("Admin")),
                  ],
                ),

                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => deleteUser(user['id']),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // =========================
  // IMAGES VIEW
  // =========================
  Widget _buildImages() {
    if (isLoadingImages) {
      return const Center(child: CircularProgressIndicator());
    }

    return GridView.count(
      crossAxisCount: 2,
      children: images.map((img) {
        return Card(
          margin: const EdgeInsets.all(10),
          child: Column(
            children: [
              Expanded(
                child: Image.network(
                  "${Constants.apiBaseUrl}/${img['image_path']}",
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => deleteImage(img['id']),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// =========================
// STAT CARD
// =========================
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