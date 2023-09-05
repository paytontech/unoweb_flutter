// ignore_for_file: prefer_initializing_formals
import 'package:unoweb_flutter/classes/Player.dart';

import 'Game.dart';

class MultiplayerController {
  MPStatus status = MPStatus();
  late Game game;
  MultiplayerController(Game game, Player me) {
    this.game = game;
  }
}

class MPStatus {
  bool connected = false;
  int playerCount = 0;
  List<String> playerUIDs = [];
  String myUID = "";
}
