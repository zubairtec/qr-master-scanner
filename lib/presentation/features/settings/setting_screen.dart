import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_master_scanner/core/app_pallete.dart';
import 'package:qr_master_scanner/presentation/widgets/ad_banner_widget.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text('Settings', style: AppTextStyles.headline2(context)),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AdBannerWidget(),
          Text(
            "Working in progress",
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          AdBannerWidget(),

          // const ListTile(title: Text('General Settings')),
          // SwitchListTile(
          //   title: const Text('Beep on successful scan'),
          //   value: true,
          //   onChanged: (value) {},
          // ),
          // SwitchListTile(
          //   title: const Text('Auto-copy to clipboard'),
          //   value: true,
          //   onChanged: (value) {},
          // ),
          // SwitchListTile(
          //   title: const Text('Vibrate on scan'),
          //   value: true,
          //   onChanged: (value) {},
          // ),
          // SwitchListTile(
          //   title: const Text('Save history'),
          //   value: true,
          //   onChanged: (value) {},
          // ),
          // const Divider(),
          // const ListTile(title: Text('Help & Support')),
          // ListTile(title: const Text('Rate App'), onTap: () {}),
          // ListTile(title: const Text('FAQ'), onTap: () {}),
          // ListTile(title: const Text('Send Feedback'), onTap: () {}),
          // ListTile(title: const Text('Privacy Policy'), onTap: () {}),
          // ListTile(title: const Text('Share App'), onTap: () {}),
        ],
      ),
    );
  }
}
