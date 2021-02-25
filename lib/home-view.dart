import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'model.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.red,
        child: Center(
          child: RaisedButton(
              child: Text("Play"),
              onPressed: () {
                Navigator.pushNamed(context, "/game",
                    arguments: ColorGameConfig()..gridSize = Size(6, 6));
              }),
        ));
  }
}
