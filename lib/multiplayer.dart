import 'dart:math';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:flutter/material.dart';

class MultiplayerPageOne extends StatefulWidget {
  const MultiplayerPageOne({super.key});

  @override
  State<MultiplayerPageOne> createState() => _MultiplayerPageOneState();
}

class _MultiplayerPageOneState extends State<MultiplayerPageOne> {
  @override
  void initState() {
    super.initState();
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  String textCode = "";
  String username1 = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Choose an option")),
      body: SingleChildScrollView(
          child: Center(
              child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
              "Would you like to create a lobby, or join an already existing lobby?"),
          Padding(
            padding: EdgeInsets.all(100),
            child: TextFormField(
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Enter a username',
              ),
              onChanged: ((value) {
                setState(() {
                  setState(() {
                    username1 = value;
                  });
                });
              }),
            ),
          ),
          const SizedBox(
            height: 50,
            width: 0,
          ),
          ElevatedButton(
              onPressed: () {
                //create a lobby
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MultiplayerGame(
                              username: username1,
                            )));
              },
              child: Text("Create")),
          const SizedBox(
            height: 50,
            width: 0,
          ),
          const Text("Join"),
          Padding(
            padding: EdgeInsets.all(100),
            child: TextFormField(
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Enter a room code',
              ),
              onChanged: ((value) {
                setState(() {
                  setState(() {
                    textCode = value;
                  });
                });
              }),
            ),
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MultiplayerGame(
                              gameCode: textCode,
                              username: username1,
                            )));
              },
              child: const Text("Join"))
        ],
      ))),
    );
  }
}

class MultiplayerGame extends StatefulWidget {
  const MultiplayerGame({super.key, this.gameCode, required this.username});

  final String? gameCode;
  final String username;

  @override
  State<MultiplayerGame> createState() => _MultiplayerGameState();
}

class _MultiplayerGameState extends State<MultiplayerGame> {
  final db = FirebaseFirestore.instance;
  int next(int min, int max) => min + Random().nextInt(max - min);
  int code = 100000 + Random().nextInt(999999 - 100000);
  Map clientState = {
    'host': false,
    'username': '',
    'playerid': 0,
    'gotInitialData': false
  };
  Map gameData = {
    'players': [],
    'currentPlayer': 0,
    'stack': {'current': {}, 'prev': []},
    'winState': {'winnerChosen': false, 'winner': {}},
    'gameCode': 0
  };
  List<Map> cards = [];
  bool invalidAttemptError = false;

  void genCards() {
    for (var i = 0; i < 10; i++) {
      cards.add({'color': 'red', 'number': i, 'special': false});
    }
    //colored special (+4, +2, reverse)
    cards.add({'color': 'red', 'type': '+2', 'special': true});
    cards.add({'color': 'red', 'type': '+4', 'special': true});
    for (var i = 0; i < 10; i++) {
      cards.add({'color': 'blue', 'number': i, 'special': false});
    }
    cards.add({'color': 'blue', 'type': '+2', 'special': true});
    cards.add({'color': 'blue', 'type': '+4', 'special': true});
    for (var i = 0; i < 10; i++) {
      cards.add({'color': 'green', 'number': i, 'special': false});
    }
    cards.add({'color': 'green', 'type': '+2', 'special': true});
    cards.add({'color': 'green', 'type': '+4', 'special': true});
    for (var i = 0; i < 10; i++) {
      cards.add({'color': 'yellow', 'number': i, 'special': false});
    }
    cards.add({'color': 'yellow', 'type': '+2', 'special': true});
    cards.add({'color': 'yellow', 'type': '+4', 'special': true});
    //wild cards
    cards.add({
      'color': 'wild',
      'type': 'normal',
      'special': true,
      'chosenColor': ''
    });
    cards.add(
        {'color': 'wild', 'type': '+4', 'special': true, 'chosenColor': ''});
  }

  @override
  void initState() {
    super.initState();
    genCards();

    if (widget.gameCode == null) {
      print("this client is host");
      clientState['host'] = true;

      addPlayer(widget.username);
      db.collection("games").doc(code.toString()).set(<String, dynamic>{
        'players': [],
        'gameData': gameData,
        'code': code,
        'dateCreated': DateTime.now()
      }).whenComplete(() {
        print("complete");
        setState(() {
          clientState['gotInitialData'] = true;
        });
      });
    } else {
      print("This client is not a host!! woohoo!");
      code = int.parse(widget.gameCode.toString());
      addPlayer(widget.username);
      updateFirebase();
      clientState['gotInitialData'] = true;
    }
  }

