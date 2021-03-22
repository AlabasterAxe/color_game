import 'dart:async';
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

enum Instrument {
  UKULELE,
}

enum NoteName {
  A,
  A_SHARP,
  B,
  C,
  C_SHARP,
  D,
  D_SHARP,
  E,
  F,
  F_SHARP,
  G,
  G_SHARP,
}

final Map<Instrument, Map<NoteName, String>> INSTRUMENTS = {
  Instrument.UKULELE: {
    NoteName.C: "audio/sfx/uke/c.mp3",
    NoteName.C_SHARP: "audio/sfx/uke/c#.mp3",
    NoteName.D: "audio/sfx/uke/d.mp3",
    NoteName.D_SHARP: "audio/sfx/uke/d#.mp3",
    NoteName.E: "audio/sfx/uke/e.mp3",
    NoteName.F: "audio/sfx/uke/f.mp3",
    NoteName.F_SHARP: "audio/sfx/uke/f#.mp3",
    NoteName.G: "audio/sfx/uke/g.mp3",
    NoteName.G_SHARP: "audio/sfx/uke/g#.mp3",
    NoteName.A: "audio/sfx/uke/a.mp3",
    NoteName.A_SHARP: "audio/sfx/uke/a#.mp3",
    NoteName.B: "audio/sfx/uke/b.mp3",
  }
};

class AudioService {
  List<AudioPlayer> sfxPlayers = [];
  Map<Instrument, Map<NoteName, AudioPlayer>> notePlayers = {};
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

  playNote(Instrument instrument, NoteName note) {
    AudioPlayer? currentAudioPlayer = notePlayers[instrument]?[note];
    if (currentAudioPlayer != null) {
      return;
    }
    AudioPlayer player = AudioPlayer();
    player.mode = PlayerMode.LOW_LATENCY;
    String? noteFile = INSTRUMENTS[instrument]?[note];
    if (noteFile != null) {
      if (kIsWeb) {
        player.play("assets/assets/${noteFile}", isLocal: true);
      } else {
        fetchToMemory(noteFile).then((file) {
          player.play(file.path, isLocal: true);
        });
      }
      notePlayers.putIfAbsent(instrument, () => {})[note] = player;
      Timer(Duration(milliseconds: 1000), () {
        AudioPlayer? notePlayer = notePlayers[instrument]?[note];
        if (notePlayer != null) {
          notePlayer.stop();
          notePlayer.dispose();
          notePlayers[instrument]!.remove(note);
        }
      });
    }
  }
}
