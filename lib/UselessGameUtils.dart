import 'dart:io' show Platform;
import 'dart:math';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'mp_chooser.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class UselessGameUtils {
  static Color getCardColor(Map? card, String? color) {
    var newCard = {};
    if (card == null) {
      newCard = {'color': color!.toLowerCase()};
    } else {
      newCard = card;
    }
    switch (newCard['color'] == 'wild'
        ? newCard['chosenColor']
        : newCard['color']) {
      case 'red':
        return (Colors.red);
      case 'blue':
        return (Colors.blue);
      case 'green':
        return (Colors.green);
      case 'yellow':
        return (const Color.fromARGB(255, 195, 176, 3));
      default:
        return (Colors.black);
    }
  }
}
