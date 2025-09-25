import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_master_scanner/core/app_pallete.dart';
import 'package:qr_master_scanner/core/services/qr_generator_service.dart';

class CreateQRResultScreen extends StatefulWidget {
  final String data;
  final String type;
  const CreateQRResultScreen({
    super.key,
    required this.data,
    required this.type,
  });
  @override
  State<CreateQRResultScreen> createState() => _CreateQRResultScreenState();
}

class _CreateQRResultScreenState extends State<CreateQRResultScreen> {
  bool _isSaving = false;
  bool _isSharing = false;
  Future<void> _saveToGallery() async {
    setState(() => _isSaving = true);
    try {
      final bytes = await QRGeneratorService.generateQRCodeData(widget.data);
      final filePath = await QRGeneratorService.saveQRCodeToGallery(bytes);
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text('QR code saved to: $filePath')));
    } catch (e) {
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _shareQRCode() async {
    setState(() => _isSharing = true);
    try {
      final bytes = await QRGeneratorService.generateQRCodeData(widget.data);
      await QRGeneratorService.shareQRCode(bytes);
    } catch (e) {
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to share: $e')));
    } finally {
      setState(() => _isSharing = false);
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
          '${widget.type} QR Code',
          style: AppTextStyles.headline2(context),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _isSaving
                ? const CircularProgressIndicator()
                : const Icon(Icons.save, color: Colors.white),
            onPressed: _isSaving ? null : _saveToGallery,
          ),
          IconButton(
            icon: _isSharing
                ? const CircularProgressIndicator()
                : const Icon(Icons.share, color: Colors.white),
            onPressed: _isSharing ? null : _shareQRCode,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: QrImageView(
                  data: widget.data,
                  version: QrVersions.auto,
                  size: 200,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(widget.type, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Card(
              color: AppColors.primaryDark,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SelectableText(
                  widget.data,
                  style: const TextStyle(
                    fontFamily: 'Monospace',
                    color: AppColors.surface,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(AppColors.primary),
                  ),

                  onPressed: _saveToGallery,
                  icon: const Icon(Icons.save),
                  label: Text('Save', style: AppTextStyles.bodyText1(context)),
                ),
                ElevatedButton.icon(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(AppColors.primary),
                  ),
                  onPressed: _shareQRCode,
                  icon: const Icon(Icons.share),
                  label: Text('Share', style: AppTextStyles.bodyText1(context)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
