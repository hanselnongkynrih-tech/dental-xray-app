import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/register_screen.dart';

import 'screens/doctor_registration_screen.dart';
import 'screens/patient_registration_screen.dart';
import 'screens/lab_registration_screen.dart';

import 'screens/doctor_profile_screen.dart';
import 'screens/patient_profile_screen.dart';
import 'screens/lab_profile_screen.dart';


import 'screens/otp_screen.dart';

import 'screens/admin_dashboard_screen.dart';

import 'screens/splash_screen.dart';

import 'screens/dashboard_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'services/auth_service.dart';




Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ IMPORTANT
  await Firebase.initializeApp(); // ✅ IMPORTANT

  runApp(const DentalClassificationApp());
}

class DentalClassificationApp extends StatelessWidget {
  const DentalClassificationApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Dental Classifier",

      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF4F6FA),

        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.blue,
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF121212),

        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.black,
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      themeMode: ThemeMode.system,

      //home: const AppStartRouter(),
      initialRoute: '/',

      routes: {

        '/': (context) => AppStartRouter(),

        //'/splash': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),

        '/home': (context) => HomeScreen(),

        '/register': (context) => const RegisterScreen(),

        '/doctor_registration': (context) =>
        const DoctorRegistrationScreen(),

        '/patient_registration': (context) =>
        const PatientRegistrationScreen(),

        '/lab_registration': (context) =>
        const LabRegistrationScreen(),

        '/doctor_profile': (context) =>
        const DoctorProfileScreen(),

        '/patient_profile': (context) =>
        const PatientProfileScreen(),

        '/lab_profile': (context) =>
        const LabProfileScreen(),

        '/dashboard': (context) {
          final role = ModalRoute.of(context)!.settings.arguments as String;
          return DashboardScreen(role: role);
        },

        '/admin_dashboard': (context) =>
        const AdminDashboardScreen(),


        '/otp': (context) {
          // ✅ Extract the Map instead of a String
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

          return OtpScreen(
            mobileNumber: args['mobileNumber'],
            role: args['role'],
          );
        },
      },
    );

  }
}

class AppStartRouter extends StatefulWidget {
  const AppStartRouter({super.key});

  @override
  State<AppStartRouter> createState() => _AppStartRouterState();
}

class _AppStartRouterState extends State<AppStartRouter> {

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    debugPrint("START CHECK LOGIN");

    final authService = AuthService();

    String? token;

    try {
      token = await authService
          .getToken()
          .timeout(const Duration(seconds: 2), onTimeout: () {
        debugPrint("TOKEN TIMEOUT");
        return null;
      });
    } catch (e) {
      debugPrint("TOKEN ERROR: $e");
      token = null;
    }

    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString("role");

    debugPrint("TOKEN: $token");
    debugPrint("ROLE: $role");

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (token != null && token.isNotEmpty && role != null) {
      debugPrint("GO TO DASHBOARD");
      Navigator.pushReplacementNamed(
        context,
        '/dashboard',
        arguments: role,
      );
    } else {
      debugPrint("GO TO WELCOME");
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}