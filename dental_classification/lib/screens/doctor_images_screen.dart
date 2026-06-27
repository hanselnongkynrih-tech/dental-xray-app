import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../services/auth_service.dart';
import 'report_details_screen.dart';
import 'doctor_case_screen.dart';

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
  final TextEditingController requestTypeController =
  TextEditingController();

  final TextEditingController priorityController =
  TextEditingController();

  final TextEditingController doctorNotesController =
  TextEditingController();

  @override
  void initState() {
    super.initState();

    requestTypeController.text =
    "General Dental Analysis";

    priorityController.text =
    "Normal";

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

                  const SizedBox(height: 15),

                  TextField(
                    controller: requestTypeController,
                    decoration: const InputDecoration(
                      labelText: "Request Type",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  DropdownButtonFormField<String>(
                    initialValue: priorityController.text,

                    decoration: const InputDecoration(
                      labelText: "Priority",
                      border: OutlineInputBorder(),
                    ),

                    items: const [

                      DropdownMenuItem(
                        value: "Low",
                        child: Text("Low"),
                      ),

                      DropdownMenuItem(
                        value: "Normal",
                        child: Text("Normal"),
                      ),

                      DropdownMenuItem(
                        value: "High",
                        child: Text("High"),
                      ),

                      DropdownMenuItem(
                        value: "Urgent",
                        child: Text("Urgent"),
                      ),

                    ],

                    onChanged: (value) {
                      priorityController.text = value!;
                    },

                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: doctorNotesController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: "Doctor Notes",
                      hintText: "Enter instructions for the lab...",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  /*TextField(
                    controller: requestTypeController,
                    decoration: const InputDecoration(
                      labelText: "Request Type",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: priorityController,
                    decoration: const InputDecoration(
                      labelText: "Priority",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: doctorNotesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Doctor Notes",
                      border: OutlineInputBorder(),
                    ),
                  ),*/

                ],
              ),

              trailing: img['status'] == "completed"
                  ? ElevatedButton(
                  child: const Text("View"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReportDetailsScreen(
                          imageId: img['image_id'] ?? img['id'],
                        ),
                      ),
                    );
                  },
              )
                  : ElevatedButton(
                child: const Text("Open Case"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DoctorCaseScreen(
                        image: Map<String, dynamic>.from(img),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  /*Future<void> _showSendToLabDialog(dynamic img) async {
    int? labId = selectedLabUserId;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Send To Lab"),

          content: StatefulBuilder(
            builder: (context, setDialogState) {

              int? labId = selectedLabUserId;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  DropdownButtonFormField<int>(
                    initialValue: labId,
                    hint: const Text("Select Lab"),

                    items: labs.map<DropdownMenuItem<int>>((lab) {

                      return DropdownMenuItem<int>(
                        value: lab["user_id"],
                        child: Text(lab["lab_name"]),
                      );

                    }).toList(),

                    onChanged: (value) {
                      setDialogState(() {
                        labId = value;
                      });
                    },

                  ),

                ],
              );
            },
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () async {

                if (labId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please select a lab"),
                    ),
                  );
                  return;
                }

                final imageId = img["image_id"] ?? img["id"];

                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);

                try {
                  await _apiClient.sendToLab(
                    imageId: imageId,
                    labUserId: labId,
                    requestType: requestTypeController.text,
                    priority: priorityController.text,
                    doctorNotes: doctorNotesController.text,
                  );

                  if (!mounted) return;

                  navigator.pop();

                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text("Sent to Lab Successfully"),
                    ),
                  );

                  loadImages();

                } catch (e) {

                  if (!mounted) return;

                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                    ),
                  );

                }
              },

              child: const Text("Send"),
            ),

          ],

        );
      },
    );
  }*/

}

