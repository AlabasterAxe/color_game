import 'dart:async';
import 'dart:math';

import 'package:color_game/game-box-widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'constants.dart';
import 'generate-game-boxes.dart';
import 'model.dart';
import 'view-transform.dart';

enum GameEventType {
  RUN,
}

class RunEventMetadata {
  int runLength;
  Color color;
  int runStreakLength;
}

class GameEvent {
  GameEventType type;
  dynamic metadata;
}

class GameWidget extends StatefulWidget {
  final ColorGameConfig config;
  final Function(GameEvent) onGameEvent;
  GameWidget({Key key, this.config, this.onGameEvent}) : super(key: key);

  @override
  _GameWidgetState createState() => _GameWidgetState();
}

class _GameWidgetState extends State<GameWidget> {
  Offset tapStartLoc;
  Offset tapUpdateLoc;
  GameBox tappedBox;
  List<GameBox> slidingRow;
  List<GameBox> slidingColumn;
  Timer boardUpdateTimer;
  bool _settled = true;
  int runStreakLength = 1;

  // if they're not dragging col, they're dragging row;
  bool draggingCol;

  List<GameBox> boxes = generateGameBoxes(colors: COLORS);

  @override
  void dispose() {
    boardUpdateTimer.cancel();
    super.dispose();
  }

  List<GameBox> getColumnMates(GameBox tappedBox) {
    List<GameBox> result = [];
    for (GameBox box in boxes.where((b) => b.color != Colors.transparent)) {
      if (tappedBox.loc.dx == box.loc.dx) {
        result.add(box);
      }
    }
    return result;
  }

  List<GameBox> getRowMates(GameBox box) {
    List<GameBox> result = [];
    for (GameBox box in boxes.where((b) => b.color != Colors.transparent)) {
      if (tappedBox.loc.dy == box.loc.dy) {
        result.add(box);
      }
    }
    return result;
  }

  GameBox getTappedBox(Offset globalTapCoords) {
    for (GameBox box in boxes.where((b) => b.color != Colors.transparent)) {
      ViewTransformation vt = ViewTransformation(
          from: Rect.fromLTRB(
              -widget.config.gridSize.width / 2,
              -widget.config.gridSize.height / 2,
              widget.config.gridSize.width / 2,
              widget.config.gridSize.height / 2),
          to: Offset(0, 0) & MediaQuery.of(context).size);
      if (box.getRect(vt).contains(globalTapCoords)) {
        return box;
      }
    }
    return null;
  }

  GameBox getBoxAtPosition(Offset loc) {
    for (GameBox box in boxes.where((b) => b.color != Colors.transparent)) {
      if ((box.loc - loc).distanceSquared < .1) {
        return box;
      }
    }
    return null;
  }

  List<GameBox> _gravitize() {
    Offset gravitationalCenter = Offset(0, 0);
    List<GameBox> distSortedBoxes = [...boxes];

    distSortedBoxes.sort((a, b) => (gravitationalCenter - a.loc)
        .distanceSquared
        .compareTo((gravitationalCenter - b.loc).distanceSquared));

    List<GameBox> affectedBoxes = [];
    List<double> cardinals = [-pi, -pi / 2, 0, pi / 2, pi];
    for (GameBox box in distSortedBoxes) {
      Offset centerOffset = gravitationalCenter - box.loc;

      List<double> candidateCardinals = [];
      double prevDist = 0;
      for (double cardinal in cardinals) {
        double dist = (cardinal - centerOffset.direction).abs();
        if (dist < pi / 3) {
          candidateCardinals.add(cardinal);
          if (dist < prevDist) {
            candidateCardinals.insert(0, cardinal);
          } else {
            candidateCardinals.add(cardinal);
          }
          prevDist = dist;
        }
      }

      for (double cardinal in candidateCardinals) {
        Offset desiredLoc = box.loc + Offset.fromDirection(cardinal, 1);
        if (getBoxAtPosition(desiredLoc) == null) {
          affectedBoxes.add(box);
          box.loc = desiredLoc;
          box.startLoc = desiredLoc;
          break;
        }
      }
    }
    return affectedBoxes;
  }

  void _snapBoxes() {
    for (GameBox box in boxes) {
      Offset roundedOffset = Offset(
          (box.loc.dx - .5).round() + .5, (box.loc.dy - .5).round() + .5);
      box.loc = roundedOffset;
      box.startLoc = roundedOffset;
    }
  }

  void _updateBoardTillSettled() {
    boardUpdateTimer = Timer.periodic(Duration(milliseconds: 1000), (t) {
      setState(() {
        var affectedRows = _removeContiguous();
        _snapBoxes();
        if (affectedRows.isNotEmpty) {
          _settled = false;
          runStreakLength += 1;
        }
        List<GameBox> affectedBoxes = [];
        if (!_settled) {
          affectedBoxes = _gravitize();
          _snapBoxes();
        }
        if (affectedRows.isEmpty && affectedBoxes.isEmpty) {
          t.cancel();
          _settled = true;
          runStreakLength = 1;
        }
      });
    });
  }

  Map<double, List<GameBox>> getRows() {
    Map<double, List<GameBox>> result = Map();
    for (GameBox box in boxes.where((b) => b.color != Colors.transparent)) {
      List<GameBox> row = result.putIfAbsent(box.loc.dy, () => []);
      row.add(box);
      row.sort((a, b) => (a.loc.dx - b.loc.dx).ceil());
    }

    return result;
  }

