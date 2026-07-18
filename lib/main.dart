import 'package:flutter/material.dart';
import "./screens/home.dart";
import "./screens/Journal.dart";
import "screens/reset.dart";
import "./screens/profile.dart";
import "package:Huddle/screens/login.dart";

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int page = 0;

  bool loggedIN = false;

  final List<Widget> _PAGES = <Widget>[
    Home(),
    Journal(),
    Community(),
    Profile(),
  ];

  void _dataFromLogin(bool status) {
    setState(() {
      loggedIN = status;
    });
  }

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
        body: loggedIN ? _PAGES[page] : Login(onLogin: _dataFromLogin),
        bottomNavigationBar: loggedIN
            ? BottomNavigationBar(
                selectedItemColor: const Color.fromARGB(255, 64, 80, 102),
                elevation: 10,
                currentIndex: page,
                enableFeedback: true,
                onTap: selectedPage,
                unselectedItemColor: Colors.grey,
                type: BottomNavigationBarType.fixed,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.book_outlined),
                    label: 'Journal',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.today_outlined),
                    label: 'Tasks',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
              )
            : Text(""),
      ),
    );
  }
}

//home page
