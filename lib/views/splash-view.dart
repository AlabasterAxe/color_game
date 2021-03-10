import 'package:color_game/services/audio-service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

import '../main.dart';

class SplashView extends StatefulWidget {
  SplashView({Key? key}) : super(key: key);

  @override
  _SplashViewState createState() => _SplashViewState();
}

const Color BACKGROUND_COLOR = Color(0xff0D6334);

List<String> steps = [
  "|",
  "|",
  "|",
  "",
  "",
  "",
  "|",
  "|",
  "|",
  "",
  "",
  "",
  "t|",
  "th|",
  "thk|",
  "thkp|",
  "thkp|",
  "thkp|",
  "thkp",
  "thkp",
  "thkp",
  "thkp|",
  "thkp|",
  "thkp|",
];

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<int> text;
  late VideoPlayerController _videoController;

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: Duration(seconds: 2, milliseconds: 400));

    text = StepTween(
      begin: 0,
      end: steps.length - 1,
    ).animate(_animationController);

    _animationController.forward();
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pushReplacementNamed(context, "/game");
      }
    });

    _videoController = VideoPlayerController.asset('assets/splash.mp4');

    _videoController.addListener(() {
      setState(() {});
    });
    _videoController.initialize().then((_) => setState(() {}));
    _videoController.play();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AppContext.of(context)
        ?.audioService
        .playSoundEffect(SoundEffectType.SPLASH);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: BACKGROUND_COLOR,
      child: Center(
          child: AnimatedBuilder(
              animation: text,
              builder: (context, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                        height: 50,
                        width: 50,
                        child: VideoPlayer(_videoController)),
                    Stack(
                      children: [
                        Text("thkp|",
                            textAlign: TextAlign.left,
                            style: GoogleFonts.courierPrime(
                                color: BACKGROUND_COLOR,
                                decoration: TextDecoration.none)),
                        Text(steps[text.value],
                            textAlign: TextAlign.left,
                            style: GoogleFonts.courierPrime(
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                                decoration: TextDecoration.none)),
                      ],
                    ),
                  ],
                );
              })),
    );
  }
}
