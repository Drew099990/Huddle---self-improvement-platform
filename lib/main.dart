import 'package:flutter/material.dart';
import "./screens/home.dart";
import "./screens/Journal.dart";
import "./screens/community.dart";
import "./screens/profile.dart";
import "package:huddle/screens/login.dart";
import "package:huddle/screens/register.dart";

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int page = 0;

  List<Widget> _PAGES = <Widget>[
    Register(),
    Login(),
    Home(),
    Journal(),
    Community(),
    Profile(),
  ];

  void selectedPage(int index) {
    setState(() {
      print(index);
      page = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 15,
          toolbarHeight: 70,
          flexibleSpace: Image.asset(
            "lib/assets/appbar.jpg",
            fit: BoxFit.cover,
          ),
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
        body: _PAGES[page],
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: const Color.fromARGB(255, 64, 80, 102),
          elevation: 10,
          currentIndex: page,
          enableFeedback: true,
          onTap: selectedPage,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined),
              label: 'Journal',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Community',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

//home page
