import 'dart:math';

import 'package:color_game/services/audio-service.dart';

import '../model.dart';

List<List<int>> CHORD_PROGRESSIONS = [
  [0, 3, 7],
  [5, 9, 12],
  [10, 14, 17],
];

class SoundGameEventListener {
  NoteName currentNote = NoteName.C;
  int playedSoundsForStep = -1;
  AudioService audioService;

  SoundGameEventListener(this.audioService);

  onGameEvent(GameEvent event) {
    switch (event.type) {
      case GameEventType.USER_MOVE:
        audioService.playSoundEffect(SoundEffectType.WHOOSH, volume: .3);
        break;
      case GameEventType.LEFT_OVER_BOX:
        audioService.playSoundEffect(SoundEffectType.POP);
        break;
      case GameEventType.RUN:
        if (playedSoundsForStep != event.metadata.stepNumber &&
            event.metadata.runStreakLength == 1) {
          currentNote = currentNote.minorSecond;
        }
        if (playedSoundsForStep < event.metadata.stepNumber) {
          List<int> intervalsToPlay = CHORD_PROGRESSIONS[min(
                  event.metadata.runStreakLength - 1,
                  CHORD_PROGRESSIONS.length - 1)]
              .take(event.metadata.multiples)
              .toList();

          for (int interval in intervalsToPlay) {
            audioService.playNote(
                Instrument.MARIMBA, currentNote.interval(interval));
          }
          playedSoundsForStep = event.metadata.stepNumber;
        }

        break;
      case GameEventType.SQUARE:
        // TODO: Handle this case.
        break;
      default:
        break;
    }
  }
}
