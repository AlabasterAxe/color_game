import 'package:color_game/constants.dart';
import 'package:color_game/game/generate-game-boxes.dart';
import 'package:color_game/model.dart';
import 'package:flutter/material.dart';

ColorGameConfig defaultConfig() => ColorGameConfig()..gridSize = Size(4, 4);

ColorGameConfig easyToMakePlus() {
  List<GameBox> game = generateGameBoxes(colors: COLORS);
  game.removeAt(21);
  game.insert(21, GameBox(Offset(.5, .5), Colors.orange));
  game.removeAt(16);
  game.insert(16, GameBox(Offset(-.5, 1.5), Colors.orange));
  game.removeAt(15);
  game.insert(15, GameBox(Offset(-.5, .5), Colors.orange));
  game.removeAt(14);
  game.insert(14, GameBox(Offset(-.5, -.5), Colors.orange));
  game.removeAt(7);
  game.insert(7, GameBox(Offset(-1.5, -1.5), Colors.orange));
  return ColorGameConfig()
    ..gridSize = Size(4, 4)
    ..predefinedGrid = game;
}
