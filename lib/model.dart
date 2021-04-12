import 'dart:ui';

import 'package:flutter/widgets.dart';

import 'view-transform.dart';

class Score {
  final int score;
  final DateTime date;
  final String levelTag;
  final int earnedStars;

  Score(
      {required this.score,
      required this.date,
      required this.levelTag,
      required this.earnedStars});

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
        score: json["score"],
        date: DateTime.parse(json["date"]),
        levelTag: json["levelTag"],
        earnedStars: json["earnedStars"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "score": score,
      "date": date.toIso8601String(),
      "levelTag": levelTag,
      "earnedStars": earnedStars,
    };
  }
}

class Settings {
  final bool developerMode;
  const Settings({this.developerMode = false});
  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(developerMode: json["developerMode"] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {
      "developerMode": this.developerMode,
    };
  }
}

class User {
  // This is a read only list of attempts if you want to save a new attempt
  // use the addScore shared prefs utility.
  final Map<String, List<Score>> attempts;

  final Settings settings;
  User({this.settings = const Settings(), this.attempts = const {}});

  Map<String, dynamic> toJson() {
    return {
      "settings": settings.toJson(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json,
      {Map<String, List<Score>> attempts = const {}}) {
    return User(
        settings: Settings.fromJson(json["settings"]), attempts: attempts);
  }
}

class TimerSpec {
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

enum DragDirection {
  HORIZONTAL,
  VERTICAL,
}

class UserMoveEventMetadata {
  final DragDirection dragDirection;
  final int dragLength;
  final List<GameBox> draggedBoxes;
  UserMoveEventMetadata(this.dragDirection, this.dragLength, this.draggedBoxes);
}

class SquareEventMetadata {
  Color? color;
  int? stepNumber;
}

class GameEvent {
  final GameEventType type;
  final dynamic metadata;
  final DateTime datetime;

  GameEvent(this.type, {DateTime? datetime, this.metadata})
      : this.datetime = datetime ?? DateTime.now();
}

abstract class StarEvaluator {
  int call(List<GameEvent> events);
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
  final StarEvaluator starEvaluator;

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

enum GameEventType {
  RUN,
  SQUARE,
  NO_MOVES,
  LEFT_OVER_BOX,
  USER_MOVE,
  TIMER_FINISHED,
  BOARD_FULL,
  GAME_START,
}

class RunEventMetadata {
  int runLength;
  Color color;
  int runStreakLength;
  int? multiples;

  // This is a way to group events together.
  // all events occurring simultaneously will have the same stepNumber.
  int? stepNumber;
  RunEventMetadata({
    required this.runLength,
    required this.color,
    required this.runStreakLength,
  });
}

enum GameBoxAttribute {
  UNGRABBABLE,
  IMMOVABLE,
  UNFEATURED,
  UNGRAVITIZABLE,
  UNRUNNABLE,
  UNQUADDABLE,
}

const List<GameBoxAttribute> IMMOVABLE_BOX_ATTRIBUTES = [
  GameBoxAttribute.IMMOVABLE,
  GameBoxAttribute.UNFEATURED,
  GameBoxAttribute.UNGRAVITIZABLE,
];

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
