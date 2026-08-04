import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerPage extends StatefulWidget {
  final String url;
  PdfViewerPage({super.key, required this.url});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  String note = " ";

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
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color.fromARGB(221, 158, 184, 199),
                  width: 2,
                ),
              ),
              child: InkWell(
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Text(
                      "Make a short note",
                      style: TextStyle(
                        color: const Color.fromARGB(255, 22, 40, 97),
                      ),
                    ),
                    content: Container(
                      height: 200,
                      child: ListView(
                        children: [
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color.fromARGB(118, 16, 42, 80),
                                width: 2,
                              ),
                              color: const Color.fromARGB(255, 201, 203, 204),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            height: 130,
                            child: Text("$note "),
                          ),
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
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Save Note",
                          style: TextStyle(
                            color: const Color.fromARGB(255, 22, 40, 97),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Close",
                          style: TextStyle(
                            color: const Color.fromARGB(255, 22, 40, 97),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.note_add_outlined,
                  color: Color.fromARGB(164, 230, 235, 240),
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
