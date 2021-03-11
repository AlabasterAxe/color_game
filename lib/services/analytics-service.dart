import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

enum AnalyticsEvent { start_game, finish_game }

extension _AnalyticsEventUtil on AnalyticsEvent {
  String get name => this.toString().split('.')[1];
}

class AnalyticsService {
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  AnalyticsService(this.analytics, this.observer);

  void logEvent(AnalyticsEvent event) {
    analytics.logEvent(name: event.name);
  }
}
