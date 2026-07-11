import "dart:async";

import "package:flutter/material.dart";
import "package:hive_flutter/hive_flutter.dart";
//journal page

DateTime date = DateTime.now();
String year = date.year.toString();
String month = date.month.toString().padLeft(2, '0');
String day = date.day.toString().padLeft(2, '0');
String hour = date.hour.toString().padLeft(2, '0');
String minute = date.minute.toString().padLeft(2, '0');

// Combine into your desired structure
String formattedString = "$year-$month-$day $hour:$minute";
// Output: 2026-07-09 15:45

class Community extends StatefulWidget {
  const Community({super.key});

  @override
  State<Community> createState() => _JournalState();
}

class _PostCard {
  _PostCard({required this.text, required this.createdAt});

  final String text;
  final DateTime createdAt;
  int remainingSeconds = 10;
  double progressWidth = 200;
  Timer? timer;
}

class _JournalState extends State<Community> {
  int count = 0;
  late Box _box;
  final List<_PostCard> _generatedCards = [];

  @override
  void initState() {
    super.initState();
    _setupHive();
  }

  Future<void> _setupHive() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('Huddle');
    final savedCards = _box.get('postCards', defaultValue: <String>[]);

    if (savedCards is List) {
      setState(() {
        _generatedCards.addAll(
          savedCards.whereType<String>().map((value) => _PostCard(text: value, createdAt: DateTime.now())),
        );
        count = _generatedCards.length;
      });
    }
  }

  void add(String value) {
    setState(() {
      _box.add(value);
    });
  }

  void _startCount() {
    final value = _post.text.trim();
    if (value.isEmpty) {
      return;
    }

    if (_generatedCards.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can create up to 5 cards only.')),
      );
      return;
    }

    final card = _PostCard(text: value, createdAt: DateTime.now());

    setState(() {
      post = value;
      _generatedCards.add(card);
      count = _generatedCards.length;
    });

    _saveCards();

    card.timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        return;
      }

      setState(() {
        if (card.remainingSeconds > 0) {
          card.remainingSeconds--;
          card.progressWidth = (card.remainingSeconds / 10) * 200;
        } else {
          timer.cancel();
          _removeCard(card);
        }
      });
    });

    _post.clear();
  }

  void _saveCards() {
    final values = _generatedCards.map((card) => card.text).toList();
    _box.put('postCards', values);
  }

  void _removeCard(_PostCard card) {
    setState(() {
      _generatedCards.remove(card);
      count = _generatedCards.length;
    });
    _saveCards();
  }

  void delete(int key) {
    _box.delete(key);
  }

  void update(int key, String value) {
    _box.put(key, value);
  }

  final _post = TextEditingController();
  String post = "";

  @override
  void dispose() {
    for (final card in _generatedCards) {
      card.timer?.cancel();
    }
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
        flexibleSpace: Image.asset("lib/assets/appbar.jpg", fit: BoxFit.cover),
        title: Center(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            margin: EdgeInsets.all(30),

            child: Text(
              "HUDDLE",
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
            SizedBox(height: 10),
            Column(
              children: [
                Text(
                  "Daily Reset",
                  style: TextStyle(
                    letterSpacing: 3,
                    color: const Color.fromARGB(221, 11, 49, 99),
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  width: MediaQuery.of(context).size.width * 0.80,
                  child: TextField(
                    autocorrect: true,
                    controller: _post,
                    enabled: true,
                    decoration: InputDecoration(
                      suffixIcon: Icon(Icons.language_outlined),
                      border: OutlineInputBorder(
                        gapPadding: 10,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: "daily goals for the day?",
                      counterText: '24 hours goals set ($count /5)',
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: _startCount,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(25, 10, 25, 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(width: 3),
                      color: const Color.fromARGB(255, 15, 75, 105),
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.post_add_outlined, color: Colors.white60),
                        Text(
                          "Start Count",
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
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                "powered by sleepy panda",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black45),
              ),
            ),
            Divider(height: 2),

            if (_generatedCards.isEmpty)
              Padding(
                padding: const EdgeInsets.all(6.0),
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
                      margin: EdgeInsets.all(10),
                      width: MediaQuery.of(context).size.width * 0.80,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(66, 170, 193, 228),
                        border: Border.all(
                          width: 2,
                          color: const Color.fromARGB(184, 4, 42, 51),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.all(20),
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
                          SizedBox(height: 4),
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
                          SizedBox(height: 10),
                          Text(
                            card.text,
                            style: TextStyle(
                              letterSpacing: 2,
                              fontStyle: FontStyle.italic,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '~to Self',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                formattedString,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Time left: ${card.remainingSeconds}s',
                            style: TextStyle(
                              fontSize: 12,
                              color: card.remainingSeconds > 0
                                  ? Colors.black54
                                  : Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            Divider(height: 2),
          ],
        ),
      ),
    );
  }
}
