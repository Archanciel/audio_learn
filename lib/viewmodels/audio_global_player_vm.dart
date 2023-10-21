import 'package:flutter/material.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';

import '../models/audio.dart';

/// Used in the AudioPlayerView screen to manage the audio playing
/// position modifications.
class AudioGlobalPlayerVM extends ChangeNotifier {
  Audio currentAudio;
  late AudioPlayer _audioPlayer;
  Duration _duration = const Duration();
  Duration _position = const Duration();

  Duration get position => _position;
  Duration get duration => _duration;
  Duration get remaining => _duration - _position;

  AudioGlobalPlayerVM({
    required this.currentAudio,
  }) {
    _audioPlayer = AudioPlayer();
    _initializePlayer();
  }

  void _initializePlayer() async {
    // Assuming filePath is the full path to your audio file
    String audioFilePathName = currentAudio.filePathName;

    // Check if the file exists before attempting to play it
    if (await File(audioFilePathName).exists()) {
      _audioPlayer.onDurationChanged.listen((duration) {
        _duration = duration;
        notifyListeners();
      });

      _audioPlayer.onPositionChanged.listen((position) {
        _position = position;
        notifyListeners();
      });
    } else {
      print('Audio file does not exist at $audioFilePathName');
    }
  }

  bool get isPlaying => _audioPlayer.state == PlayerState.playing;

  void playFromFile() {
    // <-- Renamed from playFromAssets
    // Assuming filePath is the full path to your audio file
    String audioFilePathName = currentAudio.filePathName;

    // Check if the file exists before attempting to play it
    if (File(audioFilePathName).existsSync()) {
      _audioPlayer.play(DeviceFileSource(audioFilePathName)); // <-- Directly using play method
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
