import 'package:flutter/material.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';

import '../models/audio.dart';
import '../models/playlist.dart';
import '../services/json_data_service.dart';
import 'playlist_list_vm.dart';

/// Used in the AudioPlayerView screen to manage the audio playing
/// position modifications.
class AudioGlobalPlayerVM extends ChangeNotifier {
  Audio? _currentAudio;
  Audio? get currentAudio => _currentAudio;
  final PlaylistListVM _playlistListVM;
  late AudioPlayer _audioPlayer;
  Duration _currentAudioTotalDuration = const Duration();
  Duration _currentAudioPosition = const Duration();

  Duration get currentAudioPosition => _currentAudioPosition;
  Duration get currentAudioTotalDuration => _currentAudioTotalDuration;
  Duration get currentAudioRemainingDuration =>
      _currentAudioTotalDuration - _currentAudioPosition;

  bool get isPlaying => _audioPlayer.state == PlayerState.playing;

  late DateTime _lastCurrentAudioSaveDateTime;

  AudioGlobalPlayerVM({
    required PlaylistListVM playlistListVM,
  }) : _playlistListVM = playlistListVM {
    // the next line is necessary since _audioPlayer.dispose() is
    // called in _initializePlayer()
    _audioPlayer = AudioPlayer();

    _initializeAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();

    super.dispose();
  }

  void setCurrentAudio(Audio audio) {
    setCurrentAudioAndInitializeAudioPlayer(audio);

    audio.enclosingPlaylist!.setCurrentOrPastPlayableAudio(audio);
    _lastCurrentAudioSaveDateTime = DateTime.now();
  }

  void setCurrentAudioAndInitializeAudioPlayer(Audio audio) {
    _currentAudio = audio;

    // without setting _currentAudioTotalDuration to the
    // the next instruction causes an error: Failed assertion: line 194
    // pos 15: 'value >= min && value <= max': Value 3.0 is not between
    // minimum 0.0 and maximum 0.0
    _currentAudioTotalDuration = audio.audioDuration ?? const Duration();

    _currentAudioPosition = Duration(seconds: audio.audioPositionSeconds);

    _initializeAudioPlayer();
  }

  void _initializeAudioPlayer() {
    _audioPlayer.dispose();
    _audioPlayer = AudioPlayer();

    // Assuming filePath is the full path to your audio file
    String audioFilePathName = _currentAudio?.filePathName ?? '';

    // Check if the file exists before attempting to play it
    if (audioFilePathName.isNotEmpty && File(audioFilePathName).existsSync()) {
      _audioPlayer.onDurationChanged.listen((duration) {
        _currentAudioTotalDuration = duration;
        notifyListeners();
      });

      _audioPlayer.onPositionChanged.listen((position) {
        if (isPlaying) {
          // this test avoids that when selecting another audio
          // the selected audio position is set to 0 since the
          // passed position value is 0 !
          _currentAudioPosition = position;
          updateAndSaveCurrentAudio();
        }

        notifyListeners();
      });
    }
  }

  /// Method called when the user clicks on the AudioPlayerView
  /// icon or drag to this screen.
  ///
  /// This switches to the AudioPlayerView screen without playing
  /// the selected playlist current or last played audio which
  /// is displayed correctly in the AudioPlayerView screen.
  Future<void> setCurrentAudioFromSelectedPlaylist() async {
    Audio? currentOrPastPlaylisAudio = _playlistListVM
        .getSelectedPlaylists()
        .first
        .getCurrentOrPastPlayableAudio();
    if (currentOrPastPlaylisAudio == null) {
      // the case if no audio in the selected playlist was ever played
      return;
    }

    setCurrentAudioAndInitializeAudioPlayer(currentOrPastPlaylisAudio);

    await goToAudioPlayPosition(
      Duration(seconds: _currentAudio!.audioPositionSeconds),
    );
  }

