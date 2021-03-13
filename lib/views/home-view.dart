import 'package:color_game/constants.dart';
import 'package:color_game/services/analytics-service.dart';
import 'package:color_game/widgets/cc-button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:color_game/main.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AnalyticsService analyticsService = AppContext.of(context)!.analytics;
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
                Expanded(child: Container()),
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
                            analyticsService
                                .logEvent(AnalyticsEvent.start_game);
                            Navigator.pushNamed(context, "/game",
                                arguments: ColorGameConfig());
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
                            Navigator.pushNamed(context, "/world_map",
                                arguments: ColorGameConfig());
                          }),
                    ],
                  ),
                ),
              ]),
        ));
  }
}
