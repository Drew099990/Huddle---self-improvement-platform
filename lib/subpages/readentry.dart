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

  Future<void> _deleteEntry(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 223, 228, 233),

        title: const Text('Delete entry'),
        content: const Text(
          'Are you sure you want to delete this journal entry?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color.fromARGB(179, 104, 146, 165)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Color.fromARGB(255, 148, 60, 60)),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await JournalDatabase.instance.delete(id);
    await _refreshEntries();

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Journal entry deleted.')));
  }

  Future<void> _showEditDialog(JournalEntry entry) async {
    final gratitudeController = TextEditingController(text: entry.gratitude);
    final improvementController = TextEditingController(
      text: entry.improvement,
    );
    final goalsController = TextEditingController(text: entry.goals);

    Widget buildField({
      required IconData icon,
      required TextEditingController controller,
      required String hint,
      required String counterText,
    }) {
      return Container(
        margin: const EdgeInsets.only(top: 10),
        width: MediaQuery.of(context).size.width * 0.80,
        child: TextField(
          controller: controller,
          autocorrect: true,
          maxLines: 3,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(
              gapPadding: 10,
              borderRadius: BorderRadius.circular(10),
            ),
            hintText: hint,
            counter: Text(
              counterText,
              style: const TextStyle(color: Color.fromARGB(255, 27, 59, 114)),
            ),
          ),
        ),
      );
    }

    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color.fromARGB(255, 223, 228, 233),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  width: 2,
                  color: const Color.fromARGB(137, 18, 57, 88),
                ),
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Edit journal entry #${entry.id}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 33, 66, 109),
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildField(
                    icon: Icons.favorite_outline,
                    controller: gratitudeController,
                    hint: 'what are you grateful about?',
                    counterText: 'share your progress',
                  ),
                  buildField(
                    icon: Icons.alt_route_sharp,
                    controller: improvementController,
                    hint: 'how do you wish to build up on this?',
                    counterText: 'share parts you wish to work on',
                  ),
                  buildField(
                    icon: Icons.check_box_outlined,
                    controller: goalsController,
                    hint: 'how will you achieve your goals',
                    counterText: 'share your ideas on achieving the goals',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color.fromARGB(115, 15, 69, 85),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          final gratitude = gratitudeController.text.trim();
                          final improvement = improvementController.text.trim();
                          final goals = goalsController.text.trim();

                          if (gratitude.isEmpty ||
                              improvement.isEmpty ||
                              goals.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please fill all journal fields.',
                                ),
                              ),
                            );
                            return;
                          }

                          await JournalDatabase.instance.update(
                            entry.copyWith(
                              gratitude: gratitude,
                              improvement: improvement,
                              goals: goals,
                            ),
                          );

                          await _refreshEntries();
                          if (!mounted) return;
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Journal entry updated.'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            157,
                            17,
                            50,
                            82,
                          ),
                        ),
                        child: const Text(
                          'Update',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
                  SizedBox(height: 300),
                  Center(
                    child: Text(
                      'No journal entries yet.',
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
                      color: const Color.fromARGB(55, 15, 58, 78),
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: Container(
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
                                'Daily Entry #${entry.id}',
                                style: const TextStyle(
                                  color: Colors.black45,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () => _showEditDialog(entry),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        padding: EdgeInsets.all(3),

                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                            129,
                                            51,
                                            102,
                                            94,
                                          ),
                                          border: Border.all(
                                            width: 3,
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
                                  InkWell(
                                    onTap: () => _deleteEntry(entry.id!),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        padding: EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                            164,
                                            121,
                                            47,
                                            36,
                                          ),
                                          border: Border.all(
                                            width: 3,
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
                                            211,
                                            188,
                                            186,
                                          ),
                                          Icons.delete_forever_outlined,
                                        ),
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
