import "package:flutter/material.dart";

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _LoginState();
}

class _LoginState extends State<Register> {
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
                "Register",
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
              Container(
                width: MediaQuery.of(context).size.width * 0.80,
                height: 70,
                margin: EdgeInsets.only(top: 10),
                child: TextField(
                  autocorrect: true,

                  decoration: InputDecoration(
                    hintText: " email",
                    counterText: "email",
                    suffixIcon: Icon(Icons.email_outlined),
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
                  decoration: InputDecoration(
                    suffixIcon: Icon(Icons.remove_red_eye_outlined),
                    hintText: "password",
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
                  "Register",
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
