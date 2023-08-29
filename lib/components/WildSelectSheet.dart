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
            Wrap(
              children: wildcolors
                  .map((color) => Padding(
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
                              backgroundColor: UselessGameUtils.getCardColor(
                                  GameCard.color(color.color)),
                              minimumSize: Size(
                                  MediaQuery.of(context).size.width / 4, 100),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)))),
                        ),
                      ))
                  .toList(),
            )
          ],
        ),
      ),
    );
  }
}
