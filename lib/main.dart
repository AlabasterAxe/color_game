import 'dart:io';

import 'package:color_game/services/analytics-service.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'routes.dart';
import 'services/audio-service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

const String IOS_ADMOB_APP_ID = "ca-app-pub-1235186580185107~4655451720";
const String ANDROID_ADMOB_APP_ID = "ca-app-pub-1235186580185107~4695991932";

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
    FirebaseAdMob.instance.initialize(
        appId: Platform.isIOS ? IOS_ADMOB_APP_ID : ANDROID_ADMOB_APP_ID);
    return AppContext(
        MaterialApp(
          onGenerateRoute: (RouteSettings settings) =>
              getRouteIdByName(settings.name).generateRoute(settings),
          initialRoute: "/splash",
        ),
        audioService,
        AnalyticsService(analytics, observer));
  }
}
