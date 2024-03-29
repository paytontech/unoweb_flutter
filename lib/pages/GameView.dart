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

import 'package:unoweb_flutter/pages/SettingsPage.dart';

class GameView extends StatefulWidget {
  const GameView({super.key, required this.game});
  final Game game;
  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  String myID = "";
  @override
  void initState() {
    super.initState();
    myID = widget.game.players[0].id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(
            "JustOne",
            style: TextStyle(
              color: Colors.white,
            ),
            textAlign: TextAlign.left,
          ),
          foregroundColor: Colors.white,
          leading: IconButton(
              onPressed: () {
                Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SettingsPage()))
                    .then((value) async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  setState(() {
                    widget.game.getPlayerWithUUID(myID).username =
                        prefs.getString("username") ?? "Unknown";
                  });
                });
              },
              icon: Icon(
                Icons.settings,
                color: Colors.white,
              )),
          actions: [
            IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.group,
                  color: Colors.white,
                ))
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (widget.game.reversed)
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.repeat,
                        color: Colors.grey,
                      ),
                      Text(
                        "Reversed",
                        style: TextStyle(color: Colors.grey),
                      )
                    ],
                  ),
                const Text(
                  "Your cards",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                const Text("Click on a card to play it"),
                Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    direction: Axis.horizontal,
                    children: widget.game
                        .getPlayerWithUUID(myID)
                        .cards
                        .map<Widget>((card) => PlayerCard(
                            card: card,
                            playerID: myID,
                            canPlay: UselessGameUtils.canPlayCard(
                                    card, widget.game) &&
                                widget.game.currentPlayer ==
                                    widget.game.getPlayerWithUUID(myID),
                            isTurn: widget.game.currentPlayer.id == myID,
                            playCard: () {
                              /* user selected card */
                              setState(() {
                                widget.game.playCard(
                                    card, widget.game.getPlayerWithUUID(myID));
                              });
                            },
                            wildColorChosen: (color) {
                              /* user selected color for wild card */
                              setState(() {
                                card.chosenColor = color.color;
                              });
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
                StackCardUI(
                  card: widget.game.stack.current,
                  onPressed: () {
                    setState(() {
                      widget.game.getPlayerWithUUID(myID).drawCard(widget.game);
                      widget.game.nextPlayer();
                    });
                  },
                ),
                PlayersStatusUI(game: widget.game),
              ],
            ),
          ),
        ));
  }
}
