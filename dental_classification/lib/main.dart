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

import 'screens/doctor_dashboard_screen.dart';
import 'screens/patient_dashboard_screen.dart';
import 'screens/lab_dashboard_screen.dart';

import 'screens/otp_screen.dart';

import 'screens/admin_dashboard_screen.dart';


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

      initialRoute: '/welcome',

      routes: {

        '/': (context) => const WelcomeScreen(),
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

        '/doctor_dashboard': (context) =>
        const DoctorDashboardScreen(),

        '/patient_dashboard': (context) =>
        const PatientDashboardScreen(),

        '/lab_dashboard': (context) =>
        const LabDashboardScreen(),

        '/admin_dashboard': (context) =>
        const AdminDashboardScreen(),


        '/otp': (context) {

          final mobile =
          ModalRoute.of(context)!.settings.arguments as String;

          return OtpScreen(mobileNumber: mobile);

        },
      },
    );
  }
}