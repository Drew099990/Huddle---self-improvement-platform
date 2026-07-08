import "package:flutter/material.dart";
import 'package:url_launcher/url_launcher.dart';

class Rbooks extends StatelessWidget {
  Rbooks({super.key, required this.book});

  final Map<String, String> book;

  Future<void> _openLink(BuildContext context) async {
    final link = book['link'] ?? '';
    if (link.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No link available')));
      return;
    }

    final uri = Uri.tryParse(link);
    if (uri == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid link')));
      return;
    }

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.inAppWebView);
      if (!launched) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open link')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error opening link: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = book['title'] ?? '';
    final image = book['image'] ?? '';
    final category = book['category'] ?? '';
    final summary = book['summary'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color.fromARGB(129, 87, 131, 116),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (image.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    image,
                    height: MediaQuery.of(context).size.height * 0.4,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  overflow: TextOverflow.visible,
                  letterSpacing: 2,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                category.toUpperCase(),
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Text(
                summary,
                style: TextStyle(
                  background: Paint()..color = Color.fromARGB(19, 87, 131, 116),

                  fontSize: 16,
                  color: Colors.black87,
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
                        color: const Color.fromARGB(255, 87, 131, 116),
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
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),

                  InkWell(
                    onTap: () async {
                      final link = book['link'] ?? '';
                      final uri = Uri.tryParse(link);
                      if (uri != null) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      }
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
                      child: const Text('Open Externally'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                "powered by sleepy panda",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
