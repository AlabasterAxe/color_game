import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../model.dart';

List<GameBox> generateGameBoxes({List<Color> colors}) {
  Random r = Random();
  List<GameBox> result = [];
  for (double x = -2.5; x <= 2.5; x++) {
    for (double y = -2.5; y <= 2.5; y++) {
      List<Color> availableColors = [...colors];
      for (int i = result.length - 1; i >= 0; i--) {
        if (result[i].loc.dx == x && result[i].loc.dy == y - 1) {
          availableColors.remove(result[i].color);
        } else if (result[i].loc.dy == y && result[i].loc.dx == x - 1) {
          availableColors.remove(result[i].color);
        }
      }
      int colorIdx = r.nextInt(availableColors.length);
      result.add(GameBox(Offset(x, y), availableColors[colorIdx]));
    }
  }

  return result;
}
