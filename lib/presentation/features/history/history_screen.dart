import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:qr_master_scanner/core/app_pallete.dart';
import 'package:qr_master_scanner/di/service_locator.dart';
import 'package:qr_master_scanner/domain/entities/scan_result.dart';
import 'package:qr_master_scanner/presentation/provider/scanner_provider.dart';
import 'package:qr_master_scanner/presentation/widgets/ad_banner_widget.dart';
import 'package:qr_master_scanner/presentation/widgets/error_widget.dart';
import 'package:qr_master_scanner/presentation/widgets/loading_widget.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ScanProvider _scanProvider = sl<ScanProvider>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      await _scanProvider.loadScanHistory();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFavorite(String id) async {
    try {
      await _scanProvider.toggleFavoriteStatus(id);
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update favorite: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text('Scan History', style: AppTextStyles.headline2(context)),
        centerTitle: true,
        actions: [
          Consumer<ScanProvider>(
            builder: (context, scanProvider, child) {
              return Visibility(
                visible: scanProvider.scanHistory.isNotEmpty,
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () {
                    _showDeleteConfirmationDialog(context);
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const CustomLoadingWidget()
          : Consumer<ScanProvider>(
              builder: (context, scanProvider, child) {
                if (scanProvider.error != null) {
                  return CustomErrorWidget(
                    message: scanProvider.error!,
                    onRetry: _loadHistory,
                  );
                }

                if (scanProvider.scanHistory.isEmpty) {
                  return const CustomErrorWidget(
                    message: 'No scan history yet',
                  );
                }

                return ListView.builder(
                  itemCount: scanProvider.scanHistory.length,
                  itemBuilder: (context, index) {
                    final item = scanProvider.scanHistory[index];
                    return _HistoryListItem(
                      item: item,
                      onToggleFavorite: () => _toggleFavorite(item.id),
                    );
                  },
                );
              },
            ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear History'),
          content: const Text(
            'Are you sure you want to delete all scan history?',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                sl<ScanProvider>().clearHistory();
                Get.back();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

class _HistoryListItem extends StatelessWidget {
  final ScanResult item;
  final VoidCallback onToggleFavorite;

  const _HistoryListItem({required this.item, required this.onToggleFavorite});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        item.isFavorite ? Icons.star : Icons.star_border,
        color: item.isFavorite ? Colors.amber : null,
      ),
      title: Text(item.content, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdBannerWidget(),
          Text('Type: ${item.type}'),
          Text(
            '${_formatDate(item.timestamp)} • ${_formatTime(item.timestamp)}',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
      // trailing: IconButton(
      //   icon: Icon(
      //     item.isFavorite ? Icons.favorite : Icons.favorite_border,
      //     color: item.isFavorite ? Colors.red : null,
      //   ),
      //   onPressed: onToggleFavorite,
      // ),
      onTap: () {
        _showDetailsDialog(context, item);
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showDetailsDialog(BuildContext context, ScanResult item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Scan Details (${item.type})'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AdBannerWidget(),
                SelectableText(
                  item.content,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Text(
                  'Scanned on: ${_formatDate(item.timestamp)} at ${_formatTime(item.timestamp)}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Close')),
            if (item.type == 'URL')
              TextButton(
                onPressed: () {
                  Get.back();
                },
                child: const Text('Open URL'),
              ),
          ],
        );
      },
    );
  }
}
