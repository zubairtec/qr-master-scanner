import 'package:flutter/material.dart';
import 'package:qr_master_scanner/core/app_pallete.dart';
import 'package:qr_master_scanner/presentation/widgets/ad_banner_widget.dart';

class CustomErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const CustomErrorWidget({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AdBannerWidget(),
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(AppColors.primary),
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text('Try Again', style: AppTextStyles.bodyText1(context)),
            ),
          ],
          AdBannerWidget(),
        ],
      ),
    );
  }
}
