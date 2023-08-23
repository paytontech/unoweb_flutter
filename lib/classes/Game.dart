import 'dart:math';

import 'package:unoweb/classes/Card.dart';

import 'Player.dart';

class Game {
  List<Player> players = [];
  Player? currentPlayer;
  GameStack stack = GameStack();
  WinState winState = WinState();
  bool reversed = false;
  int playerCount = 0;
  Game(List<Player> players, Player currentPlayer,
      List<GameCard> possibleCards) {
    this.players = players;
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
  GameCard? current;
  List<GameCard> prev = [];
}

class WinState {
  bool winnerChosen = false;
  Player? winner = null;
}
