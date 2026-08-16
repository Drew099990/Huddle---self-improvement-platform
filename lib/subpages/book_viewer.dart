import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerPage extends StatefulWidget {
  final String url;
  const PdfViewerPage({super.key, required this.url});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  String note = '';
  late Box _notesBox;

  @override
  void initState() {
    super.initState();
    _loadSavedNote();
  }

  Future<void> _loadSavedNote() async {
    await Hive.initFlutter();
    _notesBox = Hive.isBoxOpen('bookNotes')
        ? Hive.box('bookNotes')
        : await Hive.openBox('bookNotes');

    final savedNote = _notesBox.get(_noteKey()) ?? '';
    if (mounted) {
      setState(() {
        note = savedNote;
      });
    }
  }

  String _noteKey() => 'note_${widget.url}';

  Future<void> _saveNote() async {
    if (!Hive.isBoxOpen('bookNotes')) {
      await Hive.initFlutter();
      _notesBox = await Hive.openBox('bookNotes');
    }
    await _notesBox.put(_noteKey(), note);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'One Book At A Time ',
              style: TextStyle(color: Color.fromARGB(164, 230, 235, 240)),
            ),
            Container(
              child: InkWell(
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: const Color.fromARGB(255, 222, 228, 230),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Text(
                      "Make a short note",
                      style: TextStyle(
                        color: const Color.fromARGB(144, 22, 39, 97),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: SizedBox(
                      height: 200,
                      child: ListView(
                        children: [
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color.fromARGB(68, 16, 42, 80),
                                width: 2,
                              ),
                              color: const Color.fromARGB(255, 201, 203, 204),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            height: 130,
                            child: Text(
                              "$note ",
                              style: TextStyle(color: Colors.black45),
                            ),
                          ),
                          SizedBox(height: 5),
                          TextField(
                            onChanged: (value) {
                              setState(() {
                                note = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: "Enter your note here",
                              border: UnderlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      InkWell(
                        onTap: () async {
                          await _saveNote();
                          if (mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 2,
                              color: Color.fromARGB(132, 37, 69, 109),
                            ),
                            borderRadius: BorderRadius.circular(15),
                            color: Color.fromARGB(136, 5, 48, 77),
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Save Note",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            "Close",
                            style: TextStyle(
                              color: const Color.fromARGB(193, 22, 39, 97),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                    Icons.note_add_outlined,
                    color: Color.fromARGB(164, 230, 235, 240),
                  ),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(192, 20, 69, 82),
      ),
      body: SfPdfViewer.network(
        widget.url,
        canShowScrollStatus: true,
        canShowScrollHead: true,
      ),
    );
  }
}
