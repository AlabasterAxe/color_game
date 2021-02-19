import 'dart:ui';

import 'package:flutter/widgets.dart';

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
  Size size;

  bool userDragged = false;
  Key key = UniqueKey();

  GameBox(this.loc, this.color) {
    startLoc = loc;
  }

  Rect getRect(Size screenSize) {
    Offset screenCenterOffset =
        Offset(screenSize.width / 2, screenSize.height / 2);
    Offset boxCenterOffset =
        screenCenterOffset + (loc.scale(size.width, size.height));

    return Rect.fromCenter(
        center: boxCenterOffset, height: size.height, width: size.width);
  }
}
