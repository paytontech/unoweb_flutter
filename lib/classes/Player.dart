// ignore_for_file: unnecessary_this

import 'dart:math';

import 'package:unoweb/classes/Game.dart';

import 'Card.dart';

class Player {
  int id = 0;
  List<GameCard> cards = [];
  bool bot = false;
  String? username;
  String? uid;
  Player(this.id, this.cards) {
    this.bot = false;
  }
  Player.bot(this.id, this.cards) {
    this.bot = true;
  }
  Player.multiplayer(this.id, this.cards, this.username, this.uid) {
    this.bot = false;
  }
  drawCard(List<GameCard> possibleCards, Game gameData) {
    this.cards.add(possibleCards[Random().nextInt(possibleCards.length)]);
    gameData.nextPlayer();
  }
}
