import 'package:flutter/material.dart';

import 'routes.dart';
import 'services/audio-service.dart';

void main() {
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
    return Container(
      child: AppContext(
        MaterialApp(
          onGenerateRoute: (RouteSettings settings) =>
              getRouteIdByName(settings.name).generateRoute(settings),
          initialRoute: "/game",
        ),
        audioService,
      ),
    );
  }
}
