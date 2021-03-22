import 'dart:math';

import 'package:flutter/cupertino.dart';

class HudStarsWidget extends StatefulWidget {
  final int numberOfStars;
  final double starWidth;

  const HudStarsWidget(
      {Key? key, required this.numberOfStars, required this.starWidth})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => HudStarsWidgetState();
}

class HudStarsWidgetState extends State<HudStarsWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _SpinningAnimatedStar(
        earned: widget.numberOfStars > 0,
        size: widget.starWidth,
        durationMS: 300,
      ),
      SizedBox(width: 8),
      _SpinningAnimatedStar(
        earned: widget.numberOfStars > 1,
        size: widget.starWidth,
        durationMS: 600,
      ),
      SizedBox(width: 8),
      _SpinningAnimatedStar(
        earned: widget.numberOfStars > 2,
        size: widget.starWidth,
        durationMS: 900,
      ),
    ]);
  }
}

class _SpinningAnimatedStar extends StatefulWidget {
  final double size;
  final bool earned;
  final int durationMS;

  const _SpinningAnimatedStar(
      {Key? key,
      required this.size,
      required this.earned,
      required this.durationMS})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _SpinningAnimatedStarState();
}

class _SpinningAnimatedStarState extends State<_SpinningAnimatedStar>
    with SingleTickerProviderStateMixin {
  late AnimationController animation;
  Animation<double> angle = AlwaysStoppedAnimation(0);
  Animation<String> imageAsset =
      AlwaysStoppedAnimation("assets/images/star.png");
  Animation<double> innerSizePct = AlwaysStoppedAnimation(1.0);

  @override
  void initState() {
    super.initState();
    animation = AnimationController(
        vsync: this, duration: Duration(milliseconds: widget.durationMS));
    imageAsset = AlwaysStoppedAnimation(widget.earned
        ? "assets/images/gold_star.png"
        : "assets/images/star.png");
  }

  @override
  void didUpdateWidget(_SpinningAnimatedStar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.earned != widget.earned) {
      imageAsset = TweenSequence([
        TweenSequenceItem(
            tween: ConstantTween(widget.earned
                ? "assets/images/star.png"
                : "assets/images/gold_star.png"),
            weight: .3),
        TweenSequenceItem(
            tween: ConstantTween(widget.earned
                ? "assets/images/gold_star.png"
                : "assets/images/star.png"),
            weight: .7)
      ]).animate(animation);
      angle = Tween(begin: 0.0, end: 2 * pi * 3)
          .animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));
      innerSizePct = TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: .5), weight: .5),
        TweenSequenceItem(tween: Tween(begin: .5, end: 1.0), weight: .5)
      ]).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));
      animation.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: animation,
        builder: (context, child) => Container(
            width: widget.size,
            child: Center(
                child: Transform(
              transform: Matrix4.rotationZ(angle.value),
              alignment: Alignment.center,
              child: Image.asset(imageAsset.value,
                  width: widget.size * innerSizePct.value),
            ))));
  }
}
