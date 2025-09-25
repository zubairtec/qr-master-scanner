import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_master_scanner/core/app_pallete.dart';
import 'package:qr_master_scanner/core/services/ad_service.dart';
import 'package:qr_master_scanner/presentation/features/qrresult/create_qr_result_screen.dart';
import 'package:qr_master_scanner/presentation/widgets/ad_banner_widget.dart';

class CreateURLScreen extends StatefulWidget {
  const CreateURLScreen({super.key});

  @override
  State<CreateURLScreen> createState() => _CreateURLScreenState();
}

class _CreateURLScreenState extends State<CreateURLScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _generateQRCode() {
    AdService().showInterstitialAd();
    if (_formKey.currentState!.validate()) {
      String url = _urlController.text.trim();
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }
      Get.to(() => CreateQRResultScreen(data: url, type: 'URL'));
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
          'Create URL QR Code',
          style: AppTextStyles.headline2(context),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AdBannerWidget(),
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'Website URL',
                  hintText: 'https://example.com',
                  prefixIcon: Icon(Icons.link),
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a URL';
                  }
                  return null;
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
