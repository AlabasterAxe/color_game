import 'package:color_game/constants.dart';
import 'package:color_game/widgets/spinning-animated-star.dart';
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: CARD_SHAPE,
        elevation: 4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
<<<<<<< HEAD
                    child: SpinningAnimatedStar(
                        earned: widget.earnedStars > 0,
                        size: 80,
                        durationMS: 1300),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SpinningAnimatedStar(
                        earned: widget.earnedStars > 1,
                        size: 80,
                        durationMS: 1600),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SpinningAnimatedStar(
                        earned: widget.earnedStars > 2,
                        size: 80,
                        durationMS: 1900),
=======
                    child: Image.asset(
                        "assets/images/${widget.earnedStars > 0 ? "gold_star" : "star"}.png"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset(
                        "assets/images/${widget.earnedStars > 1 ? "gold_star" : "star"}.png"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset(
                        "assets/images/${widget.earnedStars > 2 ? "gold_star" : "star"}.png"),
>>>>>>> eeaab9f174627f13af8715feb29d7312b4631546
                  ),
                ])),
            Row(mainAxisSize: MainAxisSize.min, children: [
              ElevatedButton(child: Text("Retry"), onPressed: widget.onRetry),
              SizedBox(
                width: 16,
              ),
              ElevatedButton(child: Text("Back"), onPressed: widget.onBack)
            ]),
          ],
        ));
  }
}
