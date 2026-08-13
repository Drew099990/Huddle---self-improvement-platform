// rewarded_ad_manager.dart
//
// Standalone manager for AdMob rewarded ads. Preloads an ad, shows it on
// demand, and only reports a reward back to your app once the user has
// actually finished watching (never before).
//
// -----------------------------------------------------------------------
// SETUP required elsewhere in the project (same as any other ad type):
//   1. pubspec.yaml -> google_mobile_ads: ^5.1.0
//   2. main.dart     -> await MobileAds.instance.initialize(); before runApp()
//   3. AndroidManifest.xml -> com.google.android.gms.ads.APPLICATION_ID meta-data
//   4. Info.plist    -> GADApplicationIdentifier + SKAdNetworkItems
// -----------------------------------------------------------------------
//
// HOW TO USE
//
// 1. Save this file at lib/helpers/rewarded_ad_manager.dart.
//
// 2. In the State class of whichever screen offers the reward (e.g. a
//    "watch an ad for extra coins" button), create one instance and keep
//    it alive for the life of that screen:
//
//      import '../helpers/rewarded_ad_manager.dart';
//
//      class _MyScreenState extends State<MyScreen> {
//        final RewardedAdManager _rewardedAdManager = RewardedAdManager();
//
// 3. Start loading an ad early — e.g. in initState() — so it's ready by
//    the time the user taps the reward button. Loading takes a moment,
//    so don't wait until the tap to call load():
//
//        @override
//        void initState() {
//          super.initState();
//          _rewardedAdManager.load();
//        }
//
// 4. Dispose it with the screen to avoid leaking the ad instance:
//
//        @override
//        void dispose() {
//          _rewardedAdManager.dispose();
//          super.dispose();
//        }
//
// 5. Trigger it from your "watch ad" button. Grant the reward ONLY inside
//    onUserEarnedReward — that callback is what confirms the user actually
//    watched to completion, not just that show() was called:
//
//        ElevatedButton(
//          onPressed: () {
//            _rewardedAdManager.showIfReady(
//              onUserEarnedReward: (amount, type) {
//                setState(() {
//                  coins += amount; // grant your in-app reward here
//                });
//              },
//              onNotReady: () {
//                // ad wasn't loaded yet — tell the user to try again shortly
//                ScaffoldMessenger.of(context).showSnackBar(
//                  const SnackBar(content: Text('Ad not ready yet, try again in a moment')),
//                );
//              },
//            );
//          },
//          child: const Text('Watch ad for +10 coins'),
//        )
//
// That's it — after a successful show, the manager automatically preloads
// the next ad so the button is ready again without extra code from you.
// -----------------------------------------------------------------------

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedAdManager {
  RewardedAd? _ad;
  bool _isLoading = false;

  /// Flip to false and fill in real IDs before release.
  static const bool useTestAds = true;

  String get _adUnitId {
    if (!useTestAds) {
      if (Platform.isAndroid) return 'YOUR_ANDROID_REWARDED_ID';
      if (Platform.isIOS) return 'YOUR_IOS_REWARDED_ID';
    }
    // Google's official TEST rewarded IDs — safe during development.
    if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/5224354917';
    if (Platform.isIOS) return 'ca-app-pub-3940256099942544/1712485313';
    throw UnsupportedError('Unsupported platform');
  }

  bool get isReady => _ad != null;

  /// Loads an ad in the background. Safe to call repeatedly — no-ops if
  /// already loading or already holding a ready ad.
  void load() {
    if (_isLoading || _ad != null) return;
    _isLoading = true;
    RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
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
          if (kDebugMode) print('Rewarded ad failed to load: $error');
        },
      ),
    );
  }

  /// Shows the ad if one is ready. [onUserEarnedReward] fires only when the
  /// user watches to completion — grant the in-app reward there, nowhere
  /// else. [onNotReady] fires if no ad was loaded yet (also kicks off a
  /// fresh load automatically either way).
  void showIfReady({
    required void Function(int amount, String type) onUserEarnedReward,
    void Function()? onNotReady,
  }) {
    if (_ad == null) {
      onNotReady?.call();
      load();
      return;
    }
    _ad!.show(
      onUserEarnedReward: (ad, reward) {
        onUserEarnedReward(reward.amount.toInt(), reward.type);
      },
    );
    _ad = null;
  }

  void dispose() {
    _ad?.dispose();
    _ad = null;
  }
}
