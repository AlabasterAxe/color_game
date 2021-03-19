import 'dart:async';
import 'dart:math';

import 'package:color_game/views/disappearing-dots-block.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../constants.dart';
import '../model.dart';
import '../view-transform.dart';
import 'game-box-widget.dart';
import 'generate-game-boxes.dart';

enum GameEventType {
  RUN,
  SQUARE,
  NO_MOVES,
  LEFT_OVER_BOX,
  USER_MOVE,
  TIMER_FINISHED,
  BOARD_FULL,
}

const double MAX_BOX_ADDING_RATE = .004;

class RunEventMetadata {
  late int runLength;
  Color? color;
  late int runStreakLength;
  late int multiples;
}

enum DragDirection {
  HORIZONTAL,
  VERTICAL,
}

class UserMoveEventMetadata {
  final DragDirection dragDirection;
  final int dragLength;
  final List<GameBox> draggedBoxes;
  UserMoveEventMetadata(this.dragDirection, this.dragLength, this.draggedBoxes);
}

class SquareEventMetadata {
  Color? color;
}

class GameEvent {
  final GameEventType type;
  final dynamic metadata;
  final DateTime datetime;

  GameEvent(this.type, {DateTime? datetime, this.metadata})
      : this.datetime = datetime ?? DateTime.now();
}

class GameBoardWidget extends StatefulWidget {
  final ColorGameConfig config;
  final Function(GameEvent) onGameEvent;
  GameBoardWidget(this.config, {Key? key, required this.onGameEvent})
      : super(key: key);

  @override
  _GameBoardWidgetState createState() => _GameBoardWidgetState();
}

class _GameBoardWidgetState extends State<GameBoardWidget> {
  Offset? tapStartLoc;
  Offset? tapUpdateLoc;
  GameBox? tappedBox;
  List<GameBox>? slidingRow;
  List<GameBox>? slidingColumn;
  Timer? boardUpdateTimer;
  Timer? boxAddingTimer;
  bool _settled = true;
  int runStreakLength = 1;
  bool sentNoMovesEvent = false;
  int lastBoxAddedTimeMS = 0;
  double boxAddingRate = 0;

  // presently it's only possible to send one board full event
  // the logic here is that, either board full ends the game and it's not
  // possible for the user to do anything else, or, it doesn't end the game
  // end the outer game doesn't care anyway
  bool sentBoardFullEvent = false;

  // if they're not dragging col, they're dragging row;
  bool draggingCol = false;
  bool outsideSnap = false;

  List<GameBox> boxes = [];
  List<GameBox> toRemove = [];

  @override
  void initState() {
    super.initState();
    if (widget.config.predefinedGrid.isNotEmpty) {
      boxes = widget.config.predefinedGrid.map((e) => e.clone()).toList();
    } else {
      boxes = generateGameBoxes(
          colors: COLORS, size: widget.config.gridSize.width.round());
    }
    if (widget.config.boxAddingSpec?.behavior == BoxAddingBehavior.PER_TIME) {
      boxAddingRate =
          1 / widget.config.boxAddingSpec!.boxAddingPeriod!.inMilliseconds;
      lastBoxAddedTimeMS = DateTime.now().millisecondsSinceEpoch;
      boxAddingTimer = Timer(
          Duration(milliseconds: (1 / boxAddingRate).round()),
          _doPeriodicBoxAdd);
    }
  }

  @override
  void dispose() {
    if (boardUpdateTimer != null) {
      boardUpdateTimer!.cancel();
    }
    if (boxAddingTimer != null) {
      boxAddingTimer!.cancel();
    }
    super.dispose();
  }

  List<GameBox> getColumnMates(GameBox? tappedBox) {
    List<GameBox> result = [];
    for (GameBox box in boxes.where((b) => b.color != Colors.transparent)) {
      if (tappedBox!.loc.dx == box.loc.dx) {
        result.add(box);
      }
    }
    result.sort((a, b) => (a.loc.dy - b.loc.dy).ceil());
    List<GameBox> draggableChunk = [];
    bool chunkContainedTappedBox = false;
    for (GameBox box in result) {
      if (box == tappedBox) {
        chunkContainedTappedBox = true;
      }

      if (box.attributes.contains(GameBoxAttribute.IMMOVABLE)) {
        if (chunkContainedTappedBox) {
          return draggableChunk;
        } else {
          draggableChunk = [];
        }
      } else {
        draggableChunk.add(box);
      }
    }
    return draggableChunk;
  }

