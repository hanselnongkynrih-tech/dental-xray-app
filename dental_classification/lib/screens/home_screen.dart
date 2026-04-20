import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();

  void _logout(BuildContext context) async {
    await _authService.logout();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ── Sidebar / Drawer ──────────────────────────────────────────────────
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
                  const Text(
                    'Welcome',
                    style: TextStyle(
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

            _DrawerItem(
              icon: Icons.login_rounded,
              label: 'Login',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/login');
              },
            ),
            _DrawerItem(
              icon: Icons.app_registration_rounded,
              label: 'Register',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/register');
              },
            ),
            _DrawerItem(
              icon: Icons.medical_information_rounded,
              label: 'Doctor Info',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/doctor_profile');
              },
            ),
            _DrawerItem(
              icon: Icons.local_hospital_rounded,
              label: 'Clinic Info',
              onTap: () {
                Navigator.pop(context);
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
                _logout(context);
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
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
          children: [
            Icon(Icons.local_hospital, color: AppColors.primary, size: 24),
            const SizedBox(width: 8),
            Text(
              'HealthCare',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),

      // ── Body ──────────────────────────────────────────────────────────────
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── 2 Service cards (Lab Tests + Surgeries only) ──
            SizedBox(
              height: 230,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: const [
                  _ServiceCard(
                    title: 'Lab Tests',
                    subtitle: 'Safe and trusted lab tests',
                    bgColor: Color(0xFFE8E0F7),
                    icon: Icons.science_rounded,
                    iconColor: Color(0xFF7B3FE4),
                  ),
                  _ServiceCard(
                    title: 'Surgeries',
                    subtitle: 'Safe and trusted surgery centers',
                    bgColor: Color(0xFFEDEDED),
                    icon: Icons.medical_services_rounded,
                    iconColor: Color(0xFF5F6368),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Our Doctors header ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Consult top doctors online\nfor any health concern',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Private online consultations with verified\ndoctors in all specialists',
                        style: TextStyle(fontSize: 12, color: AppColors.textLight),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Doctor cards ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: const [
                  _DoctorCard(
                    name: 'Dr. Anjali Sharma',
                    title: 'BDS, MDS – Orthodontics',
                    specialty: 'Orthodontist',
                    experience: '12 years experience',
                    award: '🏆 Best Dentist Award 2023',
                    rating: '4.9',
                    reviews: '320 reviews',
                    avatarColor: Color(0xFFD6E8FB),
                    avatarIconColor: Color(0xFF1A73E8),
                  ),
                  SizedBox(height: 14),
                  _DoctorCard(
                    name: 'Dr. Rohan Mehta',
                    title: 'BDS, MDS – Oral Surgery',
                    specialty: 'Oral & Maxillofacial Surgeon',
                    experience: '15 years experience',
                    award: '🏅 Excellence in Surgery 2022',
                    rating: '4.8',
                    reviews: '275 reviews',
                    avatarColor: Color(0xFFD8F3EC),
                    avatarIconColor: Color(0xFF0F9D58),
                  ),
                  SizedBox(height: 14),
                  _DoctorCard(
                    name: 'Dr. Priya Nair',
                    title: 'BDS, MDS – Periodontics',
                    specialty: 'Periodontist',
                    experience: '9 years experience',
                    award: '⭐ Top Rated Specialist 2023',
                    rating: '4.7',
                    reviews: '198 reviews',
                    avatarColor: Color(0xFFE8E0F7),
                    avatarIconColor: Color(0xFF7B3FE4),
                  ),
                  SizedBox(height: 14),
                  _DoctorCard(
                    name: 'Dr. Sameer Kulkarni',
                    title: 'BDS, Fellowship – Implantology',
                    specialty: 'Implantologist',
                    experience: '18 years experience',
                    award: '🥇 National Implant Award 2021',
                    rating: '5.0',
                    reviews: '410 reviews',
                    avatarColor: Color(0xFFFFF3CD),
                    avatarIconColor: Color(0xFFF59E0B),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Drawer Item ──────────────────────────────────────────────────────────────

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
      leading: Icon(icon, color: iconColor ?? AppColors.primary, size: 22),
      title: Text(
        label,
        style: TextStyle(
          color: labelColor ?? const Color(0xFF1F2937),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      horizontalTitleGap: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    );
  }
}

// ── Service Card ─────────────────────────────────────────────────────────────

class _ServiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color bgColor;
  final IconData icon;
  final Color iconColor;

  const _ServiceCard({
    required this.title,
    required this.subtitle,
    required this.bgColor,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Center(child: Icon(icon, size: 56, color: iconColor)),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Doctor Card ──────────────────────────────────────────────────────────────

class _DoctorCard extends StatelessWidget {
  final String name;
  final String title;
  final String specialty;
  final String experience;
  final String award;
  final String rating;
  final String reviews;
  final Color avatarColor;
  final Color avatarIconColor;

  const _DoctorCard({
    required this.name,
    required this.title,
    required this.specialty,
    required this.experience,
    required this.award,
    required this.rating,
    required this.reviews,
    required this.avatarColor,
    required this.avatarIconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: avatar + name + rating
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: avatarColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person, size: 36, color: avatarIconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      specialty,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
                    const SizedBox(width: 2),
                    Text(
                      rating,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          Row(
            children: [
              Icon(Icons.work_history_rounded, size: 14, color: AppColors.textLight),
              const SizedBox(width: 4),
              Text(experience,
                  style: TextStyle(fontSize: 12, color: AppColors.textLight)),
            ],
          ),

          const SizedBox(height: 6),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Text(
              award,
              style: const TextStyle(fontSize: 11, color: Color(0xFF1D4ED8)),
            ),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(reviews,
                  style: TextStyle(fontSize: 11, color: AppColors.textLight)),
              SizedBox(
                height: 32,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Book Now',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
