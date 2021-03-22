import 'package:color_game/widgets/hud-stars-widget.dart';
import 'package:flutter/widgets.dart';

import 'animated-score.dart';

class Hud extends StatelessWidget {
  final int numberOfStars;
  final int score;
  final Widget? timerWidget;
  const Hud(
      {Key? key,
      required this.numberOfStars,
      required this.score,
      this.timerWidget})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    List<Widget> items = [];
    if (timerWidget != null) {
      items.add(timerWidget!);
    }
    items.add(Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
              child: HudStarsWidget(
            numberOfStars: numberOfStars,
            starWidth: screenSize.width / 12,
          )),
          Expanded(child: AnimatedScore(score: score)),
          Expanded(
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  "assets/icon/squarified.png",
                  width: screenSize.width / 10,
                  fit: BoxFit.fitWidth,
                ))
          ]))
        ])));
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: items,
    );
  }
}