  Future<void> playFromCurrentAudioFile() async {
    if (_currentAudio == null) {
      // the case if the AudioPlayerView is opened directly and not
      // after the user has selected an audio in the audio list of
      // the selected playlist and if the user clicks on the play
      // button.
      //
      // Getting the first selected playlist makes sense since
      // currently only one playlist can be selected at a time
      // in the PlaylistDownloadView.
      _currentAudio = _playlistListVM
          .getSelectedPlaylists()
          .first
          .getCurrentOrPastPlayableAudio();
      if (_currentAudio == null) {
        // the case if no audio in the selected playlist was ever played
        return;
      }
    }

    String audioFilePathName = _currentAudio!.filePathName;

    // Check if the file exists before attempting to play it
    if (File(audioFilePathName).existsSync()) {
      await _audioPlayer.play(DeviceFileSource(
          audioFilePathName)); // <-- Directly using play method
      await _audioPlayer.setPlaybackRate(_currentAudio!.audioPlaySpeed);
      _currentAudio!.isPlayingOnGlobalAudioPlayerVM = true;
      _currentAudio!.isPaused = false;

      notifyListeners();
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
    // _currentAudio!.isPlayingOnGlobalAudioPlayerVM = false;
    _currentAudio!.invertPaused();

    notifyListeners();
  }

  /// Method called when the user clicks on the '<<' or '>>' buttons
  Future<void> changeAudioPlayPosition(
      Duration positiveOrNegativeDuration) async {
    Duration currentAudioDuration =
        _currentAudio!.audioDuration ?? Duration.zero;
    Duration newAudioPosition =
        _currentAudioPosition + positiveOrNegativeDuration;

    // Check if the new audio position is within the audio duration.
    // If not, set the audio position to the beginning or the end
    // of the audio. This is necessary to avoid a slider error.
    //
    // This fixes the bug when clicking on >> after having clicked
    // on >| or clicking on << after having clicked on |<.
    if (newAudioPosition < Duration.zero) {
      _currentAudioPosition = Duration.zero;
    } else if (newAudioPosition > currentAudioDuration) {
      // subtracting 1 second is necessary to avoid a slider error
      _currentAudioPosition = currentAudioDuration - const Duration(seconds: 1);
    } else {
      _currentAudioPosition = newAudioPosition;
    }

    // necessary so that the audio position is stored on the
    // audio
    _currentAudio!.audioPositionSeconds = _currentAudioPosition.inSeconds;

    await _audioPlayer.seek(_currentAudioPosition);

    notifyListeners();
  }

  /// Method called when the user clicks on the audio slider
  Future<void> goToAudioPlayPosition(Duration position) async {
    _currentAudioPosition = position; // Immediately update the position

    // necessary so that the audio position is stored on the
    // audio
    _currentAudio!.audioPositionSeconds = _currentAudioPosition.inSeconds;

    await _audioPlayer.seek(position);

    notifyListeners();
  }

  Future<void> skipToStart() async {
    _currentAudioPosition = Duration.zero;
    // necessary so that the audio position is stored on the
    // audio
    _currentAudio!.audioPositionSeconds = _currentAudioPosition.inSeconds;

    await _audioPlayer.seek(_currentAudioPosition);

    notifyListeners();
  }

  Future<void> skipToEnd() async {
    _currentAudioPosition = _currentAudioTotalDuration;
    // necessary so that the audio position is stored on the
    // audio
    _currentAudio!.audioPositionSeconds = _currentAudioPosition.inSeconds;
    _currentAudio!.isPlayingOnGlobalAudioPlayerVM = false;

    await _audioPlayer.seek(_currentAudioTotalDuration);

    notifyListeners();
  }

  void updateAndSaveCurrentAudio() {
    _currentAudio!.audioPositionSeconds = _currentAudioPosition.inSeconds;

    // saving the current audio position only every 30 seconds

    DateTime now = DateTime.now();

    if (_lastCurrentAudioSaveDateTime
        .add(const Duration(seconds: 30))
        .isAfter(now)) {
      return;
    }

    _lastCurrentAudioSaveDateTime = now;

    // print(
    //     'updateAndSaveCurrentAudio() at $_lastCurrentAudioSaveDateTime currentAudio!.audioPositionSeconds: ${_currentAudio!.audioPositionSeconds}');

    Playlist? currentAudioPlaylist = _currentAudio!.enclosingPlaylist;
    JsonDataService.saveToFile(
      model: currentAudioPlaylist!,
      path: currentAudioPlaylist.getPlaylistDownloadFilePathName(),
    );
  }
}
