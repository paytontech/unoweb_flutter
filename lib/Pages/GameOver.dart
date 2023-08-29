import 'package:flutter/material.dart';
import 'package:unoweb_flutter/classes/Game.dart';

class GameOver extends StatefulWidget {
  const GameOver({super.key, required this.game, required this.myID});
  final Game game;
  final String myID;
  @override
  State<GameOver> createState() => _GameOverState();
}

class _GameOverState extends State<GameOver> {
  Widget playerText() {
    if (widget.game.winState.winner!.id == widget.myID) {
      return Text(
        "You win!",
        style: TextStyle(color: Colors.green, fontSize: 30),
      );
    } else {
      return Column(
        children: [
          Text("You lose!", style: TextStyle(color: Colors.red, fontSize: 30)),
          Text(
            "(${widget.game.winState.winner!.username ?? "unknown"} won)",
            style: TextStyle(color: Colors.grey),
          )
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Game Over"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [playerText()],
      ),
    );
  }
}
