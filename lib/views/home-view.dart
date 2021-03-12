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
                        style: GoogleFonts.lato(
                            fontWeight: FontWeight.bold,
                            fontSize: 64,
                            color: Colors.grey[200],
                            decoration: TextDecoration.none)),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ColorCollapseButton(
                          child: Text(
                            "High Scores",
                          ),
                          onPressed: () {
                            analyticsService
                                .logEvent(AnalyticsEvent.start_game);
                            Navigator.pushNamed(context, "/game",
                                arguments: ColorGameConfig());
                          }),
                      ColorCollapseButton(
                          child: Text(
                            "Play",
                          ),
                          onPressed: () {
                            analyticsService
                                .logEvent(AnalyticsEvent.start_game);
                            Navigator.pushNamed(context, "/game",
                                arguments: ColorGameConfig());
                          }),
                    ],
                  ),
                ),
              ]),
        ));
  }
}
