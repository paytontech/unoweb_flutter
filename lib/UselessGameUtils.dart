// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:unoweb/classes/Card.dart';

class UselessGameUtils {
  static Color getCardColor(GameCard card) {
    switch (card.type != null && card.type == CardType.wnormal ||
            card.type == CardType.wplus4
        ? card.chosenColor!
        : card.color) {
      case CardColor.red:
        return (Colors.red);
      case CardColor.blue:
        return (Colors.blue);
      case CardColor.green:
        return (Colors.green);
      case CardColor.yellow:
        return (const Color.fromARGB(255, 195, 176, 3));
      default:
        return (Colors.black);
    }
  }

  static bool canPlayCard(GameCard card, gameData) {
    if (((card.type == CardType.wnormal ||
            card.type == CardType.wplus4 && (card.chosenColor != null)) ||
        (card.color == gameData['stack']['current'].color) ||
        card.number == gameData['stack']['current'].number ||
        (card.special && card.type == CardType.wnormal ||
            card.type == CardType.wplus4) ||
        (card.color == gameData['stack']['current'].chosenColor))) {
      return true;
    } else {
      return false;
    }
  }
}
