import "package:Huddle/subpages/favorites.dart";
import "package:flutter/material.dart";
import 'package:url_launcher/url_launcher.dart';
import 'book_viewer.dart';

class Rbooks extends StatefulWidget {
  const Rbooks({super.key, required this.book});

  final Map<String, String> book;

  @override
  State<Rbooks> createState() => _RbooksState();
}

class _RbooksState extends State<Rbooks> {
  bool favorite = false;

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
                      onTap: () => {
                        setState(() {
                          favorite = !favorite;

                          if (favorite) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Added to Favorites"),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Removed from Favorites"),
                              ),
                            );
                          }
                        }),
                      },
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
                          vertical: 12,
                          horizontal: 24,
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
                              'Read (in-app)',
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
                      onTap: () async {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color.fromARGB(
                              148,
                              34,
                              39,
                              58,
                            ),
                            content: Text("Currently Unavailable"),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 15,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 149, 182, 171),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color.fromARGB(255, 52, 87, 75),
                            width: 2,
                          ),
                        ),
                        child: const Text(
                          'Leave Comment',
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
