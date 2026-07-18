import 'package:flutter/material.dart';
import "../subpages/readbook.dart";
import "./bookss.dart";

class Books extends StatelessWidget {
  const Books({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.70,
      ),
      itemCount: booksCollected.length,
      itemBuilder: (context, index) {
        final book = booksCollected[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => Rbooks(book: book)),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color.fromARGB(118, 16, 42, 80),
                width: 3,
              ),
              color: const Color.fromARGB(255, 201, 203, 204),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: book['image'] != null && book['image']!.isNotEmpty
                      ? Container(
                          height: 200,
                          padding: EdgeInsets.all(600),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                            image: DecorationImage(
                              image: NetworkImage(book['image']!),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Text(book["title"]),
                        )
                      : const SizedBox.shrink(),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(height: 1, color: Colors.black54),

                      Text(
                        book['title'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(137, 0, 0, 0),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        book['category']?.toUpperCase() ?? '',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 11,
                        ),
                      ),
                      Divider(height: 1, color: Colors.black54),
                      const SizedBox(height: 8),
                      Text(
                        book['summary'] ?? '',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
