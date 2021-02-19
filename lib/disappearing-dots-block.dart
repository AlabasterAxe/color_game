import 'dart:math';

import 'package:color_game/constants.dart';
import 'package:flutter/widgets.dart';

class DisappearingDotsBlock extends StatefulWidget {
  final Color color;
  final void Function() onFullyDisappeared;

  const DisappearingDotsBlock({Key key, this.color, this.onFullyDisappeared})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => DisappearingDotsBlockState();
}

class _Dot {
  final Offset c;
  final double r;

  _Dot(this.c, this.r);
}

class DisappearingDotsBlockState extends State<DisappearingDotsBlock>
    with SingleTickerProviderStateMixin {
  Random r = Random();
  AnimationController controller;

  List<_Dot> dots;

  Animation<double> dotsPctGone;
  Animation<double> overallSize;

  @override
  void initState() {
    super.initState();

    dots = [];
    for (int i = 0; i < 100; i++) {
      dots.add(_Dot(
          Offset(-1.0 + r.nextDouble() * 2.0, -1.0 + r.nextDouble() * 2.0),
          r.nextDouble() * .75));
    }

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 750));

    dotsPctGone = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    overallSize = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.05), weight: .1),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: .5), weight: .9),
    ]).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onFullyDisappeared();
      }
    });
    controller.forward();
  }

  @override
  void dispose() {
    if (controller != null) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) => CustomPaint(
        painter: DisappearingDotsBlockPainter(
            dots, dotsPctGone.value, overallSize.value, widget.color),
      ),
    );
  }
}

class DisappearingDotsBlockPainter extends CustomPainter {
  final List<_Dot> dots;
  final double pctGone;
  final double sizeMultiplier;
  final Color color;

  DisappearingDotsBlockPainter(
      this.dots, this.pctGone, this.sizeMultiplier, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    Size actualSize = size * sizeMultiplier;
    double radius = actualSize.width * .5;
    Offset center = Offset(size.width * .5, size.height * .5);
    Rect rect = Rect.fromCenter(
        center: center, width: actualSize.width, height: actualSize.height);
    canvas.saveLayer(rect, Paint());
    canvas.clipRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(BOX_BORDER_RADIUS)));

    for (_Dot d in dots) {
      canvas.drawCircle(
          Offset(center.dx + d.c.dx * radius, center.dy + d.c.dy * radius),
          radius * d.r * (1.0 - pctGone),
          Paint()..color = color);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(DisappearingDotsBlockPainter o) =>
      pctGone != o.pctGone || sizeMultiplier != o.sizeMultiplier;
}
