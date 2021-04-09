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
    Size screenSize = MediaQuery.of(context).size;
    double starSize = screenSize.width / 6;
    String message = [
      "Better Luck Next Time",
      "Good Job",
      "Nice Work!",
      "Great Job!"
    ][widget.earnedStars];
    return Card(
        shape: CARD_SHAPE,
        elevation: 4,
        child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  style: TextStyle(
                      fontSize: widget.earnedStars == 0 ? 18 : 36,
                      fontWeight: FontWeight.w800),
                ),
                SizedBox(
                  height: 32,
                ),
                Container(
                    height: starSize,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SpinningAnimatedStar(
                              earned: widget.earnedStars > 0,
                              size: starSize,
                              durationMS: 1300),
                          SizedBox(
                            width: 8,
                          ),
                          SpinningAnimatedStar(
                              earned: widget.earnedStars > 1,
                              size: starSize,
                              durationMS: 1600),
                          SizedBox(
                            width: 8,
                          ),
                          SpinningAnimatedStar(
                              earned: widget.earnedStars > 2,
                              size: starSize,
                              durationMS: 1900),
                        ])),
                SizedBox(
                  height: 32,
                ),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  ElevatedButton(
                      child: Text("Retry"), onPressed: widget.onRetry),
                  SizedBox(
                    width: 16,
                  ),
                  ElevatedButton(child: Text("Back"), onPressed: widget.onBack)
                ]),
              ],
            )));
  }
}
