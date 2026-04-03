import 'dart:io';
//import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../services/auth_service.dart';
import '../utils/constants.dart';

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  State<PatientDashboardScreen> createState() =>
      _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  File? _xrayImage;
  bool _isUploading = false;

  // ===============================
  // LOGOUT
  // ===============================
  Future<void> _logout() async {
    final navigator = Navigator.of(context);
    await _authService.logout();
    if (!mounted) return;
    navigator.pushNamedAndRemoveUntil('/welcome', (route) => false);
  }

  // ===============================
  // PICK IMAGE
  // ===============================
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

  // ===============================
  // ✅ FIXED UPLOAD FUNCTION
  // ===============================
  Future<void> _uploadXray() async {
    if (_xrayImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an X-ray image first')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final token = await _authService.getToken();

      final uri = Uri.parse('${Constants.apiBaseUrl}/images/upload');

      var request = http.MultipartRequest('POST', uri);

      // ✅ Add token
      request.headers['Authorization'] = 'Bearer $token';

      // ✅ MUST be 'file'
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload successful')),
        );

        // 🔥 Reset image after upload
        setState(() {
          _xrayImage = null;
        });

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Upload failed (${response.statusCode}): $responseBody',
            ),
          ),
        );
      }

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  // ===============================
  // IMAGE PREVIEW
  // ===============================
  Widget _buildXrayPreview() {
    if (_xrayImage == null) {
      return Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Center(
          child: Text(
            'No X-ray selected',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.file(
        _xrayImage!,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  // ===============================
  // BUTTON UI
  // ===============================
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // ===============================
  // UI
  // ===============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dental X-ray Upload',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Select an X-ray image and upload it securely for processing.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'X-ray Preview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            _buildXrayPreview(),

            const SizedBox(height: 20),

            Row(
              children: [
                _buildActionButton(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onPressed: () => _pickXray(ImageSource.gallery),
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onPressed: () => _pickXray(ImageSource.camera),
                ),
              ],
            ),

            const SizedBox(height: 20),

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
                  _isUploading ? 'Uploading...' : 'Upload X-ray',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}