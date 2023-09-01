import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  String username = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                "Welcome to JustOne",
                style: TextStyle(fontSize: 30),
              ),
              Text("Enter a username to get started."),
              Padding(
                padding: EdgeInsets.all(10),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      username = value;
                    });
                  },
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: "Username"),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: ElevatedButton(
                    onPressed: () async {
                      if (username != "") {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.setString("username", username);
                        Navigator.pop(context, true);
                      }
                    },
                    child: Text("Submit")),
              )
            ],
          ),
        ),
      ),
    );
  }
}
