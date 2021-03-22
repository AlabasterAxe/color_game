import 'dart:math';
import 'dart:ui';

import 'package:color_game/constants.dart';
import 'package:color_game/services/analytics-service.dart';
import 'package:color_game/services/audio-service.dart';
import 'package:color_game/widgets/circular-timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../main.dart';
import '../model.dart';
import '../shared-pref-helper.dart';
import 'game-board.dart';
import 'hud.dart';

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
  final ColorGameConfig config;
  GameView({Key? key, required this.config}) : super(key: key);

  @override
  _GameViewState createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  int score = 0;
  int? movesLeft;
  bool gameOver = false;
  int? earnedStars;
  Tween<int>? scoreTween;
  Key gameKey = UniqueKey();
  List<GameEvent> events = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      movesLeft = widget.config.moveLimit;
    });
  }

  void _handleNewRun(RunEventMetadata metadata) {
    AppContext.of(context)
        .audioService
        .playSoundEffect(SoundEffectType.UKULELE);
    setState(() {
      score += pow(metadata.runLength, metadata.runStreakLength) *
          metadata.multiples as int;
    });
  }

  void _handleNewSquare(SquareEventMetadata metadata) {
    AppContext.of(context)
        .audioService
        .playSoundEffect(SoundEffectType.LARGE_POOF);
    setState(() {
      score += 25;
    });
  }

  Widget _createHud() {
    Widget? timerWidget;
    if (widget.config.timerSpec != null) {
      TimerSpec spec = widget.config.timerSpec!;
      timerWidget = Container(
          width: 60,
          height: 60,
          child: CircularTimer(
              key: spec.key,
              duration: Duration(seconds: spec.numberOfSeconds),
              stop: gameOver,
              onFinished: () {
                _handleGameEvent(GameEvent(GameEventType.TIMER_FINISHED));
              }));
    }
    return Hud(
      numberOfStars: widget.config.starEvaluator(events),
      score: movesLeft ?? score,
      timerWidget: timerWidget,
    );
  }

  void _doGameOver() {
    earnedStars = widget.config.starEvaluator(events);
    AppContext.of(context).analytics.logEvent(AnalyticsEvent.finish_game);
    addScore(
        levelTag: widget.config.label, score: score, earnedStars: earnedStars!);
    setState(() {
      gameOver = true;
    });
  }

  void _handleGameEvent(GameEvent e) {
    events.add(e);
    if (widget.config.completionEvaluator(events)) {
      _doGameOver();
    }
    switch (e.type) {
      case GameEventType.RUN:
        _handleNewRun(e.metadata);
        break;
      case GameEventType.SQUARE:
        _handleNewSquare(e.metadata);
        break;
      case GameEventType.NO_MOVES:
        _doGameOver();
        break;
      case GameEventType.LEFT_OVER_BOX:
        setState(() {
          score = (score * .9).round();
        });
        break;
      case GameEventType.USER_MOVE:
        if (movesLeft != null) {
          setState(() {
            movesLeft = movesLeft! - 1;
          });
        }
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    Size screenSize = mediaQueryData.size;
    double boxSize = (screenSize.shortestSide * .9) / GRID_SIZE;
    List<Widget> stackChildren = [
      AspectRatio(
        aspectRatio: 1,
        child: FractionallySizedBox(
          heightFactor: .9,
          widthFactor: .9,
          child: Center(
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(BOX_BORDER_RADIUS * boxSize),
                      boxShadow: [
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
            child: GameBoardWidget(widget.config,
                key: gameKey, onGameEvent: _handleGameEvent),
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
      Positioned.fill(child: _createHud()),
    ];

    if (gameOver) {
      stackChildren.add(Card(
          shape: CARD_SHAPE,
          elevation: 4,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset(
                          "assets/images/${earnedStars != null && earnedStars! > 0 ? "gold_star" : "star"}.png"),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset(
                          "assets/images/${earnedStars != null && earnedStars! > 1 ? "gold_star" : "star"}.png"),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset(
                          "assets/images/${earnedStars != null && earnedStars! > 2 ? "gold_star" : "star"}.png"),
                    ),
                  ]),
              ElevatedButton(
                  child: Text("Back"),
                  onPressed: () {
                    Navigator.pop(
                        context,
                        GameCompletedEvent(
                            earnedStars != null && earnedStars! > 0));
                  }),
            ],
          )));
    }

    return Container(
      color: BOARD_BACKGROUND_COLOR,
      child: SafeArea(
        child:
            // Stack(children: [
            Stack(alignment: Alignment.center, children: stackChildren),
        //   Positioned(left: 0, right: 0, bottom: 0, child: BannerAdWidget())
        // ]),
      ),
    );
  }
}
