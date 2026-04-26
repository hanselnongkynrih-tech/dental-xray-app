import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/auth_service.dart';
import '../utils/constants.dart';

class ReportScreen extends StatefulWidget {
  final int imageId;

  const ReportScreen({super.key, required this.imageId});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  List reports = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadReports();
  }

  Future<void> loadReports() async {
    final token = await AuthService().getToken();

    final response = await http.get(
      Uri.parse("${Constants.apiBaseUrl}/doctor/reports?image_id=${widget.imageId}"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      setState(() {
        reports = jsonDecode(response.body);
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reports")),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final r = reports[index];

          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              leading: Image.network(
                "${Constants.apiBaseUrl}/${r['image_path']}",
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text(r['full_name']),
              subtitle: Text(
                "Diagnosis: ${r['label']}\nConfidence: ${(r['confidence'] * 100).toStringAsFixed(1)}%",
              ),
            ),
          );
        },
      ),
    );
  }
}