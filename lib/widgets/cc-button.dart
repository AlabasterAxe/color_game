import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ColorCollapseButton extends StatelessWidget {
  final void Function()? onPressed;
  final Widget? child;
  const ColorCollapseButton({Key? key, this.onPressed, @required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: child,
        ),
      ),
    );
  }
}