  List<GameBox> getRowMates(GameBox? box) {
    List<GameBox> result = [];
    for (GameBox box in boxes.where((b) => b.color != Colors.transparent)) {
      if (tappedBox!.loc.dy == box.loc.dy) {
        result.add(box);
      }
    }
    result.sort((a, b) => (a.loc.dx - b.loc.dx).ceil());
    List<GameBox> draggableChunk = [];
    bool chunkContainedTappedBox = false;
    for (GameBox box in result) {
      if (box == tappedBox) {
        chunkContainedTappedBox = true;
      }

      if (box.attributes.contains(GameBoxAttribute.IMMOVABLE)) {
        if (chunkContainedTappedBox) {
          return draggableChunk;
        } else {
          draggableChunk = [];
        }
      } else {
        draggableChunk.add(box);
      }
    }
    return draggableChunk;
  }

  GameBox? getTappedBox(Offset? localTapCoords, ViewTransformation vt) {
    for (GameBox box in boxes.where((b) => b.color != Colors.transparent)) {
      if (box.getRect(vt).contains(localTapCoords!) &&
          !box.attributes.contains(GameBoxAttribute.UNGRABBABLE) &&
          !box.attributes.contains(GameBoxAttribute.IMMOVABLE)) {
        return box;
      }
    }
    return null;
  }

  GameBox? getBoxAtPosition(Offset loc) {
    for (GameBox box in boxes.where((b) => b.color != Colors.transparent)) {
      if ((box.loc - loc).distanceSquared < .1) {
        return box;
      }
    }
    return null;
  }

