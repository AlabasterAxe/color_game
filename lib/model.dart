import 'dart:ui';

import 'package:color_game/game/game-board.dart';
import 'package:flutter/widgets.dart';

import 'view-transform.dart';

class ColorGameConfig {
  // the number of squares on each side of the board
  Size gridSize;

  List<GameBox> predefinedGrid;
}

class GameBox {
  // this is the box's drawn location
  Offset loc;

  // this stores the original location of the box during a drag
  Offset startLoc;
  Color color;

  bool userDragged = false;
  bool collapsing = false;
  Key key = UniqueKey();

  List<RunEventMetadata> runs = [];
  List<SquareEventMetadata> squares = [];

  GameBox(this.loc, this.color) {
    startLoc = loc;
  }

  Rect getRect(ViewTransformation vt) {
    return vt.rectForward(Rect.fromCenter(center: loc, width: 1, height: 1));
  }

  Rect getStartRect(ViewTransformation vt) {
    return vt.rectForward(Rect.fromCenter(center: startLoc, width: 1, height: 1));
  }

  bool get eligibleForInclusionInSquare => runs.isEmpty && squares.isEmpty;
}
