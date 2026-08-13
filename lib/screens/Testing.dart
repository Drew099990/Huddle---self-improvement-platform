import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../helpers/revennuecat.dart';

/// A minimal paywall screen. Swap in your own design once the
/// purchase flow is working end to end.
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  List<Package> _packages = [];
  bool _isLoading = true;
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    final packages = await PurchaseService.instance.getAvailablePackages();
    if (!mounted) return;
    setState(() {
      _packages = packages;
      _isLoading = false;
    });
  }

  Future<void> _buy(Package package) async {
    setState(() => _isPurchasing = true);
    try {
      final unlocked = await PurchaseService.instance.purchasePackage(package);
      if (!mounted) return;
      if (unlocked) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Purchase failed: $e")));
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _isPurchasing = true);
    final restored = await PurchaseService.instance.restorePurchases();
    if (!mounted) return;
    setState(() => _isPurchasing = false);
    if (restored) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No active purchases found")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Go Premium")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _packages.isEmpty
          ? const Center(child: Text("No offerings available"))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final package in _packages)
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(package.storeProduct.title),
                      subtitle: Text(package.storeProduct.description),
                      trailing: Text(package.storeProduct.priceString),
                      onTap: _isPurchasing ? null : () => _buy(package),
                    ),
                  ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _isPurchasing ? null : _restore,
                  child: const Text("Restore Purchases"),
                ),
              ],
            ),
    );
  }
}
