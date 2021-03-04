import 'dart:math';
import 'dart:ui';

import 'package:color_game/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../shared-pref-helper.dart';
import 'game-board.dart';
import 'hud.dart';
import '../model.dart';

class InvertedRectClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double boxSize = size.shortestSide / GRID_SIZE;
    return new Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: new Offset(size.width / 2, size.height / 2),
              width: size.shortestSide * .9,
              height: size.shortestSide * .9),
          Radius.circular(BOX_BORDER_RADIUS * boxSize)))
      ..addRect(new Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class GameView extends StatefulWidget {
  final ColorGameConfig? config;
  GameView({Key? key, this.config}) : super(key: key);

  @override
  _GameViewState createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  int score = 0;
  bool gameOver = false;
  Tween<int>? scoreTween;
  Key gameKey = UniqueKey();

  List<Score> highScores = [];

  @override
  void initState() {
    super.initState();
    getScores().then((scores) {
      this.highScores = scores;
      this.highScores.sort((a, b) => b.score!.compareTo(a.score!));
    });
  }

  void _handleNewRun(RunEventMetadata? metadata) {
    setState(() {
      score += pow(metadata!.runLength, metadata.runStreakLength) * metadata.multiples as int;
    });
  }

  void _handleNewSquare(SquareEventMetadata? metadata) {
    setState(() {
      score += 25;
    });
  }

  String _getAgoString(DateTime date) {
    DateTime now = DateTime.now();
    var delta = Duration(milliseconds: now.millisecondsSinceEpoch - date.millisecondsSinceEpoch);
    if (delta.inDays > 365) {
      int numYears = (delta.inDays / 365).round();
      return "${numYears} ${numYears == 1 ? "year" : "years"} ago";
    } else if (delta.inDays > 30) {
      int numMonths = (delta.inDays / 30).round();
      return "${numMonths} ${numMonths == 1 ? "month" : "months"} ago";
    } else if (delta.inDays > 7) {
      int numWeeks = (delta.inDays / 7).round();
      return "${numWeeks} ${numWeeks == 1 ? "week" : "weeks"} ago";
    } else if (delta.inDays > 0) {
      int numDays = delta.inDays;
      return "${numDays} ${numDays == 1 ? "day" : "days"} ago";
    } else if (delta.inHours > 0) {
      return "${delta.inHours} ${delta.inHours == 1 ? "hour" : "hours"} ago";
    } else if (delta.inMinutes > 0) {
      return "${delta.inMinutes} ${delta.inMinutes == 1 ? "minute" : "minutes"} ago";
    } else if (delta.inSeconds > 30) {
      return "${delta.inSeconds} minutes ago";
    } else {
      return "just now";
    }
  }

  @override
  Widget build(BuildContext context) {
    double boxSize = (MediaQuery.of(context).size.shortestSide * .9) / GRID_SIZE;
    List<Widget> stackChildren = [
      AspectRatio(
        aspectRatio: 1,
        child: FractionallySizedBox(
          heightFactor: .9,
          widthFactor: .9,
          child: Center(
              child: Container(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(BOX_BORDER_RADIUS * boxSize), boxShadow: [
            BoxShadow(
              color: Color(0xff404040),
            ),
            BoxShadow(
              color: BOARD_BACKGROUND_COLOR,
              spreadRadius: -5,
              blurRadius: 10,
            )
          ]))),
        ),
      ),
      AspectRatio(
        aspectRatio: 1,
        child: FractionallySizedBox(
          heightFactor: .9,
          widthFactor: .9,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: GameBoardWidget(
                key: gameKey,
                config: widget.config,
                onGameEvent: (GameEvent e) {
                  switch (e.type) {
                    case GameEventType.RUN:
                      _handleNewRun(e.metadata);
                      break;
                    case GameEventType.SQUARE:
                      _handleNewSquare(e.metadata);
                      break;
                    case GameEventType.NO_MOVES:
                      setState(() {
                        gameOver = true;
                      });
                      break;
                    case GameEventType.LEFT_OVER_BOX:
                      setState(() {
                        score = (score * .9).round();
                      });
                      break;
                  }
                }),
          ),
        ),
      ),
      ClipPath(
        clipper: InvertedRectClipper(),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 5,
            sigmaY: 5,
          ),
          child: Container(
            color: Colors.transparent,
          ),
        ),
      ),
      ClipPath(
        clipper: InvertedRectClipper(),
        child: Opacity(
          opacity: .1,
          child: Container(
            color: Colors.black,
          ),
        ),
      ),
      Positioned.fill(child: Hud(score: score)),
    ];

    if (gameOver) {
      stackChildren.add(Center(
          child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: IntrinsicHeight(
            child: Column(
              children: [
                Text(
                  "Your High Scores",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline4,
                ),
                SizedBox(height: 20),
                Flexible(
                    child: Column(
                        children: highScores
                            .map((score) => Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text("${score.score}"),
                                    SizedBox(width: 20),
                                    Text("(${_getAgoString(score.date)})",
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey[800], fontStyle: FontStyle.italic))
                                  ],
                                ))
                            .toList())),
                SizedBox(height: 20),
                ElevatedButton(
                    child: Text("New Game"),
                    onPressed: () {
                      addScore(score).then((_) {
                        getScores().then((scores) {
                          setState(() {
                            this.highScores = [...scores];
                            this.highScores.sort((a, b) => b.score!.compareTo(a.score!));
                          });
                        });
                      });
                      setState(() {
                        gameOver = false;
                        gameKey = UniqueKey();
                        score = 0;
                      });
                    }),
              ],
            ),
          ),
        ),
      )));
    }
    return Container(
      color: BOARD_BACKGROUND_COLOR,
      child: SafeArea(
        child: Stack(alignment: Alignment.center, children: stackChildren),
      ),
    );
  }
}
