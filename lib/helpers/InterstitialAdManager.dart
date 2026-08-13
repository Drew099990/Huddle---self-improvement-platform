// interstitial_ad_manager.dart
//
// Standalone manager for AdMob interstitial ads. Preloads an ad, shows it
// on demand, and automatically preloads the next one after each dismissal.
//
// Setup required elsewhere in the project:
//   1. pubspec.yaml -> google_mobile_ads: ^5.1.0
//   2. main.dart -> await MobileAds.instance.initialize(); before runApp()
//   3. AndroidManifest.xml -> com.google.android.gms.ads.APPLICATION_ID meta-data
//   4. Info.plist -> GADApplicationIdentifier + SKAdNetworkItems
//
// Usage:
//   final _interstitialAdManager = InterstitialAdManager();
//
//   @override
//   void initState() {
//     super.initState();
//     _interstitialAdManager.load();
//   }
//
//   @override
//   void dispose() {
//     _interstitialAdManager.dispose();
//     super.dispose();
//   }
//
//   // at a natural break point, e.g. every 3rd nav tap:
//   _interstitialAdManager.showIfReady();

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterstitialAdManager {
  InterstitialAd? _ad;
  bool _isLoading = false;

  /// Flip to false and fill in real IDs before release.
  static const bool useTestAds = false;

  String get _adUnitId {
    if (!useTestAds) {
      if (Platform.isAndroid) return 'ca-app-pub-8563885250863599/1793241580';
      if (Platform.isIOS) return 'ca-app-pub-8563885250863599/1793241580';
    }
    // Google's official TEST interstitial IDs — safe during development.
    if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/1033173712';
    if (Platform.isIOS) return 'ca-app-pub-3940256099942544/4411468910';
    throw UnsupportedError('Unsupported platform');
  }

  bool get isReady => _ad != null;

  /// Loads an ad in the background. Safe to call repeatedly — no-ops if
  /// already loading or already holding a ready ad.
  void load() {
    if (_isLoading || _ad != null) return;
    _isLoading = true;
    InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoading = false;
          _ad = ad;
          _ad!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _ad = null;
              load(); // preload the next one
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _ad = null;
              load();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          _ad = null;
          if (kDebugMode) print('Interstitial failed to load: $error');
        },
      ),
    );
  }

  /// Shows the ad if one is ready; otherwise kicks off a load for next time.
  void showIfReady() {
    if (_ad != null) {
      _ad!.show();
    } else {
      load();
    }
  }

  void dispose() {
    _ad?.dispose();
    _ad = null;
  }
}
