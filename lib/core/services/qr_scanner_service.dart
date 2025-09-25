import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class QRScannerService {
  MobileScannerController? controller;
  ValueNotifier<bool>? _torchNotifier;
  ValueNotifier<CameraFacing>? _cameraFacingNotifier;
  QRScannerService({this.controller}) {
    if (controller != null) {
      _torchNotifier = ValueNotifier<bool>(false);
      _cameraFacingNotifier = ValueNotifier<CameraFacing>(CameraFacing.back);
    }
  }
  static Future<String?> scanImage(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        return null;
      }
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final MobileScannerController tempController = MobileScannerController(
        detectionTimeoutMs: 5000,
        returnImage: false,
      );
      try {
        final BarcodeCapture? capture = await tempController.analyzeImage(
          imageBytes as String,
        );
        if (capture != null && capture.barcodes.isNotEmpty) {
          return capture.barcodes.first.rawValue;
        }
      } catch (e) {
        debugPrint('Image analysis error: $e');
      } finally {
        await tempController.dispose();
      }
      return null;
    } catch (e) {
      debugPrint('Image scanning error: $e');
      return null;
    }
  }

  static Future<String?> scanImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return null;
      return await scanImage(image.path);
    } catch (e) {
      debugPrint('Gallery image scanning error: $e');
      return null;
    }
  }

  static Future<String?> scanImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image == null) return null;
      return await scanImage(image.path);
    } catch (e) {
      debugPrint('Camera image scanning error: $e');
      return null;
    }
  }

  static Future<void> launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      debugPrint('URL launch error: $e');
      rethrow;
    }
  }

  static Future<void> launchPhone(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  static Future<void> launchEmail(String email) async {
    final url = 'mailto:$email';
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  static Future<void> launchSMS(String phoneNumber, [String? message]) async {
    final url = message != null
        ? 'smsto:$phoneNumber?body=${Uri.encodeComponent(message)}'
        : 'smsto:$phoneNumber';
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  static Future<void> launchMaps(String coordinates) async {
    final url = 'geo:$coordinates';
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

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
    } else if (content.startsWith('geo:')) {
      return 'Location';
    } else if (content.startsWith('BITCOIN:') ||
        content.startsWith('ethereum:')) {
      return 'Crypto';
    } else {
      return 'Text';
    }
  }

  static Map<String, dynamic> parseWifiQR(String content) {
    final Map<String, dynamic> wifiInfo = {};
    try {
      if (content.startsWith('WIFI:')) {
        final wifiContent = content.substring(5); // Remove "WIFI:"
        final parts = wifiContent.split(';');
        for (final part in parts) {
          if (part.contains(':')) {
            final keyValue = part.split(':');
            if (keyValue.length >= 2) {
              final key = keyValue[0];
              final value = part.substring(key.length + 1);

              switch (key) {
                case 'T':
                  wifiInfo['encryption'] = value;
                  break;
                case 'S':
                  wifiInfo['ssid'] = value;
                  break;
                case 'P':
                  wifiInfo['password'] = value;
                  break;
                case 'H':
                  wifiInfo['hidden'] = value == 'true';
                  break;
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error parsing WiFi QR: $e');
    }
    return wifiInfo;
  }

  static Map<String, String> parseContactQR(String content) {
    final Map<String, String> contactInfo = {};

    try {
      if (content.startsWith('BEGIN:VCARD')) {
        final lines = content.split('\n');
        for (final line in lines) {
          if (line.contains(':')) {
            final parts = line.split(':');
            if (parts.length >= 2) {
              final key = parts[0].toUpperCase();
              final value = parts.sublist(1).join(':');
              switch (key) {
                case 'FN':
                  contactInfo['fullName'] = value;
                  break;
                case 'TEL':
                  contactInfo['phone'] = value;
                  break;
                case 'EMAIL':
                  contactInfo['email'] = value;
                  break;
                case 'URL':
                  contactInfo['website'] = value;
                  break;
                case 'ADR':
                  contactInfo['address'] = value;
                  break;
                case 'ORG':
                  contactInfo['organization'] = value;
                  break;
                case 'TITLE':
                  contactInfo['title'] = value;
                  break;
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error parsing Contact QR: $e');
    }
    return contactInfo;
  }

  void dispose() {
    controller?.dispose();
    controller = null;
    _torchNotifier?.dispose();
    _cameraFacingNotifier?.dispose();
  }

  Future<void> toggleTorch() async {
    if (controller != null) {
      await controller!.toggleTorch();
      if (_torchNotifier != null) {
        _torchNotifier!.value = !_torchNotifier!.value;
      }
    }
  }

  Future<bool> getTorchState() async {
    return _torchNotifier?.value ?? false;
  }

  Future<void> switchCamera() async {
    if (controller != null) {
      await controller!.switchCamera();
      if (_cameraFacingNotifier != null) {
        _cameraFacingNotifier!.value =
            _cameraFacingNotifier!.value == CameraFacing.back
            ? CameraFacing.front
            : CameraFacing.back;
      }
    }
  }

  Future<CameraFacing> getCameraFacing() async {
    return _cameraFacingNotifier?.value ?? CameraFacing.back;
  }

  Future<void> stop() async {
    if (controller != null) {
      await controller!.stop();
    }
  }

  Future<void> start() async {
    if (controller != null) {
      await controller!.start();
    }
  }

  Future<bool> isRunning() async {
    return controller != null;
  }

  Future<List<BarcodeFormat>> getSupportedFormats() async {
    if (controller != null) {
      return controller!.formats;
    }
    return [BarcodeFormat.qrCode];
  }

  void addTorchListener(VoidCallback listener) {
    _torchNotifier?.addListener(listener);
  }

  void removeTorchListener(VoidCallback listener) {
    _torchNotifier?.removeListener(listener);
  }

  void addCameraFacingListener(VoidCallback listener) {
    _cameraFacingNotifier?.addListener(listener);
  }

  void removeCameraFacingListener(VoidCallback listener) {
    _cameraFacingNotifier?.removeListener(listener);
  }
}
