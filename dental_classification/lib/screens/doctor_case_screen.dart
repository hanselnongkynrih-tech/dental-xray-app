import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'manual_diagnosis_screen.dart';

class DoctorCaseScreen extends StatelessWidget {
  final Map<String, dynamic> image;

  const DoctorCaseScreen({
    super.key,
    required this.image,
  });

  String getImageUrl(String path) {
    return "${Constants.apiBaseUrl}/${path.replaceAll("\\", "/")}";
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Doctor Case"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            /// ==========================
            /// X-RAY IMAGE
            /// ==========================

            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "Original X-Ray",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        getImageUrl(image["image_path"]),
                        height: 260,
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    ),

                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// ==========================
            /// PATIENT INFORMATION
            /// ==========================

            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "Patient Information",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text("Patient : ${image["patient_name"] ?? "-"}"),

                    const SizedBox(height: 8),

                    Text("Token : ${image["token_number"] ?? "-"}"),

                    const SizedBox(height: 8),

                    Text("Status : ${image["status"] ?? "-"}"),

                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Choose Action",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.medical_services),
                label: const Text("Manual Diagnosis"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ManualDiagnosisScreen(
                        image: image,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.smart_toy),
                label: const Text("Diagnose with AI"),
                onPressed: () {},
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.science),
                label: const Text("Send To Lab"),
                onPressed: () {},
              ),
            ),

          ],
        ),
      ),
    );
  }
}