import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:qr_master_scanner/core/services/ad_service.dart';
import 'package:qr_master_scanner/core/theme.dart';
import 'package:qr_master_scanner/di/service_locator.dart';
import 'package:qr_master_scanner/presentation/features/splashscreens/welcome_screen.dart';
import 'package:qr_master_scanner/presentation/provider/scanner_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final AdService _adService = AdService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAds();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Future.delayed(const Duration(seconds: 1), () {
        if (_adService.canShowAppOpenAd()) {
          _adService.showAppOpenAd();
        }
      });
    }
  }

  void _initializeAds() {
    _adService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => sl<ScanProvider>()),
        ChangeNotifierProvider(create: (_) => _adService),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'QR Master Scanner',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: WelcomeScreen(),
      ),
    );
  }
}
