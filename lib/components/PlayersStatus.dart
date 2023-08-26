import 'package:flutter/material.dart';
import 'package:unoweb_flutter/classes/Game.dart';

class PlayersStatusUI extends StatefulWidget {
  const PlayersStatusUI({
    super.key,
    required this.game
  });

  final Game game;
  @override
  State<PlayersStatusUI> createState() => _PlayersStatusUIState();
}

class _PlayersStatusUIState extends State<PlayersStatusUI> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
                      alignment: WrapAlignment.center,
                      children: widget.game.players
                          .map<Widget>((player) => Padding(
                                padding: const EdgeInsets.all(15),
                                child: Text(
                                            "${player.bot ? "Bot ${widget.game.indexOfPlayer(player)}" : "You"}\n${player.cards.length} card(s) left",
                                            textAlign: TextAlign.center, style: TextStyle(fontWeight: widget.game.currentPlayer == player ? FontWeight.bold : FontWeight.normal),)
                              ))
                          .toList(),
                    );

  }
}
