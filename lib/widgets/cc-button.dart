import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ColorCollapseButton extends StatefulWidget {
  final void Function()? onPressed;
  final Widget child;
  final bool throb;
  const ColorCollapseButton(
      {Key? key, this.onPressed, required this.child, this.throb = false})
      : super(key: key);

  @override
  _ColorCollapseButtonState createState() => _ColorCollapseButtonState();
}

class _ColorCollapseButtonState extends State<ColorCollapseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scale;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: Duration(seconds: 1), vsync: this);
    scale = CurveTween(curve: Curves.easeInOutCubic).animate(controller);
    if (widget.throb) {
      controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: AnimatedBuilder(
          animation: scale,
          builder: (context, snapshot) {
            return Transform.scale(
              scale: 1 + (.1 * scale.value),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: widget.child,
                ),
              ),
            );
          }),
    );
  }
}
