import 'package:color_game/services/audio-service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

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
  late AnimationController controller;
  late Animation<int> text;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this, duration: Duration(seconds: 2, milliseconds: 400));

    text = StepTween(
      begin: 0,
      end: steps.length - 1,
    ).animate(controller);

    controller.forward();
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pushReplacementNamed(context, "/game");
      }
    });
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
                return Stack(
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
                );
              })),
    );
  }
}
