import 'package:flutter/material.dart';
import 'package:unoweb_flutter/classes/Game.dart';
import 'package:unoweb_flutter/classes/GameCard.dart';
import 'package:unoweb_flutter/classes/Player.dart';
import 'package:unoweb_flutter/classes/UselessGameUtils.dart';
import 'package:unoweb_flutter/components/PlayerCardUI.dart';
import 'package:unoweb_flutter/components/PlayersStatus.dart';
import 'package:unoweb_flutter/components/StackCardUI.dart';
import 'dart:async';

import 'package:unoweb_flutter/pages/GameOver.dart';
import 'package:unoweb_flutter/pages/GameView.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow),
        useMaterial3: true,
      ),
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
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      update();
    });
  }

  void update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (game.winState.winnerChosen) {
      return GameOver();
    } else if (!game.checkWinState()) {
      return GameView(
        game: game,
      );
    } else {
      return Scaffold();
    }
  }
}
