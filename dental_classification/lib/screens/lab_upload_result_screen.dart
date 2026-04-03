import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../services/auth_service.dart';
import '../utils/constants.dart';

class LabUploadResultScreen extends StatefulWidget {
  final int imageId;

  const LabUploadResultScreen({super.key, required this.imageId});

  @override
  State<LabUploadResultScreen> createState() =>
      _LabUploadResultScreenState();
}

class _LabUploadResultScreenState extends State<LabUploadResultScreen> {
  File? selectedFile;
  bool isUploading = false;

  final AuthService _authService = AuthService();

  Future<void> pickFile() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        selectedFile = File(picked.path);
      });
    }
  }

  Future<void> uploadResult() async {
    if (selectedFile == null) return;

    setState(() => isUploading = true);

    try {
      final token = await _authService.getToken();

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Constants.apiBaseUrl}/lab-results/upload'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      request.fields['image_id'] = widget.imageId.toString();

      request.files.add(
        await http.MultipartFile.fromPath('file', selectedFile!.path),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Upload successful")),
        );
        Navigator.pop(context);
      } else {
        throw Exception("Upload failed");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Result")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: pickFile,
              child: const Text("Pick Report Image"),
            ),
            const SizedBox(height: 10),
            if (selectedFile != null)
              Image.file(selectedFile!, height: 150),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: isUploading ? null : uploadResult,
              child: isUploading
                  ? const CircularProgressIndicator()
                  : const Text("Upload Result"),
            )
          ],
        ),
      ),
    );
  }
}