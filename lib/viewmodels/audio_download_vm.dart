// dart file located in lib\viewmodels

import 'dart:async';
import 'dart:io';

import 'package:audio_learn/services/json_data_service.dart';
import 'package:audio_learn/viewmodels/playlist_edit_vm.dart';
import 'package:flutter/material.dart';

// importing youtube_explode_dart as yt enables to name the app Model
// playlist class as Playlist so it does not conflict with
// youtube_explode_dart Playlist class name.
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;
import 'package:audioplayers/audioplayers.dart';

import '../constants.dart';
import '../models/audio.dart';
import '../models/playlist.dart';
import '../utils/dir_util.dart';

class AudioDownloadVM extends ChangeNotifier {
  List<Playlist> _listOfPlaylist = [];
  List<Playlist> get listOfPlaylist => _listOfPlaylist;

  Playlist? _variousAudiosPlaylist;

  late yt.YoutubeExplode _youtubeExplode;
  // setter used by test only !
  set youtubeExplode(yt.YoutubeExplode youtubeExplode) =>
      _youtubeExplode = youtubeExplode;

  late String _playlistHomePath;

  bool _isDownloading = false;
  bool get isDownloading => _isDownloading;

  double _downloadProgress = 0.0;
  double get downloadProgress => _downloadProgress;

  int _lastSecondDownloadSpeed = 0;
  int get lastSecondDownloadSpeed => _lastSecondDownloadSpeed;

  late Audio _currentDownloadingAudio;
  Audio get currentDownloadingAudio => _currentDownloadingAudio;

  bool _isHighQuality = false;
  bool get isHighQuality => _isHighQuality;

  bool _stopDownloadPressed = false;
  bool get isDownloadStopping => _stopDownloadPressed;

  bool _audioDownloadError = false;
  bool get audioDownloadError => _audioDownloadError;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  /// Passing a testPlaylistTitle has the effect that the windows
  /// test directory is used as playlist root directory. Otherwise,
  /// the windows or smartphone audio root directory is used and
  /// the value of the kUniquePlaylistTitle constant is used to
  /// load the playlist json file.
  AudioDownloadVM({String? testPlaylistTitle}) {
    _playlistHomePath =
        DirUtil.getPlaylistDownloadHomePath(isTest: testPlaylistTitle != null);

    // Should load all the playlists, not only the audio_learn or to_delete
    // playlist !
    _loadExistingPlaylists(testPlaylistTitle: testPlaylistTitle);
  }

  void _loadExistingPlaylists({String? testPlaylistTitle}) async {
    List<String> playlistPathFileNames =
        await DirUtil.listPathFileNamesInSubDirs(
      path: DirUtil.getPlaylistDownloadHomePath(),
      extension: 'json',
    );

    for (String playlistPathFileName in playlistPathFileNames) {
      dynamic currentPlaylist = JsonDataService.loadFromFile(
          jsonPathFileName: playlistPathFileName, type: Playlist);
      // is null if json file not exist
      _listOfPlaylist.add(currentPlaylist);
    }

    notifyListeners();
  }

  /// Currently not used.
  Future<Playlist> addPlaylist({
    required String playlistUrl,
  }) async {
    // get Youtube playlist
    String? playlistId;
    yt.Playlist youtubePlaylist;
    _youtubeExplode = yt.YoutubeExplode();

    playlistId = yt.PlaylistId.parsePlaylistId(playlistUrl);
    youtubePlaylist = await _youtubeExplode.playlists.get(playlistId);

    Playlist addedPlaylist = await _addPlaylist(
      playlistUrl: playlistUrl,
      youtubePlaylist: youtubePlaylist,
    );

    JsonDataService.saveToFile(
      model: addedPlaylist,
      path: addedPlaylist.getPlaylistDownloadFilePathName(),
    );

    // notifyListeners();

    return addedPlaylist;
  }

