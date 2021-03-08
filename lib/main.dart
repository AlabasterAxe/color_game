<<<<<<< HEAD
=======
import 'dart:io';

>>>>>>> 67e69a90e58bd6164845175dc5ed1ebad0c0b0e0
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';

import 'routes.dart';

const RELATIVE_GAP_SIZE = 1 / 12;
const GRID_SIZE = 6;

void main() {
  runApp(MyApp());
}

const String IOS_ADMOB_APP_ID = "ca-app-pub-1235186580185107~4655451720";
const String ANDROID_ADMOB_APP_ID = "ca-app-pub-1235186580185107~4695991932";

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    FirebaseAdMob.instance
        .initialize(appId: "ca-app-pub-3940256099942544~3347511713");
=======
    FirebaseAdMob.instance.initialize(
        appId: Platform.isIOS ? IOS_ADMOB_APP_ID : ANDROID_ADMOB_APP_ID);
>>>>>>> 67e69a90e58bd6164845175dc5ed1ebad0c0b0e0
    return MaterialApp(
      onGenerateRoute: (RouteSettings settings) =>
          getRouteIdByName(settings.name).generateRoute(settings),
      initialRoute: "/game",
    );
  }
}
