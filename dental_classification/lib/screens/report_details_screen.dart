import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../utils/constants.dart';

class ReportDetailsScreen extends StatefulWidget {
  final int imageId;

  const ReportDetailsScreen({
    super.key,
    required this.imageId,
  });

  @override
  State<ReportDetailsScreen> createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {

  final ApiClient _apiClient = ApiClient();

  bool isLoading = true;
  Map<String, dynamic>? report;

  @override
  void initState() {
    super.initState();
    loadReport();
  }

  Future<void> loadReport() async {
    try {
      final data =
      await _apiClient.getReportDetails(widget.imageId);

      setState(() {
        report = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );

      setState(() {
        isLoading = false;
      });
    }
  }



  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [

          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget imageCard(
      String title,
      String? imagePath,
      ) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [

            sectionTitle(title),

            const SizedBox(height: 10),

            if (imagePath == null ||
                imagePath.isEmpty)

              Container(
                height: 220,
                alignment: Alignment.center,
                color: Colors.grey.shade200,
                child: const Text(
                  "No Image Available",
                ),
              )

            else

              ClipRRect(
                borderRadius:
                BorderRadius.circular(10),
                child: Image.network(
                  "${Constants.apiBaseUrl}/$imagePath",
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget cardTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child:
          CircularProgressIndicator(),
        ),
      );
    }

    if (report == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Dental Report",
          ),
        ),
        body: const Center(
          child: Text(
            "No report found",
          ),
        ),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Dental Report",
          ),
          centerTitle: true,
        ),

        body: SingleChildScrollView(

          padding:
          const EdgeInsets.all(16),

          child: Column(

            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

            Card(
            elevation: 4,

            child: Padding(

              padding:
              const EdgeInsets.all(16),

              child: Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  cardTitle(
                    "Patient Information",
                  ),

                  infoTile(
                    "Patient",
                    report!["patient_name"] ?? "",
                  ),

                  infoTile(
                    "Token",
                    report!["token_number"]
                        .toString(),
                  ),

                  infoTile(
                    "Status",
                    report!["status"] ?? "",
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          imageCard(
            "Original X-Ray",
            report!["original_xray"],
          ),

          imageCard(
            "Lab Report",
            report!["lab_report"],
          ),

          Card(
            elevation: 4,
            child: Padding(
              padding:
              const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  cardTitle(
                    "Doctor Request",
                  ),

                  infoTile(
                    "Request",
                    report!["request_type"] ??
                        "",
                  ),

                  infoTile(
                    "Priority",
                    report!["priority"] ??
                        "",
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Doctor Notes",
                    style: TextStyle(
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    report!["doctor_notes"] ??
                        "",
                  ),
                ],
              ),
            ),
          ),
              const SizedBox(height: 20),

              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [

                      cardTitle("ML Diagnosis"),

                      infoTile(
                        "Disease",
                        report!["result"] ??
                            "Not Generated Yet",
                      ),

                      infoTile(
                        "Confidence",
                        report!["confidence"] == null
                            ? "-"
                            : "${((report!["confidence"] as num) * 100).toStringAsFixed(2)} %",
                      ),

                      const SizedBox(height: 15),

                      const Text(
                        "The ML model has not yet generated the final report.",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text(
                    "Download Lab Report",
                  ),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);

                    try {
                      await _apiClient.downloadLabReport(widget.imageId);
                    } catch (e) {
                      if (!mounted) return;

                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                        ),
                      );
                    }
                  },
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text(
                    "Download ML Report",
                  ),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);

                    try {
                      await _apiClient.downloadLabReport(widget.imageId);
                    } catch (e) {
                      if (!mounted) return;

                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                        ),
                      );
                    }
                  },
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text("Refresh"),
                  onPressed: loadReport,
                ),
              ),

              const SizedBox(height: 30),

            ],
          ),
        ),
    );
  }
}