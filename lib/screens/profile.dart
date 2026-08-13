import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../helpers/activity_log.dart';
import '../helpers/journal_database.dart';
import '../helpers/RewardAD.dart';
import '../helpers/revennuecat.dart';
import "../subpages/minigame.dart";
import "../subpages/favorites.dart";

String? profileImagePath;

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool _showBroadcast = false;
  String? _selectedImagePath;
  late Box _box;
  late Box _activityBox;
  bool _activityReady = false;
  int _journalCount = 0;
  String _installedDaysText = '0 days';
  bool _upgradeMenu = false;

  // --- Premium / RevenueCat state ---
  bool _isPremium = false;
  bool _premiumStatusLoading = true;
  Package? _premiumPackage;
  bool _packagesLoading = true;
  bool _isPurchasing = false;

  // --- Broadcast posting limit ---
  // Free users get 1 broadcast per day. Extra posts for the same day are
  // unlocked by watching a rewarded ad. Both values are plain int state so
  // they're easy to read/reset/persist.
  static const int _baseDailyBroadcastLimit = 1;
  static const int _bonusBroadcastsPerAd = 1;

  int _broadcastsPostedToday = 0;
  int _bonusBroadcastSlots = 0;
  String? _lastBroadcastDate;

  final RewardedAdManager _rewardedAdManager = RewardedAdManager();
  final TextEditingController _broadcastController = TextEditingController();

  int get _dailyBroadcastLimit =>
      _baseDailyBroadcastLimit + _bonusBroadcastSlots;

  bool get _canPostBroadcast => _broadcastsPostedToday < _dailyBroadcastLimit;

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadBroadcastState() async {
    final today = _todayKey();
    final savedDate = _box.get('lastBroadcastDate') as String?;

    int postedToday = _box.get('broadcastsPostedToday', defaultValue: 0) as int;
    int bonusSlots = _box.get('bonusBroadcastSlots', defaultValue: 0) as int;

    if (savedDate != today) {
      // New day — reset the daily counters.
      postedToday = 0;
      bonusSlots = 0;
      await _box.put('lastBroadcastDate', today);
      await _box.put('broadcastsPostedToday', postedToday);
      await _box.put('bonusBroadcastSlots', bonusSlots);
    }

    if (!mounted) return;
    setState(() {
      _lastBroadcastDate = today;
      _broadcastsPostedToday = postedToday;
      _bonusBroadcastSlots = bonusSlots;
    });
  }

  Future<void> _recordBroadcastPosted() async {
    _broadcastsPostedToday += 1;
    await _box.put('broadcastsPostedToday', _broadcastsPostedToday);
    await _box.put('lastBroadcastDate', _lastBroadcastDate ?? _todayKey());
    if (mounted) setState(() {});
  }

  Future<void> _grantBonusBroadcastSlot() async {
    _bonusBroadcastSlots += _bonusBroadcastsPerAd;
    await _box.put('bonusBroadcastSlots', _bonusBroadcastSlots);
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _setupHive();
    _rewardedAdManager.load();
    _loadPremiumStatus();
    _loadPremiumPackage();
  }

  @override
  void dispose() {
    _broadcastController.dispose();
    _rewardedAdManager.dispose();
    super.dispose();
  }

  bool picSelect = false;

  // --- Premium status + offering ---

  Future<void> _loadPremiumStatus() async {
    final entitled = await PurchaseService.instance.isEntitled();
    if (!mounted) return;
    setState(() {
      _isPremium = entitled;
      _premiumStatusLoading = false;
    });
  }

  Future<void> _loadPremiumPackage() async {
    final packages = await PurchaseService.instance.getAvailablePackages();
    if (!mounted) return;
    setState(() {
      // Assumes a single premium package in the default offering.
      // If you offer multiple tiers, pick the right one here instead
      // of just taking the first.
      _premiumPackage = packages.isNotEmpty ? packages.first : null;
      _packagesLoading = false;
    });
  }

  Future<void> _buyPremium(
    StateSetter setSheetState,
    BuildContext sheetContext,
  ) async {
    final package = _premiumPackage;
    if (package == null || _isPurchasing) return;

    setSheetState(() => _isPurchasing = true);
    try {
      final unlocked = await PurchaseService.instance.purchasePackage(package);
      if (!mounted) return;
      if (unlocked) {
        setState(() => _isPremium = true);
        setSheetState(() {});
        if (Navigator.of(sheetContext).canPop()) {
          Navigator.of(sheetContext).pop();
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Welcome to premium! 🎉")));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Purchase failed: $e")));
    } finally {
      if (mounted) setSheetState(() => _isPurchasing = false);
    }
  }

  Future<void> _pickProfileImage() async {
    setState(() {});
    picSelect = true;
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      await _box.put('profileImagePath', path);
      setState(() {
        _selectedImagePath = path;
      });
    }
    setState(() {
      picSelect = false;
    });
  }

  Future<void> _loadProfileStats() async {
    final journalCount = await JournalDatabase.instance.countEntries();
    final savedDate = _box.get('installDate') as String?;
    DateTime installDate = DateTime.now();

    if (savedDate != null) {
      final parsedDate = DateTime.tryParse(savedDate);
      if (parsedDate != null) {
        installDate = parsedDate;
      }
    }

    final daysInstalled = DateTime.now().difference(installDate).inDays + 1;
    final installedDaysText = daysInstalled == 1
        ? '1 day'
        : '$daysInstalled days';

    if (!mounted) return;
    setState(() {
      _journalCount = journalCount;
      _installedDaysText = installedDaysText;
    });
  }

  Future<void> _setupHive() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('profilepic');
    _activityBox = await Hive.openBox('activityLog');

    final savedPath = _box.get('profileImagePath') as String?;
    final savedInstallDate = _box.get('installDate') as String?;

    if (savedInstallDate == null) {
      await _box.put('installDate', DateTime.now().toIso8601String());
    }

    if (mounted) {
      setState(() {
        _selectedImagePath = savedPath;
        _activityReady = true;
      });
    }

    await _loadProfileStats();
    await _loadBroadcastState();
  }

  void _toggleBroadcast() {
    setState(() {
      _showBroadcast = !_showBroadcast;
    });

    if (_showBroadcast) {
      _broadcastController.clear();
      showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(10),
            ),
            alignment: Alignment.center,
            elevation: 10,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Global Board"),
                IconButton(
                  icon: Icon(
                    Icons.cancel_outlined,
                    color: const Color.fromARGB(115, 2, 36, 49),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            contentPadding: EdgeInsets.all(5),
            actions: [
              TextField(
                controller: _broadcastController,
                enabled: true,
                decoration: InputDecoration(
                  hintText: "share a messsage or quote with the world",
                ),
              ),
              Text(
                _canPostBroadcast
                    ? '${_dailyBroadcastLimit - _broadcastsPostedToday} free broadcast(s) left today'
                    : 'No free broadcasts left today — watch an ad to post more',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: _canPostBroadcast
                          ? const Color.fromARGB(146, 8, 59, 46)
                          : const Color.fromARGB(80, 8, 59, 46),
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(
                      onTap: !_canPostBroadcast
                          ? null
                          : () async {
                              await _recordBroadcastPosted();
                              setDialogState(() {});

                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: const Color.fromARGB(
                                    148,
                                    34,
                                    39,
                                    58,
                                  ),
                                  content: Text(
                                    "message shared with the world !!!",
                                  ),
                                ),
                              );
                              Navigator.pop(context);
                            },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "share message",
                            style: TextStyle(
                              color: _canPostBroadcast
                                  ? Colors.white
                                  : Colors.white38,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.language_outlined,
                            color: _canPostBroadcast
                                ? Colors.white60
                                : Colors.white24,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 78, 128, 143),
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(
                      onTap: () {
                        _rewardedAdManager.showIfReady(
                          onUserEarnedReward: (amount, type) async {
                            await _grantBonusBroadcastSlot();
                            setDialogState(() {});
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Nice! You can post $_bonusBroadcastsPerAd more broadcast(s) today.',
                                ),
                              ),
                            );
                          },
                          onNotReady: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Ad not ready yet — try again in a moment.',
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 6),
                          Icon(
                            Icons.play_circle_outline,
                            color: Colors.white70,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
            content: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 2,
                  color: Color.fromARGB(115, 202, 205, 207),
                ),
              ),
              child: Text(
                ' i am a demo message to from sleepy panda of a message to you just to say welcome! ',
                style: TextStyle(color: const Color.fromARGB(144, 0, 0, 0)),
              ),
            ),
          ),
        ),
      ).then((_) {
        if (mounted) setState(() => _showBroadcast = false);
      });
    }
  }

  void _showUpgradeSheet() {
    if (mounted) {
      setState(() {
        _upgradeMenu = true;
      });
    }
    try {
      final controller = showBottomSheet(
        context: context,
        builder: (sheetContext) => StatefulBuilder(
          builder: (sheetContext, setSheetState) => Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(131, 55, 92, 114),
            ),
            height: 431,
            width: MediaQuery.of(sheetContext).size.width * 1,
            child: Column(
              children: [
                Icon(Icons.arrow_downward, color: Colors.black38),

                Container(
                  width: MediaQuery.of(sheetContext).size.width,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(151, 14, 71, 117),
                  ),
                  child: Column(
                    children: [
                      Divider(height: 10, thickness: 5),

                      Text(
                        "hello there, Friend (❁´◡`❁) ",
                        style: TextStyle(
                          color: Colors.black45,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        "Upgrade to premium",
                        style: TextStyle(
                          color: Color.fromARGB(210, 248, 234, 209),
                        ),
                      ),
                      Divider(height: 10),
                    ],
                  ),
                ),

                Container(
                  height: 300,
                  width: 600,
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Perks("Remove all Ads"),
                      Perks("Unlimited Favorites"),
                      Perks("Access to All Games"),
                      Perks("Become a Beta Tester"),
                      Perks("Supports me ^_^"),
                      SizedBox(height: 15),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isPremium)
                            Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 15,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  width: 4,
                                  color: const Color.fromARGB(
                                    210,
                                    86,
                                    101,
                                    143,
                                  ),
                                ),
                                color: const Color.fromARGB(210, 91, 125, 170),
                              ),
                              child: Text(
                                "You're premium ✓",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(
                                    255,
                                    235,
                                    231,
                                    183,
                                  ),
                                ),
                              ),
                            )
                          else if (_packagesLoading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          else if (_premiumPackage == null)
                            const Text(
                              "No offering available right now",
                              style: TextStyle(color: Colors.white70),
                            )
                          else
                            InkWell(
                              onTap: _isPurchasing
                                  ? null
                                  : () => _buyPremium(
                                      setSheetState,
                                      sheetContext,
                                    ),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 15,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    width: 4,
                                    color: const Color.fromARGB(
                                      210,
                                      86,
                                      101,
                                      143,
                                    ),
                                  ),
                                  color: _isPurchasing
                                      ? const Color.fromARGB(120, 91, 125, 170)
                                      : const Color.fromARGB(210, 91, 125, 170),
                                ),
                                child: _isPurchasing
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        _premiumPackage!
                                            .storeProduct
                                            .priceString,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: const Color.fromARGB(
                                            255,
                                            235,
                                            231,
                                            183,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(sheetContext).size.width,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(151, 14, 71, 117),
                  ),
                  padding: EdgeInsets.only(top: 5, bottom: 5),
                  child: Text(
                    "Thanks for the support, appreciate the help !!!",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 185, 179, 161),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      controller.closed.then((_) {
        if (mounted) {
          setState(() {
            _upgradeMenu = false;
          });
        }
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(147, 191, 203, 219),
        centerTitle: true,
        title: Text(
          'Personal view',
          style: TextStyle(
            color: _upgradeMenu
                ? const Color.fromARGB(139, 25, 70, 155)
                : const Color.fromARGB(29, 25, 70, 155),
            letterSpacing: 3,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black54),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Cover + avatar
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('lib/assets/appbar.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    bottom: -60,
                    child: InkWell(
                      onTap: _pickProfileImage,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: picSelect
                              ? Border.all(
                                  color: const Color.fromARGB(87, 40, 107, 184),
                                  width: 6,
                                )
                              : Border.all(color: Colors.white, width: 6),
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: _selectedImagePath != null
                              ? FileImage(File(_selectedImagePath!))
                              : const AssetImage("lib/assets/ab.jpg"),
                          backgroundColor: Colors.grey[200],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 210,
                    bottom: 15,
                    child: InkWell(
                      onTap: _pickProfileImage,

                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                            color: const Color.fromARGB(111, 0, 85, 119),
                          ),
                          color: const Color.fromARGB(255, 241, 243, 245),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.edit_outlined,
                          color: const Color.fromARGB(146, 19, 87, 133),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 64),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'William',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '@william',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        if (_premiumStatusLoading)
                          const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else if (_isPremium)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(134, 14, 122, 71),
                              border: Border.all(
                                width: 2,
                                color: Colors.black54,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Text(
                              "premium ✓",
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                          )
                        else
                          InkWell(
                            onTap: _showUpgradeSheet,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(134, 165, 57, 14),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color.fromARGB(
                                      255,
                                      37,
                                      78,
                                      69,
                                    ).withOpacity(0.4),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                                border: Border.all(
                                  width: 2,
                                  color: Colors.black54,
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Text(
                                "upgrade",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Colors.amberAccent,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Stats
                    Row(
                      children: [
                        _buildStatCard(
                          'day installed',
                          _installedDaysText,
                          Icons.calendar_today,
                          size.width,
                        ),
                        const SizedBox(width: 8),
                        _buildStatCard(
                          'Journal',
                          '$_journalCount',
                          Icons.book,
                          size.width,
                        ),
                        const SizedBox(width: 8),
                        _buildStatCard('Posts', '4 ', Icons.forum, size.width),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Divider(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          icon: Icons.favorite_border_outlined,
                          label: "favorites",
                          color: const Color.fromARGB(132, 29, 77, 54),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => Favorites()),
                            );
                          },
                        ),
                        _buildActionButton(
                          icon: Icons.campaign_outlined,
                          label: "broadcast",
                          color: Colors.grey[300]!,
                          onTap: _toggleBroadcast,
                        ),

                        _buildActionButton(
                          icon: Icons.gamepad_outlined,
                          label: "mini games",
                          color: const Color.fromARGB(132, 29, 77, 54),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => MiniGames()),
                            );
                          },
                        ),
                      ],
                    ),

                    const Divider(height: 16),

                    const Text(
                      'Recent activity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),

                    if (!_activityReady) ...[
                      const Center(child: CircularProgressIndicator()),
                    ] else
                      ValueListenableBuilder<Box>(
                        valueListenable: _activityBox.listenable(
                          keys: ['activities'],
                        ),
                        builder: (context, box, _) {
                          final raw = box.get(
                            'activities',
                            defaultValue: <dynamic>[],
                          );
                          final activities = <Map<String, String>>[];

                          if (raw is List) {
                            activities.addAll(
                              raw.whereType<Map>().map(
                                (map) => map.cast<String, String>(),
                              ),
                            );
                          }

                          if (activities.isEmpty) {
                            return const Text(
                              'No recent activity yet. Actions like saving or favoriting books will appear here.',
                              style: TextStyle(color: Colors.grey),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: activities.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 16),
                            itemBuilder: (context, index) {
                              final activity = activities[index];
                              final message = activity['message'] ?? '';
                              final timestamp = activity['timestamp'] ?? '';

                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor: Colors.grey[200],
                                  child: const Icon(
                                    Icons.history,
                                    color: Colors.grey,
                                  ),
                                ),
                                title: Text(message),
                                subtitle: Text(
                                  ActivityLog.formatAge(timestamp),
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              );
                            },
                          );
                        },
                      ),

                    const Divider(height: 16),
                    const SizedBox(height: 24),

                    // Footer
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.12),
                        ),
                      ),
                      child: InkWell(
                        onTap: () async {
                          final uri = Uri.parse(
                            'https://sleepypanda.vercel.app',
                          );

                          await launchUrl(uri, mode: LaunchMode.inAppWebView);
                        },
                        child: const Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.language, color: Colors.grey),
                                SizedBox(width: 12),
                                Icon(
                                  Icons.facebook_outlined,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: 12),
                                Icon(Icons.mail_outline, color: Colors.grey),
                              ],
                            ),
                            SizedBox(height: 12),
                            Text(
                              'powered by sleepy panda',
                              style: TextStyle(color: Colors.grey),
                            ),
                            SizedBox(height: 5),
                            Icon(Icons.touch_app_outlined, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget Perks(String perk) {
    return Row(
      children: [
        Icon(
          Icons.star_border_outlined,
          size: 40,
          color: const Color.fromARGB(242, 197, 204, 218),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            perk,
            style: TextStyle(
              fontSize: 15,
              color: const Color.fromARGB(255, 246, 246, 248),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    double screenWidth,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.blueGrey, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color.fromARGB(172, 34, 34, 34),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color,
              border: Border.all(width: 2),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(icon),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}
