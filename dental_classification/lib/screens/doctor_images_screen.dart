import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../services/auth_service.dart';
import 'report_screen.dart';

class DoctorImagesScreen extends StatefulWidget {
  final int? patientId;
  final String? patientName;

  const DoctorImagesScreen({
    super.key,
    this.patientId,
    this.patientName,
  });

  @override
  State<DoctorImagesScreen> createState() =>
      _DoctorImagesScreenState();
}

class _DoctorImagesScreenState extends State<DoctorImagesScreen> {
  final ApiClient _apiClient = ApiClient();
  final AuthService _authService = AuthService();

  List images = [];
  bool isLoading = true;
  List<dynamic> labs = [];
  int? selectedLabUserId;

  int? doctorId;

  @override
  void initState() {
    super.initState();
    loadImages();
    fetchLabs();
  }

  Future<void> loadImages() async {
    final user = await _authService.getCurrentUser();

    if (user == null) return;

    doctorId = user['id'];

    final data = await _apiClient.getDoctorResults(doctorId!);

    List filtered = data;

    if (widget.patientId != null) {
      filtered = data.where((img) {
        final imgUserId = int.tryParse(
          (img['patient_user_id'] ?? '').toString(),
        );
        return imgUserId == widget.patientId;
      }).toList();
    }

    setState(() {
      images = filtered;
      isLoading = false;
    });
  }

  Future<void> fetchLabs() async {
    final data = await _apiClient.getLabs();
    setState(() {
      labs = data;
    });
  }

  String getImageUrl(String path) {
    final fixedPath = path.replaceAll("\\", "/"); // 🔥 fix slashes
    return "http://10.0.2.2:8000/$fixedPath";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patientName ?? "X-ray Images"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : images.isEmpty
          ? const Center(child: Text("No images found"))
          : ListView.builder(
        itemCount: images.length,
        itemBuilder: (context, index) {
          final img = images[index];

          debugPrint("IMAGE ITEM: $img"); // ✅ ADD THIS

          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              leading: img['image_path'] != null
                  ? Image.network(
                getImageUrl(img['image_path']),
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              )
                  : const Icon(Icons.image_not_supported),

              title: Text(img['patient_name'] ?? "Unknown"),

              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Token: ${img['token_number'] ?? '-'}"),
                  Text("Status: ${img['status']}"),

                  const SizedBox(height: 8),

                  DropdownButtonFormField<int>(
                    hint: const Text("Select Lab"),
                    initialValue: selectedLabUserId,
                    items: labs.map<DropdownMenuItem<int>>((lab) {
                      return DropdownMenuItem(
                        value: lab["user_id"], // ✅ IMPORTANT
                        child: Text(lab["lab_name"]),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedLabUserId = value;
                      });
                    },
                  ),
                ],
              ),

              trailing: img['status'] == "completed"
                  ? ElevatedButton(
                child: const Text("View"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ReportScreen(
                            imageId: img['image_id'] ?? img['id'],
                          )
                    ),
                  );
                },
              )
                  : ElevatedButton(
                child: const Text("Send"),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);

                  try {
                    final imageId = img['image_id'] ?? img['id'];

                    if (imageId == null) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text("Invalid image ID")),
                      );
                      return;
                    }

                    if (selectedLabUserId == null) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text("Please select a lab")),
                      );
                      return;
                    }

                    await _apiClient.sendToLab(
                      imageId: imageId,
                      labUserId: selectedLabUserId!,
                    );

                    messenger.showSnackBar(
                      const SnackBar(content: Text("Sent to Lab")),
                    );

                  } catch (e) {
                    messenger.showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}