import "dart:async";

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import "../elements/books.dart";
import "../elements/audio_books.dart";
import "../elements/vidoes.dart";

int chosen = 0;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  bool isOnline = true;

  List<Widget> display = <Widget>[Books(), AudioBooks(), Videos()];

  String show = "Currently available books";

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _subscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _initConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    final connected =
        result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.ethernet);
    setState(() {
      isOnline = connected;
    });
  }

  void _book() {
    setState(() {
      chosen = 0;
      show = "Currently available books";
    });
  }

  void _audiobooks() {
    setState(() {
      chosen = 1;
      show = "Currently available audiobooks";
    });
  }

  void _videos() {
    setState(() {
      chosen = 2;
      show = "Currently available videos";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: _book,
                child: Container(
                  height: 70,
                  width: 70,
                  margin: EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    image: isOnline
                        ? DecorationImage(
                            image: NetworkImage(
                              "https://media.istockphoto.com/id/943322510/photo/bookstore-public-old-library-creativity-concept.jpg?s=1024x1024&w=is&k=20&c=dgRM-M_Y4nwO4ZymMz8VYmafNCtvypG_ROeA6mNh3Cs=",
                            ),
                            fit: BoxFit.cover,
                          )
                        : DecorationImage(image: NetworkImage("")),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color.fromARGB(160, 64, 80, 102),
                      width: 4,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.book_outlined,
                        color: isOnline ? Colors.white : Colors.black54,
                        size: 30,
                      ),
                      Text(
                        "books",
                        style: TextStyle(
                          fontSize: 20,
                          color: isOnline ? Colors.white : Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: _audiobooks,
                child: Container(
                  margin: EdgeInsets.only(top: 10),
                  height: 70,
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  decoration: BoxDecoration(
                    image: isOnline
                        ? DecorationImage(
                            image: NetworkImage(
                              "https://media.istockphoto.com/id/1285965933/photo/audiobooks-concept.jpg?s=1024x1024&w=is&k=20&c=5W_usVS6XBX3V1DM8Q3NKQsXvEG13Yh0znl9_dv4zsU=",
                            ),
                          )
                        : DecorationImage(image: NetworkImage("")),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color.fromARGB(160, 64, 80, 102),
                      width: 4,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.audiotrack_outlined,
                        color: isOnline ? Colors.white : Colors.black54,
                        size: 30,
                      ),
                      Text(
                        "Audiobooks",
                        style: TextStyle(
                          fontSize: 15,
                          color: isOnline ? Colors.white : Colors.black54,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: _videos,
                child: Container(
                  margin: EdgeInsets.only(top: 10),
                  height: 70,
                  width: 75,
                  padding: EdgeInsets.fromLTRB(2, 0, 2, 0),
                  decoration: BoxDecoration(
                    image: isOnline
                        ? DecorationImage(
                            image: NetworkImage(
                              "https://media.istockphoto.com/id/1490665488/photo/portrait-of-a-female-doctor-talking-to-the-camera-in-online-care.jpg?s=1024x1024&w=is&k=20&c=XjQu8IEh_UODUA2h0ZxnxGp9jMY1l7AZdORsXOQ20sg=",
                            ),
                            fit: BoxFit.cover,
                          )
                        : DecorationImage(image: NetworkImage("")),

                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color.fromARGB(160, 64, 80, 102),
                      width: 4,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.video_camera_back_outlined,
                        color: isOnline ? Colors.white : Colors.black54,
                        size: 30,
                      ),
                      Text(
                        "videos",
                        style: TextStyle(
                          fontSize: 20,
                          color: isOnline ? Colors.white : Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2),

          Divider(color: const Color.fromARGB(83, 167, 176, 206), thickness: 2),
          Column(
            children: [
              Text(
                isOnline ? show : '$show (offline)',
                style: TextStyle(
                  overflow: TextOverflow.fade,
                  fontStyle: FontStyle.italic,
                  decoration: TextDecoration.underline,
                  color: Colors.black54,
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.17,
                ),
                width: MediaQuery.of(context).size.width,
                child: isOnline
                    ? display[chosen]
                    : Column(
                        children: [
                          Icon(
                            Icons.wifi_off_outlined,
                            size: 140,
                            color: const Color.fromARGB(134, 11, 57, 100),
                          ),
                          Text(
                            " you are offline",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
