import "package:Huddle/subpages/favorites.dart";
import "package:firebase_database/firebase_database.dart";
import "package:flutter/material.dart";
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../helpers/activity_log.dart';
import '../helpers/RewardAD.dart';
import 'book_viewer.dart';

List<String> addCommentToList(
  List<String> existingComments,
  String rawComment,
) {
  final trimmed = rawComment.trim();
  if (trimmed.isEmpty) {
    return existingComments;
  }

  final comments = List<String>.from(existingComments);
  comments.insert(0, trimmed);
  return comments;
}

bool canToggleFavorite({
  required bool isAlreadyFavorite,
  required int favoritesCount,
  required int limit,
}) {
  // Removing a favorite is always attemptable — whether it actually happens
  // is gated later, unconditionally, by the watch-ad flow, not by the
  // limit here. Only *adding* a new favorite is blocked once the limit
  // (base + any ad-earned bonus slots) is reached.
  if (isAlreadyFavorite) {
    return true;
  }
  return favoritesCount < limit;
}

class Rbooks extends StatefulWidget {
  const Rbooks({super.key, required this.book});

  final Map<String, String> book;

  @override
  State<Rbooks> createState() => _RbooksState();
}

class _RbooksState extends State<Rbooks> {
  bool favorite = false;

  // Base free limit. Each rewarded ad watched to unlock an addition past
  // this limit grants one permanent bonus slot (persisted in Hive), so
  // the effective limit is `_baseLimit + _bonusFavoriteSlots`.
  static const int _baseLimit = 5;
  int _bonusFavoriteSlots = 0;

  int get _favoriteLimit => _baseLimit + _bonusFavoriteSlots;

  late Box _favoriteBox;
  final TextEditingController _commentController = TextEditingController();

  final RewardedAdManager _rewardedAdManager = RewardedAdManager();

  String _bookKey() {
    final bookTitle = widget.book['title'] ?? 'daily_read';
    return bookTitle
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  /// Live stream of comments for this book, newest first.
  ///
  /// Comments are stored as individual push() children under
  /// `book_comments/{bookKey}/{pushId}` with a `text` and a server-assigned
  /// `timestamp`. This avoids the read-modify-overwrite race condition you'd
  /// get from storing comments as a single list value, since two users
  /// commenting around the same time each get their own child node instead
  /// of one clobbering the other's write.
  Stream<List<String>> _commentsStream() {
    final ref = FirebaseDatabase.instance
        .ref('book_comments/${_bookKey()}')
        .orderByChild('timestamp');

    return ref.onValue.map((event) {
      final value = event.snapshot.value;
      final entries = <MapEntry<int, String>>[];

      if (value is Map) {
        value.forEach((key, val) {
          if (val is Map && val['text'] != null) {
            final ts = val['timestamp'] is int ? val['timestamp'] as int : 0;
            entries.add(MapEntry(ts, val['text'].toString()));
          }
        });
      }

      entries.sort((a, b) => b.key.compareTo(a.key)); // newest first
      return entries.map((e) => e.value).toList();
    });
  }

  Future<void> _saveComment(String rawComment) async {
    final trimmedComment = rawComment.trim();
    if (trimmedComment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a comment before submitting.'),
        ),
      );
      return;
    }

    final ref = FirebaseDatabase.instance.ref('book_comments/${_bookKey()}');

