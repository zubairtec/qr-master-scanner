import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:qr_master_scanner/core/services/ad_service.dart';

class AdBannerWidget extends StatefulWidget {
  final AdSize adSize;

  const AdBannerWidget({super.key, this.adSize = AdSize.banner});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    final ad = AdService().getBannerAd();
    ad
        .load()
        .then((_) {
          setState(() {
            _bannerAd = ad;
            _isAdLoaded = true;
          });
        })
        .catchError((error) {
          debugPrint('Failed to load ad: $error');
        });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _bannerAd == null) {
      return Container(
        height: widget.adSize.height.toDouble(),
        color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      height: widget.adSize.height.toDouble(),
      alignment: Alignment.center,
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
