import 'dart:ui';

import 'package:color_game/game/game-board.dart';
import 'package:flutter/widgets.dart';

import 'view-transform.dart';

class TimerSpec {
  final Key key = UniqueKey();
  final int numberOfSeconds;

  TimerSpec({required this.numberOfSeconds});
}

class ColorGameConfig {
  // the number of squares on each side of the board
  final Size gridSize;

  final List<GameBox> predefinedGrid;
  final String label;

  final TimerSpec? timerSpec;

  const ColorGameConfig(this.label,
      {this.gridSize = const Size(6, 6),
      this.predefinedGrid = const [],
      this.timerSpec});
}

class GameCompletedEvent {
  bool successful;
  GameCompletedEvent(this.successful);
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

  GameBox(this.loc, this.color) : startLoc = loc;

  Rect getRect(ViewTransformation vt) {
    return vt.rectForward(Rect.fromCenter(center: loc, width: 1, height: 1));
  }

  Rect getStartRect(ViewTransformation vt) {
    return vt
        .rectForward(Rect.fromCenter(center: startLoc, width: 1, height: 1));
  }

  bool get eligibleForInclusionInSquare => runs.isEmpty && squares.isEmpty;

  GameBox clone() => GameBox(loc, color);
}
