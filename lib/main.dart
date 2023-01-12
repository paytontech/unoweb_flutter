// ignore_for_file: avoid_print

import 'dart:io' show Platform;
import 'dart:math';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'mp_chooser.dart';

void main() async {
  runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JustOne',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      themeMode: ThemeMode.system,
      home: const MyHomePage(title: 'JustOne'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  Map gameData = {
    'players': [],
    'currentPlayer': 0,
    'stack': {'current': {}, 'prev': []},
    'winState': {'winnerChosen': false, 'winner': {}},
    'reversed': false,
    'playerCount': 0
  };
  bool multiplayer = false;
  List<Map> cards = [];
  bool invalidAttemptError = false;
  Color bg = Colors.white;
  late AnimationController _controller;
  late Animation<Color?> _color;
  ColorTween fadeToRed = ColorTween(begin: Colors.white, end: Colors.red);
  ColorTween fadeToWhite = ColorTween(begin: Colors.red, end: Colors.white);

  void genCards() {
    for (var i = 0; i < 10; i++) {
      cards.add({'color': 'red', 'number': i, 'special': false});
    }
    //colored special (+4, +2, reverse)
    cards.add({'color': 'red', 'type': '+2', 'special': true});
    cards.add({'color': 'red', 'type': 'reverse', 'special': true});
    for (var i = 0; i < 10; i++) {
      cards.add({'color': 'blue', 'number': i, 'special': false});
    }
    cards.add({'color': 'blue', 'type': '+2', 'special': true});
    cards.add({'color': 'blue', 'type': 'reverse', 'special': true});
    for (var i = 0; i < 10; i++) {
      cards.add({'color': 'green', 'number': i, 'special': false});
    }
    cards.add({'color': 'green', 'type': '+2', 'special': true});
    cards.add({'color': 'green', 'type': 'reverse', 'special': true});
    for (var i = 0; i < 10; i++) {
      cards.add({'color': 'yellow', 'number': i, 'special': false});
    }
    cards.add({'color': 'yellow', 'type': '+2', 'special': true});
    cards.add({'color': 'yellow', 'type': 'reverse', 'special': true});
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

  Map mpdata = {'playerID': 0, "finishedLoading": true};
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    init();
    genCards();
    dealCards(4);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _color = ColorTween(
            begin: Colors.white, end: const Color.fromARGB(255, 85, 255, 161))
        .animate(_controller);
  }

  Future<void> init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        print("paused");
        if (mpdata['state'] == 1) {
          FirebaseFirestore.instance
              .collection("active")
              .doc(mpdata['code'].toString())
              .delete();
        } else if (mpdata['state'] == 2) {
          FirebaseFirestore.instance
              .collection("active")
              .doc(mpdata['code'].toString())
              .delete();
        } else {
          print("not in mp session");
        }
        return;
      case AppLifecycleState.resumed:
        print("paused");
        return;
      default:
        return;
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
          return (const Color.fromARGB(255, 195, 176, 3));
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
          return (const Color.fromARGB(255, 195, 176, 3));
        default:
          return (Colors.black);
      }
    } else {
      return Colors.black;
    }
  }

  void botPlay() async {
    print("bot attempting play..");
    if (gameData['currentPlayer'] > mpdata['playerID']) {
      Map bot = gameData['players'][gameData['currentPlayer']];
      List<Map> possibleCards = [];
      for (var card in bot['cards']) {
        if (card['color'] == gameData['stack']['current']['color'] ||
            card['number'] == gameData['stack']['current']['number'] ||
            (card['special'] && card['color'] == 'wild') ||
            (card['color'] == gameData['stack']['current']['chosenColor'])) {
          possibleCards.add(card);
        }
      }

      if (possibleCards.isEmpty) {
        await Future.delayed(const Duration(seconds: 3));
        print('bot has no cards');
        drawCard(bot['id']);
        botPlay();
      } else {
        //cards available

        Map chosenCard = possibleCards[Random().nextInt(possibleCards.length)];
        Map checkedCard = new Map.from(chosenCard);
        bot['cards'].remove(chosenCard);
        bot['cards'].add(checkedCard);
        if (chosenCard['color'] == 'wild') {
          int red = 0;
          int blue = 0;
          int green = 0;
          int yellow = 0;
          for (var card in bot['cards']) {
            switch (card['color']) {
              case 'red':
                red += 1;
                break;
              case 'blue':
                blue += 1;
                break;
              case 'green':
                green += 1;
                break;
              case 'yellow':
                yellow += 1;
                break;
            }
            int highest = [red, blue, green, yellow].reduce(max);
            if (red == highest) checkedCard['chosenColor'] = 'red';
            if (blue == highest) checkedCard['chosenColor'] = 'blue';
            if (yellow == highest) checkedCard['chosenColor'] = 'yellow';
            if (green == highest) checkedCard['chosenColor'] = 'green';
          }
        }
        await Future.delayed(const Duration(seconds: 3));
        playCard(checkedCard, bot['id']);
      }
    } else {
      print("bot cannot play!");
    }
  }

  void playCard(card, playerID) async {
    print("play attempted: $playerID");
    if (playerID == gameData['currentPlayer']) {
      //valid
      if (canPlayCard(card)) {
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
          } else if (card['type'] == 'reverse') {
            if (gameData['reversed']) {
              setState(() {
                gameData['reversed'] = false;
              });
            } else {
              setState(() {
                gameData['reversed'] = true;
              });
            }
          }
        }
        setState(() {
          gameData['stack']['prev'].add(gameData['stack']['current']);
          gameData['stack']['current'] = card;
          gameData['players'][playerID]['cards'].remove(card);
        });
        print(
            "current player ($playerID) card mount: ${gameData['players'][playerID]['cards'].length}");
        updatePlayer();
        if (multiplayer) {
          FirebaseFirestore.instance
              .collection("active")
              .doc(mpdata['code'].toString())
              .update({'gameData': gameData});
        }
        if (!multiplayer) {
          botPlay();
        }
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
    if (!gameData['reversed']) {
      if (gameData['currentPlayer'] >= (gameData['players'].length - 1)) {
        return 0;
      } else {
        return (gameData['currentPlayer']) + 1;
      }
    } else {
      if (gameData['currentPlayer'] > 0) {
        return gameData['currentPlayer'] - 1;
      } else {
        return (gameData['players'].length) - 1;
      }
    }
  }

  void updatePlayer() async {
    for (var player in gameData['players']) {
      if (player['cards'].isEmpty) {
        setState(() {
          gameData['winState']['winnerChosen'] = true;
          gameData['winState']['winner'] = player;
        });
      }
    }

    if (!gameData['reversed']) {
      if (gameData['currentPlayer'] >= (gameData['players'].length - 1)) {
        print("max players");

        setState(() {
          gameData['currentPlayer'] = 0;
        });
        try {
          if (!(Platform.isMacOS || Platform.isWindows)) {
            if (await Vibration.hasVibrator() ?? false) {
              Vibration.vibrate(duration: 250);
            }
          }
        } catch (err) {}
        //flash bg red
        _color = ColorTween(
                begin: Colors.white,
                end: getCardColor(gameData['stack']['current']))
            .animate(_controller);
        _controller.forward();
        await Future.delayed(const Duration(milliseconds: 250));
        _controller.reverse();
      } else {
        print("next player");
        setState(() {
          gameData['currentPlayer'] += 1;
        });
      }
    } else {
      if (gameData['currentPlayer'] > 0) {
        print("max players");

        setState(() {
          gameData['currentPlayer'] = gameData['currentPlayer'] - 1;
        });
      } else {
        setState(() {
          gameData['currentPlayer'] = gameData['players'].length - 1;
        });
      }
      if (gameData['currentPlayer'] == mpdata['playerID']) {
        try {
          if (!(Platform.isMacOS || Platform.isWindows)) {
            if (await Vibration.hasVibrator() ?? false) {
              Vibration.vibrate(duration: 250);
            }
          }
        } catch (err) {}
        //flash bg red
        _color = ColorTween(
                begin: Colors.white,
                end: getCardColor(gameData['stack']['current']))
            .animate(_controller);
        _controller.forward();
        await Future.delayed(const Duration(milliseconds: 250));
        _controller.reverse();
      }
    }
  }

  void mpGetStack() {
    Map stackCard = cards[Random().nextInt(cards.length)];
    if (stackCard['special']) {
      return;
    } else {
      gameData['stack']['current'] = stackCard;
    }
  }

  void mpDealCard(String? username, String? uid) {
    gameData['players'].add({
      'id': gameData['players'].length,
      'cards': [],
      'bot': false,
      'uid': uid,
      'username': username
    });
    for (var z = 0; z < 7; z++) {
      gameData['players'][gameData['playerCount'] - 1]['cards']
          .add(cards[Random().nextInt(cards.length)]);
    }
  }

  void dealCards(playerCount) async {
    if (!multiplayer) {
      Map stackCard = cards[Random().nextInt(cards.length)];
      if (stackCard['special']) {
        cards[Random().nextInt(cards.length)];
        dealCards(playerCount);
        return;
      } else {
        gameData['stack']['current'] = stackCard;
      }

      for (var i = 0; i < playerCount; i++) {
        if (i == 0) {
          gameData['players'].add({'id': i, 'cards': [], 'bot': false});
        } else {
          gameData['players'].add({'id': i, 'cards': [], 'bot': true});
        }
        for (var z = 0; z < 7; z++) {
          gameData['players'][i]['cards']
              .add(cards[Random().nextInt(cards.length)]);
        }
        print(gameData['players'].length);
      }
    }
  }

  void drawCard(playerID) {
    if (gameData['currentPlayer'] == playerID) {
      setState(() {
        gameData['players'][playerID]['cards']
            .add(cards[Random().nextInt(cards.length)]);
      });
      updatePlayer();
      if (multiplayer) {
        FirebaseFirestore.instance
            .collection("active")
            .doc(mpdata['code'].toString())
            .update({'gameData': gameData});
      } else {
        botPlay();
      }
    }
  }

  bool canPlayCard(card) {
    if (card['color'] == gameData['stack']['current']['color'] ||
        card['number'] == gameData['stack']['current']['number'] ||
        (card['special'] && card['color'] == 'wild') ||
        (card['color'] == gameData['stack']['current']['chosenColor'])) {
      return true;
    } else {
      return false;
    }
  }

  void resetGame(int? playerCount) {
    setState(() {
      gameData['players'] = [];
      gameData['winState']['winner'] = {};
      if (!multiplayer) {
        dealCards(playerCount);
      }
      gameData['winState']['winnerChosen'] = false;
      gameData['currentPlayer'] = 0;
    });
  }

  void setupMultiplayer() {
    setState(() {
      mpdata['finishedLoading'] = false;
    });
    int code = mpdata['code'];
    String host = mpdata['uid'];
    int state = mpdata['state'];
    setState(() {
      multiplayer = true;
    });
    if (state == 1) {
      //user is host
      resetGame(0);

      gameData['playerCount'] = 1;
      mpdata['playerID'] = 0;
      mpDealCard(mpdata['username'], mpdata['uid']);
      FirebaseFirestore.instance.collection("active").doc(code.toString()).set({
        "gameData": gameData,
        "host": host,
        "players": [host]
      }).then((value) {
        setState(() {
          mpdata['finishedLoading'] = true;
        });
      });
    } else {
      List currentPlayers = [];
      Map<String, dynamic>? data = {};
      FirebaseFirestore.instance
          .collection("active")
          .doc(code.toString())
          .get()
          .then((snap) {
        if (snap.exists) {
          data = snap.data();
          List current = data?['players'];
          current.add(mpdata['uid']);
          print(current);
          setState(() {
            final updatedData = data?['gameData'];
            updatedData['playerCount'] += 1;
            mpdata['playerID'] = updatedData['playerCount'] - 1;
            gameData = updatedData;
            mpDealCard(mpdata['username'], mpdata['uid']);
          });
          FirebaseFirestore.instance
              .collection("active")
              .doc(code.toString())
              .update({"players": current, "gameData": gameData}).then((value) {
            setState(() {
              mpdata['finishedLoading'] = true;
            });
          });
        } else {
          print("oops :( snapshot no exist :((");
        }
      });
    }

    FirebaseFirestore.instance
        .collection("active")
        .doc(code.toString())
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          gameData = snapshot.data()?['gameData'];
        });
      } else {
        resetGame(4);
      }
    });
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
            if (!multiplayer)
              if (gameData['winState']['winner']['bot'])
                Text(
                  "Bot ${gameData['winState']['winner']['id']} has won!",
                  style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 50),
                )
              else
                const Text(
                  "You Win!",
                  style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 50),
                ),
            if (multiplayer)
              if (gameData['winState']['winner']['id'] != mpdata['playerID'])
                Text(
                  "${gameData['winState']['winner']['username']} has won!",
                  style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 50),
                ),
            if (gameData['winState']['winner']['id'] == mpdata['playerID'])
              const Text(
                "You Win!",
                style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 50),
              ),
            ElevatedButton(
                onPressed: () {
                  if (!multiplayer) {
                    resetGame(4);
                  } else {}
                },
                child: const Text("Restart"))
          ],
        )),
      );
    } else if (mpdata['finishedLoading']) {
      game = AnimatedBuilder(
        animation: _color,
        builder: (BuildContext _, Widget? __) {
          return Container(
            decoration:
                BoxDecoration(color: _color.value, shape: BoxShape.rectangle),
            child: Scaffold(
              backgroundColor: _color.value,
              appBar: AppBar(
                title: Text(widget.title),
              ),
              body: Center(
                  child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (multiplayer)
                      ElevatedButton(
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection("active")
                              .doc(mpdata['code'].toString())
                              .delete();
                          setState(() {
                            mpdata['finishedLoading'] = false;
                          });
                          resetGame(4);
                        },
                        child: Text("Leave"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                      ),
                    if (!multiplayer)
                      TextButton(
                          onPressed: () async {
                            final res = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MPStart()));
                            mpdata = await res;
                            print(mpdata);
                            if (mpdata['mp']) {
                              setupMultiplayer();
                            } else {
                              print("error - mp not setup");
                            }
                          },
                          child: const Text(
                              "[Beta] Try the new online multiplayer mode!")),
                    if (multiplayer) Text("Code: ${mpdata['code']}"),
                    if (gameData['reversed'])
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.repeat,
                            color: Colors.grey,
                          ),
                          Text(
                            "Reversed",
                            style: TextStyle(color: Colors.grey),
                          )
                        ],
                      ),
                    if (gameData['currentPlayer'] != mpdata['playerID'])
                      Text("Current Player: ${gameData['currentPlayer']}"),
                    if (gameData['currentPlayer'] == mpdata['playerID'])
                      const Text(
                        "Your Turn!",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                    const Text(
                      "Your cards",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    const Text("Click on a card to play it"),
                    if (invalidAttemptError)
                      const Text(
                        "Invalid Play!",
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    const SizedBox(
                      width: 0,
                      height: 20,
                    ),
                    Wrap(
                      children: gameData['players'][mpdata['playerID']]['cards']
                          .map<Widget>((card) => Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: ElevatedButton(
                                  onPressed: (gameData['currentPlayer'] ==
                                          mpdata['playerID'])
                                      ? () {
                                          print(gameData['players']
                                              [mpdata['playerID']]['cards']);
                                          playCard(card, mpdata['playerID']);
                                        }
                                      : null,
                                  style: canPlayCard(card)
                                      ? ElevatedButton.styleFrom(
                                          backgroundColor: getCardColor(card),
                                          minimumSize: const Size(50, 120),
                                          shadowColor: getCardColor(card),
                                          elevation: 20.0,
                                        )
                                      : ElevatedButton.styleFrom(
                                          backgroundColor: getCardColor(card)
                                              .withOpacity(0.3),
                                          minimumSize: const Size(50, 120)),
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
                                              Text(
                                                  "${card['color']} ${card['type']}"),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Map newCard =
                                                      new Map.from(card);
                                                  setState(() {
                                                    newCard['chosenColor'] =
                                                        'red';
                                                    gameData['players'][mpdata[
                                                                'playerID']]
                                                            ['cards']
                                                        .remove(card);
                                                    gameData['players'][mpdata[
                                                                'playerID']]
                                                            ['cards']
                                                        .add(newCard);
                                                  });
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                    minimumSize:
                                                        const Size(80, 20)),
                                                child: const Text("Red"),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Map newCard =
                                                      new Map.from(card);
                                                  setState(() {
                                                    newCard['chosenColor'] =
                                                        'blue';
                                                    gameData['players'][mpdata[
                                                                'playerID']]
                                                            ['cards']
                                                        .remove(card);
                                                    gameData['players'][mpdata[
                                                                'playerID']]
                                                            ['cards']
                                                        .add(newCard);
                                                  });
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.blue,
                                                    minimumSize:
                                                        const Size(80, 20)),
                                                child: const Text("Blue"),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Map newCard =
                                                      new Map.from(card);
                                                  setState(() {
                                                    newCard['chosenColor'] =
                                                        'green';
                                                    gameData['players'][mpdata[
                                                                'playerID']]
                                                            ['cards']
                                                        .remove(card);
                                                    gameData['players'][mpdata[
                                                                'playerID']]
                                                            ['cards']
                                                        .add(newCard);
                                                  });
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.green,
                                                    minimumSize:
                                                        const Size(80, 20)),
                                                child: const Text("Green"),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Map newCard =
                                                      new Map.from(card);
                                                  setState(() {
                                                    newCard['chosenColor'] =
                                                        'yellow';
                                                    gameData['players'][mpdata[
                                                                'playerID']]
                                                            ['cards']
                                                        .remove(card);
                                                    gameData['players'][mpdata[
                                                                'playerID']]
                                                            ['cards']
                                                        .add(newCard);
                                                  });
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color.fromARGB(
                                                            255, 153, 138, 0),
                                                    minimumSize:
                                                        const Size(80, 20)),
                                                child: const Text("Yellow"),
                                              ),
                                            ]),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(
                      width: 0,
                      height: 20,
                    ),
                    const Text(
                      "Current Card",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    const Text("This is the card at the top of the stack"),
                    const Text(
                      "You can press the card to draw a new one",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(
                      width: 0,
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        drawCard(mpdata['playerID']);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              getCardColor(gameData['stack']['current']),
                          minimumSize: const Size(40, 100),
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
                                child: (!multiplayer)
                                    ? player['bot']
                                        ? Text(
                                            "Bot ${player['id']}\n${player['cards'].length} card(s) left",
                                            textAlign: TextAlign.center)
                                        : Text(
                                            "You\n${player['cards'].length} card(s) left",
                                            textAlign: TextAlign.center,
                                          )
                                    : !(player['id'] == mpdata['playerID'])
                                        ? Text(
                                            "${player['username']}\n${player['cards'].length} card(s) left",
                                            textAlign: TextAlign.center)
                                        : Text(
                                            "You (${player['username']})\n${player['cards'].length} card(s) left",
                                            textAlign: TextAlign.center,
                                          ),
                              ))
                          .toList(),
                    ),
                    const Text("v1.0.2")
                  ],
                ),
              )),
            ),
          );
        },
      );
    } else {
      game = Scaffold(
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.groups_outlined,
              size: 50,
            ),
            Text(
              "Loading Multiplayer...",
              style: TextStyle(fontSize: 25),
              textAlign: TextAlign.center,
            ),
          ],
        )),
      );
    }
    return Container(child: game);
  }
}
