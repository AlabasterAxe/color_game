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
  NO_MOVES,
}

class RunEventMetadata {
  int runLength;
  Color color;
  int runStreakLength;
  int multiples;
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
  bool sentNoMovesEvent = false;

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

  GameBox getTappedBox(Offset localTapCoords, ViewTransformation vt) {
    for (GameBox box in boxes.where((b) => b.color != Colors.transparent)) {
      if (box.getRect(vt).contains(localTapCoords)) {
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

      double primaryOption;
      double secondaryOption;
      double primaryDist = 0;
      for (double cardinal in cardinals) {
        double dist = (cardinal - centerOffset.direction).abs();
        if (dist < pi / 3) {
          if (primaryOption == null) {
            primaryOption = cardinal;
            primaryDist = dist;
          } else {
            if (dist < primaryDist) {
              secondaryOption = primaryOption;
              primaryOption = cardinal;
              primaryDist = dist;
            } else {
              secondaryOption = cardinal;
            }
          }
        }
      }

      Offset primaryLoc = box.loc + Offset.fromDirection(primaryOption);
      GameBox primaryBox = getBoxAtPosition(primaryLoc);
      Offset secondaryLoc;
      GameBox secondaryBox;
      if (secondaryOption != null) {
        secondaryLoc = box.loc + Offset.fromDirection(secondaryOption);
        secondaryBox = getBoxAtPosition(secondaryLoc);
      }
      if (primaryBox == null) {
        affectedBoxes.add(box);
        if (secondaryOption != null) {
          Offset diagonalLoc = box.loc +
              Offset.fromDirection(primaryOption) +
              Offset.fromDirection(secondaryOption);
          GameBox diagonalBox = getBoxAtPosition(diagonalLoc);
          if (secondaryBox == null && diagonalBox == null) {
            box.loc = diagonalLoc;
            box.startLoc = diagonalLoc;
          } else {
            box.loc = primaryLoc;
            box.startLoc = primaryLoc;
          }
        } else {
          box.loc = primaryLoc;
          box.startLoc = primaryLoc;
        }
      } else if (secondaryOption != null && secondaryBox == null) {
        affectedBoxes.add(box);
        box.loc = secondaryLoc;
        box.startLoc = secondaryLoc;
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

  bool _playerHasValidMoves() {
    if (boxes.length < 3) {
      return false;
    }

    Map<Color, int> colorMap = Map();
    for (GameBox box in boxes) {
      colorMap.putIfAbsent(box.color, () => 0);
      colorMap[box.color]++;
      if (colorMap[box.color] >= 3) {
        return true;
      }
    }
    return false;
  }

  void _updateBoardTillSettled() {
    boardUpdateTimer = Timer.periodic(Duration(milliseconds: 1000), (t) {
      setState(() {
        var affectedRows = _removeContiguous();
        if (!_playerHasValidMoves() && !sentNoMovesEvent) {
          widget.onGameEvent(GameEvent()..type = GameEventType.NO_MOVES);
          sentNoMovesEvent = true;
        }
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
  List<RunEventMetadata> _removeContiguousColors(
      Iterable<List<GameBox>> rowsorcols) {
    Set<GameBox> boxesToRemove = Set();
    List<RunEventMetadata> runs = [];

    for (List<GameBox> roworcol in rowsorcols) {
      List<GameBox> run = [];
      Color runColor;
      Offset lastBoxLoc;

      Function(List<GameBox>) handleStreak = (run) {
        boxesToRemove.addAll(run);
        runs.add(RunEventMetadata()
          ..runLength = run.length
          ..runStreakLength = runStreakLength
          ..color = runColor);
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
    }

    boxes.removeWhere((GameBox b) => boxesToRemove.contains(b));
    return runs;
  }

  List<RunEventMetadata> _removeContiguous() {
    List<RunEventMetadata> result = [];
    result.addAll(_removeContiguousColors(getRows().values));
    result.addAll(_removeContiguousColors(getCols().values));
    for (RunEventMetadata run in result) {
      run.multiples = result.length;
      widget.onGameEvent(GameEvent()
        ..type = GameEventType.RUN
        ..metadata = run);
    }
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
    return LayoutBuilder(builder: (context, constraints) {
      ViewTransformation vt = ViewTransformation(
          from: Rect.fromLTRB(
              -widget.config.gridSize.width / 2,
              -widget.config.gridSize.height / 2,
              widget.config.gridSize.width / 2,
              widget.config.gridSize.height / 2),
          to: Offset(0, 0) & constraints.biggest);
      List<Widget> stackChildren = [];

      stackChildren
          .addAll(boxes.map((b) => GameBoxWidget(box: b, vt: vt)).toList());

      return GestureDetector(
          onPanStart: (DragStartDetails deets) {
            tapStartLoc = deets.localPosition;
            tappedBox = getTappedBox(tapStartLoc, vt);
            if (tappedBox != null) {
              slidingColumn = getColumnMates(tappedBox);
              slidingRow = getRowMates(tappedBox);
            }
          },
          onPanUpdate: (DragUpdateDetails deets) {
            if (tappedBox == null) {
              return;
            }

            tapUpdateLoc = deets.localPosition;
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
            if (tappedBox != null) {
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
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: stackChildren),
              ),
            ],
          ));
    });
  }
}
