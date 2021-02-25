import 'package:flutter/widgets.dart';

import 'animated-score.dart';

class Hud extends StatelessWidget {
  final int score;
  const Hud({Key key, this.score}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [AnimatedScore(score: score)],
    );
  }
}
