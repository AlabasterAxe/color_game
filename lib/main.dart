import 'package:flutter/material.dart';

import 'game.dart';
import 'hud.dart';
import 'model.dart';

const RELATIVE_GAP_SIZE = 1 / 12;
const GRID_SIZE = 6;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  final ColorGameConfig config = ColorGameConfig()..gridSize = Size(6, 6);
  GamePage({Key key}) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int score = 0;
  Tween<int> scoreTween;

  void _handleNewRun(RunEventMetadata metadata) {
    setState(() {
      if (metadata.runLength == 3) {
        score += 100;
      } else if (metadata.runLength == 4) {
        score += 200;
      } else {
        score += 400;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(children: [
        Positioned.fill(
            child: GameWidget(
                config: widget.config,
                onGameEvent: (GameEvent e) {
                  switch (e.type) {
                    case GameEventType.RUN:
                      _handleNewRun(e.metadata);
                  }
                })),
        Positioned.fill(child: Hud(score: score)),
      ]),
    );
  }
}
