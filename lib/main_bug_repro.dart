import 'dart:ui';

import 'package:color_game/services/analytics-service.dart';
import 'package:color_game/widgets/banner-ad-widget.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

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

    MobileAds.instance.initialize().then((InitializationStatus status) {
      print('Initialization done: ${status.toString()}');
      MobileAds.instance
          .updateRequestConfiguration(RequestConfiguration(
              tagForChildDirectedTreatment:
                  TagForChildDirectedTreatment.unspecified))
          .then((value) {});
    });
    return MaterialApp(
        home: Scaffold(
      body: Stack(
        children: [
          Center(child: Container(width: 30, height: 30, color: Colors.pink)),
          Align(alignment: Alignment(-.5, -.5), child: Text("Foo")),
          Positioned.fill(
              child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Container(color: Colors.transparent),
          )),
          Center(child: Text("Foo")),
          Align(alignment: Alignment.bottomCenter, child: BannerAdWidget())
        ],
      ),
    ));
  }
}
