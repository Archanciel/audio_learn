import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

import 'package:audio_learn/models/audio.dart';
import 'package:audio_learn/models/playlist.dart';
import 'package:audio_learn/viewmodels/audio_download_vm.dart';
import 'package:audio_learn/viewmodels/warning_message_vm.dart';

class MockAudioDownloadVM extends ChangeNotifier implements AudioDownloadVM {
  final List<Playlist> _playlistLst = [];
  final WarningMessageVM _warningMessageVM;

  String _youtubePlaylistTitle = '';
  set youtubePlaylistTitle(String youtubePlaylistTitle) {
    _youtubePlaylistTitle = youtubePlaylistTitle;
  }

  MockAudioDownloadVM({
    required WarningMessageVM warningMessageVM,
    bool isTest = false,
  }) : _warningMessageVM = warningMessageVM;

  @override
  Future<void> downloadPlaylistAudios({
    required String playlistUrl,
  }) async {
    List<Audio> audioLst = [
      Audio(
          enclosingPlaylist: _playlistLst[0],
          originalVideoTitle: 'Audio 1',
          videoUrl: 'https://example.com/video2',
          audioDownloadDateTime: DateTime(2023, 3, 25),
          videoUploadDate: DateTime.now(),
          audioDuration: const Duration(minutes: 3, seconds: 42),
          compactVideoDescription: 'Video Description 1'),
      Audio(
          enclosingPlaylist: _playlistLst[0],
          originalVideoTitle: 'Audio 2',
          videoUrl: 'https://example.com/video2',
          audioDownloadDateTime: DateTime(2023, 3, 25),
          videoUploadDate: DateTime.now(),
          audioDuration: const Duration(minutes: 5, seconds: 21),
          compactVideoDescription: 'Video Description 2'),
      Audio(
          enclosingPlaylist: _playlistLst[0],
          originalVideoTitle: 'Audio 3',
          videoUrl: 'https://example.com/video2',
          audioDownloadDateTime: DateTime(2023, 3, 25),
          videoUploadDate: DateTime.now(),
          audioDuration: const Duration(minutes: 2, seconds: 15),
          compactVideoDescription: 'Video Description 3'),
    ];

    int i = 1;
    int speed = 100000;
    int size = 900000;

    for (Audio audio in audioLst) {
      audio.audioDownloadSpeed = speed * i;
      audio.audioFileSize = size * i;
      i++;
    }

    _playlistLst[0].downloadedAudioLst = audioLst;
    _playlistLst[0].playableAudioLst = audioLst;

    notifyListeners();
  }

  @override
  late yt.YoutubeExplode youtubeExplode;

  @override
  Future<Playlist?> addPlaylist({
    String playlistUrl = '',
    String localPlaylistTitle = '',
    required PlaylistQuality playlistQuality,
  }) async {
    // in the real app, the playlist title is retrieved by
    // yt.YoutubeExplode using the youtube playlist id obtained
    // using the youtube playlist url. Since integration test
    // cannot access the internet, we use the MockAudioDownloadVM !
    String playlistTitle;
    PlaylistType playlistType;

    if ((localPlaylistTitle == '')) {
      playlistTitle = _youtubePlaylistTitle;
      playlistType = PlaylistType.youtube;
    } else {
      playlistTitle = localPlaylistTitle;
      playlistType = PlaylistType.local;
    }

    Playlist addedPlaylist = Playlist(
      url: playlistUrl,
      title: playlistTitle,
      playlistType: playlistType,
      playlistQuality: playlistQuality,
    );

    // _warningMessageVM.setAddPlaylist(
    //   playlistTitle: addedPlaylist.title,
    //   playlistQuality: playlistQuality,
    // );

    _playlistLst.add(addedPlaylist);

    return addedPlaylist;
  }

  @override
  // TODO: implement currentDownloadingAudio
  Audio get currentDownloadingAudio => _playlistLst[0].downloadedAudioLst[0];

  @override
  // TODO: implement downloadProgress
  double get downloadProgress => 0.5;

  @override
  // TODO: implement isDownloading
  bool get isDownloading => false;

  @override
  // TODO: implement isHighQuality
  bool get isHighQuality => false;

  @override
  // TODO: implement lastSecondDownloadSpeed
  int get lastSecondDownloadSpeed => 100000;

  @override
  // TODO: implement listOfPlaylist
  List<Playlist> get listOfPlaylist => _playlistLst;

  @override
  void setAudioQuality({required bool isHighQuality}) {
    // TODO: implement setAudioQuality
  }

  @override
  Future<void> downloadSingleVideoAudio({
    required String videoUrl,
    required Playlist singleVideoPlaylist,
  }) async {
    // TODO: implement downloadSingleVideoAudio
    throw UnimplementedError();
  }

  @override
  void stopDownload() {
    // TODO: implement stopDownload
  }

  @override
  // TODO: implement audioDownloadError
  bool get audioDownloadError => throw UnimplementedError();

  @override
  // TODO: implement isDownloadStopping
  bool get isDownloadStopping => throw UnimplementedError();

  @override
  void updatePlaylistSelection(
      {required String playlistId, required bool isPlaylistSelected}) {
    // TODO: implement updatePlaylistSelection
  }

  @override
  void deleteAudio({required Audio audio}) {
    // TODO: implement deleteAudio
  }

  @override
  void deleteAudioFromPlaylistAswell({required Audio audio}) {
    // TODO: implement deleteAudioFromPlaylistAswell
  }

  @override
  void copyAudioToPlaylist(
      {required Audio audio, required Playlist targetPlaylist}) {
    // TODO: implement copyAudioToPlaylist
  }

  @override
  int getPlaylistJsonFileSize({required Playlist playlist}) {
    // TODO: implement getPlaylistJsonFileSize
    throw UnimplementedError();
  }

  @override
  set isHighQuality(bool isHighQuality) {
    // TODO: implement isHighQuality
  }

  @override
  void moveAudioToPlaylist(
      {required Audio audio, required Playlist targetPlaylist}) {
    // TODO: implement moveAudioToPlaylist
  }

  @override
  Playlist? obtainSingleVideoPlaylist(List<Playlist> selectedPlaylists) {
    // TODO: implement obtainSingleVideoPlaylist
    throw UnimplementedError();
  }

  @override
  void updatePlaylistJsonFiles() {
    // TODO: implement updatePlaylistJsonFiles
  }
}
