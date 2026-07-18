import 'package:flutter/material.dart';

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
        title: Center(
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
        // Removed excessive margin that was causing layout issues
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 24.0),
              child: Text(
                "Choose your mini games",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            games(
              image:
                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTk2Zv2kmYXZOEjMaMavdqO9R8hpnI_SqtXj6WpsMnsqw&s=10",
              name: "Tic Tac Toe",
            ),

            games(
              image:
                  "https://play-lh.googleusercontent.com/YAdlxXdSFvbPyxQE25oRVMRXcc_6_OCVugoH2JKO4_1bFFwrBGKWOkwrRn5gzIPmDqKD29Qk0_V1HsTsEjhSpA",
              name: "Doggy Jumper",
            ),
            const SizedBox(height: 16),

            games(
              image:
                  "https://www.alaskanmaker.fr/img/cms/R%C3%A8gles%20jeu%20de%20dames%20anglaises/JD%203.jpg",
              name: "Checkers",
            ),

            const SizedBox(height: 16),
            games(
              image: "https://cdn-icons-png.flaticon.com/512/4363/4363846.png",
              name: "Chess",
            ),
          ],
        ),
      ),
    );
  }
}

Widget games({String? image, required String name}) {
  return GestureDetector(
    onTap: () {
      // TODO: Navigate to the respective game screen
      // Example: Navigator.push(context, MaterialPageRoute(builder: (_) => TicTacToeScreen()));
    },
    child: Container(
      decoration: BoxDecoration(
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    ),
  );
}