  /// Downloads the audio of the videos referenced in the passed
  /// playlist.
  Future<void> downloadPlaylistAudios({
    required String playlistUrl,
  }) async {
    _stopDownloadPressed = false;
    _youtubeExplode = yt.YoutubeExplode();

    // get Youtube playlist
    String? playlistId;
    yt.Playlist youtubePlaylist;

    playlistId = yt.PlaylistId.parsePlaylistId(playlistUrl);
    youtubePlaylist = await _youtubeExplode.playlists.get(playlistId);

    Playlist currentPlaylist = await _addPlaylist(
      playlistUrl: playlistUrl,
      youtubePlaylist: youtubePlaylist,
    );

    // get already downloaded audio file names
    String playlistDownloadFilePathName =
        currentPlaylist.getPlaylistDownloadFilePathName();

    final List<String> downloadedAudioValidVideoTitleLst =
        await _getPlaylistDownloadedAudioValidVideoTitleLst(
            currentPlaylist: currentPlaylist);

    await for (yt.Video youtubeVideo
        in _youtubeExplode.playlists.getVideos(playlistId)) {
      _audioDownloadError = false;
      final Duration? audioDuration = youtubeVideo.duration;
      DateTime? videoUploadDate =
          (await _youtubeExplode.videos.get(youtubeVideo.id.value)).uploadDate;

      videoUploadDate ??= DateTime(00, 1, 1);

      final Audio audio = Audio(
        enclosingPlaylist: currentPlaylist,
        originalVideoTitle: youtubeVideo.title,
        videoUrl: youtubeVideo.url,
        audioDownloadDateTime: DateTime.now(),
        videoUploadDate: videoUploadDate,
        audioDuration: audioDuration!,
      );

      audio.audioPlayer = AudioPlayer();

      final bool alreadyDownloaded = downloadedAudioValidVideoTitleLst.any(
          (validVideoTitle) => validVideoTitle.contains(audio.validVideoTitle));

      if (alreadyDownloaded) {
        // print('${audio.audioFileName} already downloaded');

        // avoids that the last downloaded audio download
        // informations remain displayed until all videos referenced
        // in the playlist have been handled.
        if (_isDownloading) {
          _isDownloading = false;

          notifyListeners();
        }

        continue;
      }

      if (_stopDownloadPressed) {
        break;
      }

      Stopwatch stopwatch = Stopwatch()..start();

      if (!_isDownloading) {
        _isDownloading = true;

        notifyListeners();
      }

      // Download the audio file
      try {
        await _downloadAudioFile(
          youtubeVideoId: youtubeVideo.id,
          audio: audio,
        );
      } catch (e) {
        _notifyDownloadError(e.toString());
        continue;
      }

      stopwatch.stop();

      audio.downloadDuration = stopwatch.elapsed;

      currentPlaylist.addDownloadedAudio(audio);
      currentPlaylist.insertAtStartPlayableAudio(audio);

      JsonDataService.saveToFile(
        model: currentPlaylist,
        path: playlistDownloadFilePathName,
      );

      notifyListeners();
    }

    _isDownloading = false;
    _youtubeExplode.close();

    notifyListeners();
  }

  void updatePlaylistSelection({
    required String playlistId,
    required bool isPlaylistSelected,
  }) {
    int playlistIndex =
        _listOfPlaylist.indexWhere((element) => element.id == playlistId);

    Playlist playlist = _listOfPlaylist[playlistIndex];

    playlist.isSelected = isPlaylistSelected;

    JsonDataService.saveToFile(
      model: playlist,
      path: playlist.getPlaylistDownloadFilePathName(),
    );
  }

  _notifyDownloadError(String errorMessage) {
    _isDownloading = false;
    _downloadProgress = 0.0;
    _lastSecondDownloadSpeed = 0;
    _audioDownloadError = true;
    _errorMessage = errorMessage;

    notifyListeners();
  }

  void stopDownload() {
    _stopDownloadPressed = true;
  }

