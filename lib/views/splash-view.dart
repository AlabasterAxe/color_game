import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';

class SplashView extends StatefulWidget {
  SplashView({Key? key}) : super(key: key);

  @override
  _SplashViewState createState() => _SplashViewState();
}

const Color ANDROID_BACKGROUND_COLOR = Color(0xff0D6334);
const Color IOS_BACKGROUND_COLOR = Color(0xff0f572f);

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _videoController;

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _videoController = VideoPlayerController.asset('assets/splash.mp4');

    _videoController.initialize().then((_) => setState(() {}));
    _videoController.play();

    _videoController.addListener(() {
      setState(() {});
      // if (_videoController.value.position == _videoController.value.duration) {
      //   Navigator.pushReplacementNamed(context, "/");
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Platform.isIOS ? IOS_BACKGROUND_COLOR : ANDROID_BACKGROUND_COLOR,
      child: Center(
          child: FractionallySizedBox(
        widthFactor: 1 / 2,
        child: AspectRatio(
          aspectRatio: 2.4,
          child: VideoPlayer(_videoController),
        ),
      )),
    );
  }
}
