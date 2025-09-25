import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_master_scanner/core/app_pallete.dart';
import 'package:qr_master_scanner/presentation/features/createUrl/create_url_screen.dart';
import 'package:qr_master_scanner/presentation/features/createwifi/create_wifi_screen.dart';
import 'package:qr_master_scanner/presentation/widgets/ad_banner_widget.dart';

class CreateScreen extends StatelessWidget {
  const CreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text('Create QR Code', style: AppTextStyles.headline2(context)),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          AdBannerWidget(),
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text('Website URL'),
            onTap: () {
              Get.to(() => CreateURLScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.wifi),
            title: const Text('Wi-Fi Network'),
            onTap: () {
              Get.to(() => CreateWiFiScreen());
            },
          ),

          // ListTile(
          //   leading: const Icon(Icons.text_fields),
          //   title: const Text('Text'),
          //   onTap: () {
          //     // Navigate to text creation
          //   },
          // ),
          // ListTile(
          //   leading: const Icon(Icons.contact_page),
          //   title: const Text('Contact'),
          //   onTap: () {
          //     // Navigate to contact creation
          //   },
          // ),
          // ListTile(
          //   leading: const Icon(Icons.phone),
          //   title: const Text('Phone'),
          //   onTap: () {
          //     // Navigate to phone creation
          //   },
          // ),
          // ListTile(
          //   leading: const Icon(Icons.email),
          //   title: const Text('Email'),
          //   onTap: () {
          //     // Navigate to email creation
          //   },
          // ),
          // ListTile(
          //   leading: const Icon(Icons.message),
          //   title: const Text('SMS'),
          //   onTap: () {
          //     // Navigate to SMS creation
          //   },
          // ),
          // ListTile(
          //   leading: const Icon(Icons.calendar_today),
          //   title: const Text('Event'),
          //   onTap: () {
          //     // Navigate to event creation
          //   },
          // ),
        ],
      ),
    );
  }
}