  Future<Playlist> _addPlaylist({
    required String playlistUrl,
    required yt.Playlist youtubePlaylist,
  }) async {
    Playlist addedPlaylist;
    int existingPlaylistIndex =
        _listOfPlaylist.indexWhere((element) => element.url == playlistUrl);

    if (existingPlaylistIndex == -1) {
      // playlist was never downloaded or was deleted and recreated, which
      // associates it to a new url

      addedPlaylist = await _createYoutubePlaylist(
        playlistUrl: playlistUrl,
        youtubePlaylist: youtubePlaylist,
      );

      // checking if current playlist was deleted and recreated
      existingPlaylistIndex = _listOfPlaylist
          .indexWhere((element) => element.title == addedPlaylist.title);

      if (existingPlaylistIndex != -1) {
        // current playlist was deleted and recreated since it is referenced
        // in the _listOfPlaylist and has the same title than the recreated
        // polaylist
        Playlist existingPlaylist = _listOfPlaylist[existingPlaylistIndex];
        addedPlaylist.downloadedAudioLst = existingPlaylist.downloadedAudioLst;
        addedPlaylist.playableAudioLst = existingPlaylist.playableAudioLst;
        _listOfPlaylist[existingPlaylistIndex] = addedPlaylist;
      }
    } else {
      // playlist was already downloaded and so is stored in
      // a playlist json file
      addedPlaylist = _listOfPlaylist[existingPlaylistIndex];
    }

    return addedPlaylist;
  }

  void setAudioQuality({required bool isHighQuality}) {
    _isHighQuality = isHighQuality;

    notifyListeners();
  }

  Future<void> downloadSingleVideoAudio({
    required String videoUrl,
  }) async {
    _audioDownloadError = false;
    _stopDownloadPressed = false;
    _youtubeExplode = yt.YoutubeExplode();

    final yt.VideoId videoId = yt.VideoId(videoUrl);
    yt.Video youtubeVideo = await _youtubeExplode.videos.get(videoId);

    final Duration? audioDuration = youtubeVideo.duration;
    DateTime? videoUploadDate =
        (await _youtubeExplode.videos.get(youtubeVideo.id.value)).uploadDate;

    videoUploadDate ??= DateTime(00, 1, 1);

    _variousAudiosPlaylist ??= await _createVariousPlaylist();

    final Audio audio = Audio(
      enclosingPlaylist: _variousAudiosPlaylist,
      originalVideoTitle: youtubeVideo.title,
      videoUrl: youtubeVideo.url,
      audioDownloadDateTime: DateTime.now(),
      videoUploadDate: videoUploadDate,
      audioDuration: audioDuration!,
    );

    audio.audioPlayer = AudioPlayer();

    Stopwatch stopwatch = Stopwatch()..start();

    if (!_isDownloading) {
      _isDownloading = true;

      notifyListeners();
    }

    try {
      await _downloadAudioFile(
        youtubeVideoId: youtubeVideo.id,
        audio: audio,
      );
    } catch (e) {
      _youtubeExplode.close();
      _notifyDownloadError(e.toString());
      return;
    }

    stopwatch.stop();

    audio.downloadDuration = stopwatch.elapsed;
    _isDownloading = false;
    _youtubeExplode.close();

    notifyListeners();
  }

  Future<Playlist> _createYoutubePlaylist({
    required String playlistUrl,
    required yt.Playlist youtubePlaylist,
  }) async {
    Playlist playlist = Playlist(url: playlistUrl);
    _listOfPlaylist.add(playlist);

    playlist.id = youtubePlaylist.id.toString();

    final String playlistTitle = youtubePlaylist.title;
    playlist.title = playlistTitle;

    return await _setPlaylistPath(
      playlistTitle: playlistTitle,
      playlist: playlist,
    );
  }

  Future<Playlist> _createVariousPlaylist() async {
    Playlist playlist = Playlist(url: '');
    _listOfPlaylist.add(playlist);

    playlist.id = '';

    playlist.title = kVariousAudiosPlaylistTitle;

    return await _setPlaylistPath(
      playlistTitle: kVariousAudiosPlaylistTitle,
      playlist: playlist,
    );
  }

