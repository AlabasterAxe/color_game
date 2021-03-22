import 'package:color_game/constants.dart';
import 'package:flutter/material.dart';

class GameEndCard extends StatefulWidget {
  final int earnedStars;
  final void Function() onBack;
  final void Function() onRetry;

  const GameEndCard(
      {Key? key,
      required this.earnedStars,
      required this.onBack,
      required this.onRetry})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => GameEndCardState();
}

class GameEndCardState extends State<GameEndCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
        shape: CARD_SHAPE,
        elevation: 4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset(
                        "assets/images/${widget.earnedStars != null && widget.earnedStars! > 0 ? "gold_star" : "star"}.png"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset(
                        "assets/images/${widget.earnedStars != null && widget.earnedStars! > 1 ? "gold_star" : "star"}.png"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset(
                        "assets/images/${widget.earnedStars != null && widget.earnedStars! > 2 ? "gold_star" : "star"}.png"),
                  ),
                ]),
            ElevatedButton(child: Text("Back"), onPressed: widget.onBack),
          ],
        ));
  }
}
