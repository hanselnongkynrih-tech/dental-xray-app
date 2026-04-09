import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../services/auth_service.dart';
import '../utils/constants.dart';

class PatientUploadScreen extends StatefulWidget {
  const PatientUploadScreen({super.key});

  @override
  State<PatientUploadScreen> createState() =>
      _PatientUploadScreenState();
}

class _PatientUploadScreenState extends State<PatientUploadScreen> {
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  File? _xrayImage;
  bool _isUploading = false;

  // ===================== PICK IMAGE =====================
  Future<void> _pickXray(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 90,
    );

    if (picked != null) {
      setState(() => _xrayImage = File(picked.path));
    }
  }

  // ===================== UPLOAD =====================
  Future<void> _uploadXray() async {
    if (_xrayImage == null) {
      _showMessage("Please select an X-ray image first");
      return;
    }

    setState(() => _isUploading = true);

    try {
      final token = await _authService.getToken();

      final uri = Uri.parse('${Constants.apiBaseUrl}/images/upload');

      var request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          _xrayImage!.path,
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (!mounted) return;

      if (response.statusCode == 200) {
        _showMessage("Upload successful ✅");

        setState(() => _xrayImage = null);
      } else {
        _showMessage("Upload failed (${response.statusCode}): $responseBody");
      }

    } catch (e) {
      _showMessage("Error: $e");
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  // ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload X-ray"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // IMAGE PREVIEW CARD
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _xrayImage == null
                  ? const Center(
                child: Text(
                  "No X-ray selected",
                  style: TextStyle(color: Colors.black54),
                ),
              )
                  : ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  _xrayImage!,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // BUTTONS
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickXray(ImageSource.gallery),
                    icon: const Icon(Icons.photo),
                    label: const Text("Gallery"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickXray(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Camera"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // UPLOAD BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _uploadXray,
                icon: _isUploading
                    ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.cloud_upload),
                label: Text(
                  _isUploading ? "Uploading..." : "Upload X-ray",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}