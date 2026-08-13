import 'dart:async';
import 'package:flutter/material.dart';
import "./screens/home.dart";
import "./screens/Journal.dart";
import "screens/reset.dart";
import "./screens/profile.dart";
import "package:Huddle/screens/login.dart";
import "package:Huddle/screens/register.dart";
import 'package:google_mobile_ads/google_mobile_ads.dart';
import "../helpers/InterstitialAdManager.dart";
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './helpers/firebase_creditials.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await MobileAds.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int page = 0;

  bool loggedIN = false;
  bool _checkingAuth = true;

  // Which auth screen to show while logged out. Owned here (not by
  // Navigator pushes inside Login/Register) so a successful sign-in or
  // registration is always visible immediately, no matter which of the
  // two screens the user was last on.
  bool _showRegister = false;

  final List<Widget> _PAGES = <Widget>[
    Home(),
    Journal(),
    Community(),
    Profile(),
  ];

  // ---- Interstitial ad on bottom-nav taps ----
  final InterstitialAdManager _interstitialAdManager = InterstitialAdManager();
  int _navTapCount = 0;
  static const int _tapsBetweenAds = 4; // show every 5th bottom-nav tap

  StreamSubscription<User?>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _interstitialAdManager.load();

    // Keep loggedIN in sync with Firebase's own auth state, so a user
    // who already signed in stays logged in across app restarts, and
    // signing out anywhere (e.g. from Profile) reflects here too.
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        loggedIN = user != null;
        _checkingAuth = false;
        if (loggedIN) _showRegister = false; // reset for next logout
      });
    });
  }

  @override
  void dispose() {
    _interstitialAdManager.dispose();
    _authSubscription?.cancel();
    super.dispose();
  }

  void _dataFromLogin(bool status) {
    // FirebaseAuth's authStateChanges listener above will also fire and
    // set loggedIN, but we still update immediately here so the UI
    // responds without waiting on the stream event.
    setState(() {
      loggedIN = status;
    });
  }

  void _goToRegister() {
    setState(() {
      _showRegister = true;
    });
  }

  void _goToLogin() {
    setState(() {
      _showRegister = false;
    });
  }

  void selectedPage(int index) {
    setState(() {
      page = index;
    });
    _maybeShowInterstitial();
  }

  void _maybeShowInterstitial() {
    _navTapCount++;
    if (_navTapCount >= _tapsBetweenAds) {
      _navTapCount = 0;
      _interstitialAdManager.showIfReady();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingAuth) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    Widget authScreen = _showRegister
        ? Register(onRegister: _dataFromLogin, onSwitchToLogin: _goToLogin)
        : Login(onLogin: _dataFromLogin, onSwitchToRegister: _goToRegister);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: loggedIN ? _PAGES[page] : authScreen,
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
