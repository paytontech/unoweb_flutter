import 'package:flutter/material.dart';
import 'package:unoweb_flutter/components/WildSelectSheet.dart';
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

  void presentWildPicker() {
    showModalBottomSheet(
      isDismissible: true,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.3,
          width: MediaQuery.of(context).size.height * 0.7,
          child: WildSelectSheet(
            wildColorChosen: widget.wildColorChosen,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ElevatedButton(
          onPressed: widget.canPlay
              ? !widget.card.isWild
                  ? widget.playCard
                  : widget.card.chosenColor == null
                      ? presentWildPicker
                      : widget.playCard
              : null,
          style: ElevatedButton.styleFrom(
              minimumSize: const Size(100, 120),
              shadowColor: widget.canPlay
                  ? UselessGameUtils.getCardColor(widget.card)
                  : null,
              elevation: widget.canPlay ? 22.0 : null,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                      Radius.circular(widget.canPlay ? 15 : 5)))),
          child: Text(
            "${widget.card.humanReadableType}",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: UselessGameUtils.getCardColor(widget.card),
                fontSize: widget.canPlay ? 30 : null),
          )),
    );
  }
}