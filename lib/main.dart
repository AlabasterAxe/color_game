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
  bool gameOver = false;
  Tween<int> scoreTween;
  Key gameKey = UniqueKey();

  void _handleNewRun(RunEventMetadata metadata) {
    setState(() {
      if (metadata.runLength == 3) {
        score += 100 * metadata.runStreakLength;
      } else if (metadata.runLength == 4) {
        score += 200 * metadata.runStreakLength;
      } else {
        score += 400 * metadata.runStreakLength;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stackChildren = [
      AspectRatio(
        aspectRatio: 1,
        child: GameWidget(
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
