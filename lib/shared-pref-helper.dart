import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

const String SCORES_KEY = "co.thkp.color_collapse.scores";

class Score {
  int score;
  DateTime date;

  Score();

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score()
      ..score = json["score"]
      ..date = DateTime.parse(json["date"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "score": score,
      "date": date.toIso8601String(),
    };
  }
}

Future<void> addScore(int score) {
  return SharedPreferences.getInstance().then((prefs) {
    var scores = prefs.getStringList(SCORES_KEY);
    if (scores == null) {
      scores = [];
    }
    scores.add(json.encode((Score()
          ..score = score
          ..date = DateTime.now())
        .toJson()));
    prefs.setStringList(SCORES_KEY, scores);
  });
}

Future<List<Score>> getScores() {
  return SharedPreferences.getInstance().then((prefs) {
    List<String> scores = prefs.getStringList(SCORES_KEY);
    if (scores == null) {
      return [];
    }

    return scores.map((score) => Score.fromJson(json.decode(score))).toList();
  });
}

Future<void> clearSharedPrefs() async {
  SharedPreferences instance = await SharedPreferences.getInstance();
  await instance.clear();
}
