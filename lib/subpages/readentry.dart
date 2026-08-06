import 'package:flutter/material.dart';
import '../helpers/journal_database.dart';
import '../subpages/favorites.dart';

class readentry extends StatefulWidget {
  const readentry({super.key});

  @override
  State<readentry> createState() => _readentryState();
}

class _readentryState extends State<readentry> {
  late Future<List<JournalEntry>> _entriesFuture;

  @override
  void initState() {
    super.initState();
    _entriesFuture = JournalDatabase.instance.readAllEntries();
  }

  Future<void> _refreshEntries() async {
    setState(() {
      _entriesFuture = JournalDatabase.instance.readAllEntries();
    });
    await _entriesFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 15,
        toolbarHeight: 70,
        flexibleSpace: Image.asset('lib/assets/appbar.jpg', fit: BoxFit.cover),
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
                  'HUDDLE',
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
                  MaterialPageRoute(builder: (_) => Favorites()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color.fromARGB(221, 158, 184, 199),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.favorite_border_outlined,
                  color: Color.fromARGB(221, 178, 195, 204),
                ),
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshEntries,
        child: FutureBuilder<List<JournalEntry>>(
          future: _entriesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: \\${snapshot.error}'));
            }
            final entries = snapshot.data ?? [];
            if (entries.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 150),
                  Center(
                    child: Text(
                      'No journal entries yet. Pull to refresh after saving one.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return Container(
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromARGB(157, 15, 58, 78),
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Entry #${entry.id}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () => showDialog(
                                      context: context,
                                      builder: (_) => Container(
                                        child: AlertDialog(
                                          title: Text(
                                            "Edit: Entry #${entry.id}",
                                          ),
                                          content: Container(
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              border: Border.all(
                                                width: 2,
                                                color: const Color.fromARGB(
                                                  185,
                                                  17,
                                                  65,
                                                  80,
                                                ),
                                              ),
                                            ),
                                            height: 300,
                                            child: Column(
                                              children: [
                                                Divider(height: 2),
                                                SizedBox(height: 10),
                                                TextField(
                                                  enabled: true,
                                                  decoration: InputDecoration(
                                                    fillColor:
                                                        const Color.fromARGB(
                                                          255,
                                                          201,
                                                          203,
                                                          204,
                                                        ),

                                                    hintText: "Progress made",
                                                    counterText: "Progress",
                                                  ),
                                                ),
                                                TextField(
                                                  enabled: true,
                                                  decoration: InputDecoration(
                                                    fillColor:
                                                        const Color.fromARGB(
                                                          255,
                                                          201,
                                                          203,
                                                          204,
                                                        ),

                                                    hintText: "Room for growth",
                                                    counterText: "Improvements",
                                                  ),
                                                ),
                                                TextField(
                                                  enabled: true,
                                                  decoration: InputDecoration(
                                                    fillColor:
                                                        const Color.fromARGB(
                                                          255,
                                                          201,
                                                          203,
                                                          204,
                                                        ),

                                                    hintText: "Step to take",
                                                    counterText: "Steps",
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () => {
                                                    Navigator.pop(context),
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.all(10),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        width: 2,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            15,
                                                          ),
                                                      color:
                                                          const Color.fromARGB(
                                                            96,
                                                            22,
                                                            69,
                                                            107,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      "Update",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        padding: EdgeInsets.all(5),

                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                            129,
                                            51,
                                            102,
                                            94,
                                          ),
                                          border: Border.all(
                                            width: 4,
                                            color: const Color.fromARGB(
                                              96,
                                              20,
                                              52,
                                              71,
                                            ),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        child: Icon(
                                          color: Color.fromARGB(
                                            255,
                                            186,
                                            211,
                                            193,
                                          ),
                                          Icons.edit_outlined,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                          164,
                                          121,
                                          47,
                                          36,
                                        ),
                                        border: Border.all(
                                          width: 4,
                                          color: const Color.fromARGB(
                                            96,
                                            20,
                                            52,
                                            71,
                                          ),
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Icon(
                                        color: Color.fromARGB(
                                          255,
                                          211,
                                          188,
                                          186,
                                        ),
                                        Icons.delete_forever_outlined,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Divider(height: 30, color: Colors.black54),
                          const SizedBox(height: 8),
                          Text(
                            "Gratitude and progression",
                            style: TextStyle(
                              color: const Color.fromARGB(255, 16, 60, 102),
                            ),
                          ),
                          const SizedBox(height: 8),

                          Text(
                            ': ${entry.gratitude}',
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                          Divider(height: 10, color: Colors.black12),

                          const SizedBox(height: 8),
                          Text(
                            "Future room for improvement",
                            style: TextStyle(
                              color: const Color.fromARGB(255, 27, 75, 114),
                            ),
                          ),
                          const SizedBox(height: 8),

                          Text(
                            'Improvement: ${entry.improvement}',
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                          Divider(height: 10, color: Colors.black12),

                          const SizedBox(height: 8),
                          Text(
                            "Steps to take",
                            style: TextStyle(
                              color: const Color.fromARGB(255, 27, 59, 114),
                            ),
                          ),
                          const SizedBox(height: 8),

                          Text(
                            'Steps: ${entry.goals}',
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