    try {
      await ref.push().set({
        'text': trimmedComment,
        'timestamp': ServerValue.timestamp,
      });
      if (mounted) {
        _commentController.clear();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save the comment. Please try again.'),
          ),
        );
      }
    }
  }

  void _openCommentsSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: const Color.fromARGB(232, 221, 229, 235),
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Leave a Comment',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 27, 89, 117),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _commentController,
                  maxLines: 2,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Write your comment here...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 244, 246, 247),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 88, 116, 129),
                    ),
                    onPressed: () async {
                      final commentText = _commentController.text;
                      Navigator.pop(sheetContext);
                      await _saveComment(commentText);
                    },
                    child: const Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'All comments',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color.fromARGB(255, 27, 89, 117),
                  ),
                ),
                const SizedBox(height: 8),
                StreamBuilder<List<String>>(
                  stream: _commentsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Could not load comments: ${snapshot.error}',
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final comments = snapshot.data ?? [];

                    if (comments.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'No comments yet. Be the first to share your thoughts.',
                        ),
                      );
                    }

                    return ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 260),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: comments.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 244, 246, 247),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color.fromARGB(85, 52, 87, 75),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                comments[index],
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Box> _openFavoritesBox() async {
    if (!Hive.isBoxOpen('favoriteBooks')) {
      await Hive.initFlutter();
      return await Hive.openBox('favoriteBooks');
    }
    return Hive.box('favoriteBooks');
  }

  List<Map<String, String>> _favoriteBookList() {
    final raw = _favoriteBox.get('favorites', defaultValue: <dynamic>[]);
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((map) => map.cast<String, String>())
          .toList();
    }
    return <Map<String, String>>[];
  }

  bool _isFavoriteBook(Map<String, String> book) {
    final title = book['title'];
    return _favoriteBookList().any((favorite) => favorite['title'] == title);
  }

  Future<void> _loadFavoriteState() async {
    _favoriteBox = await _openFavoritesBox();
    final isFavorite = _isFavoriteBook(widget.book.cast<String, String>());
    final bonusSlots =
        _favoriteBox.get('bonusFavoriteSlots', defaultValue: 0) as int;
    if (mounted) {
      setState(() {
        favorite = isFavorite;
        _bonusFavoriteSlots = bonusSlots;
      });
    }
  }

  Future<void> _grantBonusFavoriteSlot() async {
    _bonusFavoriteSlots += 1;
    await _favoriteBox.put('bonusFavoriteSlots', _bonusFavoriteSlots);
    if (mounted) setState(() {});
  }

  // Adding: allowed for free up to `_favoriteLimit`. Past that, adding is
  // only possible by watching a rewarded ad (see `_watchAdForAddition`).
  // Removing: always requires watching a rewarded ad, with no other way
  // around it — there's no upgrade/paid bypass for either action.
  Future<void> _toggleFavorite() async {
    _favoriteBox = await _openFavoritesBox();
    final favorites = _favoriteBookList();
    final title = widget.book['title'];
    final isAlreadyFavorite = favorites.any((item) => item['title'] == title);

    final canToggle = canToggleFavorite(
      isAlreadyFavorite: isAlreadyFavorite,
      favoritesCount: favorites.length,
      limit: _favoriteLimit,
    );

    if (isAlreadyFavorite) {
      // Removal always requires watching an ad — no other path removes it.
      await _confirmRemoveFavorite(title);
      return;
    }

    if (!canToggle) {
      // Limit reached — the only way to add another is to watch an ad.
      await _confirmAddPastLimit();
      return;
    }

    favorites.add(widget.book.cast<String, String>());
    await _favoriteBox.put('favorites', favorites);
    await ActivityLog.add('Added favorite book: ${widget.book['title']}');

    if (mounted) {
      setState(() {
        favorite = true;
      });
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Added to Favorites')));
  }

  Future<void> _confirmAddPastLimit() async {
    final choice = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color.fromARGB(253, 221, 228, 233),
        title: const Text(
          'Limit reached',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black45),
        ),
        content: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 223, 228, 233),
            border: Border.all(
              color: const Color.fromARGB(85, 52, 87, 75),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'You can save up to $_favoriteLimit favorite books right now. '
            'Watch a short ad to unlock one more slot.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color.fromARGB(108, 32, 66, 117)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop('watch_ad'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 165, 102, 102),
            ),
            child: const Text(
              'Watch ad to add',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (choice == 'watch_ad') {
      _watchAdForAddition();
    }
  }

  void _watchAdForAddition() {
    _rewardedAdManager.showIfReady(
      onUserEarnedReward: (amount, type) async {
        await _grantBonusFavoriteSlot();

        final favorites = _favoriteBookList();
        final title = widget.book['title'];
        final alreadyThere = favorites.any((item) => item['title'] == title);

        if (!alreadyThere) {
          favorites.add(widget.book.cast<String, String>());
          await _favoriteBox.put('favorites', favorites);
          await ActivityLog.add('Added favorite book: ${widget.book['title']}');
        }

        if (mounted) {
          setState(() {
            favorite = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Slot unlocked — added to Favorites')),
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

  Future<void> _confirmRemoveFavorite(String? title) async {
    if (title == null) return;

    final choice = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Remove favorite?',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black45),
        ),
        content: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color.fromARGB(85, 52, 87, 75),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Watch a short ad to remove "$title" from your favorites.',
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop('watch_ad'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 175, 102, 102),
            ),
            child: const Text(
              'Watch ad & remove',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color.fromARGB(108, 32, 66, 117)),
            ),
          ),
        ],
      ),
    );

    if (choice == 'watch_ad') {
      _watchAdForRemoval(title);
    }
  }

  void _watchAdForRemoval(String title) {
    _rewardedAdManager.showIfReady(
      onUserEarnedReward: (amount, type) async {
        final favorites = _favoriteBookList();
        favorites.removeWhere((item) => item['title'] == title);
        await _favoriteBox.put('favorites', favorites);
        await ActivityLog.add('Removed favorite book: $title');

        if (mounted) {
          setState(() {
            favorite = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Removed from Favorites')),
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

  Future<void> _openLink(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final link = widget.book['link'] ?? '';
    if (link.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          backgroundColor: Color.fromARGB(148, 34, 39, 58),

          content: Text('Book currently unavailable'),
        ),
      );
      return;
    }

    Uri? uri = Uri.tryParse(link);
    if (uri == null || uri.scheme.isEmpty) {
      uri = Uri.tryParse('https://$link');
    }
    if (uri == null) {
      messenger.showSnackBar(
        const SnackBar(
          backgroundColor: Color.fromARGB(148, 34, 39, 58),
          content: Text('Invalid link'),
        ),
      );
      return;
    }

    try {
      final lowerLink = link.toLowerCase();
      final isPdf =
          uri.path.toLowerCase().endsWith('.pdf') || lowerLink.contains('.pdf');
      final isYouTube =
          uri.host.contains('youtube.com') || uri.host.contains('youtu.be');

      if (isPdf) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PdfViewerPage(url: uri.toString())),
        );
        return;
      }

      if (isYouTube) {
        final launched = await launchUrl(uri, mode: LaunchMode.inAppWebView);
        if (!launched) {
          final launchedExternal = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          if (!launchedExternal) {
            messenger.showSnackBar(
              const SnackBar(content: Text('Could not open YouTube link')),
            );
          }
        }
        return;
      }

      final launched = await launchUrl(uri, mode: LaunchMode.inAppWebView);
      if (!launched) {
        final launchedExternal = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (!launchedExternal) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Could not open book')),
          );
        }
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error opening link: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    _loadFavoriteState();
    _rewardedAdManager.load();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _rewardedAdManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.book['title'] ?? '';
    final image = widget.book['image'] ?? '';
    final category = widget.book['category'] ?? '';
    final summary = widget.book['summary'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Todays Daily Read",
              style: TextStyle(
                color: Colors.white60,
                overflow: TextOverflow.clip,
              ),
            ),
            Container(
              padding: EdgeInsets.all(3),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white60, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => Favorites()),
                  );
                },
                child: Icon(Icons.favorite_border, color: Colors.white60),
              ),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(192, 20, 69, 82),
      ),
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          color: const Color.fromARGB(255, 201, 203, 204),

          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (image.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color.fromARGB(157, 59, 83, 94),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        image,
                        height: MediaQuery.of(context).size.height * 0.4,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    overflow: TextOverflow.visible,
                    letterSpacing: 2,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                    InkWell(
                      onTap: _toggleFavorite,
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color.fromARGB(153, 59, 90, 79),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          favorite ? Icons.favorite : Icons.favorite_border,
                          color: favorite
                              ? const Color.fromARGB(255, 172, 71, 63)
                              : Colors.grey,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  summary,
                  style: TextStyle(
                    background: Paint()
                      ..color = Color.fromARGB(19, 87, 131, 116),

                    fontSize: 16,
                    color: const Color.fromARGB(118, 0, 0, 0),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () => _openLink(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 25,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 27, 89, 117),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color.fromARGB(255, 52, 87, 75),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.menu_book, color: Colors.white),
                            const SizedBox(width: 8),
                            const Text(
                              'Read',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    InkWell(
                      onTap: () => _openCommentsSheet(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 7,
                          horizontal: 15,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 119, 153, 142),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color.fromARGB(255, 52, 87, 75),
                            width: 2,
                          ),
                        ),
                        child: const Text(
                          'Leave a Comment',
                          style: TextStyle(color: Color.fromARGB(117, 0, 0, 0)),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Text(
                  "powered by sleepy panda",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black45),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
