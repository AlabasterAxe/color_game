import 'package:color_game/routes.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'constants.dart';
import 'services/analytics-service.dart';
import 'services/audio-service.dart';

Widget passThroughBuilder(BuildContext context, Widget widget) {
  return widget;
}

class MyApp extends StatelessWidget {
  final Widget Function(BuildContext, Widget) builderWrapper;

  const MyApp({Key? key, builderWrapper})
      : this.builderWrapper = builderWrapper ?? passThroughBuilder,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppContextState();
  }
}

class AppContext extends InheritedWidget {
  final Widget child;
  final AudioService audioService;
  final AnalyticsService analytics;

  AppContext(
    this.child,
    this.audioService,
    this.analytics, {
    Key? key,
  }) : super(key: key, child: child);

  static AppContext? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppContext>();
  }

  @override
  bool updateShouldNotify(AppContext oldWidget) {
    return true;
  }
}

class AppContextState extends StatefulWidget {
  AppContextState({Key? key}) : super(key: key);

  @override
  _AppContextStateState createState() => _AppContextStateState();
}

class _AppContextStateState extends State<AppContextState> {
  AudioService audioService = AudioService();

  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics analytics = FirebaseAnalytics();
    FirebaseAnalyticsObserver observer =
        FirebaseAnalyticsObserver(analytics: analytics);
    analytics.logAppOpen();

    ThemeData colorCollapseTheme = getTheme();
    return AppContext(
        MaterialApp(
          onGenerateRoute: (RouteSettings settings) =>
              getRouteIdByName(settings.name).generateRoute(settings),
          initialRoute: "/splash",
          theme: colorCollapseTheme,
        ),
        audioService,
        AnalyticsService(analytics, observer));
  }
}
