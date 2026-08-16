import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../screens/home.dart';
import 'readbook.dart';
import './minigame.dart';
import '../helpers/RewardAD.dart';

class Favorites extends StatefulWidget {
  const Favorites({super.key});

  @override
  State<Favorites> createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  Box? _favoriteBox;

  static const int _baseFavoriteLimit = 5;
  static const int _bonusSlotsPerAd = 1; // extra slots granted per watched ad

  final RewardedAdManager _rewardedAdManager = RewardedAdManager();

  Future<Box> _openFavoritesBox() async {
    if (!Hive.isBoxOpen('favoriteBooks')) {
      await Hive.initFlutter();
      return await Hive.openBox('favoriteBooks');
    }
    return Hive.box('favoriteBooks');
  }

  List<Map<String, String>> _favoriteBookList() {
    final box = _favoriteBox;
    if (box == null) return <Map<String, String>>[];
    final raw = box.get('favorites', defaultValue: <dynamic>[]);
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((map) => map.cast<String, String>())
          .toList();
    }
    return <Map<String, String>>[];
  }

  int _bonusSlots() {
    final box = _favoriteBox;
    if (box == null) return 0;
    return box.get('bonusFavoriteSlots', defaultValue: 0) as int;
  }

  int _favoriteLimit() => _baseFavoriteLimit + _bonusSlots();

  Future<void> _initFavorites() async {
    _favoriteBox = await _openFavoritesBox();
    if (mounted) setState(() {});
  }

  Future<void> _removeFavorite(String title) async {
    final box = _favoriteBox;
    if (box == null) return;
    final favorites = _favoriteBookList();
    favorites.removeWhere((item) => item['title'] == title);
    await box.put('favorites', favorites);
    if (mounted) setState(() {});
  }

  // Removal is ad-gated: confirming the dialog never removes the favorite
  // directly. It only kicks off a rewarded ad; the book is removed solely
  // inside the ad's onUserEarnedReward callback. There is no other path
  // (paid or otherwise) that removes a favorite.
  Future<void> _confirmRemoveFavorite(String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove favorite?'),
        content: Text(
          'Watch a short ad to remove "$title" from your favorites?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 180, 106, 106),
            ),
            child: const Text(
              'Watch ad & remove',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      _watchAdForRemoval(title);
    }
  }

  void _watchAdForRemoval(String title) {
    _rewardedAdManager.showIfReady(
      onUserEarnedReward: (amount, type) async {
        await _removeFavorite(title);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('"$title" removed from favorites.')),
          );
        }
      },
      onNotReady: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ad not ready yet — try again in a moment.'),
          ),
        );
      },
    );
  }

  Future<void> _grantBonusSlot() async {
    final box = _favoriteBox;
    if (box == null) return;
    await box.put('bonusFavoriteSlots', _bonusSlots() + _bonusSlotsPerAd);
    if (mounted) setState(() {});
  }

  // Adding past the base limit is ad-gated too: this is the only way to
  // raise the effective limit. There is no upgrade/paid bypass.
  void _watchAdForSlot() {
    _rewardedAdManager.showIfReady(
      onUserEarnedReward: (amount, type) {
        _grantBonusSlot();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Nice! You can now favorite $_bonusSlotsPerAd more book(s).',
              ),
            ),
          );
        }
      },
      onNotReady: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ad not ready yet — try again in a moment.'),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _initFavorites();
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
                  MaterialPageRoute(builder: (_) => MiniGames()),
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
                  Icons.gamepad_outlined,
                  color: const Color.fromARGB(221, 178, 195, 204),
                ),
              ),
            ),
          ],
        ),
      ),

      body: _favoriteBox == null
          ? const Center(child: CircularProgressIndicator())
          : ValueListenableBuilder<Box>(
              valueListenable: _favoriteBox!.listenable(
                keys: ['favorites', 'bonusFavoriteSlots'],
              ),
              builder: (context, box, _) {
                final favorites = _favoriteBookList();
                final limit = _favoriteLimit();

                if (favorites.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'No favorite books yet.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const Home()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              32,
                              73,
                              92,
                            ),
                          ),
                          child: const Text(
                            'Browse books',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    (favorites.length >= limit)
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'You have reached your $limit favorite book limit. Watch an ad to add more.',
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 42, 100, 122),
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: _watchAdForSlot,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(
                                      173,
                                      228,
                                      89,
                                      89,
                                    ),
                                  ),
                                  child: const Text(
                                    'Watch ad',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    "A reader lives a thousand lives before he dies. The man who never reads lives only one.",
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 42, 100, 122),
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const Home(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(
                                      137,
                                      60,
                                      77,
                                      124,
                                    ),
                                  ),
                                  child: const Text(
                                    'Browse',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                    Divider(height: 10),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: favorites.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.72,
                            ),
                        itemBuilder: (context, index) {
                          final book = favorites[index];
                          final image = book['image'] ?? '';
                          final title = book['title'] ?? 'Untitled';

                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => Rbooks(book: book),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(195, 49, 79, 88),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color.fromARGB(255, 75, 90, 102),
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      if (image.isNotEmpty)
                                        ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(16),
                                            topRight: Radius.circular(16),
                                          ),
                                          child: Image.network(
                                            image,
                                            height: 180,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      Container(
                                        padding: EdgeInsets.all(4),
                                        child: Text(
                                          "Read",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            decoration:
                                                TextDecoration.underline,
                                            color: Colors.white70,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Unfavorite button — top-right corner of the card.
                                  Positioned(
                                    top: 6,
                                    right: 6,
                                    child: InkWell(
                                      onTap: () =>
                                          _confirmRemoveFavorite(title),
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.black45,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.favorite,
                                          color: Color.fromARGB(
                                            255,
                                            196,
                                            92,
                                            92,
                                          ),
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
