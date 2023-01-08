// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

//stateful widget called MPStart
class MPStart extends StatefulWidget {
  const MPStart({super.key});
  @override
  State<MPStart> createState() => MPStartHome();
}

class MPStartHome extends State<MPStart> {
  @override
  Widget build(BuildContext ctx) {
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
                  Text(
                    "With that said, you now are faced with a very challenging and important option: To host, or not to host?",
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "Your choice here will affect your life greatly for the next 5-10 minutes, so choose wisely.",
                    textAlign: TextAlign.center,
                  ),
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
                  )
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}