  Color getCardColor(card) {
    if (!(card['color'] == 'wild')) {
      switch (card['color']) {
        case 'red':
          return (Colors.red);
        case 'blue':
          return (Colors.blue);
        case 'green':
          return (Colors.green);
        case 'yellow':
          return (Color.fromARGB(255, 153, 138, 0));
        default:
          return (Colors.black);
      }
    } else if (card['color'] == 'wild') {
      switch (card['chosenColor']) {
        case 'red':
          return (Colors.red);
        case 'blue':
          return (Colors.blue);
        case 'green':
          return (Colors.green);
        case 'yellow':
          return (Color.fromARGB(255, 153, 138, 0));
        default:
          return (Colors.black);
      }
    } else {
      return Colors.black;
    }
  }

  void playCard(card, playerID) async {
    print("play attempted: $playerID");
    if (playerID == gameData['currentPlayer']) {
      //valid
      if (card['color'] == gameData['stack']['current']['color'] ||
          card['number'] == gameData['stack']['current']['number'] ||
          (card['special'] && card['color'] == 'wild') ||
          (card['color'] == gameData['stack']['current']['chosenColor'])) {
        //valid
        if (card['special'] && card['type'] != "normal") {
          if (card['type'] == '+2') {
            print("+2 card, giving 2 cards to ${getNextPlayer()}");
            //draw 2
            for (var i = 0; i < 2; i++) {
              setState(() {
                gameData['players'][getNextPlayer()]['cards']
                    .add(cards[Random().nextInt(cards.length)]);
              });
            }
          } else if (card['type'] == "+4") {
            print("+4 card, giving 2 cards to ${getNextPlayer()}");
            for (var i = 0; i < 4; i++) {
              gameData['players'][getNextPlayer()]['cards']
                  .add(cards[Random().nextInt(cards.length)]);
            }
          }
        }
        setState(() {
          gameData['stack']['prev'].add(gameData['stack']['current']);
          gameData['stack']['current'] = card;
          gameData['players'][playerID]['cards'].remove(card);
        });
        updatePlayer();
      } else {
        if (gameData['currentPlayer'] == playerID) {
          setState(() {
            invalidAttemptError = true;
          });
          await Future.delayed(const Duration(seconds: 3));
          setState(() {
            invalidAttemptError = false;
          });
        }
      }
    } else {
      //invalid
      if (gameData['currentPlayer'] == playerID) {
        setState(() {
          invalidAttemptError = true;
        });
        await Future.delayed(const Duration(seconds: 3));
        setState(() {
          invalidAttemptError = false;
        });
      }
    }
  }

  int getNextPlayer() {
    if (gameData['currentPlayer'] >= (gameData['players'].length - 1)) {
      return 0;
    } else {
      return (gameData['currentPlayer']) + 1;
    }
  }

  void updatePlayer() {
    for (var player in gameData['players']) {
      if (player['cards'].isEmpty) {
        setState(() {
          gameData['winState']['winnerChosen'] = true;
          gameData['winState']['winner'] = player;
        });
      }
    }
    if (gameData['currentPlayer'] >= (gameData['players'].length - 1)) {
      print("max players");
      setState(() {
        gameData['currentPlayer'] = 0;
      });
    } else {
      print("next player");
      setState(() {
        gameData['currentPlayer'] += 1;
      });
    }
  }

  void updateFirebase() {
    db
        .collection("games")
        .doc(code.toString())
        .set(<String, dynamic>{'gameData': gameData}, SetOptions(merge: true));
    db.collection("games").doc(code.toString()).get().then((value) {
      setState(() {
        var data = value.data() as Map<String, dynamic>;
        gameData = data['gameData'];
      });
      print(gameData);
    });
  }

  void addPlayer(username) {
    gameData['stack']['current'] = cards[Random().nextInt(cards.length)];
    clientState['playerid'] = gameData['players'].length;
    gameData['players'].add({
      'id': gameData['players'].length,
      'cards': [],
      'username': widget.username
    });
    for (var z = 0; z < 7; z++) {
      gameData['players'][clientState['playerid']]['cards']
          .add(cards[Random().nextInt(cards.length)]);
    }
    updateFirebase();
    print(gameData['players'].length);
  }

