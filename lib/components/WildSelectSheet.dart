import 'package:flutter/material.dart';
import 'package:unoweb_flutter/classes/UselessGameUtils.dart';
import '../classes/GameCard.dart';

class WildSelectSheet extends StatefulWidget {
  const WildSelectSheet({super.key, required this.wildColorChosen});
  final Function(WildColor)? wildColorChosen;
  @override
  State<WildSelectSheet> createState() => _WildSelectSheetState();
}

class _WildSelectSheetState extends State<WildSelectSheet> {
  var wildcolors = [
    WildColor("Red", CardColor.red),
    WildColor("Blue", CardColor.blue),
    WildColor("Green", CardColor.green),
    WildColor("Yellow", CardColor.yellow)
  ];
  Widget selectionButton(WildColor color) {
    return Container(
      width: MediaQuery.of(context).size.width / 4,
      child: Padding(
        padding: EdgeInsets.all(5),
        child: ElevatedButton(
          onPressed: () {
            widget.wildColorChosen!(color);
            Navigator.pop(context);
          },
          child: Text(
            color.name,
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
              backgroundColor:
                  UselessGameUtils.getCardColor(GameCard.color(color.color)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)))),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Choose a color",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  selectionButton(wildcolors[0]),
                  selectionButton(wildcolors[1]),
                  selectionButton(wildcolors[2]),
                  selectionButton(wildcolors[3]),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
