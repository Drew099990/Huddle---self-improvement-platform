import "package:flutter/material.dart";
import "../screens/login.dart";
import "../screens/profile.dart";

class Register extends StatefulWidget {
  const Register({super.key, required this.onRegister});

  final Function(bool) onRegister;
  //call back
  @override
  State<Register> createState() => _LoginState();
}

class _LoginState extends State<Register> {
  bool loading = true;
  final _userController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  String _userCounter = "username";
  String _emailCounter = "email";
  String _passCounter = "password";

  bool user_valid = true;
  bool email_valid = true;
  bool password_valid = true;

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
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  // Image.asset("lib/assets/show.png"),
                  CircleAvatar(
                    backgroundColor: const Color.fromARGB(255, 4, 58, 71),
                    radius: MediaQuery.of(context).size.width * 0.27,
                    child: Container(
                      child: Icon(
                        Icons.face_2_outlined,
                        color: const Color.fromARGB(255, 233, 235, 236),
                        size: MediaQuery.of(context).size.width * 0.50,
                      ),
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
                      controller: _userController,
                      decoration: InputDecoration(
                        hintText: " username",
                        counter: Text(
                          "$_userCounter",
                          style: TextStyle(
                            color: user_valid
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
                  Container(
                    width: MediaQuery.of(context).size.width * 0.80,
                    height: 70,
                    margin: EdgeInsets.only(top: 10),
                    child: TextField(
                      autocorrect: true,
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: " email",
                        counter: Text(
                          "$_emailCounter",
                          style: TextStyle(
                            color: email_valid
                                ? Colors.black54
                                : Colors.redAccent,
                          ),
                        ),
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
                      controller: _passController,
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.remove_red_eye_outlined),
                        hintText: "password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        counter: Text(
                          "$_passCounter",
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
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Login(onLogin: (_) {}),
                        ),
                      );
                    },
                    child: Text(
                      "already have an account?",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: const Color.fromARGB(117, 24, 50, 95),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        loading = false;
                      });

                      if (_userController.text.isEmpty) {
                        setState(() {
                          user_valid = false;
                          _userCounter = "username is missing.";
                        });
                      }
                      if (_emailController.text.isEmpty) {
                        setState(() {
                          email_valid = false;
                          _emailCounter = "email is missing.";
                        });
                      }
                      if (_passController.text.isEmpty) {
                        setState(() {
                          password_valid = false;
                          _passCounter = "password is missing.";
                        });
                      }
                    },
                    child: AnimatedContainer(
                      duration: Duration(seconds: 3),
                      decoration: BoxDecoration(
                        color: loading
                            ? const Color.fromARGB(255, 4, 57, 65)
                            : const Color.fromARGB(157, 4, 57, 65),
                      ),
                      padding: EdgeInsets.all(10),
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Text(
                        loading ? "Register" : "Logging...",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  loading
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
