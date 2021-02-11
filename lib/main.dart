import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

const box_size = 60.0;
const gap_size = 5.0;
const world_to_offset_ratio = box_size + gap_size;

// this offset is rounding to the unit-sized .5 offset grid
const Offset roundOffset = Offset(.5, .5);

class GameBox {
  // this is the box's drawn location
  Offset loc;

  // this stores the original location of the box during a drag
  Offset startLoc;
  Color color;
  bool userDragged = false;
  Key key = UniqueKey();

  GameBox(this.loc, this.color) {
    startLoc = loc;
  }

  Rect getRect(Size screenSize) {
    double totalBoxSize = box_size + gap_size;
    Offset screenCenterOffset =
        Offset(screenSize.width / 2, screenSize.height / 2);
    Offset boxCenterOffset = screenCenterOffset + (loc * totalBoxSize);

    return Rect.fromCenter(
        center: boxCenterOffset, height: totalBoxSize, width: totalBoxSize);
  }
}

List<GameBox> generateGameBoxes() {
  Random r = Random();
  List<GameBox> result = [];
  List<Color> colors = [Colors.red, Colors.yellow, Colors.green, Colors.blue];
  for (double x = -2.5; x <= 2.5; x++) {
    for (double y = -2.5; y <= 2.5; y++) {
      List<Color> availableColors = [...colors];
      for (int i = result.length - 1; i >= 0; i--) {
        if (result[i].loc.dx == x && result[i].loc.dy == y - 1) {
          availableColors.remove(result[i].color);
        } else if (result[i].loc.dy == y && result[i].loc.dx == x - 1) {
          availableColors.remove(result[i].color);
        }
      }
      int colorIdx = r.nextInt(availableColors.length);
      result.add(GameBox(Offset(x, y), availableColors[colorIdx]));
    }
  }

  return result;
}

class GameBoxWidget extends StatelessWidget {
  final GameBox box;
  GameBoxWidget({this.box}) : super(key: box.key);

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    Rect boundsRect = box.getRect(screenSize);

    return AnimatedPositioned(
      // key: box.key,
      duration: Duration(milliseconds: box.userDragged ? 0 : 1000),
      curve: Curves.easeInOut,
      top: boundsRect.top,
      left: boundsRect.left,
      child: Padding(
          padding: const EdgeInsets.all(gap_size),
          child: Container(
              height: box_size,
              width: box_size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: box.color,
              ))),
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  Offset tapStartLoc;
  Offset tapUpdateLoc;
  GameBox tappedBox;
  List<GameBox> slidingRow;
  List<GameBox> slidingColumn;
  Timer boardUpdateTimer;
  bool _settled = true;

  // if they're not dragging col, they're dragging row;
  bool draggingCol;

  List<GameBox> boxes = generateGameBoxes();

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
    Offset sum = Offset(0, 0);
    for (GameBox box in boxes.where((b) => b.color != Colors.transparent)) {
      sum += box.loc;
    }

    Offset gravitationalCenter = sum / boxes.length.toDouble();
    List<GameBox> distSortedBoxes = [...boxes];

    distSortedBoxes.sort((a, b) => (gravitationalCenter - a.loc)
        .distanceSquared
        .compareTo((gravitationalCenter - b.loc).distanceSquared));

