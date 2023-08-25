import 'dart:math';

import 'package:unoweb_flutter/classes/Game.dart';
import 'package:unoweb_flutter/classes/UselessGameUtils.dart';

import 'Player.dart';
import 'GameCard.dart';

class Bot extends Player {
  Bot.bot(super.cards) : super.bot();
  @override
  botPlay(Game game) async {
    print("bot attempting play..");
    if (game.currentPlayer == this) {
      print("bot can play");
      List<GameCard> possibleCards = [];
      for (var card in cards) {
        if (UselessGameUtils.canPlayCard(card, game)) {
          possibleCards.add(card);
        }
      }
      print("got possible cards");
      if (possibleCards.isEmpty) {
        await Future.delayed(const Duration(seconds: 3));
        print('bot has no cards');
        drawCard(game);
      } else {
        //cards available
        print("bot has available cards");
        GameCard chosenCard =
            possibleCards[Random().nextInt(possibleCards.length)];
        print("selected card: ${chosenCard.humanReadableType}");
        GameCard checkedCard = GameCard.from(chosenCard);
        cards.remove(chosenCard);
        cards.add(checkedCard);
        if (chosenCard.isWild) {
          print("chosen card is wild :(");
          int red = 0;
          int blue = 0;
          int green = 0;
          int yellow = 0;
          for (var card in cards) {
            switch (card.color) {
              case CardColor.red:
                red += 1;
                break;
              case CardColor.blue:
                blue += 1;
                break;
              case CardColor.green:
                green += 1;
                break;
              case CardColor.yellow:
                yellow += 1;
                break;
            }
            int highest = [red, blue, green, yellow].reduce(max);
            if (red == highest) checkedCard.chosenColor = CardColor.red;
            if (blue == highest) checkedCard.chosenColor = CardColor.blue;
            if (yellow == highest) checkedCard.chosenColor = CardColor.yellow;
            if (green == highest) checkedCard.chosenColor = CardColor.green;
            print("highest: ${checkedCard.chosenColor!.name}");
          }
        }
        await Future.delayed(const Duration(seconds: 3));
        print("playing card");
        game.playCard(checkedCard, this);
      }
    } else {
      print("bot cannot play!");
    }
  }
}
