import 'package:flutter/material.dart';
import '../api/api_client.dart';

class ManualDiagnosisScreen extends StatefulWidget {
  final Map<String, dynamic> image;

  const ManualDiagnosisScreen({
    super.key,
    required this.image,
  });

  @override
  State<ManualDiagnosisScreen> createState() =>
      _ManualDiagnosisScreenState();
}

class _ManualDiagnosisScreenState
    extends State<ManualDiagnosisScreen> {

  final _diagnosisController =
  TextEditingController();

  final _prescriptionController =
  TextEditingController();

  final _treatmentController =
  TextEditingController();

  final _notesController =
  TextEditingController();

  final ApiClient _apiClient = ApiClient();


  @override
  void dispose() {

    _diagnosisController.dispose();

    _prescriptionController.dispose();

    _treatmentController.dispose();

    _notesController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Manual Diagnosis"),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            TextField(
              controller: _diagnosisController,
              decoration: const InputDecoration(
                labelText: "Diagnosis",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _prescriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Prescription",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _treatmentController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Treatment Plan",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _notesController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: "Notes",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(

                icon: const Icon(Icons.save),

                label: const Text(
                  "Save Diagnosis",
                ),

                onPressed: () async {

                  if (_diagnosisController.text.trim().isEmpty) {

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Diagnosis is required."),
                      ),
                    );

                    return;
                  }

                  try {

                    debugPrint("================================");
                    debugPrint(widget.image.toString());
                    debugPrint("image_id = ${widget.image["image_id"]}");
                    debugPrint("id = ${widget.image["id"]}");
                    debugPrint("================================");

                    await _apiClient.saveManualDiagnosis(

                      imageId: widget.image["image_id"] ?? widget.image["id"],

                      diagnosis: _diagnosisController.text,

                      prescription: _prescriptionController.text,

                      treatmentPlan: _treatmentController.text,

                      notes: _notesController.text,

                    );

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(

                      const SnackBar(

                        content: Text(
                          "✅ Diagnosis saved successfully.",
                        ),

                      ),

                    );

                    Navigator.pop(context);

                  } catch (e) {

                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(

                      SnackBar(
                        content: Text(e.toString()),
                      ),

                    );

                  }

                },

              ),
            ),

          ],
        ),
      ),
    );
  }
}