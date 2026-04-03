import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../api/api_client.dart';
import 'doctor_images_screen.dart';

class DoctorPatientsScreen extends StatefulWidget {
  const DoctorPatientsScreen({super.key});

  @override
  State<DoctorPatientsScreen> createState() => _DoctorPatientsScreenState();
}

class _DoctorPatientsScreenState extends State<DoctorPatientsScreen> {
  final AuthService _authService = AuthService();
  final ApiClient _apiClient = ApiClient();

  List<dynamic> patients = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPatients();
  }

  Future<void> loadPatients() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) return;

      final data = await _apiClient.getDoctorPatients(user['id']);

      setState(() {
        patients = data;
        isLoading = false;
      });

    } catch (e) {
      debugPrint("Error loading patients: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Patients")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : patients.isEmpty
          ? const Center(child: Text("No patients yet"))
          : ListView.builder(
        itemCount: patients.length,
        itemBuilder: (context, index) {
          final p = patients[index];

          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(p['patient_name'] ?? 'Unknown'),
              subtitle:
              Text("Token No: ${p['token_number'] ?? 'N/A'}"),
              trailing: const Icon(Icons.arrow_forward),

              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => DoctorImagesScreen(
                            patientId: p['patient_user_id'],
                            patientName: p['patient_name'],
                        )));
              },
            ),
          );
        },
      ),
    );
  }
}