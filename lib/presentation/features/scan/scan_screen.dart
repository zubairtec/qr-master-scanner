import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:qr_master_scanner/core/app_pallete.dart';
import 'package:qr_master_scanner/core/services/ad_service.dart';
import 'package:qr_master_scanner/core/services/permission_service.dart';
import 'package:qr_master_scanner/core/services/qr_scanner_service.dart';
import 'package:qr_master_scanner/domain/entities/scan_result.dart';
import 'package:qr_master_scanner/presentation/provider/scanner_provider.dart';
import 'package:qr_master_scanner/presentation/widgets/ad_banner_widget.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  MobileScannerController cameraController = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    returnImage: false,
  );
  QRScannerService? qrScannerService;
  bool hasPermission = false;
  bool isFlashOn = false;
  bool isCameraActive = true;
  CameraFacing currentCamera = CameraFacing.back;
  late AnimationController _animationController;
  late Animation<Offset> _scanLineAnimation;
  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
    qrScannerService = QRScannerService(controller: cameraController);
    // Setup scan line animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _scanLineAnimation =
        Tween<Offset>(
          begin: const Offset(0, -0.4),
          end: const Offset(0, 0.4),
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    qrScannerService?.dispose();
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _checkCameraPermission() async {
    final permissionGranted = await PermissionService.hasCameraPermission();
    setState(() {
      hasPermission = permissionGranted;
    });

    if (!permissionGranted) {
      _requestCameraPermission();
    }
  }

  Future<void> _requestCameraPermission() async {
    final permissionGranted = await PermissionService.requestCameraPermission();
    setState(() {
      hasPermission = permissionGranted;
    });
  }

  void _handleBarcode(Barcode barcode) {
    if (barcode.rawValue != null && isCameraActive) {
      setState(() => isCameraActive = false);
      _animationController.stop();
      _handleScannedData(barcode.rawValue!);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => isCameraActive = true);
          _animationController.repeat(reverse: true);
        }
      });
    }
  }

  void _handleScannedData(String content) {
    final scanProvider = Provider.of<ScanProvider>(context, listen: false);
    final type = QRScannerService.determineContentType(content);

    final result = ScanResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      content: content,
      timestamp: DateTime.now(),
    );

    scanProvider.addScanResult(result);
    _showScanResultDialog(content, type);
  }

  void _showScanResultDialog(String content, String type) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getResultIcon(type),
                      color: AppColors.primary,
                      size: 24.w,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'QR Code Scanned',
                      style: AppTextStyles.headline2(
                        context,
                      ).copyWith(fontSize: 20.sp),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Type: $type',
                        style: AppTextStyles.bodyText1(context).copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        content,
                        style: AppTextStyles.bodyText2(context),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.onSurface,
                      ),
                      child: Text(
                        'Close',
                        style: AppTextStyles.button(context),
                      ),
                    ),
                    if (type == 'URL')
                      TextButton(
                        onPressed: () {
                          Get.back();
                          QRScannerService.launchURL(content);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                        ),
                        child: Text(
                          'Open URL',
                          style: AppTextStyles.button(context),
                        ),
                      ),
                    if (type == 'Phone')
                      TextButton(
                        onPressed: () {
                          Get.back();
                          final phoneNumber = content.replaceFirst('tel:', '');
                          QRScannerService.launchPhone(phoneNumber);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: AppColors.onPrimary,
                        ),
                        child: Text(
                          'Call',
                          style: AppTextStyles.button(context),
                        ),
                      ),
                    if (type == 'Email')
                      TextButton(
                        onPressed: () {
                          Get.back();
                          final email = content.replaceFirst('mailto:', '');
                          QRScannerService.launchEmail(email);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.onPrimary,
                        ),
                        child: Text(
                          'Email',
                          style: AppTextStyles.button(context),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getResultIcon(String type) {
    switch (type) {
      case 'URL':
        return Icons.link;
      case 'Phone':
        return Icons.phone;
      case 'Email':
        return Icons.email;
      case 'WiFi':
        return Icons.wifi;
      case 'Text':
        return Icons.text_fields;
      default:
        return Icons.qr_code;
    }
  }

  Future<void> _toggleFlash() async {
    try {
      await qrScannerService?.toggleTorch();
      setState(() {
        AdService().showInterstitialAd();
        isFlashOn = !isFlashOn;
      });
    } catch (e) {
      debugPrint('Flash toggle error: $e');
    }
  }

  Future<void> _switchCamera() async {
    try {
      await qrScannerService?.switchCamera();
      setState(() {
        AdService().showInterstitialAd();
        currentCamera = currentCamera == CameraFacing.back
            ? CameraFacing.front
            : CameraFacing.back;
      });
    } catch (e) {
      debugPrint('Camera switch error: $e');
    }
  }

  Future<void> _scanFromGallery() async {
    try {
      setState(() => isCameraActive = false);
      _animationController.stop();
      final result = await QRScannerService.scanImageFromGallery();
      if (result != null && mounted) {
        _handleScannedData(result);
        AdService().showInterstitialAd();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No QR code found in the image',
              style: AppTextStyles.bodyText1(context),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gallery scan failed: $e',
              style: AppTextStyles.bodyText1(context),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isCameraActive = true);
        _animationController.repeat(reverse: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize screenutil
    ScreenUtil.init(
      context,
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
    );

    if (!hasPermission) {
      return _buildPermissionDeniedScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'QR Master Scanner',
          style: AppTextStyles.headline2(context),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: AppColors.onSurface,
              size: 24.w,
            ),
            onPressed: _toggleFlash,
            tooltip: 'Toggle Flash',
          ),
          IconButton(
            icon: Icon(
              Icons.cameraswitch,
              color: AppColors.onSurface,
              size: 24.w,
            ),
            onPressed: _switchCamera,
            tooltip: 'Switch Camera',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final scannerSize = constraints.maxWidth * 0.6;
          return Column(
            children: [
              AdBannerWidget(),
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    MobileScanner(
                      controller: cameraController,
                      onDetect: (BarcodeCapture capture) {
                        if (capture.barcodes.isNotEmpty) {
                          _handleBarcode(capture.barcodes.first);
                        }
                      },
                      errorBuilder: (context, error) {
                        return Center(
                          child: Text(
                            'Camera Error: ${error.toString()}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16.sp,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildScannerOverlay(scannerSize),
                  ],
                ),
              ),
              // Bottom controls with fixed height
              Container(
                height: 124.h, // Fixed height to prevent overflow
                padding: EdgeInsets.all(16.w),
                color: AppColors.surface,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Position QR code within frame to scan',
                      style: AppTextStyles.bodyText1(context),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),
                    ElevatedButton.icon(
                      onPressed: _scanFromGallery,
                      icon: Icon(Icons.photo_library, size: 20.w),
                      label: Text(
                        'Scan from Gallery',
                        style: AppTextStyles.button(context),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 12.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildScannerOverlay(double scannerSize) {
    return Stack(
      children: [
        // Dark overlay
        ColorFiltered(
          colorFilter: const ColorFilter.mode(Colors.black54, BlendMode.srcOut),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Center(
                child: Container(
                  width: scannerSize,
                  height: scannerSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Scanner frame
        Center(
          child: Container(
            width: scannerSize,
            height: scannerSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.primary, width: 2.w),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Stack(
                children: [
                  // Animated scan line
                  if (isCameraActive)
                    SlideTransition(
                      position: _scanLineAnimation,
                      child: Container(
                        height: 2.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              // ignore: deprecated_member_use
                              AppColors.primary.withOpacity(0.0),
                              AppColors.primary,
                              // ignore: deprecated_member_use
                              AppColors.primary.withOpacity(0.0),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),

                  // Corner indicators
                  ..._buildCornerIndicators(scannerSize),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCornerIndicators(double scannerSize) {
    final cornerSize = scannerSize * 0.08;

    return [
      Positioned(
        top: 0,
        left: 0,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.primary, width: 4.w),
              left: BorderSide(color: AppColors.primary, width: 4.w),
            ),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(16.r)),
          ),
        ),
      ),

      Positioned(
        top: 0,
        right: 0,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.primary, width: 4.w),
              right: BorderSide(color: AppColors.primary, width: 4.w),
            ),
            borderRadius: BorderRadius.only(topRight: Radius.circular(16.r)),
          ),
        ),
      ),

      // Bottom left
      Positioned(
        bottom: 0,
        left: 0,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.primary, width: 4.w),
              left: BorderSide(color: AppColors.primary, width: 4.w),
            ),
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16.r)),
          ),
        ),
      ),

      // Bottom right
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.primary, width: 4.w),
              right: BorderSide(color: AppColors.primary, width: 4.w),
            ),
            borderRadius: BorderRadius.only(bottomRight: Radius.circular(16.r)),
          ),
        ),
      ),
    ];
  }

  Widget _buildPermissionDeniedScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'QR Master Scanner',
          style: AppTextStyles.headline2(context),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.videocam_off, size: 64.w, color: AppColors.primary),
              SizedBox(height: 24.h),
              Text(
                'Camera Access Required',
                style: AppTextStyles.headline2(context),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Text(
                'To scan QR codes, this app needs access to your camera. Please grant camera permissions to continue.',
                style: AppTextStyles.bodyText1(context),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              ElevatedButton(
                onPressed: _requestCameraPermission,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                    vertical: 16.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Grant Permission',
                  style: AppTextStyles.button(context),
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}
