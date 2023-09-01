import 'package:unoweb_flutter/classes/GameCard.dart';
import 'package:unoweb_flutter/classes/GameRule.dart';

class OnlySameNumber extends GameRule {
  @override
  // TODO: implement instruction
  List get instructions => [
        GameRuleData.grSTART,
        GameRuleConditions.gcIF,
        GameRuleValues.gcNUMBER,
        GameRuleConditions.gcEQUALS,
        GameRuleValues.scNUMBER,
        GameRuleData.grEND
      ];
  @override
  bool match(GameCard card, GameCard stack) {
    bool val = false;
    for (var instruction in instructions) {
      if (instruction == GameRuleData.grSTART) {
        continue;
      }
      if (instruction == GameRuleData.grEND) {
        return val;
      }
      if (instruction == GameRuleConditions.gcIF) {}
    }
    return false;
  }

  dynamic ValueForInstruction(GameRuleValues value, GameCard card) {
    switch (value) {
      case GameRuleValues.gcCOLOR:
        if (card.isWild) {
          return card.chosenColor;
        } else {
          return card.color;
        }
      case GameRuleValues.gcISSPECIAL || GameRuleValues.scISSPECIAL:
        return card.special;
      case GameRuleValues.gcNUMBER || GameRuleValues.scNUMBER:
        return card.number ?? 0;
      case GameRuleValues.gcTYPE || GameRuleValues.scTYPE:
        return card.type ?? CardType.plus2;
      default:
        return null;
    }
  }
}
