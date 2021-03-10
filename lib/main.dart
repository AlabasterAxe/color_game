import 'dart:io';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';

import 'routes.dart';
import 'services/audio-service.dart';

void main() {
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

  AppContext(
    this.child,
    this.audioService, {
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
    FirebaseAdMob.instance.initialize(
        appId: Platform.isIOS ? IOS_ADMOB_APP_ID : ANDROID_ADMOB_APP_ID);
    return AppContext(
      MaterialApp(
        onGenerateRoute: (RouteSettings settings) =>
            getRouteIdByName(settings.name).generateRoute(settings),
        initialRoute: "/splash",
      ),
      audioService,
    );
  }
}
