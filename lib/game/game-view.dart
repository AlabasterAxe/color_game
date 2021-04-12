import 'dart:math';
import 'dart:ui';

import 'package:color_game/constants.dart';
import 'package:color_game/services/analytics-service.dart';
import 'package:color_game/services/audio-service.dart';
import 'package:color_game/widgets/banner-ad-widget.dart';
import 'package:color_game/widgets/circular-timer.dart';
import 'package:color_game/widgets/game-end-card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../main.dart';
import '../model.dart';
import '../shared-pref-helper.dart';
import 'game-board.dart';
import 'hud.dart';
import 'sound-game-event-listener.dart';

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
  Key gameKey = UniqueKey();
  List<GameEvent> events = [];
  late SoundGameEventListener soundGameEventListener;

  @override
  void initState() {
    super.initState();
    setState(() {
      movesLeft = widget.config.moveLimit;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    soundGameEventListener =
        SoundGameEventListener(AppContext.of(context).audioService);
  }

  void _handleNewRun(RunEventMetadata metadata) {
    setState(() {
      score += pow(metadata.runLength, metadata.runStreakLength) *
          metadata.multiples! as int;
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
      timerWidget = CircularTimer(
          key: gameKey,
          duration: Duration(seconds: spec.numberOfSeconds),
          stop: gameOver,
          onFinished: () {
            _handleGameEvent(GameEvent(GameEventType.TIMER_FINISHED));
          });
    }
    int? scoreGoal;
    if (widget.config.starEvaluator is PointStarEvaluator) {
      PointStarEvaluator scoreGoals =
          widget.config.starEvaluator as PointStarEvaluator;
      if (scoreGoals.oneStar != null && score < scoreGoals.oneStar!) {
        scoreGoal = scoreGoals.oneStar!;
      } else if (scoreGoals.twoStar != null && score < scoreGoals.twoStar!) {
        scoreGoal = scoreGoals.twoStar!;
      } else {
        scoreGoal = scoreGoals.threeStar;
      }
    }
    return Hud(
      numberOfStars: widget.config.starEvaluator(events),
      score: score,
      timerWidget: timerWidget,
      movesLeft: movesLeft,
      scoreGoal: scoreGoal,
      goalBoard: widget.config.goalBoard,
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
    soundGameEventListener.onGameEvent(e);
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
        child: Opacity(
          opacity: .2,
          child: Container(
            color: Colors.black,
          ),
        ),
      ),
      Positioned.fill(child: _createHud()),
    ];

    if (gameOver) {
      stackChildren.add(GameEndCard(
          earnedStars: earnedStars!,
          onBack: () {
            Navigator.pop(context,
                GameCompletedEvent(earnedStars != null && earnedStars! > 0));
          },
          onRetry: () {
            setState(() {
              this.gameKey = UniqueKey();
              this.score = 0;
              this.movesLeft = widget.config.moveLimit;
              this.gameOver = false;
              this.events.clear();
            });
          }));
    }

    return Scaffold(
        body: Container(
      color: BOARD_BACKGROUND_COLOR,
      child: SafeArea(
        child: Stack(children: [
          Stack(alignment: Alignment.center, children: stackChildren),
          Positioned(left: 0, right: 0, bottom: 0, child: BannerAdWidget())
        ]),
      ),
    ));
  }
}
