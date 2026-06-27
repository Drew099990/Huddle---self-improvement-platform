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
  List<Widget> display = <Widget>[Books(), AudioBooks(), Videos()];

  String show = "currently available books";

  void _BOOK() {
    setState(() {
      chosen = 0;
      print(show + "$chosen");
      show = " currently available books";
    });
  }

  void _AUDIOBOOKS() {
    setState(() {
      chosen = 1;
      show = " currently available audiobooks";
      print(show + "$chosen");
    });
  }

  void _VIDEOS() {
    setState(() {
      chosen = 2;
      show = "currently available videos";

      print(show + "$chosen");
    });
  }

  @override
  Widget build(BuildContext context) {
    dynamic screen = MediaQuery.of(context).size;
    double Width = screen.width;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              onTap: _BOOK,
              child: Container(
                height: 70,
                width: 70,
                margin: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      "https://media.istockphoto.com/id/943322510/photo/bookstore-public-old-library-creativity-concept.jpg?s=1024x1024&w=is&k=20&c=dgRM-M_Y4nwO4ZymMz8VYmafNCtvypG_ROeA6mNh3Cs=",
                    ),
                    fit: BoxFit.cover,
                  ),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color.fromARGB(160, 64, 80, 102),
                    width: 4,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.book_outlined, color: Colors.white, size: 30),
                    Text(
                      "books",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: _AUDIOBOOKS,
              child: Container(
                margin: EdgeInsets.only(top: 10),
                height: 70,
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      "https://media.istockphoto.com/id/1285965933/photo/audiobooks-concept.jpg?s=1024x1024&w=is&k=20&c=5W_usVS6XBX3V1DM8Q3NKQsXvEG13Yh0znl9_dv4zsU=",
                    ),
                  ),
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
                      color: Colors.white,
                      size: 30,
                    ),
                    Text(
                      "Audiobooks",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: _VIDEOS,
              child: Container(
                margin: EdgeInsets.only(top: 10),
                height: 70,
                width: 75,
                padding: EdgeInsets.fromLTRB(2, 0, 2, 0),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      "https://media.istockphoto.com/id/1490665488/photo/portrait-of-a-female-doctor-talking-to-the-camera-in-online-care.jpg?s=1024x1024&w=is&k=20&c=XjQu8IEh_UODUA2h0ZxnxGp9jMY1l7AZdORsXOQ20sg=",
                    ),
                    fit: BoxFit.cover,
                  ),
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
                      color: Colors.white,
                      size: 30,
                    ),
                    Text(
                      "videos",
                      style: TextStyle(
                        fontSize: 20,
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
        SizedBox(height: 2),

        Divider(color: const Color.fromARGB(83, 167, 176, 206), thickness: 2),
        Column(
          children: [
            Text(
              show,
              style: TextStyle(
                overflow: TextOverflow.fade,
                fontStyle: FontStyle.italic,
                decoration: TextDecoration.underline,
                color: Colors.black54,
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,

              child: display[chosen],
            ),
          ],
        ),
      ],
    );
  }
}

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  void startListening() {
    _subscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      final bool isConnected =
          results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi) ||
          results.contains(ConnectivityResult.ethernet);

      if (isConnected) {
        print("✅ User is ONLINE");
        // Trigger sync, resume operations, etc.
      } else {
        print("❌ User is OFFLINE");
        // Show snackbar, switch to offline mode
      }
    });
  }

  void dispose() {
    _subscription.cancel();
  }
}
