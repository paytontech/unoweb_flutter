// ignore_for_file: prefer_const_constructors

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      print("user changed - not showing for security resons woogogoog");
      if (user == null) {
        setState(() {
          mpdata["auth"] = false;
        });
      } else {
        setState(() {
          mpdata["auth"] = true;
          mpdata["username"] = user.displayName;
          mpdata["uid"] = user.uid;
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
                                onPressed: () {
                                  int code = 000000;
                                  code = Random().nextInt(999999) + 100000;
                                  FirebaseFirestore.instance
                                      .collection("active")
                                      .doc(code.toString())
                                      .set({}).whenComplete(() {
                                    mpdata["code"] = code;
                                    //mpdate state key:
                                    //0 = not in mp
                                    //1 = host
                                    //2 = player
                                    mpdata["state"] = 1;
                                    mpdata["mp"] = true;
                                    print(mpdata.toString());
                                    Navigator.pop(context, mpdata);
                                  });
                                },
                                child: Text("Host"))),
                        Padding(
                            padding: EdgeInsets.all(20),
                            child: ElevatedButton(
                                onPressed: () async {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              HostModal())).then((value) {
                                    if (value != null) {
                                      print("back");
                                      mpdata['code'] = value['code'];
                                      mpdata['state'] = 2;
                                      mpdata['mp'] = true;
                                      Navigator.pop(context, mpdata);
                                    }
                                  });
                                },
                                child: Text("Join")))
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

class HostModal extends StatefulWidget {
  const HostModal({super.key});

  @override
  State<HostModal> createState() => HostModalState();
}

class HostModalState extends State<HostModal> {
  int code = 000000;
  String errTxt = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(
          "Join a Session",
          style: TextStyle(fontSize: 20),
        ),
        Text(
            "So, you want to join a session. Great!\nAll you need is the game code. This is a six-digit number which the host has."),
        Padding(
          padding: EdgeInsets.all(30),
          child: TextField(
            onChanged: (value) {
              if (value.length != 6) {
                setState(() {
                  errTxt = "Code must be six digits long!";
                });
              } else {
                setState(() {
                  errTxt = "";
                });
                code = int.parse(value);
              }
            },
            onSubmitted: (value) {
              try {
                FirebaseFirestore.instance
                    .collection("active")
                    .doc(code.toString())
                    .get()
                    .then((value) {
                  if (value.exists) {
                    Map data = {};
                    data["code"] = code;
                    //mpdate state key:
                    //0 = not in mp
                    //1 = host
                    //2 = player
                    data["state"] = 2;
                    data["mp"] = true;
                    Navigator.pop(context, data);
                  } else {
                    print("doc does not exist");
                    setState(() {
                      errTxt = "Session does not exist!";
                    });
                  }
                });
              } catch (err) {
                print(err);
              }
            },
            decoration: InputDecoration(
                border: OutlineInputBorder(), hintText: "Six-Digit number"),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ),
        Text(
          errTxt,
          style: TextStyle(color: Colors.red),
        )
      ])),
    );
  }
}
