import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../model.dart';

String _getAgoString(DateTime date) {
  DateTime now = DateTime.now();
  var delta = Duration(
      milliseconds: now.millisecondsSinceEpoch - date.millisecondsSinceEpoch);
  if (delta.inDays > 365) {
    int numYears = (delta.inDays / 365).round();
    return "${numYears} ${numYears == 1 ? "year" : "years"} ago";
  } else if (delta.inDays > 30) {
    int numMonths = (delta.inDays / 30).round();
    return "${numMonths} ${numMonths == 1 ? "month" : "months"} ago";
  } else if (delta.inDays > 7) {
    int numWeeks = (delta.inDays / 7).round();
    return "${numWeeks} ${numWeeks == 1 ? "week" : "weeks"} ago";
  } else if (delta.inDays > 0) {
    int numDays = delta.inDays;
    return "${numDays} ${numDays == 1 ? "day" : "days"} ago";
  } else if (delta.inHours > 0) {
    return "${delta.inHours} ${delta.inHours == 1 ? "hour" : "hours"} ago";
  } else if (delta.inMinutes > 0) {
    return "${delta.inMinutes} ${delta.inMinutes == 1 ? "minute" : "minutes"} ago";
  } else if (delta.inSeconds > 30) {
    return "${delta.inSeconds} seconds ago";
  } else {
    return "just now";
  }
}

class HighScoresDialog extends StatelessWidget {
  final List<Score> highScores;
  const HighScoresDialog({Key? key, required this.highScores})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: IntrinsicHeight(
          child: Column(
            children: [
              Text(
                "Your High Scores",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline5,
              ),
              SizedBox(height: 20),
              DataTable(
                  headingRowHeight: 0,
                  columns: [
                    DataColumn(label: Container()),
                    DataColumn(label: Container())
                  ],
                  rows: highScores
                      .take(5)
                      .map((score) => DataRow(
                            cells: [
                              DataCell(Text("${score.score}",
                                  style: TextStyle(fontSize: 24))),
                              DataCell(Text("(${_getAgoString(score.date)})",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[800],
                                      fontStyle: FontStyle.italic))),
                            ],
                          ))
                      .toList()),
              ElevatedButton(
                  child: Text("Back"),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ],
          ),
        ),
      ),
    ));
  }
}
