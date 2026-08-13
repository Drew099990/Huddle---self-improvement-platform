// premium_status.dart
//
// Minimal, payment-free stand-in for "premium" status. Since RevenueCat was
// removed from this project, there is no real purchase or entitlement check
// anywhere — this is just a persisted boolean flag other screens can read
// (and, for now, nothing sets it to true anywhere in the app). Wire up a
// real toggle (settings switch, debug menu, or a future purchase flow) to
// call `PremiumStatus.instance.setPremium(true)` when you're ready.

import 'package:hive_flutter/hive_flutter.dart';

class PremiumStatus {
  PremiumStatus._();
  static final PremiumStatus instance = PremiumStatus._();

  static const String _boxName = 'premiumStatus';
  static const String _key = 'isPremium';

  Box? _box;

  Future<Box> _openBox() async {
    if (_box != null) return _box!;
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.initFlutter();
      _box = await Hive.openBox(_boxName);
    } else {
      _box = Hive.box(_boxName);
    }
    return _box!;
  }

  Future<bool> isPremium() async {
    final box = await _openBox();
    return box.get(_key, defaultValue: false) as bool;
  }

  Future<void> setPremium(bool value) async {
    final box = await _openBox();
    await box.put(_key, value);
  }
}
