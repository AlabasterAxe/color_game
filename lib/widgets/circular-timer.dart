import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CircularTimer extends StatefulWidget {
  final Duration duration;
  final Function() onFinished;
  final bool stop;

  const CircularTimer(
      {required Key key,
      required this.duration,
      required this.onFinished,
      this.stop = false})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => CircularTimerState();
}

class CircularTimerState extends State<CircularTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: widget.duration);
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onFinished();
      }
    });

    controller.forward();
  }

  @override
  void didUpdateWidget(CircularTimer previousWidget) {
    if (widget.stop) {
      controller.stop();
    }
  }

  @override
  void dispose() {
    if (controller != null) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: controller,
      builder: (context, child) => controller.value == 1.0
          ? Container()
          : CustomPaint(
              painter: CircularTimerPainter(1.0 - controller.value),
            ));
}

class CircularTimerPainter extends CustomPainter {
  final double pct;

  CircularTimerPainter(this.pct);

  @override
  void paint(Canvas canvas, Size size) {
    Paint p = Paint()..color = Colors.white.withAlpha(125);
    Paint stroke = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    Path piePath = Path()
      ..moveTo(size.width / 2.0, size.height / 2.0)
      ..arcTo(
          Rect.fromCircle(
              center: Offset(size.width / 2.0, size.height / 2.0),
              radius: size.width / 2.0),
          -pi / 2.0,
          2 * pi * pct,
          false)
      ..lineTo(size.width / 2.0, size.height / 2.0);
    canvas.drawPath(piePath, p);
    canvas.drawPath(piePath, stroke);
  }

  @override
  bool shouldRepaint(CircularTimerPainter o) => o.pct != pct;
}
