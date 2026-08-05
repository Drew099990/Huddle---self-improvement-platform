import "package:flutter/material.dart";
import "../subpages/readentry.dart";
import "../helpers/journal_database.dart";

class Journal extends StatefulWidget {
  const Journal({super.key});

  @override
  State<Journal> createState() => _JournalState();
}

class _JournalState extends State<Journal> {
  final _gratitudeController = TextEditingController();
  final _improvementController = TextEditingController();
  final _goalsController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _gratitudeController.dispose();
    _improvementController.dispose();
    _goalsController.dispose();
    super.dispose();
  }

  Future<void> _saveEntry() async {
    final gratitude = _gratitudeController.text.trim();
    final improvement = _improvementController.text.trim();
    final goals = _goalsController.text.trim();

    if (gratitude.isEmpty || improvement.isEmpty || goals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all journal fields.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await JournalDatabase.instance.create(
        JournalEntry(
          gratitude: gratitude,
          improvement: improvement,
          goals: goals,
        ),
      );

      _gratitudeController.clear();
      _improvementController.clear();
      _goalsController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: const Color.fromARGB(148, 34, 39, 58),
          content: Text('Journal entry saved successfully.'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color.fromARGB(148, 34, 39, 58),
          content: Text('Failed to save entry: $error'),
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
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
            Column(
              children: [
                Container(
                  padding: EdgeInsets.all(
                    MediaQuery.of(context).size.width * 0.05,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color.fromARGB(160, 15, 43, 80),
                      width: 4,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Daily entry",
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
                          controller: _gratitudeController,
                          autocorrect: true,
                          maxLines: 3,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.favorite_outline),
                            border: OutlineInputBorder(
                              gapPadding: 10,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintText: "what are you grateful about?",
                            counter: Text(
                              "share your progress",
                              style: TextStyle(
                                color: const Color.fromARGB(255, 27, 59, 114),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        width: MediaQuery.of(context).size.width * 0.80,
                        child: TextField(
                          controller: _improvementController,
                          autocorrect: true,
                          maxLines: 3,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.alt_route_sharp),
                            border: OutlineInputBorder(
                              gapPadding: 10,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintText: "how do you wish to build up on this?",
                            counter: Text(
                              "share parts you wish to work on",
                              style: TextStyle(
                                color: const Color.fromARGB(255, 27, 59, 114),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        width: MediaQuery.of(context).size.width * 0.80,
                        child: TextField(
                          controller: _goalsController,
                          autocorrect: true,
                          maxLines: 3,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.check_box_outlined),
                            border: OutlineInputBorder(
                              gapPadding: 10,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintText: "how will you achieve your goals",
                            counter: Text(
                              "share your ideas on achieving the goals",
                              style: TextStyle(
                                color: const Color.fromARGB(255, 27, 59, 114),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: _isSaving ? null : _saveEntry,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        width: 3,
                        color: const Color.fromARGB(157, 2, 54, 66),
                      ),
                      color: const Color.fromARGB(255, 15, 75, 105),
                    ),

                    child: Row(
                      children: [
                        if (_isSaving)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        else
                          const Icon(Icons.add, color: Colors.white60),
                        const SizedBox(width: 8),
                        Text(
                          _isSaving ? "saving..." : "new entry",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                InkWell(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(25, 10, 25, 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        width: 3,
                        color: const Color.fromARGB(157, 2, 54, 66),
                      ),
                      color: const Color.fromARGB(255, 15, 75, 105),
                    ),

                    child: InkWell(
                      onTap: () {
                        Navigator.of(
                          context,
                        ).push(MaterialPageRoute(builder: (_) => readentry()));
                      },
                      child: Row(
                        children: [
                          Icon(Icons.list_outlined, color: Colors.white60),
                          Text(
                            "show entries",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Text(
                "powered by sleepy panda",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
