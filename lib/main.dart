// ignore_for_file: avoid_print, prefer_conditional_assignment

import 'dart:io' show Platform;
import 'dart:math';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unoweb/UselessGameUtils.dart';
import 'package:vibration/vibration.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'mp_chooser.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'classes/Card.dart';
import 'classes/Game.dart';
import 'classes/Player.dart';
import 'package:class_to_map/class_to_map.dart';

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
          colorSchemeSeed: Colors.yellow,
          fontFamily: 'Satoshi',
          useMaterial3: true),
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
  // Map gameData = {
  //   'players': [],
  //   'currentPlayer': 0,
  //   'stack': {'current': {}, 'prev': []},
  //   'winState': {'winnerChosen': false, 'winner': {}},
  //   'reversed': false,
  //   'playerCount': 0
  // };
  Game gameData = Game();
  List<GameCard> cards = [];
  bool invalidAttemptError = false;
  String errTxt = "";
  Color bg = Colors.white;
  late AnimationController _controller;
  late Animation<Color?> _color;
  ColorTween fadeToRed = ColorTween(begin: Colors.white, end: Colors.red);
  ColorTween fadeToWhite = ColorTween(begin: Colors.red, end: Colors.white);

  void genCards() {
    for (var i = 0; i < 10; i++) {
      cards.add(GameCard(CardColor.red, i));
    }
    cards.add(GameCard.special(CardColor.red, CardType.plus2));
    cards.add(GameCard.special(CardColor.red, CardType.reverse));
    cards.add(GameCard.special(CardColor.red, CardType.skip));
    for (var i = 0; i < 10; i++) {
      cards.add(GameCard(CardColor.blue, i));
    }
    cards.add(GameCard.special(CardColor.blue, CardType.plus2));
    cards.add(GameCard.special(CardColor.blue, CardType.reverse));
    cards.add(GameCard.special(CardColor.blue, CardType.skip));
    for (var i = 0; i < 10; i++) {
      cards.add(GameCard(CardColor.yellow, i));
    }
    cards.add(GameCard.special(CardColor.green, CardType.plus2));
    cards.add(GameCard.special(CardColor.green, CardType.reverse));
    cards.add(GameCard.special(CardColor.green, CardType.skip));
    for (var i = 0; i < 10; i++) {
      cards.add(GameCard(CardColor.yellow, i));
    }
    cards.add(GameCard.special(CardColor.yellow, CardType.plus2));
    cards.add(GameCard.special(CardColor.yellow, CardType.reverse));
    cards.add(GameCard.special(CardColor.yellow, CardType.skip));
    cards.add(GameCard.wild(CardType.wnormal));
    cards.add(GameCard.wild(CardType.wplus4));
  }

  var window = WidgetsBinding.instance.window;
  Map mpdata = {'playerID': 0, "finishedLoading": true};
  bool isDarkMode = false;
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    window.onPlatformBrightnessChanged = () {
      isDarkMode = window.platformBrightness == Brightness.light ? false : true;
    };
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

  late FirebaseAnalytics analytics;
  Future<void> init() async {
    await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform)
        .whenComplete(() {
      analytics = FirebaseAnalytics.instance;
    });
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
        return;
      default:
        return;
    }
  }

  void botPlay() async {
    print("bot attempting play..");
    if (gameData.currentPlayer!.id > mpdata['playerID']) {
      Player bot = gameData.currentPlayer!;
      List<GameCard> possibleCards = [];
      for (var card in bot.cards) {
        if (UselessGameUtils.canPlayCard(card, gameData)) {
          possibleCards.add(card);
        }
      }

      if (possibleCards.isEmpty) {
        await Future.delayed(const Duration(seconds: 3));
        print('bot has no cards');
        drawCard(bot);
        botPlay();
      } else {
        //cards available

        GameCard chosenCard =
            possibleCards[Random().nextInt(possibleCards.length)];
        GameCard checkedCard = GameCard.from(chosenCard);
        bot.cards.remove(chosenCard);
        bot.cards.add(checkedCard);
        if (chosenCard.type == CardType.wnormal ||
            chosenCard.type == CardType.wplus4) {
          int red = 0;
          int blue = 0;
          int green = 0;
          int yellow = 0;
          for (var card in bot.cards) {
            switch (card.color) {
              case CardColor.red:
                red += 1;
                break;
              case CardColor.blue:
                blue += 1;
                break;
              case CardColor.green:
                green += 1;
                break;
              case CardColor.yellow:
                yellow += 1;
                break;
            }
            int highest = [red, blue, green, yellow].reduce(max);
            if (red == highest) checkedCard.chosenColor = CardColor.red;
            if (blue == highest) checkedCard.chosenColor = CardColor.blue;
            if (yellow == highest) checkedCard.chosenColor = CardColor.yellow;
            if (green == highest) checkedCard.chosenColor = CardColor.green;
          }
        }
        await Future.delayed(const Duration(seconds: 3));
        playCard(checkedCard, bot.id);
      }
    } else {
      print("bot cannot play!");
    }
  }

  void playCard(GameCard card, playerID) async {
    print("play attempted: $playerID");
    if (playerID == gameData.currentPlayer!.id) {
      //valid
      if (UselessGameUtils.canPlayCard(card, gameData)) {
        //valid
        if (card.special) {
          if (card.type == CardType.plus2) {
            print("+2 card, giving 2 cards to ${getNextPlayer()}");
            //draw 2
            for (var i = 0; i < 2; i++) {
              setState(() {
                gameData.players[getNextPlayer()].cards
                    .add(UselessGameUtils.randomCard(cards));
              });
            }
          } else if (card.type == CardType.wplus4) {
            print("+4 card, giving 2 cards to ${getNextPlayer()}");
            for (var i = 0; i < 4; i++) {
              gameData.players[getNextPlayer()].cards
                  .add(UselessGameUtils.randomCard(cards));
            }
          } else if (card.type == CardType.reverse) {
            if (gameData.reversed) {
              setState(() {
                gameData.reversed = false;
              });
            } else {
              setState(() {
                gameData.reversed = true;
              });
            }
          }
        }
        setState(() {
          invalidAttemptError = true;
          errTxt = "Please choose a color first!";
        });
        Future.delayed(Duration(seconds: 3));
        setState(() {
          errTxt = "";
        });
        setState(() {
          gameData.stack.prev.add(gameData.stack.current!);
          gameData.stack.current = card;
          gameData.players[playerID].cards.remove(card);
        });
        if (playerID == mpdata['playerID']) {
          await analytics.logEvent(
              name: "play_card_attempt",
              parameters: {'card': card.toString(), 'successful': "true"});
        }
        print(
            "current player ($playerID) card mount: ${gameData.players[playerID].cards.length}");
        if (card.type == CardType.skip) {
          updatePlayer(1);
        } else {
          updatePlayer();
        }
        if (!gameData.multiplayer) {
          botPlay();
        }

        if (gameData.multiplayer) {
          FirebaseFirestore.instance
              .collection("active")
              .doc(mpdata['code'].toString())
              .update({'gameData': gameData.toMap()});
        }
      } else {
        if (gameData.currentPlayer!.id == playerID) {
          setState(() {
            invalidAttemptError = true;
            errTxt = "Inavlid Play!";
          });
          await Future.delayed(const Duration(seconds: 3));
          setState(() {
            invalidAttemptError = false;
            errTxt = "";
          });
        }
      }
    } else {
      //invalid
      if (gameData.currentPlayer! == mpdata['playerID']) {
        await analytics.logEvent(
            name: "play_card_attempt",
            parameters: {'card': card.toString(), 'successful': "false"});
      }
      if (gameData.currentPlayer! == playerID) {
        setState(() {
          invalidAttemptError = true;
          errTxt = "It's not your turn!";
        });
        await Future.delayed(const Duration(seconds: 3));
        setState(() {
          invalidAttemptError = false;
          errTxt = "";
        });
      }
    }
  }

  //TODO - get rid of this & integrate it into game
  int getNextPlayer() {
    if (!gameData.reversed) {
      if (gameData.currentPlayer!.id >= (gameData.players.length - 1)) {
        return 0;
      } else {
        return (gameData.currentPlayer!.id) + 1;
      }
    } else {
      if (gameData.currentPlayer!.id > 0) {
        return gameData.currentPlayer!.id - 1;
      } else {
        return (gameData.players.length) - 1;
      }
    }
  }

  //TODO - remove this & integrate it into game
  void updatePlayer([int offset = 0]) async {
    for (var player in gameData.players) {
      if (player.cards.isEmpty) {
        setState(() {
          gameData.winState.winnerChosen = true;
          gameData.winState.winner = player;
        });
      }
    }
    if (gameData.reversed) {
      print("reversed..");
      if (gameData.currentPlayer!.id == 0 && offset != 0) {
        //if player is 0, game is reversed, and offset is not zero
        print(
            "offset not zero, player 0. going to player ${(gameData.players.length - 1) - offset}");
        setState(() {
          gameData.currentPlayer =
              gameData.players[(gameData.players.length - 1) - offset];
        });
      } else if (offset == 0) {
        print(
            "game reversed. offset not set. going to player ${getNextPlayer()}");
        setState(() {
          gameData.nextPlayer();
        });
      }
    } else {
      if (getNextPlayer() == (gameData.players.length - 1) && offset != 0) {
        //if current player is the last player & offset is 0
        print(
            "game not reversed. player ${gameData.players.length - 1}(last player). going to ${0 + offset}");
        setState(() {
          gameData.currentPlayer = gameData.players[0 + offset];
        });
      } else if (offset != 0) {
        print(
            "game not reversed. player ${gameData.players.length - 1}. offset 0");
        setState(() {
          gameData.currentPlayer = gameData.players[getNextPlayer() + offset];
        });
      } else if (offset == 0) {
        setState(() {
          gameData.currentPlayer = gameData.players[getNextPlayer()];
        });
      }
    }
    if (gameData.currentPlayer!.id == mpdata['playerID']) {
      _color = ColorTween(
              begin: Colors.white,
              end: UselessGameUtils.getCardColor(gameData.stack.current!))
          .animate(_controller);
      _controller.forward();
      await Future.delayed(const Duration(milliseconds: 250));
      _controller.reverse();
      try {
        if (!(Platform.isMacOS || Platform.isWindows)) {
          if (await Vibration.hasVibrator() ?? false) {
            Vibration.vibrate(duration: 250);
          }
        }
      } catch (err) {}
      //flash bg red
    }
  }

  void mpGetStack() {
    GameCard stackCard = cards[Random().nextInt(cards.length)];
    if (stackCard.special) {
      return;
    } else {
      gameData.stack.current = stackCard;
    }
  }

  void mpDealCard(String? username, String? uid) {
    gameData.addPlayer(
        Player.multiplayer(gameData.players.length, [], username, uid));
    for (var z = 0; z < 7; z++) {
      gameData.players[gameData.playerCount - 1]
          .addCard(UselessGameUtils.randomCard(cards));
    }
  }

  void dealCards(playerCount) async {
    if (!gameData.multiplayer) {
      GameCard stackCard = cards[Random().nextInt(cards.length)];
      if (stackCard.special) {
        dealCards(playerCount);
        return;
      } else {
        gameData.stack.current = stackCard;
      }

      for (var i = 0; i < playerCount; i++) {
        if (i == 0) {
          gameData.addPlayer(Player(i, []));
        } else {
          gameData.addPlayer(Player.bot(i, []));
        }
        for (var z = 0; z < 7; z++) {
          gameData.players[i].addCard(UselessGameUtils.randomCard(cards));
        }
      }
    }
  }

  void drawCard(Player player) {
    if (gameData.currentPlayer == player) {
      setState(() {
        player.addCard(UselessGameUtils.randomCard(cards));
      });
      updatePlayer();
      if (gameData.multiplayer) {
        FirebaseFirestore.instance
            .collection("active")
            .doc(mpdata['code'].toString())
            .update({'gameData': gameData.toMap()});
      } else {
        botPlay();
      }
    }
  }

  void resetMP() {
    setState(() {
      mpdata = {'playerID': 0, 'finishedLoading': true};
    });
  }

  //TODO - remove & extract to own class
  void setupMultiplayer() {
    setState(() {
      mpdata['finishedLoading'] = false;
    });
    int code = mpdata['code'];
    String host = mpdata['uid'];
    int state = mpdata['state'];
    setState(() {
      gameData.multiplayer = true;
    });
    if (state == 1) {
      //user is host
      gameData.reset();

      gameData.playerCount = 1;
      mpdata['playerID'] = 0;
      mpDealCard(mpdata['username'], mpdata['uid']);
      FirebaseFirestore.instance.collection("active").doc(code.toString()).set({
        "gameData": gameData.toMap(),
        "host": host,
        "players": [host]
      }).then((value) {
        setState(() {
          mpdata['finishedLoading'] = true;
        });
      });
    } else {
      // List currentPlayers = [];
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
            final Map<String, dynamic> updatedData = data?['gameData'];
            updatedData['playerCount'] += 1;
            mpdata['playerID'] = updatedData['playerCount'] - 1;
            gameData = updatedData.toClass<Game>();
            mpDealCard(mpdata['username'], mpdata['uid']);
          });
          FirebaseFirestore.instance
              .collection("active")
              .doc(code.toString())
              .update({"players": current, "gameData": gameData.toMap()}).then(
                  (value) {
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
          Map<String, dynamic> data = snapshot.data()?['gameData'];
          gameData = data.toClass<Game>();
        });
      } else {
        gameData.reset();
      }
    });
  }

  void presentMultiplayerView() async {
    final res = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => MPStart()));

    print(mpdata);
    if (await res != null) {
      mpdata = await res;
      setupMultiplayer();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget game;
    if (gameData.winState.winnerChosen == true) {
      game = Scaffold(
        appBar: AppBar(title: const Text("Game Over!")),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (!gameData.multiplayer)
              if (gameData.winState.winner!.bot)
                Text(
                  "Bot ${gameData.winState.winner!.bot} has won!",
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
            if (gameData.multiplayer)
              if (gameData.winState.winner!.id != mpdata['playerID'])
                Text(
                  "${gameData.winState.winner!.username} has won!",
                  style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 50),
                ),
            if (gameData.winState.winner!.id == mpdata['playerID'])
              const Text(
                "You Win!",
                style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 50),
              ),
            ElevatedButton(
                onPressed: () {
                  if (!gameData.multiplayer) {
                    setState(() {
                      gameData.reset();
                    });
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
                leading: IconButton(
                    onPressed: presentMultiplayerView, icon: Icon(Icons.group)),
              ),
              body: Center(
                  child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (gameData.multiplayer)
                      ElevatedButton(
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection("active")
                              .doc(mpdata['code'].toString())
                              .delete();
                          setState(() {
                            mpdata['finishedLoading'] = false;
                            gameData.reset();
                          });
                        },
                        child: Text("Leave"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                      ),
                    if (gameData.multiplayer) Text("Code: ${mpdata['code']}"),
                    if (gameData.reversed)
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                    if (gameData.currentPlayer.id != mpdata['playerID'])
                      if (!gameData.multiplayer &&
                          gameData.currentPlayer.id != mpdata['playerID'])
                        Text("Current Player: ${gameData.currentPlayer!.id}"),
                    if (gameData.multiplayer &&
                        gameData.currentPlayer.id != mpdata['playerID'])
                      Text(
                          "Current Player: ${gameData.currentPlayer!.username!}"),
                    if (gameData.currentPlayer.id == mpdata['playerID'])
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
                    Text(
                      errTxt,
                      style: const TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      width: 0,
                      height: 20,
                    ),
                    Wrap(
                      children: gameData.players[mpdata['playerID']].cards
                          .map<Widget>((card) => PlayerCardState(
                              card: card,
                              playerID: mpdata['playerID'],
                              canPlay:
                                  UselessGameUtils.canPlayCard(card, gameData),
                              playCard: (gameData.currentPlayer!.id ==
                                          mpdata['playerID'] &&
                                      UselessGameUtils.canPlayCard(
                                          card, gameData))
                                  ? () {
                                      playCard(card, mpdata['playerID']);
                                    }
                                  : null,
                              wildColorChosen: (ccolor) {
                                print(ccolor);
                                GameCard newCard = GameCard.wild(card.type!);
                                setState(() {
                                  newCard.chosenColor = ccolor.color;
                                  gameData.players[mpdata['playerID']].cards
                                      .remove(card);
                                  gameData.players[mpdata['playerID']].cards
                                      .add(newCard);
                                });
                              }))
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
                            backgroundColor: UselessGameUtils.getCardColor(
                                gameData.stack.current!),
                            minimumSize: const Size(40, 100),
                            alignment: Alignment.center),
                        child: Text(
                          "${gameData.stack.current!.special ? gameData.stack!.current!.type!.name : gameData.stack.current!.number.toString()}",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 30),
                        )),
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: gameData.players
                          .map<Widget>((player) => Padding(
                                padding: const EdgeInsets.all(15),
                                child: (!gameData.multiplayer)
                                    ? player.bot
                                        ? Text(
                                            "Bot ${player.id}\n${player.cards.length} card(s) left",
                                            textAlign: TextAlign.center)
                                        : Text(
                                            "You\n${player.cards.length} card(s) left",
                                            textAlign: TextAlign.center,
                                          )
                                    : !(player.id == mpdata['playerID'])
                                        ? Text(
                                            "${player.username!}\n${player.cards.length} card(s) left",
                                            textAlign: TextAlign.center)
                                        : Text(
                                            "You (${player.username!})\n${player.cards.length} card(s) left",
                                            textAlign: TextAlign.center,
                                          ),
                              ))
                          .toList(),
                    ),
                    const Text("v1.1.2 rev2")
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

class PlayerCardState extends StatefulWidget {
  const PlayerCardState(
      {super.key,
      required this.card,
      required this.playerID,
      required this.canPlay,
      required this.playCard,
      required this.wildColorChosen});

  final GameCard card;
  final int playerID;
  final bool canPlay;
  final Function()? playCard;
  final Function(WildColor)? wildColorChosen;

  @override
  State<PlayerCardState> createState() => _PlayerCardState();
}

class _PlayerCardState extends State<PlayerCardState> {
  // var wildcolors = ["Red", "Blue", "Green", "Yellow"];
  var wildcolors = [
    WildColor("Red", CardColor.red),
    WildColor("Blue", CardColor.blue),
    WildColor("Green", CardColor.green),
    WildColor("Yellow", CardColor.yellow)
  ];
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: ElevatedButton(
        onPressed: widget.playCard,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(100, 120),
          shadowColor: widget.canPlay
              ? UselessGameUtils.getCardColor(widget.card)
              : null,
          elevation: widget.canPlay ? 22.0 : null,
        ),
        child: !widget.card.special
            ? Text(
                "${widget.card.number.toString()}",
                textAlign: TextAlign.center,
                style: widget.canPlay
                    ? TextStyle(
                        color: UselessGameUtils.getCardColor(widget.card),
                        fontSize: 30)
                    : null,
              )
            : !(widget.card.chosenColor == '')
                ? Text("${widget.card.type!.name}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: widget.canPlay
                            ? UselessGameUtils.getCardColor(widget.card)
                            : null,
                        fontSize: 30))
                : Column(
                    children: wildcolors
                        .map<Widget>((ccolor) => ElevatedButton(
                              onPressed: () {
                                widget.wildColorChosen!(ccolor);
                              },
                              style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(80, 20)),
                              child: Text(ccolor.name,
                                  style: TextStyle(
                                      color: UselessGameUtils.getCardColor(
                                          GameCard.color(ccolor.color)))),
                            ))
                        .toList()),
      ),
    );
  }
}