  void _doPeriodicBoxAdd() {
    setState(() {
      _addBoxRandomlyOnBoard();
    });
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    int timeDelta = currentTime - lastBoxAddedTimeMS;
    lastBoxAddedTimeMS = currentTime;
    boxAddingRate = min(
        MAX_BOX_ADDING_RATE,
        boxAddingRate +
            (timeDelta / 1000) *
                widget.config.boxAddingSpec!.boxAddingAcceleration);
    boxAddingTimer = Timer(
        Duration(milliseconds: (1 / boxAddingRate).round()), _doPeriodicBoxAdd);
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

      double? primaryOption;
      double? secondaryOption;
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

      Offset primaryLoc = box.loc + Offset.fromDirection(primaryOption!);
      GameBox? primaryBox = getBoxAtPosition(primaryLoc);
      Offset? secondaryLoc;
      GameBox? secondaryBox;
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
          GameBox? diagonalBox = getBoxAtPosition(diagonalLoc);
          if (secondaryBox == null && diagonalBox == null) {
            box.loc = diagonalLoc;
            box.startLoc = diagonalLoc;
            box.collapsing = true;
          } else {
            box.loc = primaryLoc;
            box.startLoc = primaryLoc;
            box.collapsing = true;
          }
        } else {
          box.loc = primaryLoc;
          box.startLoc = primaryLoc;
          box.collapsing = true;
        }
      } else if (secondaryLoc != null && secondaryBox == null) {
        affectedBoxes.add(box);
        box.loc = secondaryLoc;
        box.startLoc = secondaryLoc;
        box.collapsing = true;
      }
    }
    return affectedBoxes;
  }

  void _snapBoxes() {
    double horizontalRoundOffset =
        (widget.config.gridSize.width.round() + 1) % 2 / 2;
    double verticalRoundOffset =
        (widget.config.gridSize.height.round() + 1) % 2 / 2;
    for (GameBox box in boxes) {
      Offset roundedOffset = Offset(
          (box.loc.dx - horizontalRoundOffset).round() + horizontalRoundOffset,
          (box.loc.dy - verticalRoundOffset).round() + verticalRoundOffset);
      box.loc = roundedOffset;
      box.startLoc = roundedOffset;
    }
  }

  void _penalizeRemainingBoxes() {
    if (boxAddingTimer != null) {
      boxAddingTimer!.cancel();
    }
    Timer.periodic(Duration(milliseconds: 1000), (Timer t) {
      if (boxes.isEmpty) {
        widget.onGameEvent(GameEvent(GameEventType.NO_MOVES));
        t.cancel();
        return;
      }

      setState(() {
        boxes.remove(boxes.first);
        widget.onGameEvent(GameEvent(GameEventType.LEFT_OVER_BOX));
      });
    });
  }

  bool _playerHasValidMoves() {
    if (boxes.length < 3) {
      return false;
    }

    Map<Color, int> colorMap = Map();
    for (GameBox box in boxes) {
      colorMap.putIfAbsent(box.color, () => 0);
      colorMap[box.color] = colorMap[box.color]! + 1;
      if (colorMap[box.color]! >= 3) {
        return true;
      }
    }
    return false;
  }

  void _updateBoard(Timer? t) {
    setState(() {
      bool featuresExist = _removeFeatures();
      if (!_playerHasValidMoves() && !sentNoMovesEvent) {
        sentNoMovesEvent = true;
        _penalizeRemainingBoxes();
      }
      _snapBoxes();
      if (featuresExist) {
        _settled = false;
        runStreakLength += 1;
      } else if (widget.config.gravitizeAfterEveryMove) {
        _settled = false;
      }
      List<GameBox> affectedBoxes = [];
      if (!_settled) {
        affectedBoxes = _gravitize();
        _snapBoxes();
      }
      if (!featuresExist && affectedBoxes.isEmpty) {
        if (t != null) {
          t.cancel();
        }
        _settled = true;
        runStreakLength = 1;
      }
    });
  }

  bool _addBoxRandomlyOnBoard() {
    Set<Offset> possibleLocations = Set();

    double halfWidth = (widget.config.gridSize.width - 1) / 2.0;
    double halfHeight = (widget.config.gridSize.height - 1) / 2.0;
    for (double x = -halfWidth; x <= halfWidth; x++) {
      for (double y = -halfHeight; y <= halfHeight; y++) {
        possibleLocations.add(Offset(x, y));
      }

      for (GameBox box in boxes) {
        possibleLocations.remove(box.loc);
      }
    }

    if (possibleLocations.isEmpty) {
      if (!sentBoardFullEvent) {
        widget.onGameEvent(GameEvent(GameEventType.BOARD_FULL));
        sentBoardFullEvent = true;
      }
      return false;
    } else {
      Offset newBoxLoc = possibleLocations
          .toList()[Random().nextInt(possibleLocations.length)];
      boxes.add(GameBox(newBoxLoc, COLORS[Random().nextInt(COLORS.length)]));
      return true;
    }
  }

  void _updateBoardTillSettled() {
    boardUpdateTimer = Timer(Duration(milliseconds: 200), () {
      boardUpdateTimer = Timer.periodic(
          Duration(milliseconds: COLLAPSE_DURATION_MILLISECONDS), _updateBoard);
      _updateBoard(boardUpdateTimer);
    });
  }

  Map<double, List<GameBox>> getRows() {
    Map<double, List<GameBox>> result = Map();
    for (GameBox box in boxes) {
      List<GameBox> row = result.putIfAbsent(box.loc.dy, () => []);
      row.add(box);
      row.sort((a, b) => (a.loc.dx - b.loc.dx).ceil());
    }

    return result;
  }

  Map<double, List<GameBox>> getCols() {
    Map<double, List<GameBox>> result = Map();
    for (GameBox box in boxes) {
      List<GameBox> col = result.putIfAbsent(box.loc.dx, () => []);
      col.add(box);
      col.sort((a, b) => (a.loc.dy - b.loc.dy).ceil());
    }

    return result;
  }

  // returns affected rows/columns
  List<RunEventMetadata> _markRuns(Iterable<List<GameBox>> allBoxes) {
    List<RunEventMetadata> runs = [];
    for (List<GameBox> boxes in allBoxes) {
      for (int i = 0; i < boxes.length; i++) {
        List<GameBox> run = [boxes[i]];
        for (int k = (i + 1); k < boxes.length; k++) {
          if (boxes[k].color == run.last.color &&
              (boxes[k].loc - run.last.loc).distanceSquared < 1.01) {
            run.add(boxes[k]);
          } else {
            i = k - 1;
            break;
          }
        }
        if (run.length >= 3) {
          RunEventMetadata runData = RunEventMetadata()
            ..runLength = run.length
            ..runStreakLength = runStreakLength
            ..color = run.last.color;
          run.forEach((element) => element.runs.add(runData));
          runs.add(runData);
        }
      }
    }
    return runs;
  }

  List<SquareEventMetadata> _getSquares() {
    List<SquareEventMetadata> squares = [];
    for (GameBox box in boxes) {
      if (box.eligibleForInclusionInSquare) {
        // only eligible if not part of run
        GameBox? r = getBoxAtPosition(box.loc + Offset(1.0, 0));
        if (r != null &&
            r.eligibleForInclusionInSquare &&
            r.color == box.color) {
          GameBox? b = getBoxAtPosition(box.loc + Offset(0.0, 1.0));
          if (b != null &&
              b.eligibleForInclusionInSquare &&
              b.color == box.color) {
            GameBox? rb = getBoxAtPosition(box.loc + Offset(1.0, 1.0));
            if (rb != null &&
                rb.eligibleForInclusionInSquare &&
                rb.color == box.color) {
              SquareEventMetadata e = SquareEventMetadata()..color = box.color;
              [box, r, b, rb].forEach((element) => element.squares.add(e));
              squares.add(e);
            }
          }
        }
      }
    }
    return squares;
  }

  bool _removeFeatures() {
    List<RunEventMetadata> runs = [];
    runs.addAll(_markRuns(getRows().values));
    runs.addAll(_markRuns(getCols().values));
    List<SquareEventMetadata> squares = _getSquares();
    // remove all squares and corresponding colors.
    toRemove = boxes
        .where((box) => box.runs.isNotEmpty || box.squares.isNotEmpty)
        .toList();
    for (SquareEventMetadata s in squares) {
      for (GameBox gb in boxes) {
        if (!toRemove.contains(gb) && gb.color == s.color) {
          toRemove.add(gb);
        }
      }
    }
    boxes.removeWhere((box) => toRemove.contains(box));
    for (RunEventMetadata run in runs) {
      run.multiples = runs.length;
      widget.onGameEvent(GameEvent(GameEventType.RUN, metadata: run));
    }
    for (SquareEventMetadata square in squares) {
      widget.onGameEvent(GameEvent(GameEventType.SQUARE, metadata: square));
    }
    return runs.isNotEmpty || squares.isNotEmpty;
  }

  _updateSlidingCollection(List<GameBox> draggedBoxes, Offset dragOffset,
      List<GameBox> undraggedBoxes) {
    // put the other boxes back
    for (GameBox box in undraggedBoxes) {
      box.loc = box.startLoc;
      box.userDragged = false;
      box.collapsing = false;
    }
    for (GameBox box in draggedBoxes) {
      box.loc = box.startLoc + dragOffset;
      box.userDragged = true;
      box.collapsing = false;
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

      stackChildren.addAll(toRemove.map((b) {
        Rect boundsRect = b.getRect(vt);
        double gapSize = boundsRect.width * RELATIVE_GAP_SIZE;
        return Positioned(
            key: b.key,
            top: boundsRect.top,
            left: boundsRect.left,
            child: Padding(
                padding: EdgeInsets.all(gapSize / 2),
                child: Container(
                    height: boundsRect.height - gapSize,
                    width: boundsRect.width - gapSize,
                    child: DisappearingDotsBlock(
                      color: b.color,
                      onFullyDisappeared: () {},
                    ))));
      }));

      stackChildren
          .addAll(boxes.map((b) => GameBoxWidget(box: b, vt: vt)).toList());

      return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapUp: (deets) {
            GameBox? box = getTappedBox(deets.localPosition, vt);
            setState(() {
              if (box == null) {
                boxes.add(GameBox(vt.backward(deets.localPosition), COLORS[0]));
                _snapBoxes();
              } else {
                int colorIndex = COLORS.indexOf(box.color);
                if (colorIndex == COLORS.length - 1) {
                  boxes.remove(box);
                } else {
                  box.color = COLORS[colorIndex + 1];
                }
              }
            });
          },
          onPanStart: (DragStartDetails deets) {
            tapStartLoc = deets.localPosition;
            tapUpdateLoc = deets.localPosition;
            tappedBox = getTappedBox(tapStartLoc, vt);
            if (tappedBox != null) {
              slidingColumn = getColumnMates(tappedBox);
              slidingRow = getRowMates(tappedBox);
            }
            if (boardUpdateTimer != null) {
              boardUpdateTimer!.cancel();
              boardUpdateTimer = null;
            }
          },
          onPanUpdate: (DragUpdateDetails deets) {
            if (tappedBox == null) {
              return;
            }

            tapUpdateLoc = deets.localPosition;
            Rect boxSize = tappedBox!.getStartRect(vt);
            Offset directionDelta = tapUpdateLoc! - boxSize.center;
            Offset dragDelta = tapUpdateLoc! - tapStartLoc!;
            // once the user is outside of a small window they can't change
            // whether they're dragging the column or the row
            if (boxSize.contains(tapUpdateLoc!) && !outsideSnap) {
              if (directionDelta.dy.abs() > directionDelta.dx.abs()) {
                draggingCol = true;
              } else {
                draggingCol = false;
              }
            } else {
              outsideSnap = true;
            }
            setState(() {
              if (draggingCol) {
                _updateSlidingCollection(slidingColumn!,
                    Offset(0, dragDelta.dy / boxSize.height), slidingRow!);
              } else {
                _updateSlidingCollection(slidingRow!,
                    Offset(dragDelta.dx / boxSize.width, 0), slidingColumn!);
              }
            });
          },
          onPanEnd: (DragEndDetails deets) {
            if (tappedBox != null) {
              Offset delta = tapUpdateLoc! - tapStartLoc!;
              Rect boxSize = tappedBox!.getRect(vt);
              if (draggingCol) {
                double gameWorldDragDistance = delta.dy / boxSize.height;
                setState(() {
                  for (GameBox box in slidingColumn!) {
                    Offset translatedOffset =
                        box.startLoc.translate(0, gameWorldDragDistance);

                    box.loc = translatedOffset;
                    box.startLoc = translatedOffset;
                    box.userDragged = false;
                  }
                  _snapBoxes();
                  if (gameWorldDragDistance.abs() > .5) {
                    widget.onGameEvent(GameEvent(GameEventType.USER_MOVE));
                    if (widget.config.boxAddingSpec?.behavior ==
                        BoxAddingBehavior.PER_MOVE) {
                      setState(() {
                        _addBoxRandomlyOnBoard();
                        _addBoxRandomlyOnBoard();
                      });
                    }
                  }
                });
              } else {
                double gameWorldDragDistance = delta.dx / boxSize.width;
                setState(() {
                  for (GameBox box in slidingRow!) {
                    Offset translatedOffset =
                        box.startLoc.translate(gameWorldDragDistance, 0);

                    box.loc = translatedOffset;
                    box.startLoc = translatedOffset;
                    box.userDragged = false;
                  }
                  _snapBoxes();
                  if (gameWorldDragDistance.abs() > .5) {
                    widget.onGameEvent(GameEvent(GameEventType.USER_MOVE));
                    if (widget.config.boxAddingSpec?.behavior ==
                        BoxAddingBehavior.PER_MOVE) {
                      setState(() {
                        _addBoxRandomlyOnBoard();
                        _addBoxRandomlyOnBoard();
                      });
                    }
                  }
                });
              }
            }

            tappedBox = null;
            slidingColumn = null;
            slidingRow = null;
            outsideSnap = false;
            tapStartLoc = null;
            tapUpdateLoc = null;
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
              // ElevatedButton(
              //     child: Text("Step"),
              //     onPressed: () {
              //       _updateBoard(null);
              //     }),
            ],
          ));
    });
  }
}