  Future<Playlist> _setPlaylistPath({
    required String playlistTitle,
    required Playlist playlist,
  }) async {
    final String playlistDownloadPath =
        '$_playlistHomePath${Platform.pathSeparator}$playlistTitle';

    // ensure playlist audio download dir exists
    await DirUtil.createDirIfNotExist(pathStr: playlistDownloadPath);

    playlist.downloadPath = playlistDownloadPath;

    return playlist;
  }

  /// Returns an empty list if the passed playlist was created or
  /// recreated.
  Future<List<String>> _getPlaylistDownloadedAudioValidVideoTitleLst({
    required Playlist currentPlaylist,
  }) async {
    List<Audio> playlistDownloadedAudioLst = currentPlaylist.downloadedAudioLst;
    List<String> validAudioVideoTitleLst = [];

    for (Audio downloadedAudio in playlistDownloadedAudioLst) {
      validAudioVideoTitleLst.add(downloadedAudio.validVideoTitle);
    }

    return validAudioVideoTitleLst;
  }

  Future<void> _downloadAudioFile({
    required yt.VideoId youtubeVideoId,
    required Audio audio,
  }) async {
    _currentDownloadingAudio = audio;
    final yt.StreamManifest streamManifest;

    try {
      streamManifest = await _youtubeExplode.videos.streamsClient.getManifest(
        youtubeVideoId,
      );
    } catch (e) {
      _notifyDownloadError(e.toString());
      return;
    }

    final yt.AudioOnlyStreamInfo audioStreamInfo;

    if (_isHighQuality) {
      audioStreamInfo = streamManifest.audioOnly.withHighestBitrate();
    } else {
      audioStreamInfo = streamManifest.audioOnly.first;
    }

    audio.isMusicQuality = _isHighQuality;
    final int audioFileSize = audioStreamInfo.size.totalBytes;
    audio.audioFileSize = audioFileSize;

    await _youtubeDownloadAudioFile(audio, audioStreamInfo, audioFileSize);
  }

  Future<void> _youtubeDownloadAudioFile(
    Audio audio,
    yt.AudioOnlyStreamInfo audioStreamInfo,
    int audioFileSize,
  ) async {
    final File file = File(audio.filePathName);
    final IOSink audioFileSink = file.openWrite();
    final Stream<List<int>> audioStream =
        _youtubeExplode.videos.streamsClient.get(audioStreamInfo);
    int totalBytesDownloaded = 0;
    int previousSecondBytesDownloaded = 0;

    Duration updateInterval = const Duration(seconds: 1);
    DateTime lastUpdate = DateTime.now();
    Timer timer = Timer.periodic(updateInterval, (timer) {
      if (DateTime.now().difference(lastUpdate) >= updateInterval) {
        _updateDownloadProgress(totalBytesDownloaded / audioFileSize,
            totalBytesDownloaded - previousSecondBytesDownloaded);
        previousSecondBytesDownloaded = totalBytesDownloaded;
        lastUpdate = DateTime.now();
      }
    });

    await for (var byteChunk in audioStream) {
      totalBytesDownloaded += byteChunk.length;

      // Vérifiez si le délai a été dépassé avant de mettre à jour la
      // progression
      if (DateTime.now().difference(lastUpdate) >= updateInterval) {
        _updateDownloadProgress(totalBytesDownloaded / audioFileSize,
            totalBytesDownloaded - previousSecondBytesDownloaded);
        previousSecondBytesDownloaded = totalBytesDownloaded;
        lastUpdate = DateTime.now();
      }

      audioFileSink.add(byteChunk);
    }

    // Assurez-vous de mettre à jour la progression une dernière fois
    // à 100% avant de terminer
    _updateDownloadProgress(1.0, 0);

    // Annulez le Timer pour éviter les appels inutiles
    timer.cancel();

    await audioFileSink.flush();
    await audioFileSink.close();
  }

  void _updateDownloadProgress(double progress, int lastSecondDownloadSpeed) {
    _downloadProgress = progress;
    _lastSecondDownloadSpeed = lastSecondDownloadSpeed;

    notifyListeners();
  }
}
