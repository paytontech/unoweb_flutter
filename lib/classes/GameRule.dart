import 'package:unoweb_flutter/classes/GameCard.dart';

class GameRule {
  List<dynamic> instructions = [];

  bool match(GameCard card, GameCard stack) {
    return false;
  }
}

enum GameRuleData { grSTART, grEND }

enum GameRuleConditions {
  gcIF,
  gcEQUALS,
  gcDOESNOTEQUAL,
}

enum GameRuleValues {
  gcNUMBER,
  gcCOLOR,
  gcISSPECIAL,
  gcTYPE,
  scNUMBER,
  scCOLOR,
  scISSPECIAL,
  scTYPE
}
