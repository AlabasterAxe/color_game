import 'dart:ui';

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
  Key key = UniqueKey();

  GameBox(this.loc, this.color) {
    startLoc = loc;
  }

  Rect getRect(ViewTransformation vt) {
    return vt.rectForward(Rect.fromCenter(center: loc, width: 1, height: 1));
  }
}