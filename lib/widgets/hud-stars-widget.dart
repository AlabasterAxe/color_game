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
    if (!oldWidget.earned && widget.earned) {
      imageAsset = TweenSequence([
        TweenSequenceItem(
            tween: ConstantTween("assets/images/star.png"), weight: .3),
        TweenSequenceItem(
            tween: ConstantTween("assets/images/gold_star.png"), weight: .7)
      ]).animate(animation);
      angle = Tween(begin: 0.0, end: 2 * pi * 3)
          .animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));
      animation.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: animation,
        builder: (context, child) => Transform(
              transform: Matrix4.rotationZ(angle.value),
              alignment: Alignment.center,
              child: Image.asset(imageAsset.value, width: widget.size),
            ));
  }
}
