import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'game.dart';
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
  @override
  Widget build(BuildContext context) {
    return Stack(
        children: [Positioned.fill(child: GameWidget(config: widget.config))]);
  }
}
