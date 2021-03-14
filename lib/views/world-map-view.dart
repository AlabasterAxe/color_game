import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../constants.dart';

class WorldMapView extends StatefulWidget {
  WorldMapView({Key? key}) : super(key: key);

  @override
  _WorldMapViewState createState() => _WorldMapViewState();
}

class _WorldMapViewState extends State<WorldMapView>
    with SingleTickerProviderStateMixin {
  PageController _pageController = PageController(viewportFraction: .8);
  late Animation<Color?> backgroundColor;

  @override
  void initState() {
    super.initState();
    AnimationController swipingAnimationController =
        AnimationController(vsync: this);
    _pageController.addListener(() {
      if (_pageController.page != null) {
        swipingAnimationController.value = _pageController.page! / 3;
      }
    });

    backgroundColor = TweenSequence<Color?>(
      [
        TweenSequenceItem(
          weight: 1.0,
          tween: ColorTween(
            begin: Colors.orangeAccent,
            end: Colors.lightBlue,
          ),
        ),
        TweenSequenceItem(
          weight: 1.0,
          tween: ColorTween(
            begin: Colors.lightBlue,
            end: Colors.green,
          ),
        ),
      ],
    ).animate(swipingAnimationController);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _pageController,
        builder: (context, snapshot) {
          return Scaffold(
              backgroundColor: backgroundColor.value,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text("Goal:",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline2),
                                  Text("Disappear the boxes",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1),
                                  FractionallySizedBox(
                                    widthFactor: .8,
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(context, "/game");
                                        },
                                        child: Container(
                                            color: BOARD_BACKGROUND_COLOR),
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
        });
  }
}
