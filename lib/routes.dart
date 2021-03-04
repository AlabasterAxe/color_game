import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'game/game-view.dart';
import 'home-view.dart';

enum RouteId {
  homeView,
  gameView,
}

class _RouteConfig {
  final String name;
  // if null, dynamic route must be specified
  final Route<dynamic> Function(RouteSettings) routeBuilder;

  _RouteConfig({this.name, this.routeBuilder});
}

Route<dynamic> _staticRoute(Widget child) {
  return MaterialPageRoute(builder: (context) => child);
}

Map<RouteId, _RouteConfig> _routeConfiguration = {
  RouteId.homeView: _RouteConfig(
      name: '/', routeBuilder: (settings) => _staticRoute(HomeView())),
  RouteId.gameView: _RouteConfig(
      name: '/game',
      routeBuilder: (settings) => MaterialPageRoute(
          builder: (context) => GameView(config: settings.arguments))),
};

extension RouteIdUtils on RouteId {
  String get name => _routeConfiguration[this].name;
  Route<dynamic> generateRoute(RouteSettings settings) =>
      _routeConfiguration[this].routeBuilder(settings);
}

RouteId getRouteIdByName(String name) {
  for (RouteId id in RouteId.values) {
    if (id.name == name) {
      return id;
    }
  }
  return null;
}