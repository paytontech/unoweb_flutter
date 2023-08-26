import 'package:flutter/material.dart';
import 'package:unoweb_flutter/classes/Game.dart';
import 'package:unoweb_flutter/classes/Player.dart';
import 'package:unoweb_flutter/classes/UselessGameUtils.dart';
import 'package:unoweb_flutter/components/PlayerCardUI.dart';
import 'package:unoweb_flutter/components/PlayersStatus.dart';
import 'package:unoweb_flutter/components/StackCardUI.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  String myID = "";
  Game game = Game.singleplayer(Player(UselessGameUtils.randomCards(7)));
  Timer timer = Timer(Duration.zero, () { });
  @override
  void initState() {
    super.initState();
    myID = game.players[0].id;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {update();});
  }

  

  void update() {
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title, style: TextStyle(color: Colors.white),),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  direction: Axis.horizontal,
                  children: game
                      .getPlayerWithUUID(myID)
                      .cards
                      .map<Widget>((card) => PlayerCard(
                          card: card,
                          playerID: myID,
                          canPlay: UselessGameUtils.canPlayCard(card, game) && game.currentPlayer == game.getPlayerWithUUID(myID),
                          playCard: () {
                            /* user selected card */
                            setState(() {
                              game.playCard(card, game.getPlayerWithUUID(myID));
                            });
                          },
                          wildColorChosen: (color) {
                            /* user selected color for wild card */
                          }))
                      .toList()),
              const SizedBox(
                width: 0,
                height: 20,
              ),
              const Text(
                "Stack Card",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const Text("This is the card at the top of the stack"),
              const Text(
                "You can press the card to draw a new one",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(
                width: 0,
                height: 20,
              ),
              StackCardUI(card: game.stack.current, onPressed: () {
                setState(() {
                  game.getPlayerWithUUID(myID).drawCard(game);
                });
              },),
              PlayersStatusUI(game: game)
            ],
          ),
        ));
  }
}
