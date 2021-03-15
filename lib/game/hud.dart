import 'package:flutter/widgets.dart';

import 'animated-score.dart';

class Hud extends StatelessWidget {
  final int score;
  final Widget? timerWidget;
  const Hud({Key? key, required this.score, this.timerWidget})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];
    if (timerWidget != null) {
      items.add(timerWidget!);
    }
    items.add(AnimatedScore(score: score));
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: items,
    );
  }
}
