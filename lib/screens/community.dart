import "package:flutter/material.dart";
import "package:hive_flutter/hive_flutter.dart";
//journal page

class Community extends StatefulWidget {
  const Community({super.key});

  @override
  State<Community> createState() => _JournalState();
}

class _JournalState extends State<Community> {
  late Box _box;

  @override
  void initState() {
    super.initState();
    _setupHive();
  }

  Future<void> _setupHive() async {
    await Hive.initFlutter();
    _box = await Hive.openBox("Huddle");
    setState(() {});
  }

  void add(String value) {
    setState(() {
      _box.add(value);
    });
  }

  void delete(int key) {
    _box.delete(key);
  }

  void update(int key, String value) {
    _box.put(key, value);
  }

  final _post = TextEditingController();
  String post = "";
  void _makePost() {
    setState(() {
      post = _post.text;
    });
  }

  DateTime date = DateTime.timestamp();

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
                SizedBox(height: 10),
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
                        "Community",
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
                            hintText: "what is on your mind?",
                            counterText: "thoughts",
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
                  onTap: _makePost,
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
                          "Post",
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

            Padding(
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
                    SizedBox(height: 4),
                    Text(
                      "$post",
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
                          "~william",
                          style: TextStyle(fontSize: 10, color: Colors.black54),
                        ),
                        Text(
                          "$date",
                          style: TextStyle(fontSize: 10, color: Colors.black54),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Divider(height: 2),
          ],
        ),
      ),
    );
  }
}
