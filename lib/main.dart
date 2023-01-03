import 'dart:convert';
import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'unoweb-flutter',
      theme: ThemeData(
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'unoweb-flutter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map gameData = {
    'players': [],
    'currentPlayer': 0,
    'stack': {'current': {}, 'prev': []},
    'winState': {'winnerChosen': false, 'winner': {}}
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
    dealCards(4);
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

  void botPlay() async {
    print("bot attempting play..");
    if (gameData['currentPlayer'] > 0) {
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
        Map checkedCard = Map.from(chosenCard);

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
            print("botplay chosencard: ${chosenCard}");
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
        botPlay();
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

  void dealCards(playerCount) {
    gameData['stack']['current'] = cards[Random().nextInt(cards.length)];

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

  void drawCard(playerID) {
    if (gameData['currentPlayer'] == playerID) {
      setState(() {
        gameData['players'][playerID]['cards']
            .add(cards[Random().nextInt(cards.length)]);
      });
      updatePlayer();
      botPlay();
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
                    gameData['players'] = [];
                    gameData['winState']['winner'] = {};
                    dealCards(4);
                    gameData['winState']['winnerChosen'] = false;
                    gameData['currentPlayer'] = 0;
                  });
                },
                child: Text("Restart"))
          ],
        )),
      );
    } else {
      game = Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
            child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton(
                  onPressed: () {},
                  child: const Text("New! Try Multiplayer [Beta]")),
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
                children: gameData['players'][0]['cards']
                    .map<Widget>((card) => Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: ElevatedButton(
                            onPressed: (gameData['currentPlayer'] == 0)
                                ? () {
                                    print(gameData['players'][0]['cards']);
                                    playCard(card, 0);
                                  }
                                : null,
                            style: canPlayCard(card)
                                ? ElevatedButton.styleFrom(
                                    backgroundColor: getCardColor(card),
                                    minimumSize: Size(50, 120),
                                    shadowColor: getCardColor(card),
                                    elevation: 20.0,
                                  )
                                : ElevatedButton.styleFrom(
                                    backgroundColor:
                                        getCardColor(card).withOpacity(0.3),
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
                                        Text(
                                            "${card['color']} ${card['type']}"),
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
                          ),
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
                          child: player['bot']
                              ? Text(
                                  "Bot ${player['id']}\n${player['cards'].length} card(s) left",
                                  textAlign: TextAlign.center)
                              : Text(
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
    }
    return Container(child: game);
  }
}
