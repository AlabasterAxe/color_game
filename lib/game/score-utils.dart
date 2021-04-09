import 'dart:math';

import '../model.dart';

int calculateFinalScore(List<GameEvent> events) {
  int score = 0;

  for (GameEvent e in events) {
    switch (e.type) {
      case GameEventType.RUN:
        score += pow(e.metadata.runLength, e.metadata.runStreakLength) *
            e.metadata.multiples as int;
        break;
      case GameEventType.SQUARE:
        score += 25;
        break;
      case GameEventType.LEFT_OVER_BOX:
        score = (score * .9).round();
        break;
      default:
        break;
    }
  }

  return score;
}
