import 'dart:async';

import 'package:color_game/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  late PublisherBannerAd bannerAd;
  final Completer<PublisherBannerAd> bannerCompleter =
      Completer<PublisherBannerAd>();

  @override
  void initState() {
    super.initState();
    bannerAd = PublisherBannerAd(
        adUnitId: ANDROID_BANNER_AD_UNIT_ID,
        request: PublisherAdRequest(nonPersonalizedAds: true),
        sizes: [AdSize.smartBanner],
        listener: AdListener(
          onAdLoaded: (Ad ad) {
            print('PublisherBannerAd loaded.');
            bannerCompleter.complete(ad as PublisherBannerAd);
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            print('PublisherBannerAd failedToLoad: $error');
            bannerCompleter.completeError(ad);
          },
          onAdOpened: (Ad ad) => print('$PublisherBannerAd onAdOpened.'),
          onAdClosed: (Ad ad) => print('$PublisherBannerAd onAdClosed.'),
          onApplicationExit: (Ad ad) =>
              print('PublisherBannerAd onApplicationExit.'),
        ));
    bannerAd.load();
  }

  @override
  void dispose() {
    super.dispose();
    bannerAd.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PublisherBannerAd>(
      future: bannerCompleter.future,
      builder:
          (BuildContext context, AsyncSnapshot<PublisherBannerAd> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
          case ConnectionState.active:
            return Container();
          case ConnectionState.done:
            if (snapshot.hasData) {
              return Container(height: 90.0, child: AdWidget(ad: bannerAd));
            } else {
              return Text('Error loading $PublisherBannerAd');
            }
        }
      },
    );
  }
}
