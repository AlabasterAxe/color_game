import 'package:color_game/model.dart';
import 'package:color_game/view-transform.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../constants.dart';

class GameBoxWidget extends StatefulWidget {
  final GameBox box;
  final ViewTransformation vt;

  GameBoxWidget({this.box, this.vt}) : super(key: box.key);

  @override
  State<StatefulWidget> createState() => GameBoxWidgetState();
}

class GameBoxWidgetState extends State<GameBoxWidget> {
  @override
  Widget build(BuildContext context) {
    Rect boundsRect = widget.box.getRect(widget.vt);
    double gapSize = boundsRect.width * RELATIVE_GAP_SIZE;

    return AnimatedPositioned(
      duration: Duration(milliseconds: widget.box.userDragged ? 0 : 1000),
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
                  color: widget.box.color,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: Offset(0, 0), // changes position of shadow
                    ),
                  ]))),
    );
  }
}
