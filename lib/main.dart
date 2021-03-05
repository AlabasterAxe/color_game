import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';

import 'routes.dart';

const RELATIVE_GAP_SIZE = 1 / 12;
const GRID_SIZE = 6;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    FirebaseAdMob.instance.initialize(appId: "ca-app-pub-3940256099942544~3347511713");
=======
    FirebaseAdMob.instance.initialize(appId: "appid");
>>>>>>> working on firebase setup
    return MaterialApp(
      onGenerateRoute: (RouteSettings settings) => getRouteIdByName(settings.name).generateRoute(settings),
      initialRoute: "/game",
    );
  }
}
