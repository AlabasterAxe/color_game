import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'game-board.dart';
import 'hud.dart';
import '../model.dart';

class InvertedRectClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return new Path()
      ..addRect(Rect.fromCenter(
          center: new Offset(size.width / 2, size.height / 2),
          width: size.shortestSide,
          height: size.shortestSide))
      ..addRect(new Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class GameView extends StatefulWidget {
  final ColorGameConfig config;
  GameView({Key key, this.config}) : super(key: key);

  @override
  _GameViewState createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  int score = 0;
  bool gameOver = false;
  Tween<int> scoreTween;
  Key gameKey = UniqueKey();

  void _handleNewRun(RunEventMetadata metadata) {
    setState(() {
      score += pow(metadata.runLength, metadata.runStreakLength) *
          metadata.multiples;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stackChildren = [
      AspectRatio(
        aspectRatio: 1,
        child: GameBoardWidget(
            key: gameKey,
            config: widget.config,
            onGameEvent: (GameEvent e) {
              switch (e.type) {
                case GameEventType.RUN:
                  _handleNewRun(e.metadata);
                  break;
                case GameEventType.NO_MOVES:
                  // TODO: Handle this case.
                  setState(() {
                    gameOver = true;
                  });
                  break;
              }
            }),
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
          child: RaisedButton(
              child: Text("New Game"),
              onPressed: () {
                setState(() {
                  gameOver = false;
                  gameKey = UniqueKey();
                  score = 0;
                });
              })));
    }
    return Container(
      color: Colors.grey[800],
      child: SafeArea(
        child: Stack(alignment: Alignment.center, children: stackChildren),
      ),
    );
  }
}
