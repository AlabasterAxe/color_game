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
  GameBoxWidget(this.box);

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    Rect boundsRect = box.getRect(screenSize);

    return AnimatedPositioned(
      key: box.key,
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

  List<GameBox> boxes = generateGameBoxes();

  List<GameBox> getColumnMates(GameBox tappedBox) {
    List<GameBox> result = [];
    for (GameBox box in boxes) {
      if (tappedBox.loc.dx == box.loc.dx) {
        result.add(box);
      }
    }
    return result;
  }

  List<GameBox> getRowMates(GameBox box) {
    List<GameBox> result = [];
    for (GameBox box in boxes) {
      if (tappedBox.loc.dy == box.loc.dy) {
        result.add(box);
      }
    }
    return result;
  }

  GameBox getTappedBox(Offset globalTapCoords) {
    for (GameBox box in boxes) {
      if (box.getRect(MediaQuery.of(context).size).contains(globalTapCoords)) {
        return box;
      }
    }
    return null;
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
    }

    return result;
  }

  void removeContiguousColors(Iterable<List<GameBox>> rowsorcols) {
    // search for contiguous rows
    // search for contiguous columns
    Set<GameBox> boxesToRemove = Set();
    for (List<GameBox> roworcol in rowsorcols) {
      List<GameBox> streak = [];
      Color streakColor;
      for (GameBox box in roworcol) {
        if (box.color != streakColor) {
          if (streak.length >= 3) {
            boxesToRemove.addAll(streak);
          }
          streak = [box];
          streakColor = box.color;
        } else {
          streak.add(box);
        }
      }
      if (streak.length >= 3) {
        boxesToRemove.addAll(streak);
      }
      // check streak at the end
    }

    boxes.removeWhere((GameBox b) => boxesToRemove.contains(b));
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
            if (delta.dy.abs() > delta.dx.abs()) {
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
            if (delta.dy.abs() > delta.dx.abs()) {
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
                  removeContiguousColors(getRows().values);
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
                  removeContiguousColors(getCols().values);
                }
              });
            }
            setState(() {});
            tappedBox = null;
            slidingColumn = null;
            slidingRow = null;
          },
          child: Stack(
              alignment: Alignment.center,
              children: boxes.map((b) => GameBoxWidget(b)).toList()),
        ),
      ),
    );
  }
}
