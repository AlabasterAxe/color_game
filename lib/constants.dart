import 'dart:ui';

import 'package:flutter/material.dart';

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

CompletionEvaluator noopCompletionEvaluator = (_) => false;
CompletionEvaluator timeFinishedEvaluator = (events) =>
    events.any((element) => element.type == GameEventType.TIMER_FINISHED);

CompletionEvaluator runCompletionEvaluator =
    (events) => events.any((element) => element.type == GameEventType.RUN);

CompletionEvaluator boardFullFinishedEvaluator = (events) =>
    events.any((element) => element.type == GameEventType.BOARD_FULL);

class PointStarEvaluator implements StarEvaluator {
  // It always must be possible to achieve 3 stars.
  final int threeStar;
  final int? twoStar;
  final int? oneStar;

  PointStarEvaluator({required this.threeStar, this.twoStar, this.oneStar});
  int call(List<GameEvent> events) {
    int score = calculateFinalScore(events);
    if (score >= threeStar) {
      return 3;
    } else if (twoStar != null && score >= twoStar!) {
      return 2;
    } else if (oneStar != null && score >= oneStar!) {
      return 1;
    }
    return 0;
  }
}

class MoveStarEvaluator implements StarEvaluator {
  final int threeStar;
  final int? twoStar;
  final int? oneStar;

  MoveStarEvaluator({required this.threeStar, this.twoStar, this.oneStar});

  int call(List<GameEvent> events) {
    int numMoves =
        events.where((event) => event.type == GameEventType.USER_MOVE).length;
    if (numMoves <= threeStar) {
      return 3;
    } else if (twoStar != null && numMoves <= twoStar!) {
      return 2;
    } else if (oneStar != null && numMoves <= oneStar!) {
      return 1;
    }
    return 0;
  }
}

class ConditionalPointStarEvaluator implements StarEvaluator {
  final int threeStar;
  final int? twoStar;
  final int? oneStar;
  final GameEventType forbiddenEventType;

  ConditionalPointStarEvaluator(
      {required this.threeStar,
      this.twoStar,
      this.oneStar,
      required this.forbiddenEventType});

  @override
  int call(List<GameEvent> events) {
    int starValue = PointStarEvaluator(
        threeStar: threeStar, twoStar: twoStar, oneStar: oneStar)(events);
    for (GameEvent e in events) {
      if (e.type == this.forbiddenEventType) {
        return 0;
      } else if (e.type == GameEventType.NO_MOVES) {
        return starValue;
      }
    }
    return starValue;
  }
}

CompletionEvaluator moveCompletionEvaluator(int moveLimit) {
  return (List<GameEvent> events) {
    int numMoves =
        events.where((event) => event.type == GameEventType.USER_MOVE).length;
    return numMoves >= moveLimit;
  };
}

