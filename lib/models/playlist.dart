import 'dart:io';

import 'package:audio_learn/services/settings_data_service.dart';

import 'audio.dart';

enum PlaylistType { youtube, local }

enum PlaylistQuality { music, voice }

/// This class
class Playlist {
  String id = '';
  String title = '';
  String url;
  PlaylistType playlistType;
  PlaylistQuality playlistQuality;
  String downloadPath = '';
  bool isSelected;

  // Contains the audios once referenced in the Youtube playlist
  // which were downloaded.
  //
  // List order: [first downloaded audio, ..., last downloaded audio]
  List<Audio> downloadedAudioLst = [];

  // Contains the downloaded audios currently available on the
  // device.
  //
  // List order: [last available downloaded audio, ..., first
  //              available downloaded audio]
  List<Audio> playableAudioLst = [];

  // This variable contains the index of the audio in the
  // playableAudioLst which is currently playing. The effect is that
  // this value is the index of the audio that was the last played
  // audio from the playlist. This means that if the AudioPlayerView
  // is opened without having clicked on a playlist audio item, then
  // this audio will be playing. This happens only if the audio
  // playlist is selected in the PlaylistDownloadView, i.e. referenced
  // in the app settings.json file. The value -1 means that no
  // playlist audio has been played.
  int currentOrPastPlayableAudioIndex = -1;

  Playlist({
    this.url = '',
    this.id = '',
    this.title = '',
    required this.playlistType,
    required this.playlistQuality,
    this.isSelected = false,
  });

  /// This constructor requires all instance variables
  Playlist.fullConstructor({
    required this.id,
    required this.title,
    required this.url,
    required this.playlistType,
    required this.playlistQuality,
    required this.downloadPath,
    required this.isSelected,
    required this.currentOrPastPlayableAudioIndex,
  });

  /// Factory constructor: creates an instance of Playlist from a
  /// JSON object
  factory Playlist.fromJson(Map<String, dynamic> json) {
    Playlist playlist = Playlist.fullConstructor(
      id: json['id'],
      title: json['title'],
      url: json['url'],
      playlistType: PlaylistType.values.firstWhere(
        (e) => e.toString().split('.').last == json['playlistType'],
        orElse: () => PlaylistType.youtube,
      ),
      playlistQuality: PlaylistQuality.values.firstWhere(
        (e) => e.toString().split('.').last == json['playlistQuality'],
        orElse: () => PlaylistQuality.voice,
      ),
      downloadPath: json['downloadPath'],
      isSelected: json['isSelected'],
      currentOrPastPlayableAudioIndex:
          json['currentOrPastPlayableAudioIndex'] ?? -1,
    );

    // Deserialize the Audio instances in the
    // downloadedAudioLst
    if (json['downloadedAudioLst'] != null) {
      for (var audioJson in json['downloadedAudioLst']) {
        Audio audio = Audio.fromJson(audioJson);
        audio.enclosingPlaylist = playlist;
        playlist.downloadedAudioLst.add(audio);
      }
    }

    // Deserialize the Audio instances in the
    // playableAudioLst
    if (json['playableAudioLst'] != null) {
      for (var audioJson in json['playableAudioLst']) {
        Audio audio = Audio.fromJson(audioJson);
        audio.enclosingPlaylist = playlist;
        playlist.playableAudioLst.add(audio);
      }
    }

    return playlist;
  }

