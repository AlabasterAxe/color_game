import 'dart:ui';

import 'package:flutter/material.dart';

import 'game/game-board.dart';
import 'game/generate-game-boxes.dart';
import 'game/predefined-configs.dart';
import 'game/score-utils.dart';
import 'model.dart';

const RELATIVE_GAP_SIZE = 1 / 12;
const BOX_BORDER_RADIUS = 1 / 8;
const GRID_SIZE = 6;
const COLLAPSE_DURATION_MILLISECONDS = 750;

const BOARD_BACKGROUND_COLOR = Color(0xff486173);

const RED_COLOR = Color(0xffF55454);
const YELLOW_COLOR = Color(0xffFED30B);
const GREEN_COLOR = Color(0xff9CC405);
const BLUE_COLOR = Color(0xff5099B0);

BorderRadiusGeometry cardBorderRadius = BorderRadius.circular(15.0);

ShapeBorder CARD_SHAPE = RoundedRectangleBorder(
  borderRadius: cardBorderRadius,
);

const List<Color> COLORS = [
  RED_COLOR,
  YELLOW_COLOR,
  GREEN_COLOR,
  BLUE_COLOR,
  // Colors.orange,
  // Colors.green,
  // Colors.blue,
  // Colors.purple,
  // Colors.white,
  // Colors.grey,
  // Colors.black,
];

typedef bool CompletionEvaluator(List<GameEvent> events);
typedef int StarEvaluator(List<GameEvent> events);

CompletionEvaluator noopCompletionEvaluator = (_) => false;
StarEvaluator dummyStarEvaluator = (_) => 2;
CompletionEvaluator timeFinishedEvaluator = (events) =>
    events.any((element) => element.type == GameEventType.TIMER_FINISHED);

CompletionEvaluator boardFullFinishedEvaluator = (events) =>
    events.any((element) => element.type == GameEventType.BOARD_FULL);

StarEvaluator pointStarEvaluator({int? threeStar, int? twoStar, int? oneStar}) {
  return (List<GameEvent> events) {
    int score = calculateFinalScore(events);
    if (threeStar != null && score > threeStar) {
      return 3;
    } else if (twoStar != null && score > twoStar) {
      return 2;
    } else if (oneStar != null && score > oneStar) {
      return 1;
    }
    return 0;
  };
}

CompletionEvaluator moveCompletionEvaluator(int moveLimit) {
  return (List<GameEvent> events) {
    int numMoves =
        events.where((event) => event.type == GameEventType.USER_MOVE).length;
    return numMoves > moveLimit;
  };
}

StarEvaluator moveStarEvaluator({int? threeStar, int? twoStar, int? oneStar}) {
  return (List<GameEvent> events) {
    int numMoves =
        events.where((event) => event.type == GameEventType.USER_MOVE).length;
    if (threeStar != null && numMoves <= threeStar) {
      return 3;
    } else if (twoStar != null && numMoves <= twoStar) {
      return 2;
    } else if (oneStar != null && numMoves <= oneStar) {
      return 1;
    }
    return 0;
  };
}

ColorGameConfig gravitizePerMoveLevel = ColorGameConfig(
  "level_16",
  goalString:
      "This level is actually on Jupiter. As a result, gravity can't be contained.",
  gridSize: Size(6, 6),
  // predefinedGrid: generateGameBoxes(colors: COLORS, size: 4),
  completionEvaluator: noopCompletionEvaluator,
  starEvaluator: pointStarEvaluator(threeStar: 200, twoStar: 150, oneStar: 100),
  gravitizeAfterEveryMove: true,
);

