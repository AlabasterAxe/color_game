import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

enum SoundEffectType {
  SMALL_POOF,
  MEDIUM_POOF,
  LARGE_POOF,
  SPLASH,
}

final Map<SoundEffectType, List<String>> sfxFileLocations =
    const <SoundEffectType, List<String>>{
  SoundEffectType.SMALL_POOF: [
    "audio/sfx/poof_2.wav",
  ],
  SoundEffectType.MEDIUM_POOF: [
    "audio/sfx/poof_3.wav",
  ],
  SoundEffectType.LARGE_POOF: [
    "audio/sfx/poof_4.wav",
  ],
  SoundEffectType.SPLASH: [
    "audio/sfx/splash.wav",
  ],
};

class AudioService {
  List<AudioPlayer> sfxPlayers = [];
  double sfxVolume = .5;

  void dispose() {
    _stopSounds();
    for (AudioPlayer player in sfxPlayers) {
      player.dispose();
    }
    sfxPlayers = [];
  }

  _stopSounds() {
    for (AudioPlayer player in sfxPlayers) {
      player.stop();
    }
  }

  Future<ByteData> _fetchAsset(String fileName) async {
    return await rootBundle.load('assets/$fileName');
  }

  Future<File> fetchToMemory(String fileName) async {
    final file = File('${(await getTemporaryDirectory()).path}/$fileName');
    await file.create(recursive: true);
    return await file
        .writeAsBytes((await _fetchAsset(fileName)).buffer.asUint8List());
  }

  playSoundEffect(SoundEffectType type) {
    AudioPlayer player = AudioPlayer();
    List<String>? variants = sfxFileLocations[type];
    if (variants != null) {
      if (kIsWeb) {
        player.play(
            "assets/assets/${variants[Random().nextInt(variants.length)]}",
            isLocal: true);
      } else {
        fetchToMemory(variants[Random().nextInt(variants.length)]).then((file) {
          player.play(file.path, isLocal: true);
        });
      }
      sfxPlayers.add(player);
      player.onPlayerCompletion.listen((_) {
        sfxPlayers.remove(player);
      });
    }
  }
}
