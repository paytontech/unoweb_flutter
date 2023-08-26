import 'package:flutter/material.dart';
import '../classes/GameCard.dart';
import '../classes/UselessGameUtils.dart';

class PlayerCard extends StatefulWidget {
  const PlayerCard(
      {super.key,
      required this.card,
      required this.playerID,
      required this.canPlay,
      required this.playCard,
      required this.wildColorChosen});

  final GameCard card;
  final String playerID;
  final bool canPlay;
  final Function()? playCard;
  final Function(WildColor)? wildColorChosen;

  @override
  State<PlayerCard> createState() => _PlayerCardState();
}

class _PlayerCardState extends State<PlayerCard> {
  // var wildcolors = ["Red", "Blue", "Green", "Yellow"];
  var wildcolors = [
    WildColor("Red", CardColor.red),
    WildColor("Blue", CardColor.blue),
    WildColor("Green", CardColor.green),
    WildColor("Yellow", CardColor.yellow)
  ];
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: ElevatedButton(
        onPressed: widget.canPlay ? widget.playCard : null,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(100, 120),
          shadowColor: widget.canPlay
              ? UselessGameUtils.getCardColor(widget.card)
              : null,
          elevation: widget.canPlay ? 22.0 : null,
        ),
        child: !widget.card.isWild
            ? Text(
                "${widget.card.humanReadableType}",
                textAlign: TextAlign.center,
                style: TextStyle(
                        color: UselessGameUtils.getCardColor(widget.card),
                        fontSize: widget.canPlay ? 30 : null),
              )
            : widget.card.chosenColor == null ? Column(
                children: wildcolors
                    .map<Widget>((ccolor) => ElevatedButton(
                          onPressed: () {
                            widget.wildColorChosen!(ccolor);
                          },
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size(80, 20)),
                          child: Text(ccolor.name,
                              style: TextStyle(
                                  color: UselessGameUtils.getCardColor(
                                      GameCard.color(ccolor.color)))),
                        ))
                    .toList()) : Text(
                "${widget.card.humanReadableType}",
                textAlign: TextAlign.center,
                style: TextStyle(
                        color: UselessGameUtils.getCardColor(widget.card),
                        fontSize: widget.canPlay ? 30 : null)
              ),
      ),
    );
  }
}
