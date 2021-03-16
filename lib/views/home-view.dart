import 'package:color_game/constants.dart';
import 'package:color_game/main.dart';
import 'package:color_game/services/analytics-service.dart';
import 'package:color_game/widgets/cc-button.dart';
import 'package:color_game/widgets/high-scores-dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../shared-pref-helper.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AnalyticsService analyticsService = AppContext.of(context).analytics;
    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/home_background.png"),
                fit: BoxFit.cover)),
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      ColorCollapseButton(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.settings,
                                color: BOARD_BACKGROUND_COLOR,
                                size: 48,
                              ),
                              // Text("Settings",
                              //     style: Theme.of(context).textTheme.bodyText1),
                            ],
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, "/settings");
                          }),
                    ])),
                Expanded(
                  child: Center(
                    child: Text("Color Collapse",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline1),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ColorCollapseButton(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset("assets/images/high_scores.png"),
                              Text("High Scores",
                                  style: Theme.of(context).textTheme.bodyText1),
                            ],
                          ),
                          onPressed: () {
                            getScores().then((highScores) {
                              highScores
                                  .sort((a, b) => b.score.compareTo(a.score));
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return HighScoresDialog(
                                      highScores: highScores);
                                },
                                barrierDismissible: false,
                              );
                            });
                          }),
                      ColorCollapseButton(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset("assets/images/play_button.png"),
                              Text("Play",
                                  style: Theme.of(context).textTheme.bodyText1),
                            ],
                          ),
                          onPressed: () {
                            analyticsService
                                .logEvent(AnalyticsEvent.start_game);
                            Navigator.pushNamed(
                              context,
                              "/world_map",
                            );
                          }),
                    ],
                  ),
                ),
              ]),
        ));
  }
}
