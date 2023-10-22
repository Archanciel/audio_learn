import 'package:flutter/material.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';

import '../models/audio.dart';

/// Used in the AudioPlayerView screen to manage the audio playing
/// position modifications.
class AudioGlobalPlayerVM extends ChangeNotifier {
  Audio? currentAudio;
  late AudioPlayer _audioPlayer;
  Duration _duration = const Duration();
  Duration _position = const Duration();

  Duration get position => _position;
  Duration get duration => _duration;
  Duration get remaining => _duration - _position;

  AudioGlobalPlayerVM() {
    _audioPlayer = AudioPlayer();
    _initializePlayer();
  }

  void _initializePlayer() async {
    _audioPlayer.onDurationChanged.listen((duration) {
      _duration = duration;
      notifyListeners();
    });

    _audioPlayer.onPositionChanged.listen((position) {
      _position = position;
      notifyListeners();
    });
  }

  bool get isPlaying => _audioPlayer.state == PlayerState.playing;

  Future<void> playFromCurrentAudioFile() async {
    if (currentAudio == null) {
      // the case if the user has selected the AudioPlayerView screen
      // without yet having choosed an audio file to listen. Later, you
      // will store the last played audio file in the settings.
      return;
    }

    String audioFilePathName = currentAudio!.filePathName;

    // Check if the file exists before attempting to play it
    if (File(audioFilePathName).existsSync()) {
      await _audioPlayer.play(DeviceFileSource(
          audioFilePathName)); // <-- Directly using play method
      await _audioPlayer.setPlaybackRate(currentAudio!.audioPlaySpeed);
      currentAudio!.isPlaying = true;

      notifyListeners();
    } else {
      print('Audio file does not exist at $audioFilePathName');
    }
  }

  void pause() {
    _audioPlayer.pause();
    notifyListeners();
  }

  void seekBy(Duration duration) {
    _audioPlayer.seek(_position + duration);
    notifyListeners();
  }

  void seekTo(Duration position) {
    _audioPlayer.seek(position);
    notifyListeners();
  }

  void skipToStart() {
    _audioPlayer.seek(Duration.zero);
    notifyListeners();
  }

  void skipToEnd() {
    _audioPlayer.seek(_duration);
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