    List<GameBox> affectedBoxes = [];
    for (GameBox box in distSortedBoxes) {
      List<double> cardinals = [0, pi / 2, pi, (3 * pi) / 2, 2 * pi];
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

  void updateBoardTillSettled() {
    boardUpdateTimer = Timer.periodic(Duration(milliseconds: 1000), (t) {
      setState(() {
        var affectedRows = _removeContiguous();
        if (affectedRows.isNotEmpty) {
          _settled = false;
        }
        List<GameBox> affectedBoxes = [];
        if (!_settled) {
          affectedBoxes = _gravitize();
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
  List<List<GameBox>> removeContiguousColors(
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

  void collapseRowGaps(Iterable<List<GameBox>> rows) {
    double minX;
    double maxX;
    double sumX = 0;
    for (GameBox box in boxes.where((b) => b.color != Colors.transparent)) {
      if (minX == null || minX > box.loc.dx) {
        minX = box.loc.dx;
      }
      if (maxX == null || maxX < box.loc.dx) {
        maxX = box.loc.dx;
      }
      sumX += box.loc.dx;
    }
    double centerPosition = (sumX / boxes.length).round() + .5;
    for (List<GameBox> row in rows) {
      if (row.isEmpty) {
        continue;
      }

      double boxPosition = centerPosition - (row.length / 2).round();
      for (GameBox box in row) {
        box.loc = Offset(boxPosition, box.loc.dy);
        box.startLoc = Offset(boxPosition, box.loc.dy);
        boxPosition++;
      }
    }
  }

  void collapseColGaps(Iterable<List<GameBox>> cols) {
    double minY;
    double maxY;
    double sumY = 0;
    for (GameBox box in boxes.where((b) => b.color != Colors.transparent)) {
      if (minY == null || minY > box.loc.dy) {
        minY = box.loc.dy;
      }
      if (maxY == null || maxY < box.loc.dy) {
        maxY = box.loc.dy;
      }
      sumY += box.loc.dy;
    }
    double centerPosition = (sumY / boxes.length).round() + .5;
    for (List<GameBox> col in cols) {
      double boxPosition = centerPosition - (col.length / 2).round();
      for (GameBox box in col) {
        box.loc = Offset(box.loc.dx, boxPosition);
        box.startLoc = Offset(box.loc.dx, boxPosition);
        boxPosition++;
      }
    }
  }

  List<List<GameBox>> _removeContiguous() {
    List<List<GameBox>> result = [];
    result.addAll(removeContiguousColors(getRows().values));
    result.addAll(removeContiguousColors(getCols().values));
    return result;
  }

  @override
  Widget build(BuildContext context) {
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
              // once the user is outside of a small window they can't change
              // whether they're dragging the column or the row
              if (delta.distance < box_size / 2) {
                if (delta.dy.abs() > delta.dx.abs()) {
                  draggingCol = true;
                } else {
                  draggingCol = false;
                }
              }
              if (draggingCol) {
                setState(() {
                  // put the other boxes back
                  for (GameBox box in slidingRow) {
                    box.loc = box.startLoc;
                    box.userDragged = false;
                  }
                  for (GameBox box in slidingColumn) {
                    box.loc = box.startLoc
                        .translate(0, delta.dy / world_to_offset_ratio);
                    box.userDragged = true;
                  }
                });
              } else {
                setState(() {
                  // put the other boxes back
                  for (GameBox box in slidingColumn) {
                    box.loc = box.startLoc;
                    box.userDragged = false;
                  }
                  for (GameBox box in slidingRow) {
                    box.loc = box.startLoc
                        .translate(delta.dx / world_to_offset_ratio, 0);
                    box.userDragged = true;
                  }
                });
              }
            },
            onPanEnd: (DragEndDetails deets) {
              Offset delta = tapUpdateLoc - tapStartLoc;
              if (draggingCol) {
                setState(() {
                  for (GameBox box in slidingColumn) {
                    Offset translatedOffset = box.startLoc
                            .translate(0, delta.dy / world_to_offset_ratio) +
                        roundOffset;

                    Offset roundedOffset = Offset(
                            translatedOffset.dx.roundToDouble(),
                            translatedOffset.dy.roundToDouble()) -
                        roundOffset;
                    box.loc = roundedOffset;
                    box.startLoc = roundedOffset;
                    box.userDragged = false;
                  }
                });
              } else {
                setState(() {
                  for (GameBox box in slidingRow) {
                    Offset translatedOffset = box.startLoc
                            .translate(delta.dx / world_to_offset_ratio, 0) +
                        roundOffset;

                    Offset roundedOffset = Offset(
                            translatedOffset.dx.roundToDouble(),
                            translatedOffset.dy.roundToDouble()) -
                        roundOffset;
                    box.loc = roundedOffset;
                    box.startLoc = roundedOffset;
                    box.userDragged = false;
                  }
                });
              }
              tappedBox = null;
              slidingColumn = null;
              slidingRow = null;
              updateBoardTillSettled();
            },
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                      alignment: Alignment.center,
                      children:
                          boxes.map((b) => GameBoxWidget(box: b)).toList()),
                ),
              ],
            )),
      ),
    );
  }
}