  void drawCard(playerID) {
    if (gameData['currentPlayer'] == playerID) {
      setState(() {
        gameData['players'][playerID]['cards']
            .add(cards[Random().nextInt(cards.length)]);
      });
      updatePlayer();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget game;
    if (gameData['winState']['winnerChosen'] == true) {
      game = Scaffold(
        appBar: AppBar(title: const Text("Game Over!")),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (gameData['winState']['winner']['bot'])
              Text(
                "Bot ${gameData['winState']['winner']['id']} has won!",
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 50),
              )
            else
              Text(
                "You Win!",
                style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 50),
              ),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    gameData['winState']['winner'] = {};
                    gameData['winState']['winnerChosen'] = false;
                    gameData['currentPlayer'] = 0;
                  });
                },
                child: Text("Restart"))
          ],
        )),
      );
    } else if (clientState['gotInitialData']) {
      game = Scaffold(
        appBar: AppBar(
          title: Text("unoweb"),
        ),
        body: Center(
            child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Game Code: ${code}"),
              Text("Players: ${gameData['players'].length.toString()}"),
              if (gameData['currentPlayer'] > 0)
                Text("Current Player: ${gameData['currentPlayer']}"),
              if (gameData['currentPlayer'] == 0)
                const Text(
                  "Your Turn!",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              const Text(
                "Your cards",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const Text("Click on a card to play it"),
              if (invalidAttemptError)
                Text(
                  "Invalid Play!",
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              const SizedBox(
                width: 0,
                height: 20,
              ),
              Wrap(
                children: gameData['players'][clientState['playerid']]?['cards']
                    .map<Widget>((card) => ElevatedButton(
                          onPressed: gameData['currentPlayer'] == 0
                              ? () {
                                  print(gameData['players']
                                      [gameData['playerid']]['cards']);
                                  playCard(card, 0);
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: getCardColor(card),
                              minimumSize: Size(50, 120)),
                          child: !card['special']
                              ? Text(
                                  "${card['color']}\n${card['number'].toString()}",
                                  textAlign: TextAlign.center,
                                )
                              : !(card['chosenColor'] == '')
                                  ? Text(
                                      "${card['color']}\n${card['type']}",
                                      textAlign: TextAlign.center,
                                    )
                                  : Column(children: [
                                      Text("${card['color']} ${card['type']}"),
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            card['chosenColor'] = 'red';
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            minimumSize: Size(80, 20)),
                                        child: const Text("Red"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            card['chosenColor'] = 'blue';
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            minimumSize: Size(80, 20)),
                                        child: const Text("Blue"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            card['chosenColor'] = 'green';
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            minimumSize: Size(80, 20)),
                                        child: const Text("Green"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            card['chosenColor'] = 'yellow';
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Color.fromARGB(
                                                255, 153, 138, 0),
                                            minimumSize: Size(80, 20)),
                                        child: const Text("Yellow"),
                                      ),
                                    ]),
                        ))
                    .toList(),
              ),
              TextButton(
                  onPressed: () {
                    drawCard(0);
                  },
                  child: const Text("Draw Card")),
              const SizedBox(
                width: 0,
                height: 20,
              ),
              const Text(
                "Current Card",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const Text("This is the card at the top of the stack"),
              const SizedBox(
                width: 0,
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    backgroundColor: getCardColor(gameData['stack']['current']),
                    minimumSize: Size(40, 100),
                    alignment: Alignment.center),
                child: !gameData['stack']['current']['special']
                    ? Text(
                        "${gameData['stack']['current']['color']}\n${gameData['stack']['current']['number'].toString()}",
                        textAlign: TextAlign.center,
                      )
                    : Text(
                        "${gameData['stack']['current']['color']}\n${gameData['stack']['current']['type']}",
                        textAlign: TextAlign.center,
                      ),
              ),
              Wrap(
                children: gameData['players']
                    .map<Widget>((player) => Padding(
                          padding: const EdgeInsets.all(15),
                          child: Text(
                            "You\n${player['cards'].length} card(s) left",
                            textAlign: TextAlign.center,
                          ),
                        ))
                    .toList(),
              )
            ],
          ),
        )), // This trailing comma makes auto-formatting nicer for build methods.
      );
    } else {
      game = Text("Loading..");
    }
    return Container(child: game);
  }
}
