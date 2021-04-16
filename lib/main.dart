// @dart=2.9

import 'dart:ui';

import 'package:color_game/services/analytics-service.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'constants.dart';
import 'routes.dart';
import 'services/audio-service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await MobileAds.instance.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
    Key key,
  }) : super(key: key, child: child);

  static AppContext of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppContext>();
  }

  @override
  bool updateShouldNotify(AppContext oldWidget) {
    return true;
  }
}

class AppContextState extends StatefulWidget {
  AppContextState({Key key}) : super(key: key);

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

    // MobileAds.instance.initialize().then((InitializationStatus status) {
    //   print('Initialization done: ${status.toString()}');
    //   MobileAds.instance
    //       .updateRequestConfiguration(RequestConfiguration(
    //           tagForChildDirectedTreatment:
    //               TagForChildDirectedTreatment.unspecified))
    //       .then((value) {});
    // });

    ThemeData colorCollapseTheme = getTheme(window.physicalSize.width);
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
