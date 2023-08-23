import 'dart:math';

import 'package:json_annotation/json_annotation.dart';
import 'package:unoweb/UselessGameUtils.dart';
import 'package:unoweb/classes/Card.dart';

import 'Player.dart';

class Game {
  List<Player> players = [];
  Player currentPlayer = Player.empty();
  GameStack stack = GameStack();
  WinState winState = WinState();
  bool reversed = false;
  int playerCount = 0;
  List<GameCard> possibleCards = [];
  bool multiplayer = false;
  setup(List<Player> players, Player currentPlayer,
      List<GameCard> possibleCards) {
    this.players = players;
    this.possibleCards = possibleCards;
    this.currentPlayer = players[0];
    this.playerCount = players.length - 1;
    generateStack(possibleCards);
  }

  generateStack(List<GameCard> possibleCards) {
    GameCard stackCard = possibleCards[Random().nextInt(possibleCards.length)];
    if (stackCard.special) {
      possibleCards[Random().nextInt(possibleCards.length)];
      generateStack(possibleCards);
      return;
    } else {
      this.stack.current = stackCard;
    }
  }

  reset() {
    this.players = [];

    this.winState = WinState();
    this.playerCount = 1;
    this.players.add(Player(0, []));
    if (!multiplayer) {
      addBots(3);
    }
    this.currentPlayer = players[0];
  }

  addBots(int botCount) {
    for (int i = playerCount; i < botCount; i++) {
      Player bot = Player.bot(i, []);
      for (int z = 0; i < 7; i++) {
        bot.addCard(UselessGameUtils.randomCard(possibleCards));
      }
      this.players.add(bot);
    }
  }

  addPlayer(Player player) {
    this.players.add(player);
    this.playerCount = players.length - 1;
  }

  nextPlayer() {
    int currentIndex = players.indexOf(currentPlayer!);
    if (!reversed) {
      if (currentIndex >= playerCount) {
        currentPlayer = players[0];
      } else {
        currentPlayer = players[currentIndex + 1];
      }
    } else {
      if (currentIndex > 0) {
        currentPlayer = players[currentIndex - 1];
      } else {
        currentPlayer = players[playerCount];
      }
    }
  }
}

class GameStack {
  GameCard current = GameCard.empty();
  List<GameCard> prev = [];
}

class WinState {
  bool winnerChosen = false;
  Player? winner = null;
}
