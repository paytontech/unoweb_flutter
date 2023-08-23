class GameCard {
  CardColor color = CardColor.red;
  int? number;
  CardType? type;
  bool special = false;
  CardColor? chosenColor;
  //normal
  GameCard(CardColor color, int number) {
    this.color = color;
    this.number = number;
    this.special = false;
  }
  //special -- not wild
  GameCard.special(CardColor color, CardType type) {
    this.color = color;
    this.type = type;
    this.special = true;
  }

  GameCard.wild(CardType type) {
    this.type = type;
    this.special = true;
    this.chosenColor = null;
  }
  GameCard.color(CardColor color) {
    this.color = color;
  }
  GameCard.from(GameCard card) {
    this.color = card.color;
    this.number = card.number;
    this.type = card.type;
    this.special = card.special;
    this.chosenColor = card.chosenColor;
  }
}

class WildColor {
  String name = "";
  CardColor color = CardColor.red;
  WildColor(this.name, this.color);
}

enum CardColor { red, green, blue, yellow }

extension ColorName on CardColor {
  String get name {
    switch (this) {
      case CardColor.red:
        return "Red";
      case CardColor.blue:
        return "Blue";
      case CardColor.yellow:
        return "Yellow";
      case CardColor.green:
        return "Green";
    }
  }
}

enum CardType { plus2, skip, reverse, wnormal, wplus4 }

extension TypeName on CardType {
  String get name {
    switch (this) {
      case CardType.plus2:
        return "+2";
      case CardType.reverse:
        return "Reverse";
      case CardType.skip:
        return "Skip";
      case CardType.wnormal:
        return "Wild";
      case CardType.wplus4:
        return "Wild +4";
    }
  }
}
