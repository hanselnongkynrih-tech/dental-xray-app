import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../services/auth_service.dart';
import 'lab_upload_result_screen.dart';

class LabRequestsScreen extends StatefulWidget {
  const LabRequestsScreen({super.key});

  @override
  State<LabRequestsScreen> createState() => _LabRequestsScreenState();
}

class _LabRequestsScreenState extends State<LabRequestsScreen> {
  final ApiClient _apiClient = ApiClient();
  final AuthService _authService = AuthService();

  List images = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  Future<void> loadImages() async {
    final user = await _authService.getCurrentUser();
    if (user == null) return;

    final data = await _apiClient.getLabImages(user['id']);
    debugPrint("LAB DATA: $data");

    setState(() {
      images = data;
      isLoading = false;
    });
  }

  String getImageUrl(String path) {
    return "http://10.0.2.2:8000/$path";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lab Requests")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : images.isEmpty
          ? const Center(child: Text("No requests"))
          : ListView.builder(
        itemCount: images.length,
        itemBuilder: (context, index) {
          final img = images[index];

          return Card(
            child: ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LabUploadResultScreen(
                      imageId: img['id'],
                    ),
                  ),
                );
              },

              leading: Image.network(
                getImageUrl(img['image_path']),
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),

              title: Text("Patient ID: ${img['user_id']}"),
              subtitle: Text("Status: ${img['status']}"),
            ),
          );
        },
      ),
    );
  }
}