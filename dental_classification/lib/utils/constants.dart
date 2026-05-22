// lib/utils/constants.dart
/*class Constants {
  // CHANGE this IP to your PC's IPv4 from `ipconfig`
  static const String apiBaseUrl = 'http://192.168.29.163:8000';
}
*/

import 'package:flutter/material.dart';

//import 'dart:io';

class AppColors {

  static const primary = Color(0xFF2563EB);

  static const background = Color(0xFFF4F6FA);

  static const card = Colors.white;

  static const textDark = Color(0xFF1F2937);

  static const textLight = Color(0xFF6B7280);

}

class AppSpacing {

  static const small = 8.0;
  static const medium = 16.0;
  static const large = 24.0;

}

/*class Constants {
  // for Android emulator
  static const apiBaseUrl = 'http://10.0.2.2:8000';
}*/

/*class Constants {

  static String get apiBaseUrl {

    // Android Emulator
    if (Platform.isAndroid) {

      // Detect emulator
      if (!Platform.environment.containsKey('FLUTTER_TEST')) {
        return 'http://10.0.2.2:8000';
      }
    }

    // Physical device using adb reverse
    return 'http://127.0.0.1:8000';
  }
}*/

class Constants {
  static const String apiBaseUrl = 'http://127.0.0.1:8000';
}