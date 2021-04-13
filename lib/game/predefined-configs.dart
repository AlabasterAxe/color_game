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
    goalString: "Plusses work too!",
    gridSize: Size(4, 4),
    predefinedGrid: game,
    completionEvaluator: (_) => false,
    starEvaluator: PointStarEvaluator(threeStar: 0),
  );
}

ColorGameConfig immovable() {
  List<GameBox> game = [
    GameBox(
      Offset(-1.5, -1.5),
      Colors.black,
      attributes: [
        GameBoxAttribute.IMMOVABLE,
        GameBoxAttribute.UNGRAVITIZABLE,
        GameBoxAttribute.UNFEATURED,
      ],
    ),
    GameBox(
      Offset(1.5, 1.5),
      Colors.black,
      attributes: [
        GameBoxAttribute.IMMOVABLE,
        GameBoxAttribute.UNGRAVITIZABLE,
        GameBoxAttribute.UNFEATURED,
      ],
    ),
    GameBox(
      Offset(-1.5, 1.5),
      Colors.black,
      attributes: [
        GameBoxAttribute.IMMOVABLE,
        GameBoxAttribute.UNGRAVITIZABLE,
        GameBoxAttribute.UNFEATURED,
      ],
    ),
    GameBox(
      Offset(1.5, -1.5),
      Colors.black,
      attributes: [
        GameBoxAttribute.IMMOVABLE,
        GameBoxAttribute.UNFEATURED,
        GameBoxAttribute.UNGRAVITIZABLE,
      ],
    ),
    GameBox(
      Offset(-2.5, -2.5),
      Colors.purple,
    ),
    GameBox(
      Offset(2.5, 2.5),
      Colors.purple,
    ),
    GameBox(
      Offset(-2.5, 2.5),
      Colors.purple,
    ),
    GameBox(
      Offset(2.5, -2.5),
      Colors.purple,
    ),
  ];
  return ColorGameConfig(
    "immovable_boxes",
    goalString:
        "Black boxes can't move at all. Trust me, we've tried. Just make a purple quad.",
    gridSize: Size(6, 6),
    predefinedGrid: game,
    completionEvaluator: (_) => false,
    starEvaluator: PointStarEvaluator(threeStar: 0),
    goalBoard: [
      GameBox(Offset(.5, -.5), Colors.purple),
      GameBox(Offset(-.5, .5), Colors.purple),
      GameBox(Offset(.5, .5), Colors.purple),
      GameBox(Offset(-.5, -.5), Colors.purple),
    ],
  );
}

ColorGameConfig undraggable() {
  List<GameBox> game = [
    GameBox(
      Offset(-1.5, -1.5),
      Colors.grey,
      attributes: [GameBoxAttribute.UNGRABBABLE],
    ),
    GameBox(
      Offset(1.5, 1.5),
      Colors.grey,
      attributes: [GameBoxAttribute.UNGRABBABLE],
    ),
    GameBox(
      Offset(-1.5, 1.5),
      Colors.grey,
      attributes: [GameBoxAttribute.UNGRABBABLE],
    ),
    GameBox(
      Offset(1.5, -1.5),
      Colors.grey,
      attributes: [GameBoxAttribute.UNGRABBABLE],
    ),
    GameBox(Offset(-2.5, -2.5), Colors.purple, attributes: [
      GameBoxAttribute.UNFEATURED,
      GameBoxAttribute.UNGRAVITIZABLE
    ]),
    GameBox(Offset(2.5, 2.5), Colors.purple, attributes: [
      GameBoxAttribute.UNFEATURED,
      GameBoxAttribute.UNGRAVITIZABLE
    ]),
    GameBox(Offset(-2.5, 2.5), Colors.purple, attributes: [
      GameBoxAttribute.UNFEATURED,
      GameBoxAttribute.UNGRAVITIZABLE
    ]),
    GameBox(Offset(2.5, -2.5), Colors.purple, attributes: [
      GameBoxAttribute.UNFEATURED,
      GameBoxAttribute.UNGRAVITIZABLE
    ]),
  ];
  return ColorGameConfig(
    "undraggable_boxes",
    goalString:
        "Grey boxes don't like to be touched. Use the purple boxes to make a quad out of the grey boxes.",
    gridSize: Size(6, 6),
    predefinedGrid: game,
    completionEvaluator: (_) => false,
    starEvaluator: PointStarEvaluator(threeStar: 0),
    goalBoard: [
      GameBox(Offset(.5, -.5), Colors.grey),
      GameBox(Offset(-.5, .5), Colors.grey),
      GameBox(Offset(.5, .5), Colors.grey),
      GameBox(Offset(-.5, -.5), Colors.grey),
    ],
  );
}

