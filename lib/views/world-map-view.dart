import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../constants.dart';

class WorldMapView extends StatefulWidget {
  WorldMapView({Key? key}) : super(key: key);

  @override
  _WorldMapViewState createState() => _WorldMapViewState();
}

class _WorldMapViewState extends State<WorldMapView> {
  PageController _pageController = PageController(viewportFraction: .8);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: GREEN_COLOR,
        body: PageView.builder(
            itemCount: 3,
            itemBuilder: (context, page) {
              return FractionallySizedBox(
                  widthFactor: .9,
                  heightFactor: .6,
                  child: Card(
                      shape: CARD_SHAPE,
                      elevation: 4,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text("Goal:",
                                style: Theme.of(context).textTheme.headline2),
                            Text("Disappear the boxes",
                                style: Theme.of(context).textTheme.bodyText1),
                            FractionallySizedBox(
                              widthFactor: .8,
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, "/game");
                                  },
                                  child:
                                      Container(color: BOARD_BACKGROUND_COLOR),
                                ),
                              ),
                            ),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Image.asset("assets/images/star.png"),
                                  Image.asset("assets/images/star.png"),
                                  Image.asset("assets/images/star.png"),
                                ])
                          ])));
            },
            controller: _pageController));
  }
}
