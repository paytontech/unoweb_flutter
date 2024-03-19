// ignore_for_file: prefer_initializing_formals, unnecessary_this

import 'package:flutter/material.dart';
import 'package:unoweb_flutter/classes/Game.dart';

class GameCard {
  CardColor color = CardColor.red;
  int? number;
  CardType? type;
  bool special = false;
  CardColor? chosenColor;
  bool isWild = false;
  String humanReadableType = "";
  //normal
  GameCard(CardColor color, int number) {
    this.color = color;
    this.number = number;
    this.special = false;
    humanReadableType = this.number.toString();
  }
  //special -- not wild
  GameCard.special(CardColor color, CardType type) {
    this.color = color;
    this.type = type;
    this.special = true;
    this.humanReadableType = this.type!.name;
  }

  GameCard duplicate() {
    return GameCard(this.color, this.number!);
  }

  GameCard.wild(CardType type) {
    this.type = type;
    this.special = true;
    this.chosenColor = null;
    this.isWild = true;
    this.humanReadableType = this.type!.name;
  }
  GameCard.color(CardColor color) {
    this.color = color;
  }
  GameCard.from(GameCard card) {
    this.color = card.color;
    this.number = card.number;
    this.type = card.type;
    this.special = card.special;
    this.chosenColor = card.chosenColor;
    if (card.special) {
      this.humanReadableType = this.type!.name;
    } else {
      this.humanReadableType = this.number.toString();
    }
  }
  GameCard.empty() {}

  void onPlay(Game game) {
    game.nextPlayer();
  }
}

class WildColor {
  String name = "";
  CardColor color = CardColor.red;
  WildColor(this.name, this.color);
}

enum CardColor { red, green, blue, yellow }

extension ColorName on CardColor {
  String get name {
    switch (this) {
      case CardColor.red:
        return "Red";
      case CardColor.blue:
        return "Blue";
      case CardColor.yellow:
        return "Yellow";
      case CardColor.green:
        return "Green";
    }
  }

  Future<Image> get symbol async {
    switch (this) {
      case CardColor.red:
        return Image.asset("assets/images/triangle.png");
      case CardColor.blue:
        return Image.asset("assets/images/square.png");
      case CardColor.green:
        return Image.asset("assets/images/circle.png");
      case CardColor.yellow:
        return Image.asset("assets/images/x.png");
    }
  }
}

enum CardType { plus2, skip, reverse, wnormal, wplus4 }

extension TypeName on CardType {
  String get name {
    switch (this) {
      case CardType.plus2:
        return "+2";
      case CardType.reverse:
        return "Reverse";
      case CardType.skip:
        return "Skip";
      case CardType.wnormal:
        return "Wild";
      case CardType.wplus4:
        return "Wild +4";
    }
  }

  IconData get icon {
    switch (this) {
      case CardType.reverse:
        return Icons.repeat_rounded;
      case CardType.skip:
        return Icons.next_plan_rounded;
      case CardType.wplus4:
        return Icons.four_k_plus_rounded;
      case CardType.plus2:
        return Icons.exposure_plus_2_rounded;
      case CardType.wnormal:
        return Icons.view_cozy_rounded;
      default:
        return Icons.note;
    }
  }
}
