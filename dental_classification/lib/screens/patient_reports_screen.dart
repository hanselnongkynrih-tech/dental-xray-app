import 'package:flutter/material.dart';

import '../api/api_client.dart';
import 'report_details_screen.dart';

class PatientReportsScreen extends StatefulWidget {
  const PatientReportsScreen({Key? key}) : super(key: key);

  @override
  State<PatientReportsScreen> createState() =>
      _PatientReportsScreenState();
}

class _PatientReportsScreenState
    extends State<PatientReportsScreen> {
  final ApiClient _apiClient = ApiClient();

  bool isLoading = true;

  List<dynamic> reports = [];

  @override
  void initState() {
    super.initState();
    loadReports();
  }

  Future<void> loadReports() async {
    try {
      final data =
      await _apiClient.getPatientReports();

      if (!mounted) return;

      setState(() {
        reports = data;
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

  Widget reportCard(Map report) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [

            Row(
              children: [

                const CircleAvatar(
                  radius: 24,
                  child: Icon(Icons.description),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [

                      Text(
                        "Token #${report["token_number"]}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "Status : ${report["status"]}",
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon:
                const Icon(Icons.visibility),
                label:
                const Text("View Report"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ReportDetailsScreen(
                            imageId:
                            report["image_id"],
                          ),
                    ),
                  );
                },
              ),
            ),
          ],
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

    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "My Reports",
          ),
          centerTitle: true,
        ),

        body: RefreshIndicator(
            onRefresh: loadReports,

            child: reports.isEmpty
                ? ListView(
              physics:
              const AlwaysScrollableScrollPhysics(),
              children: const [

                SizedBox(height: 120),

                Icon(
                  Icons.description_outlined,
                  size: 80,
                  color: Colors.grey,
                ),

                SizedBox(height: 20),

                Center(
                  child: Text(
                    "No Reports Available",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(height: 10),

                Center(
                  child: Text(
                    "Completed reports will appear here.",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            )

                : ListView.builder(

              padding:
              const EdgeInsets.all(16),

              itemCount: reports.length,

              itemBuilder: (context, index) {

                return reportCard(
                  reports[index],
                );

              },
            ),
        ),
    );
  }
}