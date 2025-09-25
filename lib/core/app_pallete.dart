import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Pallete {
  static const backgroundColor = Colors.white;
  static const bldtxtstyle = TextStyle(
    color: Colors.black,
    fontSize: 25,
    fontWeight: FontWeight.bold,
  );
  static const lighttxtstyle = TextStyle(
    color: Colors.grey,
    fontSize: 20,
    fontWeight: FontWeight.normal,
  );
  static final sizedBoxH8 = SizedBox(height: 8);
  static final sizedBoxH20 = SizedBox(height: 20);
  static final sizedBoxH50 = SizedBox(height: 50);
  static final sizedBoxW10 = SizedBox(width: 10);
  static final sizedBoxW20 = SizedBox(width: 20);
}

class AppConstants {
  static const String appName = 'QR Master Scanner';
  static const String appVersion = '1.0.0';

  static const String admobAppId = 'ca-app-pub-1147747067812343~8429183889';
  static const String bannerAdId = 'ca-app-pub-1147747067812343/6697353713';
  static const String interstitialAdId =
      'ca-app-pub-1147747067812343/5711575108';
  static const String appOpenAdId = 'ca-app-pub-1147747067812343/1234567890';
  static const String scanHistoryKey = 'scan_history';
  static const String favoritesKey = 'favorites';

  static const String beepOnScanKey = 'beep_on_scan';
  static const String vibrateOnScanKey = 'vibrate_on_scan';
  static const String autoCopyKey = 'auto_copy';
  static const String saveHistoryKey = 'save_history';
}

class AppColors {
  static const Color primary = Color(0xFF0066FF);
  static const Color primaryDark = Color(0xFF0055DD);
  static const Color accent = Color(0xFFFF6B35);
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceLight = Color(0xFF2D2D2D);
  static const Color onPrimary = Colors.white;
  static const Color onBackground = Colors.white;
  static const Color onSurface = Colors.white;
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
}

class AppTextStyles {
  static TextStyle headline1(BuildContext context) => TextStyle(
    fontSize: 28.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.onBackground,
  );

  static TextStyle headline2(BuildContext context) => TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.onBackground,
  );

  static TextStyle bodyText1(BuildContext context) => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.onBackground,
  );

  static TextStyle bodyText2(BuildContext context) => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.onBackground,
  );

  static TextStyle caption(BuildContext context) => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.normal,
    color: Colors.white70,
  );

  static TextStyle button(BuildContext context) => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.onPrimary,
  );
}
