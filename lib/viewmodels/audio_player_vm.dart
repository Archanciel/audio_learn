import 'package:flutter/material.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';

import '../models/audio.dart';
import '../models/playlist.dart';
import '../services/json_data_service.dart';
import '../utils/duration_expansion.dart';
import 'playlist_list_vm.dart';

/// Used in the AudioPlayerView screen to manage the audio playing
/// position modifications and much more ...
class AudioPlayerVM extends ChangeNotifier {
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

  DateTime _currentAudioLastSaveDateTime = DateTime.now();

  AudioPlayerVM({
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

  /// Calling this method instead of the AudioPlayerVM dispose()
  /// method enables audio player view integr test to be ok even
  /// if the test app is not the active Windows app.
  void disposeAudioPlayer() {
    _audioPlayer.dispose();
  }

  void setCurrentPlaylist({
    required Playlist selectedPlaylist,
  }) {}

  /// Method called when the user clicks on the audio title or sub
  /// title or when he clicks on a play icon or when he selects an
  /// audio in the AudioOneSelectableDialogWidget displayed by
  /// clicking on the audio title on the AudioPlayerView or by
  /// long pressing on the >| button.
  ///
  /// Method called also by setNextAudio() or setPreviousAudio().
  Future<void> setCurrentAudio(Audio audio) async {
    await _setCurrentAudioAndInitializeAudioPlayer(audio);

    audio.enclosingPlaylist!.setCurrentOrPastPlayableAudio(audio);
    updateAndSaveCurrentAudio(forceSave: true);

    notifyListeners();
  }

  /// Method called indirectly when the user clicks on the audio title
  /// or sub title or when he clicks on a play icon or when he selects
  /// an audio in the AudioOneSelectableDialogWidget displayed by
  /// clicking on the audio title on the AudioPlayerView or by
  /// long pressing on the >| button.
  ///
  /// Method called indirectly also by setNextAudio() or
  /// setPreviousAudio().
  ///
  /// Method called indirectly also when the user clicks on the
  /// AudioPlayerView icon or drag to this screen. This switches to
  /// the AudioPlayerView screen without playing the selected playlist
  /// current or last played audio which is displayed correctly in the
  /// AudioPlayerView screen.
  Future<void> _setCurrentAudioAndInitializeAudioPlayer(Audio audio) async {
    if (_currentAudio != null && !_currentAudio!.isPaused) {
      _currentAudio!.isPaused = true;
      // saving the previous current audio state before changing
      // the current audio
      updateAndSaveCurrentAudio(forceSave: true);
    }

    _currentAudio = audio;

    // without setting _currentAudioTotalDuration to the audio duration,
    // the next instruction causes an error: Failed assertion: line 194
    // pos 15: 'value >= min && value <= max': Value 3.0 is not between
    // minimum 0.0 and maximum 0.0
    _currentAudioTotalDuration = audio.audioDuration ?? const Duration();

    // setting the audio position to the audio position stored on the
    // audio. The advantage is that when the AudioPlayerView is opened
    // the audio position is set to the last position played.
    //
    // Then, when the user clicks on the play icon, the audio position
    // is reduced according to the time elapsed since the audio was
    // paused, which is done in _setCurrentAudioPosition().
    _currentAudioPosition = Duration(seconds: audio.audioPositionSeconds);

    _initializeAudioPlayer();
  }

  /// Adjusts the playback start position of the current audio based on the elapsed
  /// time since it was last paused.
  ///
  /// This method applies a decrement to the saved play position to accommodate
  /// for human memory retention and comfort when resuming audio playback.
  ///
  /// The decrement is determined by the duration for which the audio has been paused:
  /// - If the audio was paused less than a minute ago, the play position will be
  ///   rewound by 2 seconds to help recall the immediate context.
  /// - If the audio was paused more than a minute ago but less than an hour, the
  ///   play position will be rewound by 20 seconds to re-establish context without
  ///   significant overlap.
  /// - If the audio was paused for an hour or longer, the play position will be
  ///   rewound by 30 seconds to cater for a longer gap in listening continuity.
  ///
  /// The play position will not be adjusted to a negative value; if the rewind
  /// operation results in a negative position, it will be set to the start of the
  /// audio.
  ///
  /// Precondition:
  /// The `_currentAudio` must be non-null and must have a valid `audioPositionSeconds`.
  ///
  /// Postcondition:
  /// The `_currentAudioPosition` will be updated to reflect the adjusted play position,
  /// and the audio player will seek to this new position.
  ///
  /// If the `audioPausedDateTime` is null, indicating that the audio has not been paused,
  /// the audio player's position will not be adjusted.
  Future<void> _setCurrentAudioPosition() async {
    DateTime? audioPausedDateTime = _currentAudio!.audioPausedDateTime;

    if (audioPausedDateTime != null) {
      final int pausedDurationSecs =
          DateTime.now().difference(audioPausedDateTime).inSeconds;
      int rewindSeconds = 0;

      if (pausedDurationSecs < 60) {
        rewindSeconds = 2;
      } else if (pausedDurationSecs < 3600) {
        rewindSeconds = 20;
      } else {
        rewindSeconds = 30;
      }

      int newPositionSeconds =
          _currentAudio!.audioPositionSeconds - rewindSeconds;
      // Ensure the new position is not negative
      _currentAudioPosition = Duration(
          seconds: newPositionSeconds.clamp(
              0, _currentAudio!.audioDuration!.inSeconds));

      await _audioPlayer.seek(_currentAudioPosition);
    }
  }

  /// Method called by skipToEndNoPlay() if the audio is positioned
  /// at end and by playNextAudio().
  Future<void> _setNextAudio() async {
    Audio? nextAudio = _playlistListVM.getSubsequentlyDownloadedPlayableAudio(
      currentAudio: _currentAudio!,
    );

    if (nextAudio == null) {
      return;
    }

    await setCurrentAudio(nextAudio);
  }

  Future<void> _setNextAudioAndplay() async {
    Audio? nextAudio = _playlistListVM.getSubsequentlyDownloadedPlayableAudio(
      currentAudio: _currentAudio!,
    );
    if (nextAudio == null) {
      // the case if the current audio is the last downloaded
      // audio
      return;
    }
    await setCurrentAudio(nextAudio);
    await playFromCurrentAudioFile();
  }

  /// Method called by skipToStart() if the audio is positioned at
  /// start.
  Future<void> _setPreviousAudio() async {
    Audio? previousAudio = _playlistListVM.getPreviouslyDownloadedPlayableAudio(
      currentAudio: _currentAudio!,
    );

    if (previousAudio == null) {
      return;
    }

    await setCurrentAudio(previousAudio);
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
        if (_audioPlayer.state == PlayerState.playing) {
          // this test avoids that when selecting another audio
          // the selected audio position is set to 0 since the
          // passed position value of an AudioPlayer not playing
          // is 0 !
          _currentAudioPosition = position;
          updateAndSaveCurrentAudio();
        }

        _audioPlayer.onPlayerComplete.listen((event) async {
          // solves the problem of playing the last playable audio
          // when the current audio which is not before the last
          // audio is terminated
          await _audioPlayer.dispose();

          // Play next audio when current audio finishes.
          await playNextAudio();
        });

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
    Audio? currentOrPastPlaylistAudio = _playlistListVM
        .getSelectedPlaylists()
        .first
        .getCurrentOrLastlyPlayedAudioContainedInPlayableAudioLst();
    if (currentOrPastPlaylistAudio == null) {
      // causes "No audio selected" audio title to be displayed
      // in the AudioPlayerView screen. Reinitializing the
      // the _currentAudioPosition as well as the 
      // _currentAudioTotalDuration ensure that the audio slider
      // is correctly displayed at position 0:00 and that the
      // displayed audio duration is 0:00.
      _currentAudio = null;
      _currentAudioPosition = const Duration();
      _currentAudioTotalDuration = const Duration();
      
      _initializeAudioPlayer();

      return;
    }

    if (_currentAudio == currentOrPastPlaylistAudio) {
      return;
    }

    await _setCurrentAudioAndInitializeAudioPlayer(currentOrPastPlaylistAudio);

    // await goToAudioPlayPosition(
    //   Duration(seconds: _currentAudio!.audioPositionSeconds),
    // );
  }

  Future<void> playFromCurrentAudioFile() async {
    if (_currentAudio == null) {
      // the case if the AudioPlayerView is opened directly by
      // dragging to it or clicking on the title or sub title
      // of an audio and not after the user has clicked on the
      // audio play icon button.
      //
      // Getting the first selected playlist makes sense since
      // currently only one playlist can be selected at a time
      // in the PlaylistDownloadView.
      _currentAudio = _playlistListVM
          .getSelectedPlaylists()
          .first
          .getCurrentOrLastlyPlayedAudioContainedInPlayableAudioLst();
      if (_currentAudio == null) {
        // the case if no audio in the selected playlist was ever played
        return;
      }
    }

    String audioFilePathName = _currentAudio!.filePathName;

    // Check if the file exists before attempting to play it
    if (File(audioFilePathName).existsSync()) {
      await _setCurrentAudioPosition();

      await _audioPlayer.play(DeviceFileSource(
          audioFilePathName)); // <-- Directly using play method
      await _audioPlayer.setPlaybackRate(_currentAudio!.audioPlaySpeed);
      _currentAudio!.isPlayingOrPausedWithPositionBetweenAudioStartAndEnd =
          true;
      _currentAudio!.isPaused = false;

      notifyListeners();
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();

    if (_currentAudio!.isPlayingOrPausedWithPositionBetweenAudioStartAndEnd) {
      _currentAudio!.isPaused = true;
      _currentAudio!.audioPausedDateTime = DateTime.now();
    }

    updateAndSaveCurrentAudio(forceSave: true);
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
      _currentAudioPosition = currentAudioDuration;
    } else {
      _currentAudioPosition = newAudioPosition;
    }

    // necessary so that the audio position is stored on the
    // audio
    _currentAudio!.audioPositionSeconds = _currentAudioPosition.inSeconds;

    await _audioPlayer.seek(_currentAudioPosition);

    // now, when clicking on position buttons, the playlist.json file
    // is updated
    updateAndSaveCurrentAudio(forceSave: true);

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
    if (_currentAudioPosition.inSeconds == 0) {
      // situation when the user clicks on |< when the audio
      // position is at audio start. The case if the user clicked
      // twice on the |< icon.
      await _setPreviousAudio();

      notifyListeners();

      return;
    }

    _currentAudioPosition = Duration.zero;
    // necessary so that the audio position is stored on the
    // audio
    _currentAudio!.audioPositionSeconds = _currentAudioPosition.inSeconds;

    await _audioPlayer.seek(_currentAudioPosition);

    notifyListeners();
  }

  /// Method not used for the moment
  Future<void> skipToEndNoPlay() async {
    if (_currentAudioPosition == _currentAudioTotalDuration) {
      updateAndSaveCurrentAudio();

      // situation when the user clicks on >| when the audio
      // position is at audio end. This is the case if the user
      // clicks twice on the >| icon.
      await _setNextAudio();

      notifyListeners();

      return;
    }

    // subtracting 1 second is necessary to avoid a slider error
    // which happens when clicking on AudioListItemWidget play icon
    //
    // I commented out next code since commenting it does not
    // causes a slider error happening when clicking on
    // AudioListItemWidget play icon. to see if realy ok !
    // _currentAudioPosition =
    //     _currentAudioTotalDuration - const Duration(seconds: 1);

    _currentAudioPosition = _currentAudioTotalDuration;
    // necessary so that the audio position is stored on the
    // audio
    _currentAudio!.audioPositionSeconds = _currentAudioPosition.inSeconds;
    _currentAudio!.isPlayingOrPausedWithPositionBetweenAudioStartAndEnd = false;
    updateAndSaveCurrentAudio();

    await _audioPlayer.seek(_currentAudioTotalDuration);

    notifyListeners();
  }

  /// Method called when the user clicks on the >| icon,
  /// either the first time or the second time.
  Future<void> skipToEndAndPlay() async {
    if (_currentAudioPosition == _currentAudioTotalDuration) {
      // situation when the user clicks on >| when the audio
      // position is at audio end. This is also the case when
      // the user clicks twice on the >| icon.
      await playNextAudio();

      return;
    }

    // part of method executed when the user click the first time
    // on the >| icon button

    _currentAudioPosition = _currentAudioTotalDuration;
    _currentAudio!.isPlayingOrPausedWithPositionBetweenAudioStartAndEnd = false;
    updateAndSaveCurrentAudio();

    await _audioPlayer.seek(_currentAudioTotalDuration);

    notifyListeners();
  }

  /// Method called when _audioPlayer.onPlayerComplete happens,
  /// i.e. when the current audio is terminated and when
  /// skipToEndAndPlay() is executed after the user clicked
  /// the second time on the >| icon button.
  Future<void> playNextAudio() async {
    _currentAudio!.isPaused = true;

    // set to false since the audio playing position is set to
    // audio end
    _currentAudio!.isPlayingOrPausedWithPositionBetweenAudioStartAndEnd = false;
    updateAndSaveCurrentAudio();

    await _setNextAudio();
    await playFromCurrentAudioFile();

    notifyListeners();
  }

  void updateAndSaveCurrentAudio({
    bool forceSave = false,
  }) {
    // necessary so that the audio position is stored on the
    // audio. Must not be located after the if which can return
    // without saving the audio position. This would cause the
    // play icon's appearance to be wrong.
    _currentAudio!.audioPositionSeconds = _currentAudioPosition.inSeconds;

    DateTime now = DateTime.now();

    if (!forceSave) {
      // saving the current audio position only every 30 seconds

      if (_currentAudioLastSaveDateTime
          .add(const Duration(seconds: 30))
          .isAfter(now)) {
        return;
      }
    }

    // print(
    //     'updateAndSaveCurrentAudio() at $_lastCurrentAudioSaveDateTime currentAudio!.audioPositionSeconds: ${_currentAudio!.audioPositionSeconds}');

    Playlist? currentAudioPlaylist = _currentAudio!.enclosingPlaylist;
    JsonDataService.saveToFile(
      model: currentAudioPlaylist!,
      path: currentAudioPlaylist.getPlaylistDownloadFilePathName(),
    );

    _currentAudioLastSaveDateTime = now;
  }

  /// The returned list is ordered by download time, placing
  /// latest downloaded audios at end of list, so reversing
  /// the playlist playable audio list.
  ///
  /// playableAudioLst order: [available audio last downloaded, ...,
  ///                          available audio first downloaded]
  List<Audio> getPlayableAudiosOrderedByDownloadTime() {
    if (_currentAudio == null) {
      // the case if "No audio selected" audio title is
      // displayed in the AudioPlayerView screen
      return _playlistListVM
          .getSelectedPlaylists()
          .first
          .playableAudioLst
          .reversed
          .toList();
    }

    return _currentAudio!.enclosingPlaylist!.playableAudioLst.reversed.toList();
  }

  String? getCurrentAudioTitleWithDuration() {
    if (_currentAudio == null) {
      return null;
    }

    return '${_currentAudio!.validVideoTitle}\n${_currentAudio!.audioDuration!.HHmmssZeroHH()}';
  }

  int getCurrentAudioIndex() {
    if (_currentAudio == null) {
      // the case if "No audio selected" audio title is
      // displayed in the AudioPlayerView screen
      return -1;
    }

    return _currentAudio!.enclosingPlaylist!.playableAudioLst.reversed
        .toList()
        .indexWhere((element) => element == _currentAudio);
  }
}
