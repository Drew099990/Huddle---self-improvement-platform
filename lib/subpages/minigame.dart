import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import "../subpages/favorites.dart";
import "../games/TicTacToe.dart";
import "../games/checkers.dart";
import "../games/chess.dart";
import "../games/dino.dart";
import "../helpers/RewardAD.dart";
import "../helpers/premium_status.dart";

class MiniGames extends StatefulWidget {
  const MiniGames({super.key});

  @override
  State<MiniGames> createState() => _MiniGamesState();
}

class _MiniGamesState extends State<MiniGames> {
  final RewardedAdManager _rewardedAdManager = RewardedAdManager();

  // Every Nth game launch triggers a rewarded ad before the game opens.
  // NOTE: as requested, premium sees an ad MORE often (every 3rd launch)
  // than non-premium (every 5th launch) — this is intentionally the
  // opposite of the usual "premium removes ads" pattern, confirmed as
  // deliberate.
  static const int _nonPremiumAdEveryNGames = 5;
  static const int _premiumAdEveryNGames = 3;

  static const String _counterBoxName = 'gamePlayCounter';
  static const String _counterKey = 'playCount';

  Box? _counterBox;
  bool _isPremium = false;
  bool _statusReady = false;

  Future<Box> _openCounterBox() async {
    if (!Hive.isBoxOpen(_counterBoxName)) {
      await Hive.initFlutter();
      return await Hive.openBox(_counterBoxName);
    }
    return Hive.box(_counterBoxName);
  }

  Future<void> _init() async {
    final counterBox = await _openCounterBox();
    final isPremium = await PremiumStatus.instance.isPremium();
    if (!mounted) return;
    setState(() {
      _counterBox = counterBox;
      _isPremium = isPremium;
      _statusReady = true;
    });
  }

  int get _adInterval =>
      _isPremium ? _premiumAdEveryNGames : _nonPremiumAdEveryNGames;

  // Increments the play counter, persists it, and decides whether this
  // particular launch needs a rewarded ad first. The actual navigation
  // (`openGame`) only runs once we're clear to proceed — either because
  // this launch didn't land on the ad interval, or because the ad was
  // watched to completion.
  Future<void> _playGame(BuildContext context, WidgetBuilder openGame) async {
    final box = _counterBox;
    if (box == null) {
      // Counter not ready yet (shouldn't normally happen since the UI is
      // gated on _statusReady) — fail open rather than blocking play.
      Navigator.push(context, MaterialPageRoute(builder: openGame));
      return;
    }

    final currentCount = box.get(_counterKey, defaultValue: 0) as int;
    final newCount = currentCount + 1;
    await box.put(_counterKey, newCount);

    final needsAd = newCount % _adInterval == 0;

    if (!needsAd) {
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: openGame));
      return;
    }

    _rewardedAdManager.showIfReady(
      onUserEarnedReward: (amount, type) {
        if (!mounted) return;
        Navigator.push(context, MaterialPageRoute(builder: openGame));
      },
      onNotReady: () {
        // No ad available right now — don't block play, just let them in
        // and try again on the next interval.
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Ad not ready — enjoy the game, we\'ll catch it next time.',
            ),
          ),
        );
        Navigator.push(context, MaterialPageRoute(builder: openGame));
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _init();
    _rewardedAdManager.load();
  }

  @override
  void dispose() {
    _rewardedAdManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 15,
        toolbarHeight: 70,
        flexibleSpace: Image.asset("lib/assets/appbar.jpg", fit: BoxFit.cover),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Center(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Text(
                  "HUDDLE",
                  style: TextStyle(
                    letterSpacing: 5,
                    fontSize: 27,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => Favorites()),
                );
              },
              child: Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color.fromARGB(221, 158, 184, 199),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.favorite_border_outlined,
                  color: const Color.fromARGB(221, 178, 195, 204),
                ),
              ),
            ),
          ],
        ),
        // Removed excessive margin that was causing layout issues
      ),
      body: !_statusReady
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromARGB(66, 26, 78, 112),
                          width: 2,
                        ),
                      ),
                      child: const Text(
                        '"In this game, everyone needs a break to refuel, recharge, and jump back in full throttle." — Helen Edwards',
                        style: TextStyle(
                          color: Color.fromARGB(158, 40, 94, 139),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                  games(
                    image:
                        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTk2Zv2kmYXZOEjMaMavdqO9R8hpnI_SqtXj6WpsMnsqw&s=10",
                    name: "Tic Tac Toe",
                    ontap: () =>
                        _playGame(context, (context) => TicTacToeApp()),
                  ),

                  games(
                    image:
                        "https://www.alaskanmaker.fr/img/cms/R%C3%A8gles%20jeu%20de%20dames%20anglaises/JD%203.jpg",
                    name: "Checkers",
                    ontap: () => _playGame(context, (context) => CheckersApp()),
                  ),
                  const SizedBox(height: 16),

                  Text("play more games ?"),
                  const SizedBox(height: 16),

                  games(
                    image:
                        "https://play-lh.googleusercontent.com/YAdlxXdSFvbPyxQE25oRVMRXcc_6_OCVugoH2JKO4_1bFFwrBGKWOkwrRn5gzIPmDqKD29Qk0_V1HsTsEjhSpA",
                    name: "Chicken Ninja",
                    ontap: () => _playGame(context, (context) => DinoJumpApp()),
                  ),

                  const SizedBox(height: 16),
                  games(
                    image:
                        "https://cdn-icons-png.flaticon.com/512/4363/4363846.png",
                    name: "Chess",
                    ontap: () => _playGame(context, (context) => ChessApp()),
                  ),
                ],
              ),
            ),
    );
  }
}

Widget games({String? image, required String name, GestureTapCallback? ontap}) {
  return InkWell(
    onTap: ontap,
    child: Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(
          width: 2,
          color: const Color.fromARGB(66, 26, 78, 112),
        ),
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              image ?? '',
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 180,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, size: 60),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              name,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Divider(height: 2, color: Colors.black54),
          SizedBox(height: 12),
        ],
      ),
    ),
  );
}
