import 'dart:math';

import 'package:color_game/widgets/hud-stars-widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../constants.dart';
import '../model.dart';
import 'animated-score.dart';
import 'game-board.dart';

class Hud extends StatelessWidget {
  final int numberOfStars;
  final int score;
  final Widget? timerWidget;
  final int? movesLeft;
  final int? scoreGoal;
  final List<GameBox>? goalBoard;
  const Hud({
    Key? key,
    required this.numberOfStars,
    required this.score,
    this.timerWidget,
    this.movesLeft,
    this.scoreGoal,
    this.goalBoard,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    Widget rightSideWidget = ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.asset(
          "assets/icon/squarified.png",
          width: screenSize.width / 10,
          fit: BoxFit.fitWidth,
        ));
    if (timerWidget != null) {
      rightSideWidget = Container(
          width: screenSize.width / 10,
          height: screenSize.height / 10,
          child: timerWidget!);
    } else if (movesLeft != null) {
      rightSideWidget = Column(
        children: [
          Text(
            "moves left",
            style: TextStyle(
                fontSize: 16, color: Colors.white, fontWeight: FontWeight.w800),
          ),
          Text(
            "$movesLeft",
            style: TextStyle(
                fontSize: 16, color: Colors.white, fontWeight: FontWeight.w800),
          )
        ],
      );
    } else if (scoreGoal != null) {
      rightSideWidget = Column(
        children: [
          Text(
            "next star at",
            style: TextStyle(
                fontSize: 16, color: Colors.white, fontWeight: FontWeight.w800),
          ),
          Text(
            "$scoreGoal",
            style: TextStyle(
                fontSize: 16, color: Colors.white, fontWeight: FontWeight.w800),
          )
        ],
      );
    }

    Widget? goalBoardWidget;
    if (goalBoard != null && goalBoard!.isNotEmpty) {
      double? minX;
      double? maxX;
      double? minY;
      double? maxY;
      for (GameBox box in goalBoard!) {
        if (minX == null || minX > box.loc.dx) {
          minX = box.loc.dx;
        }
        if (maxX == null || maxX < box.loc.dx) {
          maxX = box.loc.dx;
        }
        if (minY == null || minY > box.loc.dy) {
          minY = box.loc.dx;
        }
        if (maxY == null || maxY < box.loc.dy) {
          maxY = box.loc.dy;
        }
      }

      double xDimension = maxX! - minX!;
      double yDimension = maxY! - minY!;
      goalBoardWidget = GameBoardWidget(
          ColorGameConfig("goal",
              goalString: "shouldn't be seen",
              predefinedGrid: goalBoard!,
              gridSize: Size(
                  max(yDimension, xDimension), max(yDimension, xDimension)),
              completionEvaluator: (_) => false,
              starEvaluator: PointStarEvaluator(threeStar: 0)),
          onGameEvent: (_) {});
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                      child: HudStarsWidget(
                    numberOfStars: numberOfStars,
                    starWidth: screenSize.width / 12,
                  )),
                  goalBoardWidget != null
                      ? Expanded(
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                          Text(
                            "goal",
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w800),
                          ),
                          Flexible(
                            child: Center(
                              child: FractionallySizedBox(
                                  widthFactor: .3,
                                  child: AspectRatio(
                                      aspectRatio: 1, child: goalBoardWidget)),
                            ),
                          )
                        ]))
                      : Expanded(child: AnimatedScore(score: score)),
                  Expanded(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [rightSideWidget]))
                ]))
      ],
    );
  }
}
