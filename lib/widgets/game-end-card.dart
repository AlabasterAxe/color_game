import 'package:color_game/constants.dart';
import 'package:color_game/main.dart';
import 'package:color_game/services/audio-service.dart';
import 'package:color_game/widgets/cc-button.dart';
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
  void didChangeDependencies() {
    super.didChangeDependencies();

    AppContext.of(context).audioService.playSoundEffect(widget.earnedStars > 0
        ? SoundEffectType.SUCCESS
        : SoundEffectType.FAILURE);
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double starSize = screenSize.width / 6;
    String message = [
      "Nice Try",
      "Good Job",
      "Nice Work!",
      "Great Job!"
    ][widget.earnedStars];
    return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 420),
        child: Padding(
            padding: EdgeInsets.all(32),
            child: Card(
                shape: CARD_SHAPE,
                elevation: 12,
                color: Colors.grey.shade600,
                child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          message,
                          style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: Colors.white),
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
                          Expanded(
                              child: ColorCollapseButton(
                                  child: Text(
                                    "Retry",
                                    style: TextStyle(
                                        fontSize: 32,
                                        color: BOARD_BACKGROUND_COLOR,
                                        fontWeight: FontWeight.w800),
                                    textAlign: TextAlign.center,
                                  ),
                                  onPressed: widget.onRetry)),
                          SizedBox(
                            width: 16,
                          ),
                          Expanded(
                              child: ColorCollapseButton(
                                  child: Text(
                                    "Next",
                                    style: TextStyle(
                                        fontSize: 32,
                                        color: BOARD_BACKGROUND_COLOR,
                                        fontWeight: FontWeight.w800),
                                    textAlign: TextAlign.center,
                                  ),
                                  onPressed: widget.onBack))
                        ]),
                      ],
                    )))));
  }
}
