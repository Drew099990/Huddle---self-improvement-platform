import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Central place for all RevenueCat interactions.
///
/// Replace the placeholder API keys and entitlement ID with your own
/// values from app.revenuecat.com before running.
class PurchaseService {
  PurchaseService._();
  static final PurchaseService instance = PurchaseService._();

  // TODO: replace with your RevenueCat public API keys.
  // Android keys are prefixed "goog_", iOS keys are prefixed "appl_".
  // These are DIFFERENT keys from DIFFERENT dashboard project entries —
  // do not reuse the Android key for iOS (that was the previous bug here).
  static const String _androidApiKey = "goog_XVjWyKvvyzSOqPAyVRwdxDjSTCP";
  static const String _iosApiKey = "appl_REPLACE_WITH_YOUR_IOS_KEY";

  // TODO: replace with the entitlement identifier you configured in RevenueCat.
  // NOTE: no surrounding single quotes — those were being taken literally
  // as part of the string and would never match a real entitlement key.
  static const String entitlementId = "Huddle";

  bool _isConfigured = false;

  /// Call once, early in app startup (e.g. in main() before runApp).
  Future<void> configure({String? appUserId}) async {
    if (_isConfigured) return;

    await Purchases.setLogLevel(LogLevel.debug); // lower/remove in production

    late PurchasesConfiguration configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(_androidApiKey);
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration(_iosApiKey);
    } else {
      throw UnsupportedError(
        "RevenueCat is only configured for iOS/Android here",
      );
    }

    if (appUserId != null) {
      configuration.appUserID = appUserId;
    }

    await Purchases.configure(configuration);
    _isConfigured = true;
  }

  /// Fetches the current default offering's packages.
  /// Swallows errors and returns [] — kept for existing callers, but
  /// prefer [getAvailablePackagesOrThrow] when you need to show *why*
  /// no packages came back (e.g. in upgrade-sheet UI).
  Future<List<Package>> getAvailablePackages() async {
    try {
      return await getAvailablePackagesOrThrow();
    } catch (e) {
      // ignore: avoid_print
      print("Error fetching offerings: $e");
      return [];
    }
  }

  /// Same as [getAvailablePackages] but rethrows on failure instead of
  /// swallowing the error, so the UI can surface the real reason
  /// (missing configure() call, no "current" offering set in the
  /// RevenueCat dashboard, bad API key, products not approved, etc.)
  /// instead of a generic "no offering available" dead end.
  Future<List<Package>> getAvailablePackagesOrThrow() async {
    if (!_isConfigured) {
      throw StateError(
        'RevenueCat SDK not configured yet — PurchaseService.instance.'
        'configure() must complete before fetching offerings.',
      );
    }
    final offerings = await Purchases.getOfferings();
    return offerings.current?.availablePackages ?? [];
  }

  /// Attempts to purchase a package. Returns true if the entitlement
  /// is active afterward, false otherwise (including on cancel).
  Future<bool> purchasePackage(Package package) async {
    try {
      final result = await Purchases.purchasePackage(package);
      return _hasEntitlement(result.customerInfo);
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        return false;
      }
      // ignore: avoid_print
      print("Purchase error: $errorCode - ${e.message}");
      rethrow;
    }
  }

  /// Restores previous purchases for the current store account.
  Future<bool> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      return _hasEntitlement(customerInfo);
    } catch (e) {
      // ignore: avoid_print
      print("Restore error: $e");
      return false;
    }
  }

  /// Checks whether the user currently has the configured entitlement.
  Future<bool> isEntitled() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return _hasEntitlement(customerInfo);
    } catch (e) {
      // ignore: avoid_print
      print("Error checking entitlement: $e");
      return false;
    }
  }

  /// Call after your own login flow to link RevenueCat to your user ID.
  Future<void> logIn(String appUserId) async {
    await Purchases.logIn(appUserId);
  }

  /// Call on logout to reset RevenueCat to an anonymous user.
  Future<void> logOut() async {
    await Purchases.logOut();
  }

  bool _hasEntitlement(CustomerInfo customerInfo) {
    return customerInfo.entitlements.all[entitlementId]?.isActive == true;
  }
}
