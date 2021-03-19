import 'dart:ui';

import 'package:color_game/game/game-board.dart';
import 'package:flutter/widgets.dart';

import 'view-transform.dart';

class TimerSpec {
  final Key key = UniqueKey();
  final int numberOfSeconds;

  TimerSpec({required this.numberOfSeconds});
}

enum GameMode {
  MOVE_LIMIT,
  POINT_GOAL,
  TIME_LIMIT,
  TIME_ATTACK,
}

enum BoxAddingBehavior {
  PER_MOVE,
  PER_TIME,
}

class BoxAddingSpec {
  BoxAddingBehavior behavior;
  Duration? boxAddingPeriod;

  // expressed in boxes per second per second
  double boxAddingAcceleration;
  int? addBoxEveryNMoves;
  BoxAddingSpec({
    required this.behavior,
    this.boxAddingPeriod,
    this.addBoxEveryNMoves,
    this.boxAddingAcceleration = 0,
  });
}

class ColorGameConfig {
  // the number of squares on each side of the board
  final Size gridSize;

  final List<GameBox> predefinedGrid;
  final String label;
  final String goalString;

  final TimerSpec? timerSpec;
  final int? moveLimit;

  final bool Function(List<GameEvent> events) completionEvaluator;
  final int Function(List<GameEvent> events) starEvaluator;

  final bool gravitizeAfterEveryMove;

  final GameMode mode;

  final BoxAddingSpec? boxAddingSpec;

  const ColorGameConfig(
    this.label, {
    this.gridSize = const Size(6, 6),
    this.predefinedGrid = const [],
    required this.completionEvaluator,
    required this.starEvaluator,
    required this.goalString,
    this.timerSpec,
    this.gravitizeAfterEveryMove = false,
    this.moveLimit,
    this.mode = GameMode.POINT_GOAL,
    this.boxAddingSpec,
  });
}

class GameCompletedEvent {
  bool successful;
  GameCompletedEvent(this.successful);
}

enum GameBoxAttribute {
  UNGRABBABLE,
  IMMOVABLE,
  UNFEATURED,
  UNGRAVITIZABLE,
}

class GameBox {
  // this is the box's drawn location
  Offset loc;

  // this stores the original location of the box during a drag
  Offset startLoc;
  Color color;
  List<GameBoxAttribute> attributes;

  bool userDragged = false;
  bool collapsing = false;
  Key key = UniqueKey();

  List<RunEventMetadata> runs = [];
  List<SquareEventMetadata> squares = [];

  GameBox(this.loc, this.color, {this.attributes = const []}) : startLoc = loc;

  Rect getRect(ViewTransformation vt) {
    return vt.rectForward(Rect.fromCenter(center: loc, width: 1, height: 1));
  }

  Rect getStartRect(ViewTransformation vt) {
    return vt
        .rectForward(Rect.fromCenter(center: startLoc, width: 1, height: 1));
  }

  bool get eligibleForInclusionInSquare => runs.isEmpty && squares.isEmpty;

  GameBox clone() => GameBox(loc, color, attributes: attributes);
}
