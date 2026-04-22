import 'package:flutter/material.dart';
import '../utils/constants.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToLogin() => Navigator.pushReplacementNamed(context, '/login');
  void _goToRegister() => Navigator.pushNamed(context, '/register');

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF7F9FC),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── TOP BAR ──────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.health_and_safety,
                                color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "ScanMyTooth",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              color: isDark ? Colors.white : const Color(0xFF0D1B2A),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _IconBtn(icon: Icons.notifications_none_rounded, isDark: isDark),
                          const SizedBox(width: 8),
                          _IconBtn(icon: Icons.logout_rounded, isDark: isDark),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── HERO BANNER ───────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF1565C0),
                          Color(0xFF42A5F5),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x591565C0),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  "AI-Powered",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "Smart Dental\nDiagnosis",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Upload X-rays & get instant\nAI analysis in seconds",
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.medical_services_rounded,
                            color: Colors.white,
                            size: 42,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── QUICK ACTIONS ─────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.videocam_rounded,
                          label: "Instant Video\nConsultation",
                          sub: "Connect within 60 secs",
                          color: const Color(0xFFDCEEFF),
                          iconColor: const Color(0xFF1E6FC4),
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.person_search_rounded,
                          label: "Find Dentists\nNear You",
                          sub: "Confirmed appointments",
                          color: const Color(0xFFD7F5EC),
                          iconColor: const Color(0xFF0E9E6A),
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── DENTAL CONCERNS ───────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Common Dental Concerns",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF0D1B2A),
                        ),
                      ),
                      Text(
                        "View All",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.85,
                    children: const [
                      _ConcernBubble(
                        icon: Icons.sentiment_dissatisfied_rounded,
                        label: "Tooth\nPain",
                        bg: Color(0xFFFFE5E5),
                        iconColor: Color(0xFFD94040),
                      ),
                      _ConcernBubble(
                        icon: Icons.wb_sunny_rounded,
                        label: "Teeth\nWhitening",
                        bg: Color(0xFFFFF6D6),
                        iconColor: Color(0xFFCC9A00),
                      ),
                      _ConcernBubble(
                        icon: Icons.grid_view_rounded,
                        label: "X-Ray\nAnalysis",
                        bg: Color(0xFFDCEEFF),
                        iconColor: Color(0xFF1E6FC4),
                      ),
                      _ConcernBubble(
                        icon: Icons.healing_rounded,
                        label: "Cavity\nDetection",
                        bg: Color(0xFFD7F5EC),
                        iconColor: Color(0xFF0E9E6A),
                      ),
                      _ConcernBubble(
                        icon: Icons.child_friendly_rounded,
                        label: "Gum\nDisease",
                        bg: Color(0xFFF0E4FF),
                        iconColor: Color(0xFF7B3FC4),
                      ),
                      _ConcernBubble(
                        icon: Icons.psychology_rounded,
                        label: "Dental\nAnxiety",
                        bg: Color(0xFFFFEBD6),
                        iconColor: Color(0xFFD97706),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── CONSULT TOP DENTISTS ──────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Consult top dentists",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF0D1B2A),
                        ),
                      ),
                      Text(
                        "View All",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Private consultations with verified dental specialists",
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    height: 190,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: const [
                        _DoctorCard(
                          name: "Dr. Anjali Sharma",
                          title: "Orthodontist",
                          experience: "12 yrs exp",
                          rating: "4.9",
                        ),
                        _DoctorCard(
                          name: "Dr. Rohan Mehta",
                          title: "Oral Surgeon",
                          experience: "15 yrs exp",
                          rating: "4.8",
                        ),
                        _DoctorCard(
                          name: "Dr. Priya Nair",
                          title: "Periodontist",
                          experience: "9 yrs exp",
                          rating: "4.7",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── CTA BUTTONS ───────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _goToLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 6,
                        shadowColor: AppColors.primary.withValues(alpha: 0.4),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _goToRegister,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppColors.primary, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        "Create Account",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── ICON BUTTON ──────────────────────────────────────────────────────────────
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  const _IconBtn({required this.icon, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon,
          size: 20,
          color: isDark ? Colors.white70 : const Color(0xFF0D1B2A)),
    );
  }
}

// ── QUICK ACTION CARD ─────────────────────────────────────────────────────────
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final Color color;
  final Color iconColor;
  final bool isDark;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.sub,
    required this.color,
    required this.iconColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? color.withValues(alpha: 0.15) : color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.35,
              color: isDark ? Colors.white : const Color(0xFF0D1B2A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }
}

// ── CONCERN BUBBLE ────────────────────────────────────────────────────────────
class _ConcernBubble extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bg;
  final Color iconColor;

  const _ConcernBubble({
    required this.icon,
    required this.label,
    required this.bg,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: isDark ? bg.withValues(alpha: 0.15) : bg,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            height: 1.3,
            color: isDark ? Colors.white70 : const Color(0xFF2D3748),
          ),
        ),
      ],
    );
  }
}

// ── DOCTOR CARD ───────────────────────────────────────────────────────────────
class _DoctorCard extends StatelessWidget {
  final String name;
  final String title;
  final String experience;
  final String rating;

  const _DoctorCard({
    required this.name,
    required this.title,
    required this.experience,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: Icon(Icons.person_rounded,
                    size: 32, color: AppColors.primary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E9E6A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "✓",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
              height: 1.3,
              color: isDark ? Colors.white : const Color(0xFF0D1B2A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
              const SizedBox(width: 3),
              Text(
                rating,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white70 : const Color(0xFF0D1B2A),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                experience,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}