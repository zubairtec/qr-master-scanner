import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_master_scanner/core/app_pallete.dart';
import 'package:qr_master_scanner/core/services/ad_service.dart';
import 'package:qr_master_scanner/core/services/mobile_scanner_service.dart';
import 'package:qr_master_scanner/presentation/features/home/home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _navigated = false;
  bool _isLoading = true;
  bool _showGetStarted = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final adService = Provider.of<AdService>(context, listen: false);

    try {
      adService.initialize();

      await _tryShowAppOpenAd(adService);
    } catch (e) {
      debugPrint('Ad initialization error: $e');
    } finally {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted && !_navigated) {
          setState(() {
            _isLoading = false;
            _showGetStarted = true;
          });
        }
      });
    }
  }

  Future<void> _tryShowAppOpenAd(AdService adService) async {
    try {
      await Future.any<dynamic>([
        Future.delayed(const Duration(seconds: 2)),
        adService.showAppOpenAd().catchError((e) {
          debugPrint('App open ad error caught: $e');
          return;
        }),
      ]);
    } catch (e) {
      debugPrint('App open ad flow error: $e');
    }
  }

  void _navigateToHome() async {
    if (_navigated) return;
    _navigated = true;

    final adService = Provider.of<AdService>(context, listen: false);

    await _showInterstitialWithTimeout(adService);

    Get.offAll(() => const HomeScreen());
  }

  Future<void> _showInterstitialWithTimeout(AdService adService) async {
    try {
      await Future.any<dynamic>([
        Future.delayed(const Duration(seconds: 3)),
        Future(() => adService.showInterstitialAd()).catchError((e) {
          debugPrint('Interstitial ad error caught: $e');
          return;
        }),
      ]);
    } catch (e) {
      debugPrint('Interstitial flow error: $e');
    }
  }

  void _openPrivacyPolicy() {
    MobileScannerService.launchURL('https://zubairtec.github.io');
  }

  void _openTermsOfUse() {
    MobileScannerService.launchURL(
      'https://docs.google.com/document/d/1THC8FPo8bkH8f0M_zq-KtDZRUOJDamUECl2laBPRa6rw/edit?tab=t.0',
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(360, 800),
      minTextAdapt: true,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              // ignore: deprecated_member_use
              AppColors.primary.withOpacity(0.8),
              AppColors.primaryDark,
              AppColors.background,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: AppColors.surfaceLight.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: EdgeInsets.all(24.w),
                child: Image.asset(
                  "assets/images/playstore.png",
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 30.h),
              Text(
                "QR Master Scanner",
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onPrimary,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Scan. Save. Organize.",
                style: TextStyle(
                  fontSize: 16.sp,
                  // ignore: deprecated_member_use
                  color: AppColors.onSurface.withOpacity(0.8),
                  fontWeight: FontWeight.w300,
                ),
              ),
              SizedBox(height: 50.h),
              if (_isLoading)
                Column(
                  children: [
                    SizedBox(
                      width: 30.w,
                      height: 30.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.onPrimary,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      "Preparing...",
                      style: TextStyle(
                        fontSize: 14.sp,
                        // ignore: deprecated_member_use
                        color: AppColors.onPrimary.withOpacity(0.7),
                      ),
                    ),
                  ],
                )
              else if (_showGetStarted)
                Container(
                  width: 200.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25.r),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 32.w,
                        vertical: 12.h,
                      ),
                    ),
                    onPressed: _navigateToHome,
                    child: Text(
                      "Get Started",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 20.h),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        fontSize: 12.sp,
                        // ignore: deprecated_member_use
                        color: AppColors.onPrimary.withOpacity(0.8),
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = _openPrivacyPolicy,
                    ),
                    TextSpan(
                      text: ' • ',
                      style: TextStyle(
                        fontSize: 12.sp,
                        // ignore: deprecated_member_use
                        color: AppColors.onPrimary.withOpacity(0.6),
                      ),
                    ),
                    TextSpan(
                      text: 'Terms of Use',
                      style: TextStyle(
                        fontSize: 12.sp,
                        // ignore: deprecated_member_use
                        color: AppColors.onPrimary.withOpacity(0.8),
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = _openTermsOfUse,
                    ),
                    TextSpan(
                      text: '\nVersion ${AppConstants.appVersion}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        // ignore: deprecated_member_use
                        color: AppColors.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _navigated = true;
    super.dispose();
  }
}
