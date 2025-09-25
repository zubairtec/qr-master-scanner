import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_master_scanner/core/app_pallete.dart';
import 'package:qr_master_scanner/core/services/ad_service.dart';
import 'package:qr_master_scanner/core/services/qr_generator_service.dart';
import 'package:qr_master_scanner/presentation/features/qrresult/create_qr_result_screen.dart';
import 'package:qr_master_scanner/presentation/widgets/ad_banner_widget.dart';

class CreateWiFiScreen extends StatefulWidget {
  const CreateWiFiScreen({super.key});

  @override
  State<CreateWiFiScreen> createState() => _CreateWiFiScreenState();
}

class _CreateWiFiScreenState extends State<CreateWiFiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ssidController = TextEditingController();
  final _passwordController = TextEditingController();
  String _encryptionType = 'WPA';

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _generateQRCode() {
    if (_formKey.currentState!.validate()) {
      AdService().showInterstitialAd();
      final wifiData = QRGeneratorService.createWifiQRCode(
        _ssidController.text.trim(),
        _passwordController.text.trim(),
        _encryptionType,
      );
      Get.to(() => CreateQRResultScreen(data: wifiData, type: 'WiFi'));
    } else {
      debugPrint("Validation Failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Create WiFi QR Code',
          style: AppTextStyles.headline2(context),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              AdBannerWidget(),
              TextFormField(
                controller: _ssidController,
                decoration: const InputDecoration(
                  labelText: 'Network Name (SSID)',
                  prefixIcon: Icon(Icons.wifi),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter network name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _encryptionType,
                decoration: const InputDecoration(
                  labelText: 'Encryption Type',
                  prefixIcon: Icon(Icons.security),
                ),
                items: const [
                  DropdownMenuItem(value: 'WPA', child: Text('WPA/WPA2')),
                  DropdownMenuItem(value: 'WEP', child: Text('WEP')),
                  DropdownMenuItem(
                    value: 'nopass',
                    child: Text('No Encryption'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _encryptionType = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(AppColors.primary),
                ),
                onPressed: _generateQRCode,
                child: Text(
                  'Generate QR Code',
                  style: AppTextStyles.bodyText1(context),
                ),
              ),

              const SizedBox(height: 20),
              AdBannerWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