List<ColorGameConfig> levels = [
  ColorGameConfig(
    "tut_1",
    goalString: "Make a run of 3.",
    gridSize: Size(3, 3),
    predefinedGrid: [
      GameBox(Offset(-1, 0), YELLOW_COLOR),
      GameBox(Offset(0, 1), YELLOW_COLOR),
      GameBox(Offset(1, 0), YELLOW_COLOR),
    ],
    completionEvaluator: noopCompletionEvaluator,
    starEvaluator: pointStarEvaluator(threeStar: 2),
  ),
  ColorGameConfig(
    "tut_2",
    goalString: "Make a run of 5.",
    gridSize: Size(5, 5),
    predefinedGrid: [
      GameBox(Offset(-2, 0), YELLOW_COLOR),
      GameBox(Offset(-1, 0), YELLOW_COLOR),
      GameBox(Offset(0, 1), YELLOW_COLOR),
      GameBox(Offset(1, 0), YELLOW_COLOR),
      GameBox(Offset(2, 0), YELLOW_COLOR),
    ],
    completionEvaluator: noopCompletionEvaluator,
    starEvaluator: pointStarEvaluator(threeStar: 35),
  ),
  ColorGameConfig(
    "tut_3",
    goalString: "You are rewarded handsomely for multiples.",
    gridSize: Size(5, 5),
    predefinedGrid: [
      GameBox(Offset(-2, 0), YELLOW_COLOR),
      GameBox(Offset(-1, 0), YELLOW_COLOR),
      GameBox(Offset(0, 1), YELLOW_COLOR),
      GameBox(Offset(1, 0), YELLOW_COLOR),
      GameBox(Offset(2, 0), YELLOW_COLOR),
      GameBox(Offset(-2, 1), BLUE_COLOR),
      GameBox(Offset(-1, 1), BLUE_COLOR),
      GameBox(Offset(0, 2), BLUE_COLOR),
      GameBox(Offset(1, 1), BLUE_COLOR),
      GameBox(Offset(2, 1), BLUE_COLOR),
      GameBox(Offset(-2, -1), RED_COLOR),
      GameBox(Offset(-1, -1), RED_COLOR),
      GameBox(Offset(0, 0), RED_COLOR),
      GameBox(Offset(1, -1), RED_COLOR),
      GameBox(Offset(2, -1), RED_COLOR),
      GameBox(Offset(-2, -2), GREEN_COLOR),
      GameBox(Offset(-1, -2), GREEN_COLOR),
      GameBox(Offset(0, -1), GREEN_COLOR),
      GameBox(Offset(1, -2), GREEN_COLOR),
      GameBox(Offset(2, -2), GREEN_COLOR),
    ],
    completionEvaluator: noopCompletionEvaluator,
    starEvaluator: pointStarEvaluator(threeStar: 575),
  ),
  ColorGameConfig(
    "tut_4",
    goalString: "Learn about the magic of quads.",
    gridSize: Size(6, 6),
    predefinedGrid: [
      GameBox(Offset(-2.5, -2.5), RED_COLOR),
      GameBox(Offset(2.5, 2.5), RED_COLOR),
      GameBox(Offset(-2.5, 2.5), RED_COLOR),
      GameBox(Offset(2.5, -2.5), RED_COLOR),
      GameBox(Offset(-1.5, -.5), RED_COLOR),
      GameBox(Offset(-.5, .5), RED_COLOR),
      GameBox(Offset(.5, .5), RED_COLOR),
      GameBox(Offset(-.5, -.5), RED_COLOR),
    ],
    completionEvaluator: noopCompletionEvaluator,
    starEvaluator: pointStarEvaluator(threeStar: 24),
  ),
  ColorGameConfig(
    "tut_5",
    goalString:
        "After runs or quads, the boxes collapse inward (generally...).",
    gridSize: Size(6, 6),
    predefinedGrid: [
      GameBox(Offset(-3.5, -3.5), BLUE_COLOR),
      GameBox(Offset(3.5, 3.5), BLUE_COLOR),
      GameBox(Offset(-3.5, 3.5), BLUE_COLOR),
      GameBox(Offset(3.5, -3.5), BLUE_COLOR),
      GameBox(Offset(-2.5, -2.5), YELLOW_COLOR),
      GameBox(Offset(2.5, 2.5), YELLOW_COLOR),
      GameBox(Offset(-2.5, 2.5), YELLOW_COLOR),
      GameBox(Offset(2.5, -2.5), YELLOW_COLOR),
      GameBox(Offset(-1.5, -1.5), GREEN_COLOR),
      GameBox(Offset(1.5, 1.5), GREEN_COLOR),
      GameBox(Offset(-1.5, 1.5), GREEN_COLOR),
      GameBox(Offset(1.5, -1.5), GREEN_COLOR),
      GameBox(Offset(-1.5, -.5), RED_COLOR),
      GameBox(Offset(-.5, .5), RED_COLOR),
      GameBox(Offset(.5, .5), RED_COLOR),
      GameBox(Offset(-.5, -.5), RED_COLOR),
    ],
    completionEvaluator: noopCompletionEvaluator,
    starEvaluator: pointStarEvaluator(threeStar: 24),
  ),
  ColorGameConfig(
    "level_6",
    goalString: "Take your time. Disappear the boxes. Get some points.",
    completionEvaluator: noopCompletionEvaluator,
    starEvaluator:
        pointStarEvaluator(threeStar: 200, twoStar: 100, oneStar: 50),
  ),
  ColorGameConfig(
    "level_7",
    goalString: "Sometimes, you only have a few moves.",
    gridSize: Size(6, 6),
    predefinedGrid: [
      GameBox(Offset(-1.5, -1.5), GREEN_COLOR),
      GameBox(Offset(1.5, 1.5), GREEN_COLOR),
      GameBox(Offset(-1.5, 1.5), GREEN_COLOR),
      GameBox(Offset(1.5, -1.5), GREEN_COLOR),
    ],
    completionEvaluator: moveCompletionEvaluator(30),
    moveLimit: 30,
    starEvaluator: moveStarEvaluator(threeStar: 5, twoStar: 15, oneStar: 30),
  ),
  ColorGameConfig(
    "level_9",
    goalString: "Sometimes, you only have a few seconds.",
    gridSize: Size(5, 5),
    predefinedGrid: [
      GameBox(Offset(0, -1), GREEN_COLOR),
      GameBox(Offset(1, -2), GREEN_COLOR),
      GameBox(Offset(2, -2), GREEN_COLOR),
    ],
    completionEvaluator: timeFinishedEvaluator,
    starEvaluator: (List<GameEvent> events) =>
        events.any((element) => element.type == GameEventType.TIMER_FINISHED)
            ? 0
            : 3,
    timerSpec: TimerSpec(numberOfSeconds: 60),
  ),
  ColorGameConfig(
    "level_10",
    goalString: "Have I been here before?",
    gridSize: Size(6, 6),
    predefinedGrid: [
      GameBox(Offset(-2.5, -2.5), RED_COLOR),
      GameBox(Offset(2.5, 2.5), RED_COLOR),
      GameBox(Offset(-2.5, 2.5), RED_COLOR),
      GameBox(Offset(2.5, -2.5), RED_COLOR),
    ],
    completionEvaluator: moveCompletionEvaluator(30),
    moveLimit: 30,
    starEvaluator: moveStarEvaluator(threeStar: 5, twoStar: 15, oneStar: 30),
  ),
  ColorGameConfig(
    "level_11",
    goalString: "Hmm... Are more boxes supposed to be showing up?",
    gridSize: Size(7, 7),
    predefinedGrid: generateGameBoxes(colors: COLORS, size: 5),
    completionEvaluator: timeFinishedEvaluator,
    starEvaluator: (List<GameEvent> events) => events
            .any((element) => element.type == GameEventType.NO_MOVES)
        ? pointStarEvaluator(threeStar: 200, twoStar: 150, oneStar: 100)(events)
        : 0,
    boxAddingSpec: BoxAddingSpec(
        behavior: BoxAddingBehavior.PER_MOVE, addBoxEveryNMoves: 1),
    timerSpec: TimerSpec(numberOfSeconds: 60),
  ),
  ColorGameConfig("level_12",
      goalString: "This doesn't look good...",
      gridSize: Size(7, 7),
      predefinedGrid: generateGameBoxes(colors: COLORS, size: 5),
      completionEvaluator: boardFullFinishedEvaluator,
      starEvaluator:
          pointStarEvaluator(threeStar: 200, twoStar: 150, oneStar: 100),
      boxAddingSpec: BoxAddingSpec(
        behavior: BoxAddingBehavior.PER_TIME,
        boxAddingPeriod: Duration(seconds: 1),
        boxAddingAcceleration: .00001,
      )),
  immovable(),
  undraggable(),
  ColorGameConfig(
    "blocked",
    goalString: "You're penned in!",
    gridSize: Size(6, 6),
    predefinedGrid: [
      ...generateGameBoxes(colors: COLORS, size: 6),
      ...getImmovableBorder()
    ],
    completionEvaluator: noopCompletionEvaluator,
    starEvaluator: pointStarEvaluator(threeStar: 24),
  ),
];

const String ANDROID_BANNER_AD_UNIT_ID =
    "ca-app-pub-1235186580185107/8452878897";
const String IOS_BANNER_AD_UNIT_ID = "ca-app-pub-1235186580185107/4021026902";

ThemeData colorCollapseTheme = ThemeData(
  // Define the default font family.
  fontFamily: 'Lato',

  // Define the default TextTheme. Use this to specify the default
  // text styling for headlines, titles, bodies of text, and more.
  textTheme: TextTheme(
    headline1: TextStyle(
        fontSize: 64.0, fontWeight: FontWeight.bold, color: Colors.white),
    headline2: TextStyle(
        fontSize: 32.0,
        fontWeight: FontWeight.bold,
        color: BOARD_BACKGROUND_COLOR),
    bodyText1: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
        color: BOARD_BACKGROUND_COLOR),
  ),
);
