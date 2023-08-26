import 'dart:math';

import 'package:flutter/material.dart';
import 'GameCard.dart';
import 'Game.dart';

class UselessGameUtils {
  static Color getCardColor(GameCard card) {
    switch (card.type != null && card.type == CardType.wnormal ||
            card.type == CardType.wplus4
        ? card.chosenColor
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

  static bool canPlayCard(GameCard card, Game gameData) {
    if (((card.type == CardType.wnormal ||
            card.type == CardType.wplus4 && (card.chosenColor != null)) ||
        (card.color == gameData.stack.current.color) ||
        card.number == gameData.stack.current.number ||
        (card.special && card.type == CardType.wnormal ||
            card.type == CardType.wplus4) ||
        (card.color == gameData.stack.current.chosenColor))) {
      return true;
    } else {
      return false;
    }
  }

  static List<GameCard> possibleCards() {
    List<GameCard> cards = [];
    for (var i = 0; i < 10; i++) {
      cards.add(GameCard(CardColor.red, i));
    }
    cards.add(GameCard.special(CardColor.red, CardType.plus2));
    cards.add(GameCard.special(CardColor.red, CardType.reverse));
    cards.add(GameCard.special(CardColor.red, CardType.skip));
    for (var i = 0; i < 10; i++) {
      cards.add(GameCard(CardColor.blue, i));
    }
    cards.add(GameCard.special(CardColor.blue, CardType.plus2));
    cards.add(GameCard.special(CardColor.blue, CardType.reverse));
    cards.add(GameCard.special(CardColor.blue, CardType.skip));
    for (var i = 0; i < 10; i++) {
      cards.add(GameCard(CardColor.yellow, i));
    }
    cards.add(GameCard.special(CardColor.green, CardType.plus2));
    cards.add(GameCard.special(CardColor.green, CardType.reverse));
    cards.add(GameCard.special(CardColor.green, CardType.skip));
    for (var i = 0; i < 10; i++) {
      cards.add(GameCard(CardColor.yellow, i));
    }
    cards.add(GameCard.special(CardColor.yellow, CardType.plus2));
    cards.add(GameCard.special(CardColor.yellow, CardType.reverse));
    cards.add(GameCard.special(CardColor.yellow, CardType.skip));
    cards.add(GameCard.wild(CardType.wnormal));
    cards.add(GameCard.wild(CardType.wplus4));
    return cards;
  }

  static List<GameCard> randomCards(int cardCount) {
    List<GameCard> cards = [];
    for (var i = 0; i < cardCount; i++) {
      cards.add(randomCard());
    }
    return cards;
  }

  static GameCard randomCard() {
    return UselessGameUtils.possibleCards()[
        Random().nextInt(UselessGameUtils.possibleCards().length)];
  }
}
