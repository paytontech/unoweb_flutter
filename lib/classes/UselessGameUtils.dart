import 'dart:math';

import 'package:flutter/material.dart';
import 'package:unoweb_flutter/classes/Special%20Cards/DrawTwo.dart';
import 'package:unoweb_flutter/classes/Special%20Cards/ReverseCard.dart';
import 'package:unoweb_flutter/classes/Special%20Cards/SkipCard.dart';
import 'package:unoweb_flutter/classes/Special%20Cards/WirdCard.dart';
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
    cards.add(DrawTwoCard(CardColor.red));
    cards.add(ReverseCard(CardColor.red));
    cards.add(SkipCard(CardColor.red));
    for (var i = 0; i < 10; i++) {
      cards.add(GameCard(CardColor.blue, i));
    }
    cards.add(DrawTwoCard(CardColor.blue));
    cards.add(ReverseCard(CardColor.blue));
    cards.add(SkipCard(CardColor.blue));
    for (var i = 0; i < 10; i++) {
      cards.add(GameCard(CardColor.yellow, i));
    }
    cards.add(DrawTwoCard(CardColor.green));
    cards.add(ReverseCard(CardColor.green));
    cards.add(SkipCard(CardColor.green));
    for (var i = 0; i < 10; i++) {
      cards.add(GameCard(CardColor.yellow, i));
    }
    cards.add(DrawTwoCard(CardColor.yellow));
    cards.add(ReverseCard(CardColor.yellow));
    cards.add(SkipCard(CardColor.yellow));
    cards.add(WildCard(CardType.wnormal));
    cards.add(WildCard(CardType.wplus4));
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
