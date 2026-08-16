import "dart:async";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";

class Register extends StatefulWidget {
  const Register({
    super.key,
    required this.onRegister,
    required this.onSwitchToLogin,
  });

  final Function(bool) onRegister;
  final VoidCallback onSwitchToLogin;

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

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _register() async {
    // Reset validation state
    setState(() {
      user_valid = true;
      email_valid = true;
      password_valid = true;
      _userCounter = "username";
      _emailCounter = "email";
      _passCounter = "password";
    });

    bool hasError = false;

    if (_userController.text.isEmpty) {
      hasError = true;
      setState(() {
        user_valid = false;
        _userCounter = "username is missing.";
      });
    }
    if (_emailController.text.isEmpty) {
      hasError = true;
      setState(() {
        email_valid = false;
        _emailCounter = "email is missing.";
      });
    }
    if (_passController.text.isEmpty) {
      hasError = true;
      setState(() {
        password_valid = false;
        _passCounter = "password is missing.";
      });
    } else if (_passController.text.length < 6) {
      hasError = true;
      setState(() {
        password_valid = false;
        _passCounter = "password must be 6+ characters.";
      });
    }

    if (hasError) {
      Timer(Duration(seconds: 3), () {
        if (!mounted) return;
        setState(() {
          loading = true;
          _userCounter = "username";
          _emailCounter = "email";
          _passCounter = "password";
          user_valid = true;
          email_valid = true;
          password_valid = true;
        });
      });
      return;
    }

    setState(() {
      loading = false;
    });

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passController.text,
      );

      // Save the chosen username as the display name
      await credential.user?.updateDisplayName(_userController.text.trim());

      if (!mounted) return;
      setState(() {
        loading = true;
      });
      widget.onRegister(true);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;
      switch (e.code) {
        case "email-already-in-use":
          message = "An account already exists for that email.";
          break;
        case "invalid-email":
          message = "That email address is invalid.";
          break;
        case "weak-password":
          message = "That password is too weak.";
          break;
        case "operation-not-allowed":
          message = "Email/password accounts are not enabled.";
          break;
        default:
          message = e.message ?? "Registration failed. Please try again.";
      }

      setState(() {
        loading = true;
        email_valid = false;
        password_valid = false;
        _emailCounter = message;
        _passCounter = message;
      });

      Timer(Duration(seconds: 3), () {
        if (!mounted) return;
        setState(() {
          _emailCounter = "email";
          _passCounter = "password";
          email_valid = true;
          password_valid = true;
        });
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = true;
        email_valid = false;
        _emailCounter = "Something went wrong. Please try again.";
      });
    }
  }

  @override
  void dispose() {
    _userController.dispose();
    _emailController.dispose();
    _passController.dispose();
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
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.80,
                    height: 70,
                    child: TextField(
                      autocorrect: true,
                      controller: _userController,
                      decoration: InputDecoration(
                        hintText: " username",
                        counter: Text(
                          _userCounter,
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

                      enabled: loading,
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.80,
                    height: 70,
                    margin: EdgeInsets.only(top: 10),
                    child: TextField(
                      autocorrect: false,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: " email",
                        counter: Text(
                          _emailCounter,
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

                      enabled: loading,
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.80,
                    height: 70,
                    child: TextField(
                      autocorrect: false,
                      obscureText: true,
                      controller: _passController,
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.remove_red_eye_outlined),
                        hintText: "password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        counter: Text(
                          _passCounter,
                          style: TextStyle(
                            color: password_valid
                                ? Colors.black54
                                : Colors.redAccent,
                          ),
                        ),
                      ),

                      enabled: loading,
                    ),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: loading ? widget.onSwitchToLogin : null,
                    child: Text(
                      "already have an account?",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: const Color.fromARGB(117, 24, 50, 95),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: loading ? _register : null,
                    child: AnimatedContainer(
                      duration: Duration(seconds: 3),
                      decoration: BoxDecoration(
                        borderRadius: loading
                            ? BorderRadius.circular(0)
                            : BorderRadius.circular(40),

                        color: loading
                            ? const Color.fromARGB(255, 4, 57, 65)
                            : const Color.fromARGB(255, 201, 203, 204),
                      ),
                      padding: EdgeInsets.all(10),
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Text(
                        loading ? "Register" : "Registering...",
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
