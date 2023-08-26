// ignore_for_file: unnecessary_this

import 'package:unoweb_flutter/classes/Game.dart';
import 'package:unoweb_flutter/classes/GameCard.dart';

class SkipCard extends GameCard {
  SkipCard(CardColor color) : super.special(color, CardType.skip) {
    this.color = color;
    this.type = CardType.skip;
    this.special = true;
    this.humanReadableType = this.type!.name;
  }

  @override
  void onPlay(Game game) {
    game.nextPlayer(1);
  }
  
}