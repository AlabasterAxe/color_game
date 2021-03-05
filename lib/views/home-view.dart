import 'package:color_game/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../model.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: BOARD_BACKGROUND_COLOR,
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Text("Color Collapse",
                style: TextStyle(fontSize: 64, color: Colors.grey[200], decoration: TextDecoration.none)),
            ElevatedButton(
                child: Text(
                  "Play",
                ),
                onPressed: () {
                  Navigator.pushNamed(context, "/game", arguments: ColorGameConfig());
                }),
          ]),
        ));
  }
}
