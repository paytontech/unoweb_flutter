// ignore_for_file: prefer_initializing_formals

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'Game.dart';

class MultiplayerController {
  late IO.Socket socket;
  MPStatus status = MPStatus();
  late Game game;
  MultiplayerController(String serverURL, Game game) {
    this.game = game;
    socket = IO.io(serverURL);
    socket.on("fromServer", (data) {
      print("data from server: ${data.toString()}");
    });
    socket.emit("fromClient", {"hi": "hello :)"});
    socket.onAny((event, data) {
      print("$event $data");
    });
    socket.connect();
  }
}

class MPStatus {
  bool connected = false;
  int playerCount = 0;
  List<String> playerUIDs = [];
  String myUID = "";
}
