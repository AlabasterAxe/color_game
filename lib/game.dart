import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'constants.dart';
import 'generate-game-boxes.dart';
import 'model.dart';

class GameBoxWidget extends StatelessWidget {
  final GameBox box;
  GameBoxWidget({this.box}) : super(key: box.key);

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    Rect boundsRect = box.getRect(screenSize);
    double gapSize = boundsRect.width * RELATIVE_GAP_SIZE;

    return AnimatedPositioned(
      duration: Duration(milliseconds: box.userDragged ? 0 : 1000),
      curve: Curves.easeInOut,
      top: boundsRect.top,
      left: boundsRect.left,
      child: Padding(
          padding: EdgeInsets.all(gapSize / 2),
          child: Container(
              height: boundsRect.height - gapSize,
              width: boundsRect.width - gapSize,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.all(Radius.circular(BOX_BORDER_RADIUS)),
                color: box.color,
              ))),
    );
  }
}

class GameWidget extends StatefulWidget {
  final ColorGameConfig config;
  GameWidget({Key key, this.config}) : super(key: key);

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

  // if they're not dragging col, they're dragging row;
  bool draggingCol;

  List<GameBox> boxes = generateGameBoxes(colors: COLORS);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (GameBox box in boxes) {
      double boxEdgeSize = MediaQuery.of(context).size.shortestSide / GRID_SIZE;
      box.size = Size.square(boxEdgeSize);
    }
  }

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
      if (box.getRect(MediaQuery.of(context).size).contains(globalTapCoords)) {
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
        }
        List<GameBox> affectedBoxes = [];
        if (!_settled) {
          affectedBoxes = _gravitize();
          _snapBoxes();
        }
        if (affectedRows.isEmpty && affectedBoxes.isEmpty) {
          t.cancel();
          _settled = true;
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
      List<GameBox> streak = [];
      Color streakColor;
      bool hadStreak = false;
      Offset lastBoxLoc;
      for (GameBox box
          in roworcol.where((b) => b.color != Colors.transparent)) {
        if (box.color != streakColor ||
            // if there's a gap don't count it as a streak
            (box.loc.dx - lastBoxLoc.dx).abs() > 1 ||
            (box.loc.dy - lastBoxLoc.dy).abs() > 1) {
          if (streak.length >= 3) {
            hadStreak = true;
            boxesToRemove.addAll(streak);
          }
          streak = [box];
          streakColor = box.color;
        } else {
          streak.add(box);
        }
        lastBoxLoc = box.loc;
      }
      if (streak.length >= 3) {
        hadStreak = true;
        boxesToRemove.addAll(streak);
      }
      if (hadStreak) {
        affectedRowOrCols.add(roworcol);
        roworcol.removeWhere((GameBox b) => boxesToRemove.contains(b));
      }
    }

    // boxesToRemove.forEach((GameBox b) => b.color = Colors.transparent);
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
    stackChildren.addAll(boxes.map((b) => GameBoxWidget(box: b)).toList());

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
              Rect boxSize = tappedBox.getRect(MediaQuery.of(context).size);
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
              Rect boxSize = tappedBox.getRect(MediaQuery.of(context).size);
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
