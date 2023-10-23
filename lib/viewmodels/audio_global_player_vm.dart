import 'package:flutter/material.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import '../models/audio.dart';
import '../models/playlist.dart';
import '../services/json_data_service.dart';

/// Used in the AudioPlayerView screen to manage the audio playing
/// position modifications.
class AudioGlobalPlayerVM extends ChangeNotifier {
  Audio? _currentAudio;
  late AudioPlayer _audioPlayer;
  Duration _currentAudioTotalDuration = const Duration();
  Duration _currentAudioPosition = const Duration();

  Duration get currentAudioPosition => _currentAudioPosition;
  Duration get currentAudioTotalDuration => _currentAudioTotalDuration;
  Duration get currentAudioRemainingDuration =>
      _currentAudioTotalDuration - _currentAudioPosition;

  AudioGlobalPlayerVM() {
    _audioPlayer = AudioPlayer();

    _initializePlayer();
  }

  void _initializePlayer() async {
    _audioPlayer.onDurationChanged.listen((duration) {
      _currentAudioTotalDuration = duration;

      notifyListeners();
    });

    _audioPlayer.onPositionChanged.listen((position) {
      // called each time the audio position has been changed
      // by the user, either clicking on or dragging the audio slider
      // or clicking on the '<<' or '>>' or '|<' or '>|' buttons as
      // well as on play or pause buttons.
      _currentAudioPosition = position;
      updateAndSaveCurrentAudio();

      notifyListeners();
    });
  }

  bool get isPlaying => _audioPlayer.state == PlayerState.playing;

  void setCurrentAudio(Audio audio) {
    _currentAudio = audio;
    _currentAudioPosition = Duration(seconds: audio.audioPositionSeconds);
    audio.enclosingPlaylist!.setCurrentPlayableAudio(audio);

    notifyListeners();
  }

  Future<void> playFromCurrentAudioFile() async {
    if (_currentAudio == null) {
      // the case if the user has selected the AudioPlayerView screen
      // without yet having choosed an audio file to listen. Later, you
      // will store the last played audio file in the settings.
      return;
    }

    String audioFilePathName = _currentAudio!.filePathName;

    // Check if the file exists before attempting to play it
    if (File(audioFilePathName).existsSync()) {
      await _audioPlayer.play(DeviceFileSource(
          audioFilePathName)); // <-- Directly using play method
      await _audioPlayer.setPlaybackRate(_currentAudio!.audioPlaySpeed);
      _currentAudio!.isPlayingOnGlobalAudioPlayerVM = true;

      notifyListeners();
    } else {
      print('Audio file does not exist at $audioFilePathName');
    }
  }

  void pause() {
    _audioPlayer.pause();
    _currentAudio!.isPlayingOnGlobalAudioPlayerVM = false;

    notifyListeners();
  }

  /// Method called when the user clicks on the '<<' or '>>' buttons
  void changeAudioPlayPosition(Duration positiveOrNegativeDuration) {
    _audioPlayer.seek(_currentAudioPosition + positiveOrNegativeDuration);

    notifyListeners();
  }

  /// Method called when the user clicks on the audio slider
  void goToAudioPlayPosition(Duration position) {
    _audioPlayer.seek(position);

    notifyListeners();
  }

  /// Method called when the user clicks on the '|<' buttons
  void skipToStart() {
    _audioPlayer.seek(Duration.zero);

    notifyListeners();
  }

  /// Method called when the user clicks on the '>|' buttons
  void skipToEnd() {
    _audioPlayer.seek(_currentAudioTotalDuration);
    _currentAudio!.isPlayingOnGlobalAudioPlayerVM = false;

    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();

    super.dispose();
  }

  void updateAndSaveCurrentAudio() {
    if (_currentAudio != null) {
      _currentAudio!.audioPositionSeconds = _currentAudioPosition.inSeconds;
      Playlist? currentAudioPlaylist = _currentAudio!.enclosingPlaylist;
      JsonDataService.saveToFile(
        model: currentAudioPlaylist!,
        path: currentAudioPlaylist.getPlaylistDownloadFilePathName(),
      );
    }
  }
}
