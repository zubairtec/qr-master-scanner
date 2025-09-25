import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

class MobileScannerService {
  static MobileScannerController controller = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  static String determineContentType(String content) {
    if (content.startsWith('http://') || content.startsWith('https://')) {
      return 'URL';
    } else if (content.startsWith('tel:')) {
      return 'Phone';
    } else if (content.startsWith('mailto:')) {
      return 'Email';
    } else if (content.startsWith('smsto:')) {
      return 'SMS';
    } else if (content.startsWith('WIFI:')) {
      return 'WiFi';
    } else if (content.startsWith('BEGIN:VCARD')) {
      return 'Contact';
    } else if (content.startsWith('BEGIN:VEVENT')) {
      return 'Event';
    } else {
      return 'Text';
    }
  }

  static Future<String?> scanFromCamera() async {
    try {
      return null;
    } catch (e) {
      debugPrint('Mobile scanner error: $e');
      return null;
    }
  }

  static Future<void> launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  static void dispose() {
    controller.dispose();
  }
}
