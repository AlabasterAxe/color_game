import 'package:color_game/constants.dart';
import 'package:color_game/game/generate-game-boxes.dart';
import 'package:color_game/model.dart';
import 'package:flutter/material.dart';

ColorGameConfig easyToMakePlus() {
  List<GameBox> game = generateGameBoxes(colors: COLORS);
  GameBox box = game.removeAt(21);
  game.insert(21, GameBox(box.loc, Colors.orange));
  box = game.removeAt(16);
  game.insert(16, GameBox(box.loc, Colors.orange));
  box = game.removeAt(15);
  game.insert(15, GameBox(box.loc, Colors.orange));
  box = game.removeAt(14);
  game.insert(14, GameBox(box.loc, Colors.orange));
  box = game.removeAt(7);
  game.insert(7, GameBox(box.loc, Colors.orange));
  return ColorGameConfig(
    "plus_master_flex",
    gridSize: Size(4, 4),
    predefinedGrid: game,
    completionEvaluator: (_) => false,
    starEvaluator: (_) => 3,
  );
}
