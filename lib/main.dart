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
    return MaterialApp(
      onGenerateRoute: (RouteSettings settings) =>
          getRouteIdByName(settings.name).generateRoute(settings),
      initialRoute: "/game",
    );
  }
}
