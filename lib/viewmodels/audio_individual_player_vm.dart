// dart file located in lib\viewmodels

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';

import '../models/audio.dart';

/// Used in the AudioListItemWidget to play, pause, or stop
/// the current audio.
class AudioIndividualPlayerVM extends ChangeNotifier {
  /// Play an audio file located in the device file system.
  ///
  /// Example: filePathName =
  /// '/storage/emulated/0/Download/audio/230628-audio short 23-06-10.mp3'
  ///
  /// {playBackRate} is the speed of playing the audio file. It is 1.0 by
  /// default. In this case, the speed of playing the audio file is the one
  /// defined in the audio instance itself. If {playBackRate} is different
  /// from 1.0, the speed of the audio file is changed to {playBackRate}.
  Future<void> playFromAudioFile({
    required Audio audio,
  }) async {
    final file = File(audio.filePathName);

    if (!await file.exists()) {
      print('File not found: ${audio.filePathName}');
    }

    AudioPlayer? audioPlayer = audio.audioPlayer;

    if (audioPlayer == null) {
      audioPlayer = AudioPlayer();
      audio.audioPlayer = audioPlayer;
    }

    await audioPlayer.play(DeviceFileSource(
      audio.filePathName,
    ));
    await audioPlayer.setPlaybackRate(audio.audioPlaySpeed);
    audio.isPlaying = true;

    notifyListeners();
  }

  /// Play an audio file located in the assets folder.
  ///
  /// Example: filePathName = 'audio/Sirdalud.mp3' if
  /// the audio file is located in the assets/audio folder.
  ///
  /// Path separator must be / and not \ since the assets/audio
  /// path is defined in the pubspec.yaml file.
  Future<void> playFromAssets(
    Audio audio,
  ) async {
    final file = File(audio.filePathName);

    if (!await file.exists()) {
      print('File not found: ${audio.filePathName}');
    }

    AudioPlayer? audioPlayer = audio.audioPlayer;

    if (audioPlayer == null) {
      audioPlayer = AudioPlayer();
      audio.audioPlayer = audioPlayer;
    }

    await audioPlayer.play(AssetSource(audio.filePathName));
    audio.isPlaying = true;

    notifyListeners();
  }

  Future<void> pause(
    Audio audio,
  ) async {
    // Stop the audio
    if (audio.isPaused) {
      await audio.audioPlayer!.resume();
    } else {
      await audio.audioPlayer!.pause();
    }

    audio.invertPaused();

    notifyListeners();
  }

  Future<void> stop(
    Audio audio,
  ) async {
    // Stop the audio
    await audio.audioPlayer!.stop();
    audio.isPlaying = false;
    notifyListeners();
  }
}
