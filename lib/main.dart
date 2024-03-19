import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unoweb_flutter/classes/Game.dart';
import 'package:unoweb_flutter/classes/GameCard.dart';
import 'package:unoweb_flutter/classes/Player.dart';
import 'package:unoweb_flutter/classes/UselessGameUtils.dart';
import 'package:unoweb_flutter/components/PlayerCardUI.dart';
import 'package:unoweb_flutter/components/PlayersStatus.dart';
import 'package:unoweb_flutter/components/StackCardUI.dart';
import 'dart:async';
import 'classes/MultiplayerController.dart';

import './Pages/GameOver.dart';
import 'package:unoweb_flutter/pages/GameView.dart';
import 'package:unoweb_flutter/pages/Onboarding.dart';

import 'classes/HorizontalScrollBehavior.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JustOne',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 209, 214, 232)),
        useMaterial3: true,
      ),
      scrollBehavior: HorizontalScrollBehavior(),
      home: const MyHomePage(title: 'JustOne'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Game game = Game.singleplayer(Player(UselessGameUtils.randomCards(7)));

  Timer timer = Timer(Duration.zero, () {});
  @override
  void initState() {
    super.initState();
    checkOnboarding().then((value) {
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        update();
      });
      setUsername();
    });
  }

  Future<void> checkOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasOnboarded = prefs.getBool("obcomplete") ?? false;
    if (!hasOnboarded) {
      Navigator.push(
              context, MaterialPageRoute(builder: (context) => Onboarding()))
          .then((value) async {
        await prefs.setBool("obcomplete", value);
        setUsername();
      });
    }
  }

  void setUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String un = prefs.getString("username") ?? "Unknown";
    game.players[0].username = un;
  }

  void update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (game.winState.winnerChosen) {
      return GameOver(
        game: game,
        myID: game.players[0].id,
      );
    } else if (!game.checkWinState()) {
      return GameView(
        game: game,
      );
    } else {
      return Scaffold();
    }
  }
}