  Map<double, List<GameBox>> getCols() {
    Map<double, List<GameBox>> result = Map();
    for (GameBox box in boxes.where((b) => b.color != Colors.transparent)) {
      List<GameBox> col = result.putIfAbsent(box.loc.dx, () => []);
      col.add(box);
      col.sort((a, b) => (a.loc.dy - b.loc.dy).ceil());
    }

    return result;
  }

  // returns affected rows/columns
  List<List<GameBox>> _removeContiguousColors(
      Iterable<List<GameBox>> rowsorcols) {
    Set<GameBox> boxesToRemove = Set();
    List<List<GameBox>> affectedRowOrCols = [];

    for (List<GameBox> roworcol in rowsorcols) {
      List<GameBox> run = [];
      Color runColor;
      bool hadRun = false;
      Offset lastBoxLoc;

      Function(List<GameBox>) handleStreak = (run) {
        hadRun = true;
        boxesToRemove.addAll(run);
        widget.onGameEvent(GameEvent()
          ..type = GameEventType.RUN
          ..metadata = (RunEventMetadata()
            ..runLength = run.length
            ..runStreakLength = runStreakLength
            ..color = runColor));
      };

      for (GameBox box
          in roworcol.where((b) => b.color != Colors.transparent)) {
        if (box.color != runColor ||
            // if there's a gap don't count it as a streak
            (box.loc.dx - lastBoxLoc.dx).abs() > 1 ||
            (box.loc.dy - lastBoxLoc.dy).abs() > 1) {
          if (run.length >= 3) {
            handleStreak(run);
          }
          run = [box];
          runColor = box.color;
        } else {
          run.add(box);
        }
        lastBoxLoc = box.loc;
      }
      if (run.length >= 3) {
        handleStreak(run);
      }
      if (hadRun) {
        affectedRowOrCols.add(roworcol);
        roworcol.removeWhere((GameBox b) => boxesToRemove.contains(b));
      }
    }

    boxes.removeWhere((GameBox b) => boxesToRemove.contains(b));
    return affectedRowOrCols;
  }

  List<List<GameBox>> _removeContiguous() {
    List<List<GameBox>> result = [];
    result.addAll(_removeContiguousColors(getRows().values));
    result.addAll(_removeContiguousColors(getCols().values));
    return result;
  }

  _updateSlidingCollection(List<GameBox> draggedBoxes, Offset dragOffset,
      List<GameBox> undraggedBoxes) {
    // put the other boxes back
    for (GameBox box in undraggedBoxes) {
      box.loc = box.startLoc;
      box.userDragged = false;
    }
    for (GameBox box in draggedBoxes) {
      box.loc = box.startLoc + dragOffset;
      box.userDragged = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stackChildren = [];
    ViewTransformation vt = ViewTransformation(
        from: Rect.fromLTRB(
            -widget.config.gridSize.width / 2,
            -widget.config.gridSize.height / 2,
            widget.config.gridSize.width / 2,
            widget.config.gridSize.height / 2),
        to: Offset(0, 0) & MediaQuery.of(context).size);
    stackChildren
        .addAll(boxes.map((b) => GameBoxWidget(box: b, vt: vt)).toList());

    return Scaffold(
      body: Center(
        child: GestureDetector(
            onPanStart: (DragStartDetails deets) {
              tapStartLoc = deets.globalPosition;
              tappedBox = getTappedBox(tapStartLoc);
              slidingColumn = getColumnMates(tappedBox);
              slidingRow = getRowMates(tappedBox);
            },
            onPanUpdate: (DragUpdateDetails deets) {
              tapUpdateLoc = deets.globalPosition;
              Offset delta = tapUpdateLoc - tapStartLoc;
              Rect boxSize = tappedBox.getRect(vt);
              // once the user is outside of a small window they can't change
              // whether they're dragging the column or the row
              if (delta.distance < boxSize.width / 2) {
                if (delta.dy.abs() > delta.dx.abs()) {
                  draggingCol = true;
                } else {
                  draggingCol = false;
                }
              }
              setState(() {
                if (draggingCol) {
                  _updateSlidingCollection(slidingColumn,
                      Offset(0, delta.dy / boxSize.height), slidingRow);
                } else {
                  _updateSlidingCollection(slidingRow,
                      Offset(delta.dx / boxSize.width, 0), slidingColumn);
                }
              });
            },
            onPanEnd: (DragEndDetails deets) {
              Offset delta = tapUpdateLoc - tapStartLoc;
              Rect boxSize = tappedBox.getRect(vt);
              if (draggingCol) {
                setState(() {
                  for (GameBox box in slidingColumn) {
                    Offset translatedOffset =
                        box.startLoc.translate(0, delta.dy / boxSize.height);

                    box.loc = translatedOffset;
                    box.startLoc = translatedOffset;
                    box.userDragged = false;
                  }
                  _snapBoxes();
                });
              } else {
                setState(() {
                  for (GameBox box in slidingRow) {
                    Offset translatedOffset =
                        box.startLoc.translate(delta.dx / boxSize.width, 0);
                    box.loc = translatedOffset;
                    box.startLoc = translatedOffset;
                    box.userDragged = false;
                  }
                  _snapBoxes();
                });
              }
              tappedBox = null;
              slidingColumn = null;
              slidingRow = null;
              _updateBoardTillSettled();
            },
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                      alignment: Alignment.center, children: stackChildren),
                ),
              ],
            )),
      ),
    );
  }
}
