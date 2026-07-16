import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

DateTime date = DateTime.now();
String year = date.year.toString();
String month = date.month.toString().padLeft(2, '0');
String day = date.day.toString().padLeft(2, '0');
String hour = date.hour.toString().padLeft(2, '0');
String minute = date.minute.toString().padLeft(2, '0');

String formattedString = '$year-$month-$day ';

class Community extends StatefulWidget {
  const Community({super.key});

  @override
  State<Community> createState() => _JournalState();
}

class _PostCard {
  _PostCard({
    required this.title,
    required this.text,
    required this.remainingSeconds,
    required this.updatedAt,
  });

  final String title;
  final String text;
  int remainingSeconds;
  DateTime updatedAt;
  double progressWidth = 200;
}

class _JournalState extends State<Community> {
  late Box _box;
  final TextEditingController _posttitle = TextEditingController();
  final TextEditingController _post = TextEditingController();
  String post = '';
  int count = 0;
  bool _allowOverLimit = false;
  final List<_PostCard> _generatedCards = [];
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _setupHive();
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _syncCountdowns();
        });
      }
    });
  }

  Future<void> _setupHive() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('Huddle');
    final savedCards = _box.get('postCards', defaultValue: <dynamic>[]);

    if (savedCards is List) {
      final restoredCards = savedCards.whereType<Map>().map((entry) {
        final map = Map<String, dynamic>.from(entry);
        final savedAt = DateTime.parse(map['updatedAt'] as String);
        final elapsedSeconds = DateTime.now()
            .difference(savedAt)
            .inSeconds
            .clamp(0, 24 * 60 * 60);
        final remainingSeconds = math.max(
          0,
          (map['remainingSeconds'] as int) - elapsedSeconds,
        );

        return _PostCard(
          title: (map['title'] as String?) ?? 'Untitled',
          text: map['text'] as String,
          remainingSeconds: remainingSeconds,
          updatedAt: DateTime.now(),
        );
      }).toList();

      if (mounted) {
        setState(() {
          _generatedCards.addAll(restoredCards);
          count = _generatedCards.length;
        });
      }
    }
  }

  void add(String value) {
    setState(() {
      _box.add(value);
    });
  }

  void _startCount() {
    final value = _post.text.trim();
    final title = _posttitle.text.trim();
    if (value.isEmpty) {
      return;
    }

    if (!_allowOverLimit && _generatedCards.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color.fromARGB(255, 37, 130, 167),
          content: const Text(
            'You can set up to 5 goals per day in free tier, see ya tommorrow for more.',
            style: TextStyle(color: Colors.white),
          ),
          action: SnackBarAction(label: 'okay', onPressed: () {}),
        ),
      );
      return;
    }

    final card = _PostCard(
      title: title.isNotEmpty ? title : 'Untitled',
      text: value,
      remainingSeconds: 24 * 60 * 60,
      updatedAt: DateTime.now(),
    );

    post = value;
    if (mounted) {
      setState(() {
        _generatedCards.add(card);
        count = _generatedCards.length;
      });
    }
    _saveCards();
    _post.clear();
    _posttitle.clear();
  }

  void _saveCards() {
    final values = _generatedCards.map((card) {
      return {
        'title': card.title,
        'text': card.text,
        'remainingSeconds': card.remainingSeconds,
        'updatedAt': card.updatedAt.toIso8601String(),
      };
    }).toList();
    _box.put('postCards', values);
  }

  void _syncCountdowns() {
    final now = DateTime.now();
    final remainingCards = <_PostCard>[];
    var changed = false;

    for (final card in _generatedCards) {
      final elapsedSeconds = now.difference(card.updatedAt).inSeconds;
      if (elapsedSeconds > 0) {
        card.remainingSeconds = math.max(
          0,
          card.remainingSeconds - elapsedSeconds,
        );
        card.updatedAt = now;
        card.progressWidth = (card.remainingSeconds / (24 * 60 * 60)) * 200;
        changed = true;
      }

      if (card.remainingSeconds > 0) {
        remainingCards.add(card);
      } else {
        changed = true;
      }
    }

    if (remainingCards.length != _generatedCards.length || changed) {
      setState(() {
        _generatedCards.clear();
        _generatedCards.addAll(remainingCards);
        count = _generatedCards.length;
      });
      _saveCards();
    }
  }

  void delete(int key) {
    _box.delete(key);
  }

  void update(int key, String value) {
    _box.put(key, value);
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}h ${minutes.toString().padLeft(2, '0')}m ${secs.toString().padLeft(2, '0')}s';
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _posttitle.dispose();
    _post.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 15,
        toolbarHeight: 70,
        flexibleSpace: Image.asset('lib/assets/appbar.jpg', fit: BoxFit.cover),
        title: Center(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            margin: const EdgeInsets.all(30),
            child: const Text(
              'HUDDLE',
              style: TextStyle(
                letterSpacing: 5,
                fontSize: 27,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 10),
            Column(
              children: [
                const Text(
                  'Daily Reset',
                  style: TextStyle(
                    letterSpacing: 3,
                    color: Color.fromARGB(221, 11, 49, 99),
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: MediaQuery.of(context).size.width * 0.80,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 56,
                        child: TextField(
                          maxLines: 1,
                          autocorrect: true,
                          controller: _posttitle,
                          enabled: true,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            suffixIcon: const Icon(Icons.language_outlined),
                            border: OutlineInputBorder(
                              gapPadding: 10,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintText: 'title',
                            counterText: 'title',
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 56,
                        child: TextField(
                          autocorrect: true,
                          controller: _post,
                          enabled: true,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            suffixIcon: const Icon(Icons.language_outlined),
                            border: OutlineInputBorder(
                              gapPadding: 10,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintText: 'daily goals for the day?',
                            counterText:
                                '24 hours goals set ($count /${_allowOverLimit ? '5+' : '5'})',
                          ),
                        ),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Bypass the 5-card daily limit',
                          style: TextStyle(fontSize: 12),
                        ),
                        subtitle: const Text(
                          'Enable this to add more than 5 cards today.',
                        ),
                        value: _allowOverLimit,
                        onChanged: (value) {
                          setState(() {
                            _allowOverLimit = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: _startCount,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(width: 3),
                      color: const Color.fromARGB(255, 15, 75, 105),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.post_add_outlined, color: Colors.white60),
                        Text(
                          'Start Count',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                'powered by sleepy panda',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black45),
              ),
            ),
            const Divider(height: 3),
            if (_generatedCards.isEmpty)
              const Padding(
                padding: EdgeInsets.all(6.0),
                child: Text(
                  'Start the countdown to create your first card.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
              )
            else
              Column(
                children: _generatedCards.map((card) {
                  return Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      width: MediaQuery.of(context).size.width * 0.80,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(66, 170, 193, 228),
                        border: Border.all(
                          width: 6,
                          color: const Color.fromARGB(115, 4, 20, 51),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: BoxBorder.all(
                                width: 2,
                                color: const Color.fromARGB(31, 51, 116, 146),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedContainer(
                            width: card.progressWidth,
                            duration: const Duration(seconds: 1),
                            curve: Curves.linear,
                            decoration: BoxDecoration(
                              border: BoxBorder.all(
                                width: 2,
                                color: const Color.fromARGB(137, 51, 116, 146),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadiusGeometry.circular(10),
                            child: Text(
                              " <" + card.title + "> ",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,

                                background: Paint()
                                  ..color = const Color.fromARGB(
                                    115,
                                    180,
                                    198,
                                    216,
                                  ),
                                color: const Color.fromARGB(221, 8, 30, 58),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            card.text,
                            style: const TextStyle(
                              letterSpacing: 2,
                              fontStyle: FontStyle.italic,
                              fontSize: 15,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '~to Self',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                '$year-$month-$day ',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: BoxBorder.all(
                                width: 2,
                                color: const Color.fromARGB(31, 51, 116, 146),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedContainer(
                            width: card.progressWidth,
                            duration: const Duration(seconds: 1),
                            curve: Curves.linear,
                            decoration: BoxDecoration(
                              border: BoxBorder.all(
                                width: 2,
                                color: const Color.fromARGB(137, 51, 116, 146),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Time left: ${_formatDuration(card.remainingSeconds)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: card.remainingSeconds > 0
                                  ? Colors.black54
                                  : Colors.redAccent,
                            ),
                          ),
                          const Divider(height: 2),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            const Divider(height: 2),
          ],
        ),
      ),
    );
  }
}
