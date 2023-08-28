// ignore_for_file: unnecessary_this

import 'dart:math';

import 'package:unoweb_flutter/classes/UselessGameUtils.dart';

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

  botPlay(Game game) {}
  drawCard(Game gameData) {
    this.cards.add(UselessGameUtils.randomCard());
  }

  addCard(GameCard card) {
    cards.add(card);
  }
}
