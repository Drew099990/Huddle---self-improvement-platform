import "package:flutter/material.dart";

//journal page

class Journal extends StatefulWidget {
  const Journal({super.key});

  @override
  State<Journal> createState() => _JournalState();
}

class _JournalState extends State<Journal> {
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
                Icon(
                  Icons.menu_book_outlined,
                  size: 150,
                  color: const Color.fromARGB(221, 11, 52, 71),
                ),
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
                          autocorrect: true,

                          enabled: true,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.favorite_outline),

                            border: OutlineInputBorder(
                              gapPadding: 10,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintText: "what are you grateful about?",
                            counterText: "share your progess",
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),

                        width: MediaQuery.of(context).size.width * 0.80,
                        child: TextField(
                          autocorrect: true,

                          enabled: true,

                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.alt_route_sharp),
                            border: OutlineInputBorder(
                              gapPadding: 10,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintText: "what do you wish you did better? ",
                            counterText: "share parts you wish to work on",
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),

                        width: MediaQuery.of(context).size.width * 0.80,
                        child: TextField(
                          autocorrect: true,

                          enabled: true,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.check_box_outlined),

                            border: OutlineInputBorder(
                              gapPadding: 10,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintText: "how will you achive you goals",
                            counterText:
                                "share your ideas on achiveing the goals",
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

                    child: Row(
                      children: [
                        Icon(Icons.add, color: Colors.white60),

                        Text(
                          "new entry",
                          style: TextStyle(
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
