import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import 'package:qr_master_scanner/core/app_pallete.dart';

class AdService extends ChangeNotifier {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  AppOpenAd? _appOpenAd;
  int _interstitialLoadAttempts = 0;
  static const int _maxLoadAttempts = 3;
  bool _isAppOpenAdLoaded = false;
  bool _isShowingAd = false;
  DateTime _appOpenAdLoadTime = DateTime.now();
  String? _error;
  bool get isAppOpenAdLoaded => _isAppOpenAdLoaded;
  bool get isShowingAd => _isShowingAd;
  String? get error => _error;
  void initialize() {
    if (kIsWeb) {
      debugPrint('Web platform - Ads disabled');
      return;
    }
    MobileAds.instance.initialize();
    _loadInterstitialAd();
    _loadAppOpenAd();
  }

  BannerAd getBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AppConstants.bannerAdId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) => debugPrint('Banner ad loaded.'),
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          debugPrint('Banner ad failed to load: $error');
          ad.dispose();
        },
        onAdOpened: (Ad ad) => debugPrint('Banner ad opened.'),
        onAdClosed: (Ad ad) => debugPrint('Banner ad closed.'),
      ),
    );
    return _bannerAd!;
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AppConstants.interstitialAdId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _interstitialLoadAttempts = 0;
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('Interstitial ad failed to load: $error');
          _interstitialAd = null;
          _interstitialLoadAttempts += 1;
          if (_interstitialLoadAttempts < _maxLoadAttempts) {
            _loadInterstitialAd();
          }
        },
      ),
    );
  }

  bool get isAppOpenAdReady {
    if (_appOpenAd == null) return false;
    return DateTime.now().difference(_appOpenAdLoadTime).inHours < 4;
  }

  Future<void> _loadAppOpenAd() async {
    if (kIsWeb) {
      debugPrint('App Open Ads not supported on web');
      return;
    }
    try {
      await AppOpenAd.load(
        adUnitId: AppConstants.appOpenAdId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('App Open Ad loaded successfully');
            _appOpenAd = ad;
            _isAppOpenAdLoaded = true;
            _appOpenAdLoadTime = DateTime.now();
            _setAppOpenAdCallbacks();
            notifyListeners();
          },
          onAdFailedToLoad: (error) {
            debugPrint('App Open Ad failed to load: $error');
            _isAppOpenAdLoaded = false;
            Future.delayed(const Duration(seconds: 60), _loadAppOpenAd);
          },
        ),
      );
    } catch (e) {
      debugPrint('Error loading App Open Ad: $e');
    }
  }

  void _setAppOpenAdCallbacks() {
    _appOpenAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        debugPrint('App Open Ad showed');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('App Open Ad dismissed');
        _isShowingAd = false;
        _isAppOpenAdLoaded = false;
        ad.dispose();
        _appOpenAd = null;
        _loadAppOpenAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('App Open Ad failed to show: $error');
        _isShowingAd = false;
        _isAppOpenAdLoaded = false;
        ad.dispose();
        _appOpenAd = null;
        _loadAppOpenAd();
      },
    );
  }

  Future<void> showAppOpenAd() async {
    if (_appOpenAd == null || !_isAppOpenAdLoaded) {
      debugPrint('App Open Ad not ready - skipping');
      return;
    }

    if (_isShowingAd) {
      debugPrint('App Open Ad already showing');
      return;
    }

    try {
      _isShowingAd = true;
      await _appOpenAd!.show().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException('App Open Ad show timeout');
        },
      );
    } on TimeoutException catch (e) {
      debugPrint('App Open Ad timeout: $e');
      _disposeAppOpenAd();
    } catch (e) {
      debugPrint('Failed to show App Open Ad: $e');
      _disposeAppOpenAd();
    } finally {
      _isShowingAd = false;
    }
  }

  void _disposeAppOpenAd() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
    _isAppOpenAdLoaded = false;
    _isShowingAd = false;
  }

  bool canShowAppOpenAd() {
    return _appOpenAd != null &&
        _isAppOpenAdLoaded &&
        isAppOpenAdReady &&
        !_isShowingAd;
  }

  void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (InterstitialAd ad) =>
            debugPrint('Interstitial ad showed.'),
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          debugPrint('Interstitial ad dismissed.');
          ad.dispose();
          _loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          debugPrint('Interstitial ad failed to show: $error');
          ad.dispose();
          _loadInterstitialAd();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _appOpenAd?.dispose();
    super.dispose();
  }
}
