import 'dart:io';

import 'package:flutter/material.dart';
import 'package:unoweb_flutter/components/WildSelectSheet.dart';
import '../classes/GameCard.dart';
import '../classes/UselessGameUtils.dart';

import 'package:shared_preferences/shared_preferences.dart';

class PlayerCard extends StatefulWidget {
  const PlayerCard(
      {super.key,
      required this.card,
      required this.playerID,
      required this.canPlay,
      required this.playCard,
      required this.wildColorChosen,
      required this.isTurn});

  final GameCard card;
  final String playerID;
  final bool isTurn;
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

  Future<bool> getColorblindMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getBool("colorblindmode") ?? false;
  }

  bool isColorblind = false;

  Image? cardSymbol;

  void refreshColorblindSettings() {
    getColorblindMode().then((value) {
      setState(() {
        isColorblind = value;
      });
      if (isColorblind) {
        widget.card.color.symbol.then((value) {
          setState(() {
            cardSymbol = value;
          });
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    refreshColorblindSettings();
    return Padding(
        padding: const EdgeInsets.all(4.0),
        child: Opacity(
          opacity: widget.canPlay ? 1 : 0.5,
          child: ElevatedButton(
              onPressed: widget.isTurn
                  ? widget.canPlay
                      ? !widget.card.isWild
                          ? widget.playCard
                          : widget.card.chosenColor == null
                              ? presentWildPicker
                              : widget.playCard
                      : () {}
                  : null,
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(100, 120),
                  shadowColor: widget.canPlay
                      ? UselessGameUtils.getCardColor(widget.card)
                      : null,
                  backgroundColor: UselessGameUtils.getCardColor(widget.card),
                  elevation: widget.canPlay ? 22.0 : null,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                          Radius.circular(widget.canPlay ? 15 : 5)))),
              child: Column(
                children: [
                  Text(
                    "${widget.card.humanReadableType}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 30,
                        color: widget.isTurn
                            ? Colors.white
                            : UselessGameUtils.getCardColor(widget.card)),
                  ),
                  if (isColorblind && cardSymbol != null)
                    Image(
                      image: cardSymbol!.image,
                      width: 25,
                      height: 25,
                    )
                ],
              )),
        ));
  }
}
