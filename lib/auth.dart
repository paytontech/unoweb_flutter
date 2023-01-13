// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthWelcome extends StatefulWidget {
  const AuthWelcome({super.key});

  @override
  State<AuthWelcome> createState() => AuthWelcomeState();
}

class AuthWelcomeState extends State<AuthWelcome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome to JustOne",
              style: TextStyle(fontSize: 20),
            ),
            Text(
              "If you're here right now, you just tried to play the brand new, barely functioning JustOne Online Multiplayer beta, but were blocked my a strange sentence saying a bad joke.\nIf this describes your current situation, you're in the right place!\nNow, the classic questio- this joke is old now, just choose an option",
              textAlign: TextAlign.center,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(30),
                  child: ElevatedButton(
                      onPressed: () async {
                        final res = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignUpForm()))
                            .whenComplete(() => Navigator.pop(context));
                      },
                      child: Text("Create Account")),
                ),
                Padding(
                  padding: EdgeInsets.all(30),
                  child: ElevatedButton(
                      onPressed: () async {
                        final res = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginForm()))
                            .whenComplete(() => Navigator.pop(context));
                      },
                      child: Text("Log In")),
                ),
              ],
            ),
          ],
        ),
      )),
    );
  }
}

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  State<SignUpForm> createState() => SignUpFormState();
}

class SignUpFormState extends State<SignUpForm> {
  String email = "";
  String password = "";
  String confirmPass = "";
  String username = "";
  String errTxt = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Great choice!"),
          Text("Just provide the following info, NOW:"),
          Padding(
            padding: EdgeInsets.all(30),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  username = value;
                });
              },
              decoration: InputDecoration(
                  hintText: 'Username (3-12 characters)',
                  border: OutlineInputBorder()),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(30),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  email = value;
                });
              },
              decoration: InputDecoration(
                  hintText: 'Email', border: OutlineInputBorder()),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(30),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  password = value;
                });
              },
              decoration: InputDecoration(
                  hintText: 'Password', border: OutlineInputBorder()),
              obscureText: true,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(30),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  confirmPass = value;
                });
              },
              decoration: InputDecoration(
                  hintText: 'Confirm Password', border: OutlineInputBorder()),
              obscureText: true,
            ),
          ),
          Text(
            errTxt,
            style: TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          ElevatedButton(
              onPressed: () async {
                if (username.length > 12 || username.length < 3) {
                  setState(() {
                    errTxt =
                        "Your username is not valid! It must be more than three characters and less than 12 characters.";
                  });
                  return;
                }
                if (!(password.length >= 8 && password == confirmPass)) {
                  setState(() {
                    errTxt =
                        "Your password is not valid! Make sure it is at least 8 characters, and that \"Confirm Passowrd\" and \"Password\" is the same.";
                  });
                  return;
                }
                try {
                  FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                          email: email, password: password)
                      .whenComplete(() => {
                            FirebaseAuth.instance.currentUser
                                ?.updateDisplayName(username)
                                .whenComplete(() {
                              Navigator.pop(context, true);
                            }),
                          });
                } catch (err) {
                  print(err);
                  Navigator.pop(context, false);
                }
              },
              child: Text("Create Account"))
        ],
      )),
    ));
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  State<LoginForm> createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  String email = "";
  String password = "";
  String confirmPass = "";
  String username = "";
  String errTxt = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Great choice!"),
          Text("Just provide the following info, NOW:"),
          Padding(
            padding: EdgeInsets.all(30),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  email = value;
                });
              },
              decoration: InputDecoration(
                  hintText: 'Email', border: OutlineInputBorder()),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(30),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  password = value;
                });
              },
              decoration: InputDecoration(
                  hintText: 'Password', border: OutlineInputBorder()),
              obscureText: true,
            ),
          ),
          Text(
            errTxt,
            style: TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          ElevatedButton(
              onPressed: () async {
                if (!(password.length >= 8)) {
                  setState(() {
                    errTxt =
                        "Your password is not valid! Make sure it is at least 8 characters, and that \"Confirm Passowrd\" and \"Password\" is the same.";
                  });
                  return;
                }
                try {
                  FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                          email: email, password: password)
                      .whenComplete(() => {Navigator.pop(context, true)});
                } catch (err) {
                  print(err);
                  Navigator.pop(context, false);
                }
              },
              child: Text("Sign In"))
        ],
      )),
    );
  }
}
