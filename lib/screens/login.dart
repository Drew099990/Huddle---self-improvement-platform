import "dart:async";

import "package:Huddle/screens/home.dart";
import "package:flutter/material.dart";
import "../screens/register.dart";

class Login extends StatefulWidget {
  const Login({super.key, required this.onLogin});

  final Function(bool) onLogin;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _name = TextEditingController();
  final _password = TextEditingController();
  String userCounter = "username";
  String passwordCounter = "password";

  bool not_Loading = true;
  bool password_valid = true;
  bool username_valid = true;

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
                        counter: Text(
                          "$userCounter",
                          style: TextStyle(
                            color: username_valid
                                ? Colors.black54
                                : Colors.redAccent,
                          ),
                        ),
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
                        counter: Text(
                          "$passwordCounter",
                          style: TextStyle(
                            color: password_valid
                                ? Colors.black54
                                : Colors.redAccent,
                          ),
                        ),
                      ),

                      enabled: true,
                    ),
                  ),
                  SizedBox(height: 18),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Register(onRegister: (_) {}),
                        ),
                      );
                    },
                    child: Text(
                      "create new account?",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: const Color.fromARGB(117, 24, 50, 95),
                      ),
                    ),
                  ),

                  InkWell(
                    onTap: () {
                      setState(() {
                        not_Loading = false;
                      });

                      if (_name.text.isNotEmpty && _password.text.isNotEmpty) {
                        Timer(Duration(seconds: 2), () {
                          setState(() {
                            widget.onLogin(true);
                            not_Loading = true;
                          });
                        });
                      }

                      if (_name.text.isEmpty) {
                        setState(() {
                          username_valid = false;
                          userCounter = "username is missing.";

                          Timer(Duration(seconds: 2), () {
                            setState(() {
                              not_Loading = true;
                              userCounter = "username";
                              username_valid = true;
                            });
                          });
                        });
                      }
                      if (_password.text.isEmpty) {
                        setState(() {
                          password_valid = false;
                          passwordCounter = "password is missing";
                          Timer(Duration(seconds: 2), () {
                            setState(() {
                              not_Loading = true;
                              passwordCounter = "password";
                              password_valid = true;
                            });
                          });
                        });
                      }
                    },
                    child: AnimatedContainer(
                      duration: Duration(seconds: 4),
                      decoration: BoxDecoration(
                        color: not_Loading
                            ? const Color.fromARGB(255, 4, 57, 65)
                            : const Color.fromARGB(255, 201, 203, 204),
                      ),
                      padding: EdgeInsets.all(10),
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Text(
                        not_Loading ? "Login" : "Logging...",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  not_Loading
                      ? Text(
                          "Powered by sleepy panda",
                          style: TextStyle(color: Colors.black45),
                        )
                      : CircularProgressIndicator(
                          color: const Color.fromARGB(255, 4, 57, 65),
                          strokeWidth: 2,
                          trackGap: 1,
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
