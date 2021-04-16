// @dart=2.9

import 'package:device_preview/device_preview.dart'; // ignore: unused_import
import 'package:device_preview/plugins.dart'; // ignore: unused_import
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await MobileAds.instance.initialize();
  runApp(DevicePreview(
      enabled: true,
      plugins: [const ScreenshotPlugin()],
      builder: (context) {
        return MyApp(
          builderWrapper: DevicePreview.appBuilder,
        );
      }));
}
