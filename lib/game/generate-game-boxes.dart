import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../model.dart';

List<GameBox> generateGameBoxes({List<Color>? colors, int size = 6}) {
  Random r = Random();
  List<GameBox> result = [];
  double halfSize = (size - 1) / 2.0;
  for (double x = -halfSize; x <= halfSize; x++) {
    for (double y = -halfSize; y <= halfSize; y++) {
      List<Color> availableColors = [...colors!];
      for (int i = result.length - 1; i >= 0; i--) {
        if (result[i].loc!.dx == x && result[i].loc!.dy == y - 1) {
          availableColors.remove(result[i].color);
        } else if (result[i].loc!.dy == y && result[i].loc!.dx == x - 1) {
          availableColors.remove(result[i].color);
        }
      }
      int colorIdx = r.nextInt(availableColors.length);
      result.add(GameBox(Offset(x, y), availableColors[colorIdx]));
    }
  }

  return result;
}
