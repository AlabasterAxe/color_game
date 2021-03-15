import 'dart:async';

import 'package:color_game/game/game-board.dart';
import 'package:color_game/widgets/cc-button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../constants.dart';
import '../model.dart';

class WorldMapView extends StatefulWidget {
  WorldMapView({Key? key}) : super(key: key);

  @override
  _WorldMapViewState createState() => _WorldMapViewState();
}

class WorldMapItem {
  ColorGameConfig gameConfig;
  Color backgroundColor;
  WorldMapItem({
    this.gameConfig = const ColorGameConfig("default"),
    this.backgroundColor = Colors.black,
  });
}

class _WorldMapViewState extends State<WorldMapView>
    with SingleTickerProviderStateMixin {
  PageController _pageController = PageController(viewportFraction: .8);
  late List<WorldMapItem> _items;

  @override
  void initState() {
    super.initState();
    _items = levels
        .asMap()
        .entries
        .map((entry) => WorldMapItem(
              gameConfig: entry.value,
              backgroundColor: COLORS[entry.key % COLORS.length],
            ))
        .toList();
  }

  bool _shouldAdvancePage(GameCompletedEvent? ev) {
    return (ev != null &&
        ev.successful &&
        _pageController.page != null &&
        _pageController.page! < _items.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _pageController,
        builder: (context, snapshot) {
          double pageValue =
              _pageController.hasClients ? _pageController.page ?? 0 : 0;
          int prevPage = pageValue.floor();
          int nextPage = pageValue.ceil();
          double pageLerp = pageValue - prevPage;

          return Scaffold(
              backgroundColor: Color.lerp(_items[prevPage].backgroundColor,
                  _items[nextPage].backgroundColor, pageLerp),
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
                                          Navigator.pushNamed(context, "/game",
                                                  arguments:
                                                      _items[page.floor()]
                                                          .gameConfig)
                                              .then((ev) {
                                            if (_shouldAdvancePage(
                                                ev as GameCompletedEvent?)) {
                                              Timer(Duration(seconds: 1), () {
                                                _pageController.animateToPage(
                                                  (_pageController.page! + 1)
                                                      .round(),
                                                  duration: Duration(
                                                      milliseconds: 500),
                                                  curve: Curves.easeInOut,
                                                );
                                              });
                                            }
                                          });
                                        },
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        cardBorderRadius,
                                                    color:
                                                        BOARD_BACKGROUND_COLOR),
                                                child: GameBoardWidget(
                                                    _items[page.floor()]
                                                        .gameConfig)),
                                            Opacity(
                                              opacity: .7,
                                              child: ColorCollapseButton(
                                                child: Image.asset(
                                                    "assets/images/play_button.png"),
                                              ),
                                            ),
                                          ],
                                        ),
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
