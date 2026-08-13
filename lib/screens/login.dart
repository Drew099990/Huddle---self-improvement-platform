import "dart:async";
import "package:firebase_auth/firebase_auth.dart";
import "../helpers/Bannner.dart";
import "package:flutter/material.dart";

class Login extends StatefulWidget {
  const Login({
    super.key,
    required this.onLogin,
    required this.onSwitchToRegister,
  });

  final Function(bool) onLogin;
  final VoidCallback onSwitchToRegister;

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

  double rad = 0;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _login() async {
    // Reset validation state
    setState(() {
      username_valid = true;
      password_valid = true;
      userCounter = "username";
      passwordCounter = "password";
    });

    if (_name.text.isEmpty) {
      setState(() {
        username_valid = false;
        userCounter = "username is missing.";
      });
    }
    if (_password.text.isEmpty) {
      setState(() {
        password_valid = false;
        passwordCounter = "password is missing";
      });
    }

    if (_name.text.isEmpty || _password.text.isEmpty) {
      // Reset the messages after a short delay, same as before
      Timer(Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() {
          userCounter = "username";
          passwordCounter = "password";
          username_valid = true;
          password_valid = true;
        });
      });
      return;
    }

    setState(() {
      not_Loading = false;
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: _name.text.trim(),
        password: _password.text,
      );

      if (!mounted) return;
      setState(() {
        not_Loading = true;
      });
      widget.onLogin(true);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;
      switch (e.code) {
        case "user-not-found":
          message = "No account found for that username.";
          break;
        case "wrong-password":
          message = "Incorrect password.";
          break;
        case "invalid-email":
          message = "That email address is invalid.";
          break;
        case "invalid-credential":
          message = "Username or password is incorrect.";
          break;
        case "user-disabled":
          message = "This account has been disabled.";
          break;
        case "too-many-requests":
          message = "Too many attempts. Try again later.";
          break;
        default:
          message = e.message ?? "Login failed. Please try again.";
      }

      setState(() {
        not_Loading = true;
        username_valid = false;
        password_valid = false;
        userCounter = message;
        passwordCounter = message;
      });

      Timer(Duration(seconds: 3), () {
        if (!mounted) return;
        setState(() {
          userCounter = "username";
          passwordCounter = "password";
          username_valid = true;
          password_valid = true;
        });
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        not_Loading = true;
        username_valid = false;
        userCounter = "Something went wrong. Please try again.";
      });
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _password.dispose();
    super.dispose();
  }

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
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.80,
                    height: 70,
                    child: TextField(
                      autocorrect: true,
                      controller: _name,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: " email",
                        counter: Text(
                          userCounter,
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

                      enabled: not_Loading,
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.80,
                    height: 70,
                    child: TextField(
                      autocorrect: false,
                      obscureText: true,
                      controller: _password,
                      decoration: InputDecoration(
                        hintText: "password",
                        suffixIcon: Icon(Icons.remove_red_eye_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        counter: Text(
                          passwordCounter,
                          style: TextStyle(
                            color: password_valid
                                ? Colors.black54
                                : Colors.redAccent,
                          ),
                        ),
                      ),

                      enabled: not_Loading,
                    ),
                  ),
                  SizedBox(height: 18),
                  TextButton(
                    onPressed: not_Loading ? widget.onSwitchToRegister : null,
                    child: Text(
                      "create new account?",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: const Color.fromARGB(117, 24, 50, 95),
                      ),
                    ),
                  ),

                  InkWell(
                    onTap: not_Loading ? _login : null,
                    child: AnimatedContainer(
                      duration: Duration(seconds: 4),
                      decoration: BoxDecoration(
                        borderRadius: not_Loading
                            ? BorderRadius.circular(rad)
                            : BorderRadius.circular(40),
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
                  SizedBox(height: 4),
                  BannerAdWidget(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