ColorGameConfig generateCrossLevel() {
  List<GameBox> boxes = generateGameBoxes(colors: COLORS, size: 6);
  GameBox box = boxes.removeAt(0);
  boxes.insert(
      0, GameBox(box.loc, Colors.black, attributes: IMMOVABLE_BOX_ATTRIBUTES));
  box = boxes.removeAt(1);
  boxes.insert(
      1, GameBox(box.loc, Colors.black, attributes: IMMOVABLE_BOX_ATTRIBUTES));
  box = boxes.removeAt(4);
  boxes.insert(
      4, GameBox(box.loc, Colors.black, attributes: IMMOVABLE_BOX_ATTRIBUTES));
  box = boxes.removeAt(5);
  boxes.insert(
      5, GameBox(box.loc, Colors.black, attributes: IMMOVABLE_BOX_ATTRIBUTES));
  box = boxes.removeAt(6);
  boxes.insert(
      6, GameBox(box.loc, Colors.black, attributes: IMMOVABLE_BOX_ATTRIBUTES));
  box = boxes.removeAt(7);
  boxes.insert(
      7, GameBox(box.loc, Colors.black, attributes: IMMOVABLE_BOX_ATTRIBUTES));
  box = boxes.removeAt(10);
  boxes.insert(
      10, GameBox(box.loc, Colors.black, attributes: IMMOVABLE_BOX_ATTRIBUTES));
  box = boxes.removeAt(11);
  boxes.insert(
      11, GameBox(box.loc, Colors.black, attributes: IMMOVABLE_BOX_ATTRIBUTES));
  box = boxes.removeAt(24);
  boxes.insert(
      24, GameBox(box.loc, Colors.black, attributes: IMMOVABLE_BOX_ATTRIBUTES));
  box = boxes.removeAt(25);
  boxes.insert(
      25, GameBox(box.loc, Colors.black, attributes: IMMOVABLE_BOX_ATTRIBUTES));
  box = boxes.removeAt(28);
  boxes.insert(
      28, GameBox(box.loc, Colors.black, attributes: IMMOVABLE_BOX_ATTRIBUTES));
  box = boxes.removeAt(29);
  boxes.insert(
      29, GameBox(box.loc, Colors.black, attributes: IMMOVABLE_BOX_ATTRIBUTES));
  box = boxes.removeAt(30);
  boxes.insert(
      30, GameBox(box.loc, Colors.black, attributes: IMMOVABLE_BOX_ATTRIBUTES));
  box = boxes.removeAt(31);
  boxes.insert(
      31, GameBox(box.loc, Colors.black, attributes: IMMOVABLE_BOX_ATTRIBUTES));
  box = boxes.removeAt(34);
  boxes.insert(
      34, GameBox(box.loc, Colors.black, attributes: IMMOVABLE_BOX_ATTRIBUTES));
  box = boxes.removeAt(35);
  boxes.insert(
      35, GameBox(box.loc, Colors.black, attributes: IMMOVABLE_BOX_ATTRIBUTES));
  return ColorGameConfig(
    "level_22",
    goalString: "This level's a cross. Why? Nobody knows.",
    gridSize: Size(6, 6),
    predefinedGrid: boxes,
    completionEvaluator: noopCompletionEvaluator,
    starEvaluator: PointStarEvaluator(threeStar: 75, twoStar: 50, oneStar: 40),
  );
}

