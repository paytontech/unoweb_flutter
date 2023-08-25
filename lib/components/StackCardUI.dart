import 'package:flutter/material.dart';
import '../classes/GameCard.dart';
import '../classes/UselessGameUtils.dart';

class StackCardUI extends StatefulWidget {
  const StackCardUI({
    super.key,
    required this.card,
  });

  final GameCard card;

  @override
  State<StackCardUI> createState() => _StackCardUIState();
}

class _StackCardUIState extends State<StackCardUI> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(100, 120),
            backgroundColor: UselessGameUtils.getCardColor(widget.card),
          ),
          child: Text("${widget.card.humanReadableType}",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30, color: Colors.white))),
    );
  }
}
