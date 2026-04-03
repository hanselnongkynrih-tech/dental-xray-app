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

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {

  final AuthService _authService = AuthService();

  late TabController _tabController;

  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> images = [];

  bool isLoadingUsers = true;
  bool isLoadingImages = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

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
  // USER CARD
  // =========================
  Widget userCard(Map<String, dynamic> user) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: ListTile(
        title: Text(user['full_name'] ?? ''),
        subtitle: Text(
          "${user['mobile_number']} • ${user['role']}",
        ),
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
  }

  // =========================
  // IMAGE CARD
  // =========================
  Widget imageCard(Map<String, dynamic> image) {

    final imageUrl =
        "${Constants.apiBaseUrl}/${image['image_path']}";

    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [

          Expanded(
            child: Image.network(
              imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
              const Icon(Icons.broken_image),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("User ID: ${image['user_id']}"),
          ),

          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => deleteImage(image['id']),
          ),
        ],
      ),
    );
  }

  // =========================
  // BUILD
  // =========================
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Admin Panel"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Users"),
            Tab(text: "Images"),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [

          // USERS TAB
          isLoadingUsers
              ? const Center(child: CircularProgressIndicator())
              : ListView(
            children: users
                .map((user) => userCard(user))
                .toList(),
          ),

          // IMAGES TAB
          isLoadingImages
              ? const Center(child: CircularProgressIndicator())
              : GridView.count(
            crossAxisCount: 2,
            children: images
                .map((image) => imageCard(image))
                .toList(),
          ),

        ],
      ),
    );
  }
}