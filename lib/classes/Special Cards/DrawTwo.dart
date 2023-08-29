// ignore_for_file: unnecessary_this

import 'package:unoweb_flutter/classes/Game.dart';
import 'package:unoweb_flutter/classes/GameCard.dart';

class DrawTwoCard extends GameCard {
  DrawTwoCard(CardColor color) : super.special(color, CardType.plus2) {
    this.color = color;
    this.type = CardType.plus2;
    this.special = true;
    this.humanReadableType = this.type!.name;
  }

  DrawTwoCard duplicate() {
    return DrawTwoCard(this.color);
  }

  @override
  void onPlay(Game game) {
    for (var i = 0; i < 2; i++) {
      print("card $i");
      print(game.indexOfPlayer(game.getNextPlayer()));
      game.getNextPlayer().drawCard(game);
    }
    game.nextPlayer(1);
  }
}
