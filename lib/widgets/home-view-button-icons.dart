import 'package:flutter/material.dart';

class TriangleFacingEast extends StatelessWidget {
  final Color color;

  const TriangleFacingEast({Key? key, required this.color}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: TriangleFacingEastPainter(color));
  }
}

class BarChartIcon extends StatelessWidget {
  final Color color;

  const BarChartIcon({Key? key, required this.color}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: BarChartIconPainter(color));
  }
}

class TriangleFacingEastPainter extends CustomPainter {
  final Color color;
  final double pctPadding = .1;

  TriangleFacingEastPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    double padding = size.width * pctPadding;
    canvas.drawPath(
        Path()
          ..moveTo(padding, size.height)
          ..lineTo(size.width - padding, size.height / 2)
          ..lineTo(padding, 0)
          ..close(),
        Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BarChartIconPainter extends CustomPainter {
  final Color color;
  final double pctSpacing = .07;

  BarChartIconPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    double spacing = size.width * pctSpacing;
    double p0 = spacing / 2;
    double p1 = size.width / 3 - spacing / 2;
    double p2 = size.width / 3 + spacing / 2;
    double p3 = (size.width * 2) / 3 - spacing / 2;
    double p4 = (size.width * 2) / 3 + spacing / 2;
    double p5 = size.width - spacing / 2;
    canvas.drawPath(
        Path()
          ..moveTo(p0, size.height)
          ..lineTo(p0, (size.height * 2) / 3)
          ..lineTo(p1, (size.height * 2) / 3)
          ..lineTo(p1, size.height)
          ..moveTo(p2, size.height)
          ..lineTo(p2, 0)
          ..lineTo(p3, 0)
          ..lineTo(p3, size.height)
          ..moveTo(p4, size.height)
          ..lineTo(p4, (size.height * 2) / 5)
          ..lineTo(p5, (size.height * 2) / 5)
          ..lineTo(p5, size.height),
        Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
