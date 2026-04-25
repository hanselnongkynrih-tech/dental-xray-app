import 'package:flutter/material.dart';

import 'patient_dashboard_screen.dart';
import 'doctor_dashboard_screen.dart';
import 'lab_dashboard_screen.dart';
import 'admin_dashboard_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String role;

  const DashboardScreen({super.key, required this.role});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  @override
  void initState() {
    super.initState();
    _navigate();
  }

  void _navigate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {

      if (widget.role == 'patient') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const PatientDashboardScreen(),
          ),
        );

      } else if (widget.role == 'doctor') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const DoctorDashboardScreen(),
          ),
        );

      } else if (widget.role == 'lab') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LabDashboardScreen(),
          ),
        );

      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const AdminDashboardScreen(),
          ),
        );
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}