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
      Image.asset(
        widget.numberOfStars > 0
            ? "assets/images/gold_star.png"
            : "assets/images/star.png",
        width: widget.starWidth,
      ),
      SizedBox(width: 8),
      Image.asset(
          widget.numberOfStars > 1
              ? "assets/images/gold_star.png"
              : "assets/images/star.png",
          width: widget.starWidth),
      SizedBox(width: 8),
      Image.asset(
          widget.numberOfStars > 2
              ? "assets/images/gold_star.png"
              : "assets/images/star.png",
          width: widget.starWidth)
    ]);
  }
}
