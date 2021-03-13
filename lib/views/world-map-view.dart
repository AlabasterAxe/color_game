import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../constants.dart';

class WorldMapView extends StatefulWidget {
  WorldMapView({Key? key}) : super(key: key);

  @override
  _WorldMapViewState createState() => _WorldMapViewState();
}

class _WorldMapViewState extends State<WorldMapView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GREEN_COLOR,
    );
  }
}
