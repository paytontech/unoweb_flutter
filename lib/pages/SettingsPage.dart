// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  void setColorblindMode(bool v) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("colorblindmode", v);
  }

  Future<bool> getColorblindMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("colorblindmode") ?? false;
  }

  bool colorblindMode = false;

  @override
  void initState() {
    super.initState();
    getColorblindMode().then((value) {
      setState(() {
        colorblindMode = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Colorblind Mode",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      "Makes cards use shape values instead of color values.",
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.start,
                    )
                  ],
                ),
                Switch(
                    value: colorblindMode,
                    onChanged: (b) async {
                      setColorblindMode(b);
                      getColorblindMode().then((value) {
                        setState(() {
                          colorblindMode = value;
                        });
                      });
                    })
              ],
            )
          ],
        ),
      ),
    );
  }
}
