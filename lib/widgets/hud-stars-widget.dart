import 'package:color_game/widgets/spinning-animated-star.dart';
import 'package:flutter/cupertino.dart';

class HudStarsWidget extends StatefulWidget {
  final int numberOfStars;
  final double starWidth;

  const HudStarsWidget(
      {Key? key, required this.numberOfStars, required this.starWidth})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => HudStarsWidgetState();
}

class HudStarsWidgetState extends State<HudStarsWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SpinningAnimatedStar(
        earned: widget.numberOfStars > 0,
        size: widget.starWidth,
        durationMS: 1300,
      ),
      SizedBox(width: 8),
      SpinningAnimatedStar(
        earned: widget.numberOfStars > 1,
        size: widget.starWidth,
        durationMS: 1600,
      ),
      SizedBox(width: 8),
      SpinningAnimatedStar(
        earned: widget.numberOfStars > 2,
        size: widget.starWidth,
        durationMS: 1900,
      ),
    ]);
  }
}
