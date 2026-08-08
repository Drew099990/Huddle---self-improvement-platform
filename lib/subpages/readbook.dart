import "package:Huddle/subpages/favorites.dart";
import "package:firebase_database/firebase_database.dart";
import "package:flutter/material.dart";
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../helpers/activity_log.dart';
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
  if (isAlreadyFavorite) {
    return favoritesCount >= limit;
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
  int limit = 5;
  late Box _favoriteBox;
  final TextEditingController _commentController = TextEditingController();
  List<String> _comments = [];

  String _bookKey() {
    final bookTitle = widget.book['title'] ?? 'daily_read';
    return bookTitle
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  Future<void> _loadComments() async {
    final ref = FirebaseDatabase.instance.ref('book_comments/${_bookKey()}');

    try {
      final snapshot = await ref.get();
      final value = snapshot.value;
      List<String> loadedComments = [];

      if (value is List) {
        loadedComments = value
            .map((item) => item?.toString() ?? '')
            .where((item) => item.trim().isNotEmpty)
            .toList();
      } else if (value is Map) {
        loadedComments = value.values
            .map((item) => item?.toString() ?? '')
            .where((item) => item.trim().isNotEmpty)
            .toList();
      }

      if (mounted) {
        setState(() {
          _comments = loadedComments;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _comments = [];
        });
      }
    }
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

    final updatedComments = addCommentToList(_comments, trimmedComment);
    final ref = FirebaseDatabase.instance.ref('book_comments/${_bookKey()}');

    try {
      await ref.set(updatedComments);
      if (mounted) {
        setState(() {
          _comments = updatedComments;
          _commentController.clear();
        });
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
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 260),
                  child: _comments.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'No comments yet. Be the first to share your thoughts.',
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: _comments.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                _comments[index],
                                style: const TextStyle(fontSize: 15),
                              ),
                            );
                          },
                        ),
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
    if (mounted) {
      setState(() {
        favorite = isFavorite;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    _favoriteBox = await _openFavoritesBox();
    final favorites = _favoriteBookList();
    final title = widget.book['title'];
    final isAlreadyFavorite = favorites.any((item) => item['title'] == title);

    final canToggle = canToggleFavorite(
      isAlreadyFavorite: isAlreadyFavorite,
      favoritesCount: favorites.length,
      limit: limit,
    );

    if (!canToggle) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color.fromARGB(253, 221, 228, 233),
          title: const Text('Favorite limit reached'),
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
            child: const Text(
              'You can only save up to 5 favorite books. Upgrade to add more.',
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
              onPressed: () {
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: const Color.fromARGB(255, 223, 228, 233),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                    contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    title: const Text(
                      'Upgrade to Premium',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(200, 27, 52, 77),
                      ),
                    ),

                    content: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 420,
                        maxHeight: MediaQuery.of(context).size.height * 0.75,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(131, 55, 92, 114),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Perks("Remove all Ads"),
                                  Perks("Unlimited Favorites"),
                                  Perks("Access to All Games"),
                                  Perks("Become a Beta Tester"),
                                  Perks("Supports me ^_^"),
                                  const SizedBox(height: 12),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Navigate to the upgrade page or perform upgrade action
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            55,
                            99,
                            134,
                          ),
                        ),
                        child: const Text(
                          '\$9.99',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 40, 80, 104),
              ),
              child: const Text(
                'Upgrade',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      );
      return;
    }

    if (isAlreadyFavorite && favorites.length >= limit) {
      favorites.removeWhere((item) => item['title'] == title);
      await ActivityLog.add('Removed favorite book: ${widget.book['title']}');
    } else {
      favorites.add(widget.book.cast<String, String>());
      await ActivityLog.add('Added favorite book: ${widget.book['title']}');
    }

    await _favoriteBox.put('favorites', favorites);

    if (mounted) {
      setState(() {
        favorite = !isAlreadyFavorite;
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isAlreadyFavorite ? 'Removed from Favorites' : 'Added to Favorites',
        ),
      ),
    );
  }

  Future<void> _openLink(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final link = widget.book['link'] ?? '';
    if (link.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          backgroundColor: const Color.fromARGB(148, 34, 39, 58),

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
          backgroundColor: const Color.fromARGB(148, 34, 39, 58),
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
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
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

Widget Perks(String perk) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.star_border_outlined,
          size: 34,
          color: const Color.fromARGB(242, 197, 204, 218),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            perk,
            softWrap: true,
            style: const TextStyle(
              fontSize: 15,
              color: Color.fromARGB(255, 246, 246, 248),
            ),
          ),
        ),
      ],
    ),
  );
}
