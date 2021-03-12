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
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Container(
        height: getSmartBannerHeight(
            mediaQueryData.size, mediaQueryData.orientation),
        child: FutureBuilder<PublisherBannerAd>(
          future: bannerCompleter.future,
          builder: (BuildContext context,
              AsyncSnapshot<PublisherBannerAd> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
              case ConnectionState.active:
                return Container();
              case ConnectionState.done:
                if (snapshot.hasData) {
                  return AdWidget(ad: bannerAd);
                } else {
                  // this will occur in the case of an error loading the ad.
                  return Container();
                }
            }
          },
        ));
  }
}

double getSmartBannerHeight(Size screenSize, Orientation orientation) {
  double dpHeight = orientation == Orientation.portrait
      ? screenSize.height
      : screenSize.width;
  if (dpHeight <= 400.0) {
    return 32.0;
  }
  if (dpHeight > 720.0) {
    return 90.0;
  }
  return 50.0;
}
