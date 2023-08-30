import 'package:flutter/material.dart';
import '../classes/GameCard.dart';
import '../classes/UselessGameUtils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StackCardUI extends StatefulWidget {
  const StackCardUI({super.key, required this.card, required this.onPressed});

  final GameCard card;
  final Function()? onPressed;
  @override
  State<StackCardUI> createState() => _StackCardUIState();
}

class _StackCardUIState extends State<StackCardUI> {
  Future<bool> getColorblindMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getBool("colorblindmode") ?? false;
  }

  bool isColorblind = false;

  Image? cardSymbol;

  void refreshColorblindSettings() {
    getColorblindMode().then((value) {
      setState(() {
        isColorblind = value;
      });
      if (isColorblind) {
        widget.card.color.symbol.then((value) {
          setState(() {
            cardSymbol = value;
          });
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    refreshColorblindSettings();
    return Padding(
        padding: const EdgeInsets.all(2.0),
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
              minimumSize: const Size(100, 120),
              backgroundColor: UselessGameUtils.getCardColor(widget.card),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)))),
          child: Column(
            children: [
              Text("${widget.card.humanReadableType}",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30, color: Colors.white)),
              if (isColorblind && cardSymbol != null)
                Image(
                  image: cardSymbol!.image,
                  width: 25,
                  height: 25,
                )
            ],
          ),
        ));
  }
}