  // Method: converts an instance of Playlist to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'playlistType': playlistType.toString().split('.').last,
      'playlistQuality': playlistQuality.toString().split('.').last,
      'downloadPath': downloadPath,
      'downloadedAudioLst':
          downloadedAudioLst.map((audio) => audio.toJson()).toList(),
      'playableAudioLst':
          playableAudioLst.map((audio) => audio.toJson()).toList(),
      'isSelected': isSelected,
      'currentOrPastPlayableAudioIndex': currentOrPastPlayableAudioIndex,
    };
  }

  /// Adds the downloaded audio to the downloadedAudioLst and to
  /// the playableAudioLst.
  /// 
  /// downloadedAudioLst order: [first downloaded audio, ...,
  ///                            last downloaded audio]
  /// playableAudioLst order: [last available downloaded audio, ...,
  ///                          first available downloaded audio]
  void addDownloadedAudio(Audio downloadedAudio) {
    downloadedAudio.enclosingPlaylist = this;
    downloadedAudioLst.add(downloadedAudio);
    playableAudioLst.insert(0, downloadedAudio);
  }

  /// Adds the copied audio to the downloadedAudioLst and to
  /// the playableAudioLst.
  /// 
  /// downloadedAudioLst order: [first downloaded audio, ...,
  ///                            last downloaded audio]
  /// playableAudioLst order: [last available downloaded audio, ...,
  ///                          first available downloaded audio]
  void addCopiedAudio(Audio copiedAudio) {
    // Creating a copy of the audio to be copied so that the passed
    // original audio will not be modified by this method.
    Audio audioCopy = copiedAudio.copy();
    audioCopy.enclosingPlaylist = this;

    downloadedAudioLst.add(audioCopy);
    playableAudioLst.insert(0, audioCopy);
  }

  /// Adds the moved audio to the downloadedAudioLst and to the
  /// playableAudioLst. Adding the audio to the downloadedAudioLst
  /// is necessary even if the audio was not downloaded from this
  /// playlist so that if the audio is then moved to another
  /// playlist, the moving action will not fail since moving is
  /// done from the downloadedAudioLst.
  ///
  /// Before, sets the enclosingPlaylist to this as well as the
  /// movedFromPlaylistTitle.
  void addMovedAudio({
    required Audio movedAudio,
    required String movedFromPlaylistTitle,
  }) {
    // Creating a copy of the audio to be moved so that the passed
    // original audio will not be modified by this method.
    Audio movedAudioCopy = movedAudio.copy();

    Audio? existingDownloadedAudio;

    try {
      existingDownloadedAudio = downloadedAudioLst.firstWhere(
        (audio) => audio.audioFileName == movedAudio.audioFileName,
      );
    } catch (e) {
      existingDownloadedAudio = null;
    }

    movedAudioCopy.enclosingPlaylist = this;
    movedAudioCopy.movedFromPlaylistTitle = movedFromPlaylistTitle;

    if (existingDownloadedAudio != null) {
      // the case if the audio was moved to this playlist a first
      // time and then moved back to the source playlist or moved
      // to another playlist and then moved back to this playlist.
      existingDownloadedAudio.movedFromPlaylistTitle = movedFromPlaylistTitle;
      existingDownloadedAudio.movedToPlaylistTitle = title;
      existingDownloadedAudio.enclosingPlaylist = this;
      playableAudioLst.insert(0, existingDownloadedAudio);
    } else {
      downloadedAudioLst.add(movedAudioCopy);
      playableAudioLst.insert(0, movedAudioCopy);
    }
  }

  /// Removes the downloaded audio from the downloadedAudioLst
  /// and from the playableAudioLst.
  ///
  /// This is used when the downloaded audio is moved to another
  /// playlist and is not kept in downloadedAudioLst of the source
  /// playlist. In this case, the user is advised to remove the
  /// corresponding video from the playlist on Youtube.
  void removeDownloadedAudioFromDownloadAndPlayableAudioLst({
    required Audio downloadedAudio,
  }) {
    // removes from the list all audios with the same audioFileName
    downloadedAudioLst.removeWhere(
        (Audio audio) => audio.audioFileName == downloadedAudio.audioFileName);

    // removes from the list all audios with the same audioFileName
    playableAudioLst.removeWhere(
        (Audio audio) => audio.audioFileName == downloadedAudio.audioFileName);
  }

  /// Removes the downloaded audio from the playableAudioLst only.
  ///
  /// This is used when the downloaded audio is moved to another
  /// playlist and is keeped in downloadedAudioLst of the source
  /// playlist so that it will not be downloaded again.
  void removeDownloadedAudioFromPlayableAudioLstOnly({
    required Audio downloadedAudio,
  }) {
    playableAudioLst.remove(downloadedAudio);
  }

  void setMovedAudioToPlaylistTitle({
    required String audioFileName,
    required String movedToPlaylistTitle,
  }) {
    downloadedAudioLst
        .firstWhere((audio) => audio.audioFileName == audioFileName)
        .movedToPlaylistTitle = movedToPlaylistTitle;
  }

  /// Used when uploading the Playlist json file. Since the
  /// json file contains the playable audio list in the right
  /// order, i.e. [last available downloaded audio, ..., first
  ///              available downloaded audio]
  /// using add and not insert maintains the right order !
  void addPlayableAudio(Audio playableAudio) {
    playableAudio.enclosingPlaylist = this;
    playableAudioLst.add(playableAudio);
  }

  void removePlayableAudio(Audio playableAudio) {
    playableAudioLst.remove(playableAudio);
  }

  @override
  String toString() {
    return '$title isSelected: $isSelected';
  }

  String getPlaylistDownloadFilePathName() {
    return '$downloadPath${Platform.pathSeparator}$title.json';
  }

  DateTime? getLastDownloadDateTime() {
    Audio? lastDownloadedAudio =
        downloadedAudioLst.isNotEmpty ? downloadedAudioLst.last : null;

    return (lastDownloadedAudio != null)
        ? lastDownloadedAudio.audioDownloadDateTime
        : null;
  }

  Duration getPlayableAudioLstTotalDuration() {
    Duration totalDuration = Duration.zero;

    for (Audio audio in playableAudioLst) {
      totalDuration += audio.audioDuration ?? Duration.zero;
    }

    return totalDuration;
  }

  int getPlayableAudioLstTotalFileSize() {
    int totalFileSize = 0;

    for (Audio audio in playableAudioLst) {
      totalFileSize += audio.audioFileSize;
    }

    return totalFileSize;
  }

  /// Removes from the playableAudioLst the audios that are no longer
  /// in the playlist download path.
  ///
  /// Returns the number of audios removed from the playable audio
  /// list.
  /// 
  /// playableAudioLst order: [last available downloaded audio, ...,
  ///                          first available downloaded audio]

  int updatePlayableAudioLst() {
    int removedPlayableAudioNumber = 0;

    // since we are removing items from the list, we need to make a
    // copy of the list because we cannot iterate over a list that
    // is being modified.
    List<Audio> copyAudioLst = List<Audio>.from(playableAudioLst);

    for (Audio audio in copyAudioLst) {
      if (!File(audio.filePathName).existsSync()) {
        playableAudioLst.remove(audio);
        removedPlayableAudioNumber++;
      }
    }

    return removedPlayableAudioNumber;
  }

  void sortDownloadedAudioLst({
    required AudioSortCriterion audioSortCriteriomn,
    required bool isSortAscending,
  }) {
    _sortAudioLst(
      lstToSort: downloadedAudioLst,
      audioSortCriterion: audioSortCriteriomn,
      isSortAscending: isSortAscending,
    );
  }

  void sortPlayableAudioLst({
    required AudioSortCriterion audioSortCriteriomn,
    required bool isSortAscending,
  }) {
    _sortAudioLst(
      lstToSort: playableAudioLst,
      audioSortCriterion: audioSortCriteriomn,
      isSortAscending: isSortAscending,
    );
  }

  void _sortAudioLst({
    required List<Audio> lstToSort,
    required AudioSortCriterion audioSortCriterion,
    required bool isSortAscending,
  }) {
    lstToSort.sort((a, b) {
      dynamic aValue;
      dynamic bValue;

      switch (audioSortCriterion) {
        case AudioSortCriterion.validVideoTitle:
          aValue = a.validVideoTitle;
          bValue = b.validVideoTitle;
          break;
        case AudioSortCriterion.audioDownloadDateTime:
          aValue = a.audioDownloadDateTime;
          bValue = b.audioDownloadDateTime;
          break;
        default:
          break;
      }

      int compareResult = aValue.compareTo(bValue);

      return isSortAscending ? compareResult : -compareResult;
    });
  }

  void renameDownloadedAndPlayableAudioFile({
    required String oldFileName,
    required String newFileName,
  }) {
    Audio? existingDownloadedAudio;

    try {
      existingDownloadedAudio = downloadedAudioLst.firstWhere(
        (audio) => audio.audioFileName == oldFileName,
      );
    } catch (e) {
      existingDownloadedAudio = null;
    }

    if (existingDownloadedAudio != null) {
      existingDownloadedAudio.audioFileName = newFileName;
    }

    Audio? existingPlayableAudio;

    try {
      existingPlayableAudio = playableAudioLst.firstWhere(
        (audio) => audio.audioFileName == oldFileName,
      );
    } catch (e) {
      existingPlayableAudio = null;
    }

    if (existingPlayableAudio != null) {
      existingPlayableAudio.audioFileName = newFileName;
    }
  }

  void setCurrentOrPastPlayableAudio(Audio audio) {
    currentOrPastPlayableAudioIndex = playableAudioLst
        .indexWhere((item) => item == audio); // using Audio == operator
  }

  /// Returns the currently playing audio or the playlist audio
  /// which was played the last time. If no valid audio index is
  /// found, returns null.
  Audio? getCurrentOrLastlyPlayedAudioContainedInPlayableAudioLst() {
    if (currentOrPastPlayableAudioIndex == -1) {
      return null;
    }

    return playableAudioLst[currentOrPastPlayableAudioIndex];
  }
}
