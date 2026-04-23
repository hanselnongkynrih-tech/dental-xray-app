import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

// Doctor screens
import 'doctor_patients_screen.dart';
import 'doctor_images_screen.dart';

// Patient screens
import 'patient_dashboard_screen.dart';


// Lab screens
import 'lab_requests_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String role;

  const DashboardScreen({super.key, required this.role});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();

  // ─────────────────────────────────────────────
  // LOGOUT  (matches all individual dashboards)
  // ─────────────────────────────────────────────
  Future<void> _logout() async {
    final navigator = Navigator.of(context);
    await _authService.logout();
    if (!mounted) return;
    navigator.pushNamedAndRemoveUntil('/welcome', (route) => false);
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final role = widget.role;

    return Scaffold(
      backgroundColor: AppColors.background,

      // ── Drawer (matches home_screen.dart style) ──────────────────────────
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
              color: AppColors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, size: 36, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    role.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'dental_classification',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Profile drawer item — role-aware
            _DrawerItem(
              icon: Icons.person_rounded,
              label: 'Profile',
              onTap: () {
                Navigator.pop(context);
                if (role == 'doctor') {
                  Navigator.pushNamed(context, '/doctor_profile');
                } else if (role == 'patient') {
                  Navigator.pushNamed(context, '/patient_profile');
                } else if (role == 'lab') {
                  Navigator.pushNamed(context, '/lab_profile');
                }
              },
            ),

            const Divider(indent: 16, endIndent: 16),

            _DrawerItem(
              icon: Icons.logout_rounded,
              label: 'Logout',
              iconColor: Colors.redAccent,
              labelColor: Colors.redAccent,
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'v1.0.0 · Dental Classification',
                style: TextStyle(fontSize: 11, color: AppColors.textLight),
              ),
            ),
          ],
        ),
      ),

      // ── AppBar ────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          role == 'doctor'
              ? 'Doctor Dashboard'
              : role == 'patient'
              ? 'Patient Dashboard'
              : role == 'lab'
              ? 'Lab Dashboard'
              : 'Admin Dashboard',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: _logout,
          ),
        ],
      ),

      // ── Body ──────────────────────────────────────────────────────────────
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: _buildCards(role),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ROLE-BASED CARDS — exact same navigation as individual dashboard files
  // ─────────────────────────────────────────────────────────────────────────
  List<Widget> _buildCards(String role) {

    // ── DOCTOR ──────────────────────────────────────────────────────────────
    if (role == 'doctor') {
      return [
        _card(Icons.people, "Patients", () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const DoctorPatientsScreen(),
            ),
          );
        }),

        _card(Icons.medical_services, "Diagnoses", () {
          // TODO: wire up DiagnoseScreen when ready
        }),

        _card(Icons.image, "X-ray Images", () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const DoctorImagesScreen(),
            ),
          );
        }),

        _card(Icons.person, "Profile", () {
          Navigator.pushNamed(context, '/doctor_profile');
        }),
      ];

      // ── PATIENT ─────────────────────────────────────────────────────────────
    } else if (role == 'patient') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
          MaterialPageRoute(
            builder: (_) => const PatientDashboardScreen(),
          ),
        );
      });

  return [const SizedBox()]; // temporary empty


  // ── LAB ─────────────────────────────────────────────────────────────────
  }else if (role == 'lab') {
      return [
        _card(Icons.science, "Test Requests", () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const LabRequestsScreen(),
            ),
          );
        }),

        _card(Icons.upload_file, "Upload Results", () {
          // TODO: wire up LabUploadScreen when ready
        }),

        _card(Icons.history, "Reports History", () {
          // TODO: wire up LabReportsScreen when ready
        }),

        _card(Icons.person, "Profile", () {
          Navigator.pushNamed(context, '/lab_profile');
        }),
      ];

      // ── ADMIN ────────────────────────────────────────────────────────────────
    } else {
      return [
        _card(Icons.people, "Manage Users", () {
          Navigator.pushNamed(context, '/admin_dashboard');
        }),

        _card(Icons.image, "All Images", () {
          Navigator.pushNamed(context, '/admin_dashboard');
        }),
      ];
    }
  }

  // ─────────────────────────────────────────────
  // CARD WIDGET  (matches doctor/patient/lab style)
  // ─────────────────────────────────────────────
  Widget _card(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 42, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DRAWER ITEM WIDGET  (matches home_screen.dart)
// ─────────────────────────────────────────────
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.primary),
      title: Text(
        label,
        style: TextStyle(color: labelColor),
      ),
      onTap: onTap,
    );
  }
}