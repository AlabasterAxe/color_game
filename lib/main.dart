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

const box_size = 100.0;
const gap_size = 10.0;
const world_to_offset_ratio = box_size + gap_size;

// this offset is rounding to the unit-sized .5 offset grid
const Offset roundOffset = Offset(.5, .5);

class GameBox {
  // this is the box's drawn location
  Offset loc;

  // this stores the original location of the box during a drag
  Offset startLoc;
  Color color;

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

class GameBoxWidget extends StatelessWidget {
  final GameBox box;
  GameBoxWidget(this.box);

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    Rect boundsRect = box.getRect(screenSize);

    return Positioned(
      top: boundsRect.top,
      left: boundsRect.left,
      child: Padding(
        padding: const EdgeInsets.all(gap_size),
        child: Container(
          height: box_size,
          width: box_size,
          color: box.color,
        ),
      ),
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  Offset tapStartLoc;
  Offset tapUpdateLoc;
  GameBox tappedBox;
  List<GameBox> slidingRow;
  List<GameBox> slidingColumn;

  List<GameBox> boxes = [
    GameBox(Offset(.5, .5), Colors.red),
    GameBox(Offset(.5, -.5), Colors.green),
    GameBox(Offset(-.5, -.5), Colors.yellow),
    GameBox(Offset(-0.5, .5), Colors.blue),
  ];

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
                for (GameBox box in slidingColumn) {
                  box.loc = box.startLoc
                      .translate(0, delta.dy / world_to_offset_ratio);
                }
              });
            } else {
              setState(() {
                for (GameBox box in slidingRow) {
                  box.loc = box.startLoc
                      .translate(delta.dx / world_to_offset_ratio, 0);
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
                }
              });
            }
            tappedBox = null;
            slidingColumn = null;
            slidingRow = null;
            // snap boxes
            // update start locations
          },
          child: Stack(
              alignment: Alignment.center,
              children: boxes.map((b) => GameBoxWidget(b)).toList()),
        ),
      ),
    );
  }
}
