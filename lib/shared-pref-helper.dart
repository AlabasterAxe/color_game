import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'model.dart';

const String SCORES_KEY = "co.thkp.colorcollapse.scores";
const String USER_KEY = "co.thkp.colorcollapse.user";

Future<void> addScore(
    {required String levelTag,
    required int score,
    required int earnedStars}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
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
  await prefs.setStringList(SCORES_KEY, scores);
}

Future<List<Score>> getScores([String? levelTag]) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
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
}

Future<User> getUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userJsonString = prefs.getString(USER_KEY);
  List<Score> attempts = await getScores();
  Map<String, List<Score>> attemptMap =
      attempts.fold({}, (Map<String, List<Score>> result, attempt) {
    List<Score> attemptList = result.putIfAbsent(attempt.levelTag, () => []);
    attemptList.add(attempt);
    return result;
  });
  if (userJsonString != null) {
    return User.fromJson(json.decode(userJsonString), attempts: attemptMap);
  }
  return User();
}

Future<void> setUser(User user) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  await prefs.setString(USER_KEY, json.encode(user.toJson()));
}

Future<void> clearSharedPrefs() async {
  SharedPreferences instance = await SharedPreferences.getInstance();
  await instance.clear();
}
