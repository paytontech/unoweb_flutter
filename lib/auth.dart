// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class AuthWelcome extends StatefulWidget {
  const AuthWelcome({super.key});

  @override
  State<AuthWelcome> createState() => AuthWelcomeState();
}

class AuthWelcomeState extends State<AuthWelcome> {
  int option = 0;
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
                      onPressed: () {
                        setState(() {
                          option = 1;
                        });
                      },
                      child: Text("Create Account")),
                ),
                Padding(
                  padding: EdgeInsets.all(30),
                  child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          option = 2;
                        });
                      },
                      child: Text("Log In")),
                ),
              ],
            ),
            if (option == 1)
              SizedBox(
                height: 1000,
                width: 500,
                child: SignUpForm(),
              )
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text("Create Account")],
      )),
    );
  }
}
