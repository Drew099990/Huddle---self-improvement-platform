import 'package:Huddle/screens/Journal.dart';
import 'package:flutter/material.dart';
import "../subpages/favorites.dart";
import "../games/TicTacToe.dart";
import "../games/checkers.dart";
import "../games/chess.dart";
import "../games/dino.dart";

class MiniGames extends StatelessWidget {
  const MiniGames({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 15,
        toolbarHeight: 70,
        flexibleSpace: Image.asset("lib/assets/appbar.jpg", fit: BoxFit.cover),
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
                  "HUDDLE",
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
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color.fromARGB(221, 158, 184, 199),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.favorite_border_outlined,
                  color: const Color.fromARGB(221, 178, 195, 204),
                ),
              ),
            ),
          ],
        ),
        // Removed excessive margin that was causing layout issues
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(66, 26, 78, 112),
                    width: 2,
                  ),
                ),
                child: const Text(
                  '"In this game, everyone needs a break to refuel, recharge, and jump back in full throttle." — Helen Edwards',
                  style: TextStyle(
                    color: Color.fromARGB(158, 40, 94, 139),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
            games(
              image:
                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTk2Zv2kmYXZOEjMaMavdqO9R8hpnI_SqtXj6WpsMnsqw&s=10",
              name: "Tic Tac Toe",
              ontap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TicTacToeApp()),
                );
              },
            ),

            games(
              image:
                  "https://play-lh.googleusercontent.com/YAdlxXdSFvbPyxQE25oRVMRXcc_6_OCVugoH2JKO4_1bFFwrBGKWOkwrRn5gzIPmDqKD29Qk0_V1HsTsEjhSpA",
              name: "Chicken Ninja",
              ontap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DinoJumpApp()),
                );
              },
            ),
            const SizedBox(height: 16),

            games(
              image:
                  "https://www.alaskanmaker.fr/img/cms/R%C3%A8gles%20jeu%20de%20dames%20anglaises/JD%203.jpg",
              name: "Checkers",
              ontap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CheckersApp()),
                );
              },
            ),

            const SizedBox(height: 16),
            games(
              image: "https://cdn-icons-png.flaticon.com/512/4363/4363846.png",
              name: "Chess",
              ontap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChessApp()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

Widget games({String? image, required String name, GestureTapCallback? ontap}) {
  return GestureDetector(
    onTap: () {
      // TODO: Navigate to the respective game screen
      // Example: Navigator.push(context, MaterialPageRoute(builder: (_) => TicTacToeScreen()));
    },
    child: InkWell(
      onTap: ontap,
      child: Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: const Color.fromARGB(66, 26, 78, 112),
          ),
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                image ?? '',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 60),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Divider(height: 2, color: Colors.black54),
            SizedBox(height: 12),
          ],
        ),
      ),
    ),
  );
}
