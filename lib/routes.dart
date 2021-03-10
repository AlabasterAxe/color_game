import 'package:color_game/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'game/game-view.dart';
import 'views/home-view.dart';
import 'views/splash-view.dart';

enum RouteId {
  homeView,
  splashView,
  gameView,
}

class _RouteConfig {
  final String? name;
  // if null, dynamic route must be specified
  final Route<dynamic> Function(RouteSettings)? routeBuilder;

  _RouteConfig({this.name, this.routeBuilder});
}

Route<dynamic> _staticRoute(Widget child) {
  return MaterialPageRoute(builder: (context) => child);
}

Map<RouteId, _RouteConfig> _routeConfiguration = {
  RouteId.homeView: _RouteConfig(
      name: '/', routeBuilder: (settings) => _staticRoute(HomeView())),
  RouteId.splashView: _RouteConfig(
      name: '/splash', routeBuilder: (settings) => _staticRoute(SplashView())),
  RouteId.gameView: _RouteConfig(
      name: '/game',
      routeBuilder: (settings) => MaterialPageRoute(builder: (context) {
            if (settings.arguments != null) {
              return GameView(config: settings.arguments as ColorGameConfig);
            }
            return GameView();
          })),
};

extension RouteIdUtils on RouteId? {
  String? get name => _routeConfiguration[this!]!.name;
  Route<dynamic> generateRoute(RouteSettings settings) =>
      _routeConfiguration[this!]!.routeBuilder!(settings);
}

RouteId? getRouteIdByName(String? name) {
  for (RouteId id in RouteId.values) {
    if (id.name == name) {
      return id;
    }
  }
  return null;
}
