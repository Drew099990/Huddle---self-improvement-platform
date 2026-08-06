import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../screens/home.dart';
import 'readbook.dart';
import './minigame.dart';

class Favorites extends StatefulWidget {
  const Favorites({super.key});

  @override
  State<Favorites> createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  Box? _favoriteBox;

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

  @override
  void initState() {
    super.initState();
    _initFavorites();
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
        // Removed excessive margin that was causing layout issues
      ),

      body: _favoriteBox == null
          ? const Center(child: CircularProgressIndicator())
          : ValueListenableBuilder<Box>(
              valueListenable: _favoriteBox!.listenable(keys: ['favorites']),
              builder: (context, box, _) {
                final favorites = _favoriteBookList();
                if (favorites.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'No favorite books yet. Tap the heart icon on a book to add it.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const Home()),
                            );
                          },
                          child: const Text('Browse books'),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    if (favorites.length >= 5)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                'You have reached the 5 favorite book limit. Upgrade to add more.',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 42, 100, 122),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const Home(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  137,
                                  16,
                                  46,
                                  100,
                                ),
                              ),
                              child: const Text(
                                'Upgrade',
                                style: TextStyle(color: Colors.white70),
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
                          final category = book['category'] ?? '';

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
                                color: const Color.fromARGB(195, 50, 89, 100),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                        color: Colors.white70,
                                        fontWeight: FontWeight.bold,
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
