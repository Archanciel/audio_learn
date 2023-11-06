import 'package:flutter/material.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';

import '../models/audio.dart';
import '../models/playlist.dart';
import '../services/json_data_service.dart';
import '../utils/duration_expansion.dart';
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

  late DateTime _currentAudioLastSaveDateTime;

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
    await pause();
    await _setCurrentAudioAndInitializeAudioPlayer(audio);

    audio.enclosingPlaylist!.setCurrentOrPastPlayableAudio(audio);
    updateAndSaveCurrentAudio(forceSave: true);

    notifyListeners();
  }

  Future<void> _setCurrentAudioAndInitializeAudioPlayer(Audio audio) async {
    _currentAudio = audio;

    // without setting _currentAudioTotalDuration to the
    // the next instruction causes an error: Failed assertion: line 194
    // pos 15: 'value >= min && value <= max': Value 3.0 is not between
    // minimum 0.0 and maximum 0.0
    _currentAudioTotalDuration = audio.audioDuration ?? const Duration();

    _currentAudioPosition = Duration(seconds: audio.audioPositionSeconds);

    _initializeAudioPlayer();

    await _audioPlayer.seek(_currentAudioPosition);
  }

  /// Method called by skipToEnd() if the audio is positioned at
  /// end.
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

        _audioPlayer.onPlayerComplete.listen((event) {
          // Play next audio when current audio finishes.
          skipToEndAndPlay();
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
    if (currentOrPastPlaylistAudio == null ||
        _currentAudio == currentOrPastPlaylistAudio) {
      // the case if no audio in the selected playlist was ever played
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

    if (_currentAudio!.isPlayingOnGlobalAudioPlayerVM) {
      _currentAudio!.isPaused = true;
    }

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
      // which happens when clicking on AudioListItemWidget play icon
      _currentAudioPosition = currentAudioDuration - const Duration(seconds: 1);
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

  Future<void> skipToEnd() async {
    if (_currentAudioPosition >=
        _currentAudioTotalDuration - const Duration(seconds: 1)) {
      // subtracting 1 second and saving current audio is necessary
      // to avoid a slider erro which happens when clicking on
      // AudioListItemWidget play icon
      _currentAudioPosition =
          _currentAudioTotalDuration - const Duration(seconds: 1);
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
    _currentAudio!.isPlayingOnGlobalAudioPlayerVM = false;

    await _audioPlayer.seek(_currentAudioTotalDuration);

    notifyListeners();
  }

  Future<void> skipToEndAndPlay() async {
    if (_currentAudioPosition >=
        _currentAudioTotalDuration - const Duration(seconds: 1)) {
      // situation when the user clicks on >| when the audio
      // position is at audio end. This is the case if the user
      // clicks twice on the >| icon.
      await _setNextAudio();
      await playFromCurrentAudioFile();

      notifyListeners();

      return;
    }

    _currentAudioPosition = _currentAudioTotalDuration;
    // necessary so that the audio position is stored on the
    // audio
    _currentAudio!.audioPositionSeconds = _currentAudioPosition.inSeconds;
    _currentAudio!.isPlayingOnGlobalAudioPlayerVM = false;

    await _audioPlayer.seek(_currentAudioTotalDuration);

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

  /// the returned list is ordered by download time, placing
  /// latest downloaded audios at end of list.
  List<Audio> getPlayableAudiosContainedInCurrentAudioEnclosingPlaylist() {
    return _currentAudio!.enclosingPlaylist!.playableAudioLst.reversed.toList();
  }

  String getCurrentAudioTitle() {
    return '${_currentAudio!.validVideoTitle}\n${_currentAudio!.audioDuration!.HHmmssZeroHH()}';
  }
}
