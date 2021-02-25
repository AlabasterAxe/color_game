import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'game-board.dart';
import 'hud.dart';
import '../model.dart';

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
      score += pow(metadata.runLength, metadata.multiples) *
          metadata.runStreakLength;
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