List<ColorGameConfig> levels = [
  ColorGameConfig("tut_1",
      goalString: "Drag the middle column up to make a run of 3.",
      gridSize: Size(3, 3),
      predefinedGrid: [
        GameBox(Offset(-1, 0), YELLOW_COLOR),
        GameBox(Offset(0, 1), YELLOW_COLOR),
        GameBox(Offset(1, 0), YELLOW_COLOR),
      ],
      completionEvaluator: noopCompletionEvaluator,
      starEvaluator: PointStarEvaluator(threeStar: 3),
      goalBoard: [
        GameBox(Offset(-1, 0), YELLOW_COLOR),
        GameBox(Offset(0, 0), YELLOW_COLOR),
        GameBox(Offset(1, 0), YELLOW_COLOR),
      ]),
  ColorGameConfig(
    "tut_2",
    goalString: "Drag the middle row to the right to make a run of 5.",
    gridSize: Size(5, 5),
    predefinedGrid: [
      GameBox(Offset(0, -2), YELLOW_COLOR),
      GameBox(Offset(0, -1), YELLOW_COLOR),
      GameBox(Offset(1, 0), YELLOW_COLOR),
      GameBox(Offset(0, 1), YELLOW_COLOR),
      GameBox(Offset(0, 2), YELLOW_COLOR),
    ],
    completionEvaluator: noopCompletionEvaluator,
    starEvaluator: PointStarEvaluator(threeStar: 5),
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
    starEvaluator: PointStarEvaluator(threeStar: 80),
  ),
  ColorGameConfig(
    "tut_4",
    goalString:
        "Making a 2x2 grid (or \"quad\") of a single color clears all the boxes of that color.",
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
    starEvaluator: PointStarEvaluator(threeStar: 25),
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
    starEvaluator: PointStarEvaluator(threeStar: 25),
  ),
  ColorGameConfig(
    "level_6",
    goalString: "Take your time. Disappear the boxes. Get some points.",
    completionEvaluator: noopCompletionEvaluator,
    starEvaluator:
        PointStarEvaluator(threeStar: 200, twoStar: 100, oneStar: 50),
  ),
  ColorGameConfig(
    "level_7",
    goalString: "Make a green quad in 15 moves or less.",
    gridSize: Size(6, 6),
    predefinedGrid: [
      GameBox(Offset(-1.5, -1.5), GREEN_COLOR,
          attributes: [GameBoxAttribute.UNRUNNABLE]),
      GameBox(Offset(1.5, 1.5), GREEN_COLOR,
          attributes: [GameBoxAttribute.UNRUNNABLE]),
      GameBox(Offset(-1.5, 1.5), GREEN_COLOR,
          attributes: [GameBoxAttribute.UNRUNNABLE]),
      GameBox(Offset(1.5, -1.5), GREEN_COLOR,
          attributes: [GameBoxAttribute.UNRUNNABLE]),
    ],
    completionEvaluator: moveCompletionEvaluator(15),
    moveLimit: 15,
    starEvaluator: MoveStarEvaluator(threeStar: 5, twoStar: 10, oneStar: 14),
  ),
  ColorGameConfig(
    "level_10",
    goalString: "Have I been here before?",
    gridSize: Size(6, 6),
    predefinedGrid: [
      GameBox(Offset(-2.5, -2.5), RED_COLOR,
          attributes: [GameBoxAttribute.UNRUNNABLE]),
      GameBox(Offset(2.5, 2.5), RED_COLOR,
          attributes: [GameBoxAttribute.UNRUNNABLE]),
      GameBox(Offset(-2.5, 2.5), RED_COLOR,
          attributes: [GameBoxAttribute.UNRUNNABLE]),
      GameBox(Offset(2.5, -2.5), RED_COLOR,
          attributes: [GameBoxAttribute.UNRUNNABLE]),
    ],
    completionEvaluator: moveCompletionEvaluator(30),
    moveLimit: 30,
    starEvaluator: MoveStarEvaluator(threeStar: 5, twoStar: 15, oneStar: 29),
  ),
  ColorGameConfig(
    "level_11",
    goalString: "Hmm... Are more boxes supposed to be showing up?",
    gridSize: Size(7, 7),
    predefinedGrid: generateGameBoxes(colors: COLORS, size: 5),
    completionEvaluator: timeFinishedEvaluator,
    starEvaluator: ConditionalPointStarEvaluator(
        threeStar: 200,
        twoStar: 150,
        oneStar: 100,
        forbiddenEventType: GameEventType.TIMER_FINISHED),
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
          PointStarEvaluator(threeStar: 200, twoStar: 150, oneStar: 100),
      boxAddingSpec: BoxAddingSpec(
        behavior: BoxAddingBehavior.PER_TIME,
        boxAddingPeriod: Duration(seconds: 1),
        boxAddingAcceleration: .00001,
      )),
  undraggable(),
  immovable(),
  ColorGameConfig(
    "level_15",
    goalString: "You're penned in!",
    gridSize: Size(6, 6),
    predefinedGrid: [
      ...generateGameBoxes(colors: COLORS, size: 6),
      ...getImmovableBorder()
    ],
    completionEvaluator: noopCompletionEvaluator,
    starEvaluator: PointStarEvaluator(threeStar: 24),
  ),
  ColorGameConfig(
    "level_17",
    goalString: "I guess most of these aren't really goals...",
    gridSize: Size(6, 6),
    predefinedGrid: [
      ...generateGameBoxes(colors: [...COLORS, Colors.orange], size: 6),
    ],
    completionEvaluator: noopCompletionEvaluator,
    starEvaluator: PointStarEvaluator(threeStar: 24),
  ),
  ColorGameConfig(
    "level_20",
    goalString:
        "This one is definitely a goal though! Get more than 100 points in under 10 moves.",
    gridSize: Size(6, 6),
    predefinedGrid: [
      ...generateGameBoxes(colors: COLORS, size: 6),
    ],
    completionEvaluator: moveCompletionEvaluator(10),
    moveLimit: 10,
    starEvaluator: PointStarEvaluator(threeStar: 100),
  ),
  generateCrossLevel(),
  ColorGameConfig(
    "level_23",
    goalString:
        "No runs allowed! We've turned off gravity because we're only mostly heartless.",
    gridSize: Size(6, 6),
    predefinedGrid: [
      ...generateGameBoxes(
          colors: COLORS,
          size: 6,
          attributes: [GameBoxAttribute.UNGRAVITIZABLE]),
    ],
    completionEvaluator: runCompletionEvaluator,
    starEvaluator: ConditionalPointStarEvaluator(
        forbiddenEventType: GameEventType.RUN, threeStar: 0),
  ),
  ColorGameConfig(
    "level_25",
    goalString:
        "Get 1000 points! All or nothing. It's definitely probably possible.",
    completionEvaluator: noopCompletionEvaluator,
    starEvaluator: PointStarEvaluator(threeStar: 1000),
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
