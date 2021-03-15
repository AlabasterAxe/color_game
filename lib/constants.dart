import 'dart:ui';

import 'package:flutter/material.dart';

import 'model.dart';

const RELATIVE_GAP_SIZE = 1 / 12;
const BOX_BORDER_RADIUS = 1 / 8;
const GRID_SIZE = 6;
const COLLAPSE_DURATION_MILLISECONDS = 750;

const BOARD_BACKGROUND_COLOR = Color(0xff486173);

const RED_COLOR = Color(0xffF55454);
const YELLOW_COLOR = Color(0xffFED30B);
const GREEN_COLOR = Color(0xff9CC405);
const BLUE_COLOR = Color(0xff5099B0);

BorderRadiusGeometry cardBorderRadius = BorderRadius.circular(15.0);

ShapeBorder CARD_SHAPE = RoundedRectangleBorder(
  borderRadius: cardBorderRadius,
);

const List<Color> COLORS = [
  RED_COLOR,
  YELLOW_COLOR,
  GREEN_COLOR,
  BLUE_COLOR,
  // Colors.orange,
  // Colors.green,
  // Colors.blue,
  // Colors.purple,
  // Colors.white,
  // Colors.grey,
  // Colors.black,
];

List<ColorGameConfig> levels = [
  ColorGameConfig("tut_1", gridSize: Size(3, 3), predefinedGrid: [
    GameBox(Offset(-1, 0), YELLOW_COLOR),
    GameBox(Offset(0, 1), YELLOW_COLOR),
    GameBox(Offset(1, 0), YELLOW_COLOR),
  ]),
  ColorGameConfig("tut_2", gridSize: Size(5, 5), predefinedGrid: [
    GameBox(Offset(-2, 0), YELLOW_COLOR),
    GameBox(Offset(-1, 0), YELLOW_COLOR),
    GameBox(Offset(0, 1), YELLOW_COLOR),
    GameBox(Offset(1, 0), YELLOW_COLOR),
    GameBox(Offset(2, 0), YELLOW_COLOR),
  ]),
  ColorGameConfig("gamerino"),
];

const String ANDROID_BANNER_AD_UNIT_ID =
    "ca-app-pub-1235186580185107/8452878897";
const String IOS_BANNER_AD_UNIT_ID = "ca-app-pub-1235186580185107/4021026902";

ThemeData colorCollapseTheme = ThemeData(
  // Define the default font family.
  fontFamily: 'Lato',

  // Define the default TextTheme. Use this to specify the default
  // text styling for headlines, titles, bodies of text, and more.
  textTheme: TextTheme(
    headline1: TextStyle(
        fontSize: 64.0, fontWeight: FontWeight.bold, color: Colors.white),
    headline2: TextStyle(
        fontSize: 32.0,
        fontWeight: FontWeight.bold,
        color: BOARD_BACKGROUND_COLOR),
    bodyText1: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
        color: BOARD_BACKGROUND_COLOR),
  ),
);
