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

  // Contains audio videos currently referrenced in the Youtube
  // playlist.
  final List<Audio> _youtubePlaylistAudioLst = [];
  List<Audio> get youtubePlaylistAudioLst => _youtubePlaylistAudioLst;

  // Contains the audios once referenced in the Youtube playlist
  // which were downloaded.
  List<Audio> downloadedAudioLst = [];

  // Contains the downloaded audios currently available on the
  // device.
  List<Audio> playableAudioLst = [];

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
    };
  }

  /// Adds the downloaded audio to the downloadedAudioLst and to
  /// the playableAudioLst.
  void addDownloadedAudio(Audio downloadedAudio) {
    downloadedAudio.enclosingPlaylist = this;
    downloadedAudioLst.add(downloadedAudio);
    playableAudioLst.insert(0, downloadedAudio);
  }

  /// Removes the downloaded audio from the downloadedAudioLst
  /// and from the playableAudioLst.
  void removeDownloadedAudio(Audio downloadedAudio) {
    if (downloadedAudio.enclosingPlaylist == this) {
      downloadedAudio.enclosingPlaylist = null;
    }

    downloadedAudioLst.remove(downloadedAudio);
    playableAudioLst.remove(downloadedAudio);
  }

  /// Used when uploading the Playlist json file. Since the
  /// json file contains the playable audio list in the right
  /// order, using add and not insert maintains the right order !
  void addPlayableAudio(Audio playableAudio) {
    playableAudio.enclosingPlaylist = this;
    playableAudioLst.add(playableAudio);
  }

  void removePlayableAudio(Audio playableAudio) {
    playableAudioLst.remove(playableAudio);
  }

  @override
  String toString() {
    return title;
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
      audioSortCriteriomn: audioSortCriteriomn,
      isSortAscending: isSortAscending,
    );
  }

  void sortPlayableAudioLst({
    required AudioSortCriterion audioSortCriteriomn,
    required bool isSortAscending,
  }) {
    _sortAudioLst(
      lstToSort: playableAudioLst,
      audioSortCriteriomn: audioSortCriteriomn,
      isSortAscending: isSortAscending,
    );
  }

  void _sortAudioLst({
    required List<Audio> lstToSort,
    required AudioSortCriterion audioSortCriteriomn,
    required bool isSortAscending,
  }) {
    lstToSort.sort((a, b) {
      dynamic aValue;
      dynamic bValue;

      switch (audioSortCriteriomn) {
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
}
