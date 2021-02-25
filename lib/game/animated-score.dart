import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AnimatedScore extends StatefulWidget {
  final int score;
  AnimatedScore({Key key, this.score}) : super(key: key);

  @override
  _AnimatedScoreState createState() => _AnimatedScoreState();
}

class _AnimatedScoreState extends State<AnimatedScore>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  int prevScore = 0;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
  }

  @override
  void didUpdateWidget(AnimatedScore oldWidget) {
    super.didUpdateWidget(oldWidget);
    prevScore = oldWidget.score;
    controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return Text(
              "${((widget.score - prevScore) * controller.value + prevScore).round()}",
              style: TextStyle(
                  color: Colors.grey[200], decoration: TextDecoration.none));
        });
  }
}
