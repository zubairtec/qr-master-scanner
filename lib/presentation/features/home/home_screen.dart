import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_master_scanner/presentation/features/createscan/create_scan_screen.dart';
import 'package:qr_master_scanner/presentation/features/history/history_screen.dart';
import 'package:qr_master_scanner/presentation/features/scan/scan_screen.dart';
import 'package:qr_master_scanner/presentation/features/settings/setting_screen.dart';
import 'package:qr_master_scanner/presentation/provider/scanner_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ScanScreen(),
    const HistoryScreen(),
    const CreateScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ScanProvider>(context, listen: false).loadScanHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Create'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
