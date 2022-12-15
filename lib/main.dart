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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
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
  int _counter = 0;
  Map gameData = {
    'players': [],
    'currentPlayer': 0,
    'stack': {'current': {}, 'prev': []}
  };
  List<Map> cards = [];
  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  void genCards() {
    for (var i = 0; i < 10; i++) {
      cards.add({'color': 'red', 'number': i, 'special': false});
    }
    for (var i = 0; i < 10; i++) {
      cards.add({'color': 'blue', 'number': i, 'special': false});
    }
    for (var i = 0; i < 10; i++) {
      cards.add({'color': 'green', 'number': i, 'special': false});
    }
    for (var i = 0; i < 10; i++) {
      cards.add({'color': 'yellow', 'number': i, 'special': false});
    }
  }

  @override
  void initState() {
    super.initState();
    genCards();
    dealCards(4);
  }

  Color getCardColor(card) {
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
  }

  void botPlay() async {
    print("bot attempting play..");
    if (gameData['currentPlayer'] > 0) {
      Map bot = gameData['players'][gameData['currentPlayer']];
      List<Map> possibleCards = [];
      for (var card in bot['cards']) {
        if (card['color'] == gameData['stack']['current']['color'] ||
            card['number'] == gameData['stack']['current']['number']) {
          possibleCards.add(card);
        }
      }

      if (possibleCards.isEmpty) {
        print('bot has no cards');
        drawCard(bot['id']);
        botPlay();
      } else {
        //cards available
        await Future.delayed(const Duration(seconds: 3));
        playCard(
            possibleCards[Random().nextInt(possibleCards.length)], bot['id']);
      }
    } else {
      print("bot cannot play!");
    }
  }

  void playCard(card, playerID) {
    print("play attempted: $playerID");
    if (playerID == gameData['currentPlayer']) {
      //valid
      if (card['color'] == gameData['stack']['current']['color'] ||
          card['number'] == gameData['stack']['current']['number']) {
        //valid
        setState(() {
          gameData['stack']['current'] = card;
          gameData['players'][playerID]['cards'].remove(card);
        });
        updatePlayer();
        botPlay();
      }
    } else {
      //invalid
    }
  }

  void updatePlayer() {
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
    setState(() {
      gameData['players'][playerID]['cards']
          .add(cards[Random().nextInt(cards.length)]);
      updatePlayer();
      botPlay();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (gameData['currentPlayer'] > 0)
              Text("Current Player: ${gameData['currentPlayer']}"),
            if (gameData['currentPlayer'] == 0)
              Text(
                "Your Turn!",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            const Text(
              "Your cards",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const Text("Click on a card to play it"),
            const SizedBox(
              width: 0,
              height: 20,
            ),
            Wrap(
              children: gameData['players'][0]['cards']
                  .map<Widget>((card) => ElevatedButton(
                        onPressed: () {
                          playCard(card, 0);
                          print(gameData['players'][0]['cards']);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: getCardColor(card),
                            minimumSize: Size(40, 100)),
                        child: Text(
                          card['color'] + "\n" + card['number'].toString(),
                          textAlign: TextAlign.center,
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
                  minimumSize: Size(40, 100)),
              child: Text(
                gameData['stack']['current']['color'] +
                    "\n" +
                    gameData['stack']['current']['number'].toString(),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
