import 'package:color_game/widgets/hud-stars-widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'animated-score.dart';

class Hud extends StatelessWidget {
  final int numberOfStars;
  final int score;
  final Widget? timerWidget;
  final int? movesLeft;
  const Hud(
      {Key? key,
      required this.numberOfStars,
      required this.score,
      this.timerWidget,
      this.movesLeft})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    Widget rightSideWidget = ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.asset(
          "assets/icon/squarified.png",
          width: screenSize.width / 10,
          fit: BoxFit.fitWidth,
        ));
    if (timerWidget != null) {
      rightSideWidget = Container(
          width: screenSize.width / 10,
          height: screenSize.height / 10,
          child: timerWidget!);
    } else if (movesLeft != null) {
      rightSideWidget = Column(
        children: [
          Text(
            "moves left",
            style: TextStyle(
                fontSize: 16, color: Colors.white, fontWeight: FontWeight.w800),
          ),
          Text("$movesLeft")
        ],
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: HudStarsWidget(
                    numberOfStars: numberOfStars,
                    starWidth: screenSize.width / 12,
                  )),
                  Expanded(child: AnimatedScore(score: score)),
                  Expanded(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [rightSideWidget]))
                ]))
      ],
    );
  }
}