List<GameBox> getImmovableBorder() {
  // todo: loop? loop.
  return [
    GameBox(Offset(-1.5, -4.5), Colors.black,
        attributes: IMMOVABLE_BOX_ATTRIBUTES),
    GameBox(Offset(-2.5, -4.5), Colors.black,
        attributes: IMMOVABLE_BOX_ATTRIBUTES),
    GameBox(Offset(-0.5, -4.5), Colors.black,
        attributes: IMMOVABLE_BOX_ATTRIBUTES),
    GameBox(Offset(0.5, -4.5), Colors.black,
        attributes: IMMOVABLE_BOX_ATTRIBUTES),
    GameBox(Offset(1.5, -4.5), Colors.black,
        attributes: IMMOVABLE_BOX_ATTRIBUTES),
    GameBox(Offset(2.5, -4.5), Colors.black,
        attributes: IMMOVABLE_BOX_ATTRIBUTES),
    GameBox(Offset(-2.5, 4.5), Colors.black,
        attributes: IMMOVABLE_BOX_ATTRIBUTES),
    GameBox(Offset(-1.5, 4.5), Colors.black,
        attributes: IMMOVABLE_BOX_ATTRIBUTES),
    GameBox(Offset(-0.5, 4.5), Colors.black,
        attributes: IMMOVABLE_BOX_ATTRIBUTES),
    GameBox(Offset(0.5, 4.5), Colors.black,
        attributes: IMMOVABLE_BOX_ATTRIBUTES),
    GameBox(Offset(1.5, 4.5), Colors.black,
        attributes: IMMOVABLE_BOX_ATTRIBUTES),
    GameBox(Offset(2.5, 4.5), Colors.black,
        attributes: IMMOVABLE_BOX_ATTRIBUTES),
    GameBox(Offset(4.5, 2.5), Colors.black,
        attributes: IMMOVABLE_BOX_ATTRIBUTES),
    GameBox(Offset(4.5, 1.5), Colors.black,
        attributes: IMMOVABLE_BOX_ATTRIBUTES),
    GameBox(Offset(4.5, 0.5), Colors.black,
        attributes: IMMOVABLE_BOX_ATTRIBUTES),
    GameBox(Offset(4.5, -0.5), Colors.black,
        attributes: IMMOVABLE_BOX_ATTRIBUTES),
    GameBox(Offset(4.5, -1.5), Colors.black,
        attributes: IMMOVABLE_BOX_ATTRIBUTES),
    GameBox(Offset(4.5, -2.5), Colors.black,
        attributes: IMMOVABLE_BOX_ATTRIBUTES),
    GameBox(Offset(-4.5, 2.5), Colors.black,
        attributes: IMMOVABLE_BOX_ATTRIBUTES),
    GameBox(Offset(-4.5, 1.5), Colors.black,
        attributes: IMMOVABLE_BOX_ATTRIBUTES),
    GameBox(Offset(-4.5, 0.5), Colors.black,
        attributes: IMMOVABLE_BOX_ATTRIBUTES),
    GameBox(Offset(-4.5, -0.5), Colors.black,
        attributes: IMMOVABLE_BOX_ATTRIBUTES),
    GameBox(Offset(-4.5, -1.5), Colors.black,
        attributes: IMMOVABLE_BOX_ATTRIBUTES),
    GameBox(Offset(-4.5, -2.5), Colors.black,
        attributes: IMMOVABLE_BOX_ATTRIBUTES),
  ];
}
