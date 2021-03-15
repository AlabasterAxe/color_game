import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String SCORES_KEY = "co.thkp.colorcollapse.scores";

class Score {
  final int score;
  final DateTime date;
  final String levelTag;

  Score._(this.score, this.date, this.levelTag);

  factory Score.c(
      {@required int? score,
      @required DateTime? date,
      @required String? levelTag}) {
    List<String> missingRequiredParameters = [];
    if (score == null) {
      missingRequiredParameters.add("score");
    }
    if (date == null) {
      missingRequiredParameters.add("date");
    }
    if (levelTag == null) {
      missingRequiredParameters.add("levelTag");
    }

    if (missingRequiredParameters.isNotEmpty) {
      throw ArgumentError(
          "Missing required parameters: $missingRequiredParameters");
    }

    return Score._(score!, date!, levelTag!);
  }

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score._(
        json["score"], DateTime.parse(json["date"]), json["levelTag"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "score": score,
      "date": date.toIso8601String(),
      "levelTag": date.toIso8601String(),
    };
  }
}

Future<void> addScore(String levelTag, int score) {
  return SharedPreferences.getInstance().then((prefs) {
    var scores = prefs.getStringList(SCORES_KEY);
    if (scores == null) {
      scores = [];
    }
    scores
        .add(json.encode((Score._(score, DateTime.now(), levelTag).toJson())));
    prefs.setStringList(SCORES_KEY, scores);
  });
}

Future<List<Score>> getScores() {
  return SharedPreferences.getInstance().then((prefs) {
    List<String>? scores = prefs.getStringList(SCORES_KEY);
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
