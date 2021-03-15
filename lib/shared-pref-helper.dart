import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String SCORES_KEY = "co.thkp.colorcollapse.scores";

class Score {
  final int score;
  final DateTime date;
  final String levelTag;
  final int earnedStars;

  Score(
      {required this.score,
      required this.date,
      required this.levelTag,
      required this.earnedStars});

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
        score: json["score"],
        date: DateTime.parse(json["date"]),
        levelTag: json["levelTag"],
        earnedStars: json["earnedStars"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "score": score,
      "date": date.toIso8601String(),
      "levelTag": levelTag,
      "earnedStars": earnedStars,
    };
  }
}

Future<void> addScore(
    {required String levelTag, required int score, required int earnedStars}) {
  return SharedPreferences.getInstance().then((prefs) {
    var scores = prefs.getStringList(SCORES_KEY);
    if (scores == null) {
      scores = [];
    }
    scores.add(json.encode((Score(
            score: score,
            date: DateTime.now(),
            levelTag: levelTag,
            earnedStars: earnedStars)
        .toJson())));
    prefs.setStringList(SCORES_KEY, scores);
  });
}

Future<List<Score>> getScores([String? levelTag]) {
  return SharedPreferences.getInstance().then((prefs) {
    List<String>? scores = prefs.getStringList(SCORES_KEY);
    if (scores == null) {
      return [];
    }

    return scores
        .map((scoreJson) {
          Score score = Score.fromJson(json.decode(scoreJson));
          if (levelTag == null || levelTag == score.levelTag) {
            return score;
          }
          return null;
        })
        .where((score) => score != null)
        .toList() as List<Score>;
  });
}

Future<void> clearSharedPrefs() async {
  SharedPreferences instance = await SharedPreferences.getInstance();
  await instance.clear();
}
