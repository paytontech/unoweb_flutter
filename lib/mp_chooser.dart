// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth.dart';

//stateful widget called MPStart
class MPStart extends StatefulWidget {
  const MPStart({super.key});
  @override
  State<MPStart> createState() => MPStartHome();
}

class MPStartHome extends State<MPStart> {
  Map mpdata = {"auth": false, "username": ""};
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      print(user);
      if (user == null) {
        setState(() {
          mpdata["auth"] = false;
        });
      } else {
        setState(() {
          mpdata["auth"] = true;
          mpdata["username"] = user.displayName;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start a Multiplayer Session'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Center(
                child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.groups_outlined,
                    size: 50,
                  ),
                  Text(
                    "Introducing Online Multiplayer",
                    style: TextStyle(fontSize: 25),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "in JustOne",
                    style: TextStyle(color: Colors.grey),
                  ),
                  Divider(
                    thickness: 2,
                  ),
                  Text(
                    "Online Multiplayer allows you to play JustOne online with your friends!",
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "Please note: Online Multiplayer is in beta and should not be relied on in high risk situations. JustOne in general should not, and really cannot, be relied on in high-risk situations, but out of all features in JustOne to be relied on, this is the least.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  if (mpdata["auth"])
                    Text(
                      "With that said, you now are faced with a very challenging and important option: To host, or not to host?",
                      textAlign: TextAlign.center,
                    ),
                  if (mpdata["auth"])
                    Text(
                      "Your choice here will affect your life greatly for the next 5-10 minutes, so choose wisely.",
                      textAlign: TextAlign.center,
                    ),
                  if (mpdata["auth"])
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                            padding: EdgeInsets.all(10),
                            child: ElevatedButton(
                                onPressed: () {}, child: Text("Host"))),
                        Padding(
                            padding: EdgeInsets.all(20),
                            child: ElevatedButton(
                                onPressed: () {}, child: Text("Join")))
                      ],
                    ),
                  if (!mpdata["auth"])
                    Text(
                      "Now, normally there would be a snarky sentence about \"To host or not to host,\" but, as to your choice, you have none currently. This is for one reason, and only one reason:",
                      textAlign: TextAlign.center,
                    ),
                  if (!mpdata["auth"])
                    Text(
                      "You need to be signed in!\nAh, the classic choice: To create an account or to not create an account? I think i'm streching this joke a little too far now. Bottom line: sign in to play online",
                      textAlign: TextAlign.center,
                    ),
                  if (!mpdata["auth"])
                    ElevatedButton(
                        onPressed: () async {
                          final res = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) => AuthWelcome())));
                          print(await res);
                        },
                        child: Text("Go to Auth page")),
                  if (mpdata['auth'])
                    ElevatedButton(
                        onPressed: () {
                          FirebaseAuth.instance.signOut();
                        },
                        child: Text("Sign Out"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red))
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}
