import "package:flutter/material.dart";

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _name = TextEditingController();
  final _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              SizedBox(height: 70),
              // Image.asset("lib/assets/show.png"),
              CircleAvatar(
                backgroundColor: const Color.fromARGB(255, 4, 58, 71),
                radius: MediaQuery.of(context).size.width * 0.27,
                child: Icon(
                  Icons.face_2_outlined,
                  color: const Color.fromARGB(255, 233, 235, 236),
                  size: MediaQuery.of(context).size.width * 0.50,
                ),
              ),
              Text(
                "Login",
                style: TextStyle(
                  fontSize: 18,
                  color: const Color.fromARGB(255, 7, 17, 32),
                  letterSpacing: 6,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Container(
                width: MediaQuery.of(context).size.width * 0.80,
                height: 70,
                child: TextField(
                  autocorrect: true,
                  controller: _name,
                  decoration: InputDecoration(
                    hintText: " username",
                    counterText: "username",
                    suffixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  enabled: true,
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: MediaQuery.of(context).size.width * 0.80,
                height: 70,
                child: TextField(
                  autocorrect: true,
                  controller: _password,
                  decoration: InputDecoration(
                    hintText: "password",
                    suffixIcon: Icon(Icons.remove_red_eye_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    counterText: "password",
                  ),

                  enabled: true,
                ),
              ),
              SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 16, 32, 58),
                ),
                padding: EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width * 0.6,
                child: Text(
                  "Login",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Powered by sleepy panda",
                style: TextStyle(color: Colors.black45),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
