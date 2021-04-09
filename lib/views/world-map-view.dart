import 'dart:async';
import 'dart:math';

import 'package:color_game/game/game-board.dart';
import 'package:color_game/main.dart';
import 'package:color_game/services/analytics-service.dart';
import 'package:color_game/widgets/cc-button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../constants.dart';
import '../model.dart';
import '../shared-pref-helper.dart';

class WorldMapView extends StatefulWidget {
  WorldMapView({Key? key}) : super(key: key);

  @override
  _WorldMapViewState createState() => _WorldMapViewState();
}

class WorldMapItem {
  ColorGameConfig gameConfig;
  Color backgroundColor;
  int maxStars;
  WorldMapItem({
    required this.gameConfig,
    required this.backgroundColor,
    required this.maxStars,
  });
}

class _WorldMapViewState extends State<WorldMapView>
    with SingleTickerProviderStateMixin {
  PageController _pageController = PageController(viewportFraction: .8);
  late List<WorldMapItem> _items;
  int _numVisibleItems = 2;

  // this control whether we jump to the next page after the user completes a
  // level
  bool shouldAdvancePage = false;

  @override
  void initState() {
    super.initState();
    _items = levels
        .asMap()
        .entries
        .map((entry) => WorldMapItem(
              gameConfig: entry.value,
              backgroundColor: COLORS[entry.key % COLORS.length],
              maxStars: 0,
            ))
        .toList();
    _getAttemptHistory().then((_) {
      int targetPage = _numVisibleItems - 2;
      _pageController.jumpToPage(max(0, targetPage - 4));
      _pageController.animateToPage(targetPage,
          duration: Duration(milliseconds: 750), curve: Curves.easeInOut);
    });
    _pageController.addListener(() {
      shouldAdvancePage = false;
    });
  }

  Future<void> _getAttemptHistory() async {
    int newVisibleItems = 2;
    for (WorldMapItem item in _items) {
      List<Score> scores = await getScores(item.gameConfig.label);
      int newMax =
          scores.fold(0, (maxStars, score) => max(maxStars, score.earnedStars));
      if (newMax > item.maxStars) {
        setState(() {
          item.maxStars = newMax;
        });
      }
      if (newMax > 0) {
        newVisibleItems += 1;
        setState(() {
          _numVisibleItems = newVisibleItems;
        });
      }
    }
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
              appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
              backgroundColor: Color.lerp(_items[prevPage].backgroundColor,
                  _items[nextPage].backgroundColor, pageLerp),
              body: PageView.builder(
                  itemCount: min(_numVisibleItems, _items.length),
                  itemBuilder: (context, page) {
                    return FractionallySizedBox(
                        widthFactor: .9,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 32),
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
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                          _items[page].gameConfig.goalString,
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1!),
                                    ),
                                    FractionallySizedBox(
                                      widthFactor: .8,
                                      child: AspectRatio(
                                        aspectRatio: 1,
                                        child: GestureDetector(
                                          onTap: page == (_numVisibleItems - 1)
                                              ? null
                                              : () {
                                                  AppContext.of(context)
                                                      .analytics
                                                      .logEvent(AnalyticsEvent
                                                          .start_game);
                                                  Navigator.pushNamed(
                                                          context, "/game",
                                                          arguments: _items[
                                                                  page.floor()]
                                                              .gameConfig)
                                                      .then((ev) {
                                                    int nextPage =
                                                        (_pageController.page! +
                                                                1)
                                                            .round();
                                                    shouldAdvancePage =
                                                        _shouldAdvancePage(ev
                                                            as GameCompletedEvent?);
                                                    Timer(
                                                        Duration(
                                                            milliseconds: 400),
                                                        () {
                                                      _getAttemptHistory();
                                                      if (shouldAdvancePage) {
                                                        Timer(
                                                            Duration(
                                                                milliseconds:
                                                                    750), () {
                                                          if (shouldAdvancePage) {
                                                            _pageController
                                                                .animateToPage(
                                                              nextPage,
                                                              duration: Duration(
                                                                  milliseconds:
                                                                      500),
                                                              curve: Curves
                                                                  .easeInOut,
                                                            );
                                                          }
                                                        });
                                                      }
                                                    });
                                                  });
                                                },
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Container(
                                                  clipBehavior: Clip.hardEdge,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          cardBorderRadius,
                                                      color:
                                                          BOARD_BACKGROUND_COLOR),
                                                  child: IgnorePointer(
                                                    child: GameBoardWidget(
                                                        _items[page.floor()]
                                                            .gameConfig,
                                                        onGameEvent: (_) {}),
                                                  )),
                                              Opacity(
                                                opacity: .7,
                                                child: ColorCollapseButton(
                                                  child: Icon(
                                                    page ==
                                                            (_numVisibleItems -
                                                                1)
                                                        ? Icons.lock
                                                        : Icons.play_arrow,
                                                    color:
                                                        BOARD_BACKGROUND_COLOR,
                                                    size: 72,
                                                  ),
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
                                          Image.asset(
                                              "assets/images/${_items[page].maxStars > 0 ? "gold_star" : "star"}.png"),
                                          Image.asset(
                                              "assets/images/${_items[page].maxStars > 1 ? "gold_star" : "star"}.png"),
                                          Image.asset(
                                              "assets/images/${_items[page].maxStars > 2 ? "gold_star" : "star"}.png"),
                                        ])
                                  ])),
                        ));
                  },
                  controller: _pageController));
        });
  }
}
