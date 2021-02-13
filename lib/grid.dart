import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

List<Widget> grid(Size screenSize, Rect boxRect) {
  List<Widget> results = [];
  double maxWidth = 0;
  double minWidth = 0;
  while (maxWidth - minWidth < screenSize.width) {
    results.add(Positioned(
        top: 0,
        bottom: 0,
        left: screenSize.width / 2 + maxWidth + 1,
        width: 2,
        child: Container(color: Colors.grey)));
    if (minWidth != maxWidth) {
      results.add(Positioned(
          top: 0,
          bottom: 0,
          left: screenSize.width / 2 + minWidth + 1,
          width: 2,
          child: Container(color: Colors.grey)));
    }

    maxWidth += boxRect.width;
    minWidth -= boxRect.width;
  }

  double maxHeight = 0;
  double minHeight = 0;
  while (maxHeight - minHeight < screenSize.height) {
    results.add(Positioned(
        left: 0,
        right: 0,
        top: screenSize.height / 2 + maxHeight + 1,
        height: 2,
        child: Container(color: Colors.grey)));
    if (minHeight != maxHeight) {
      results.add(Positioned(
          left: 0,
          right: 0,
          top: screenSize.height / 2 + minHeight + 1,
          height: 2,
          child: Container(color: Colors.grey)));
    }

    maxHeight += boxRect.height;
    minHeight -= boxRect.height;
  }

  return results;
}
