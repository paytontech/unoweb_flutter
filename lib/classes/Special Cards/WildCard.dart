// ignore_for_file: unnecessary_this

import 'package:unoweb_flutter/classes/Game.dart';
import 'package:unoweb_flutter/classes/GameCard.dart';

class WildCard extends GameCard {
  WildCard(CardType type) : super.wild(type) {
    this.type = type;
    this.special = true;
    this.chosenColor = null;
    this.isWild = true;
    this.humanReadableType = this.type!.name;
  }

  WildCard duplicate() {
    WildCard card = WildCard(this.type!);
    card.chosenColor = this.chosenColor;
    return card;
  }

  @override
  void onPlay(Game game) {
    if (this.type! == CardType.wplus4) {
      for (var i = 0; i < 4; i++) {
        print("drawing card $i");
        game.getNextPlayer().drawCard(game);
      }
      game.nextPlayer(1);
      return;
    } else {
      print("not +4");
    }
    game.nextPlayer();
  }
}
