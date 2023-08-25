import 'dart:math';

import 'Game.dart';

import 'GameCard.dart';

import 'package:uuid/uuid.dart';

class Player {
  String id = const Uuid().v1();
  List<GameCard> cards = [];
  bool bot = false;
  String? username;
  String? uid;
  Player(this.cards) {
    this.bot = false;
  }
  Player.bot(this.cards) {
    this.bot = true;
  }
  Player.multiplayer(this.username, this.uid) {
    this.bot = false;
  }
  Player.empty() {}

  drawCard(List<GameCard> possibleCards, Game gameData) {
    this.cards.add(possibleCards[Random().nextInt(possibleCards.length)]);
    gameData.nextPlayer();
  }

  addCard(GameCard card) {
    cards.add(card);
  }
}
