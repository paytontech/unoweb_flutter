// ignore_for_file: unnecessary_this

import 'package:flutter/material.dart';
import 'package:unoweb_flutter/classes/Game.dart';
import 'package:unoweb_flutter/classes/GameCard.dart';

class ReverseCard extends GameCard {
  ReverseCard(CardColor color) : super.special(color, CardType.reverse) {
    this.color = color;
    this.type = CardType.reverse;
    this.special = true;
    this.humanReadableType = this.type!.name;
  }

  @override
  void onPlay(Game game) {
    game.reversed = !game.reversed;
  }
  
}