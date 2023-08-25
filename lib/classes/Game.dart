// ignore_for_file: unnecessary_this

import 'dart:math';

import 'package:unoweb_flutter/classes/Bot.dart';

import 'UselessGameUtils.dart';
import 'GameCard.dart';

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
  bool started = false;
  // setup(List<Player> players, Player currentPlayer,
  //     List<GameCard> possibleCards) {
  //   this.players = players;
  //   this.possibleCards = possibleCards;
  //   this.currentPlayer = players[0];
  //   this.playerCount = players.length - 1;
  //   generateStack(possibleCards);
  // }
  Game.singleplayer(Player player) {
    this.players.add(player);
    this.addBots(3);
    this.playerCount = players.length - 1;
    this.currentPlayer = player;
    generateStack();
    this.started = true;
  }

  generateStack() {
    GameCard stackCard = UselessGameUtils.possibleCards()[
        Random().nextInt(UselessGameUtils.possibleCards().length)];
    if (stackCard.special) {
      generateStack();
      return;
    } else {
      this.stack.current = stackCard;
    }
  }

  void playCard(GameCard card, Player player) {
    print(indexOfPlayer(player));
    if (currentPlayer.id.toLowerCase() == player.id.toLowerCase() &&
        UselessGameUtils.canPlayCard(card, this)) {
      stack.prev.add(stack.current);
      stack.current = card;
      this.players[indexOfPlayer(player)].cards.remove(card);
      print(indexOfPlayer(player));
      nextPlayer();
    } else {}
  }

  Player getPlayerWithUUID(String uuid) {
    return this.players.firstWhere((player) => player.id == uuid);
  }

  int indexOfPlayer(Player player) {
    return players.indexOf(player);
  }

  reset() {
    this.players = [];

    this.winState = WinState();
    this.playerCount = 1;
    this.players.add(Player(UselessGameUtils.randomCards(7)));
    if (!multiplayer) {
      addBots(3);
    }
    this.currentPlayer = players[0];
  }

  addBots(int botCount) {
    for (int i = playerCount; i < botCount; i++) {
      Bot bot = Bot.bot(UselessGameUtils.randomCards(7));
      this.players.add(bot);
    }
  }

  addPlayer(Player player) {
    this.players.add(player);
    this.playerCount = players.length - 1;
  }

  nextPlayer() {
    int currentIndex = players.indexOf(currentPlayer);
    if (!reversed) {
      print("not reversed");
      if (currentIndex >= playerCount) {
        print(
            "currentIndex IS >= playerCount (${currentIndex}, ${playerCount})");
        currentPlayer = players[0];
      } else {
        print(
            "currentIndex IS NOT >= playerCount (${currentIndex}, ${playerCount})");
        currentPlayer = players[currentIndex + 1];
      }
    } else {
      if (currentIndex > 0) {
        currentPlayer = players[currentIndex - 1];
      } else {
        currentPlayer = players[playerCount];
      }
    }
    print(
        "botPlay for bot ${this.currentPlayer.id} (${this.indexOfPlayer(currentPlayer)})");
    this.currentPlayer.botPlay(this);
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
