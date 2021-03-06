import 'dart:ui';

import 'package:flutter/cupertino.dart';

class ViewTransformation {
  Rect? from;
  Rect? to;

  late double xm;

  late double ym;

  ViewTransformation({this.from, this.to}) {
    double aXSpan = this.from!.right - this.from!.left;
    double bXSpan = this.to!.right - this.to!.left;

    xm = aXSpan / bXSpan;

    double aYSpan = this.from!.top - this.from!.bottom;
    double bYSpan = this.to!.top - this.to!.bottom;

    ym = aYSpan / bYSpan;
  }

  Offset forward(Offset point) {
    Offset shifted = point - Offset(from!.left, from!.bottom);
    Offset scaled = Offset(shifted.dx / xm, shifted.dy / ym);
    return scaled + Offset(to!.left, to!.bottom);
  }

  Offset backward(Offset point) {
    Offset shifted = point - Offset(to!.left, to!.bottom);
    Offset scaled = Offset(shifted.dx * xm, shifted.dy * ym);
    return scaled + Offset(from!.left, from!.bottom);
  }

  double scaleForwards(double val) {
    return val / xm;
  }

  double scaleBackwards(double val) {
    return val * xm;
  }

  Rect rectForward(Rect val) {
    return Rect.fromPoints(
        this.forward(val.topLeft), this.forward(val.bottomRight));
  }

  Rect rectBackward(Rect val) {
    return Rect.fromPoints(
        this.backward(val.topLeft), this.backward(val.bottomRight));
  }
}
