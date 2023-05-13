// dart file located in lib\viewmodels

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';


// importing youtube_explode_dart as yt enables to name the app Model
// playlist class as Playlist so it does not conflict with
// youtube_explode_dart Playlist class name.
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;
import 'package:audioplayers/audioplayers.dart';

import '../services/json_data_service.dart';
import '../constants.dart';
import '../models/audio.dart';
import '../models/playlist.dart';
import '../utils/dir_util.dart';
import 'warning_message_vm.dart';

class AudioDownloadVM extends ChangeNotifier {
  List<Playlist> _listOfPlaylist = [];
  List<Playlist> get listOfPlaylist => _listOfPlaylist;

  Playlist? _variousAudiosPlaylist;

  late yt.YoutubeExplode _youtubeExplode;
  // setter used by test only !
  set youtubeExplode(yt.YoutubeExplode youtubeExplode) =>
      _youtubeExplode = youtubeExplode;

  late String _playlistsHomePath;

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

  final WarningMessageVM _warningMessageVM;

  /// Passing a testPlaylistTitle has the effect that the windows
  /// test directory is used as playlist root directory. Otherwise,
  /// the windows or smartphone audio root directory is used and
  /// the value of the kUniquePlaylistTitle constant is used to
  /// load the playlist json file.
  AudioDownloadVM(
      {required WarningMessageVM warningMessageVM, String? testPlaylistTitle})
      : _warningMessageVM = warningMessageVM {
    _playlistsHomePath =
        DirUtil.getPlaylistDownloadHomePath(isTest: testPlaylistTitle != null);

    _loadExistingPlaylists();
  }

  void _loadExistingPlaylists() {
    List<String> playlistPathFileNameLst = DirUtil.listPathFileNamesInSubDirs(
      path: _playlistsHomePath,
      extension: 'json',
    );

    for (String playlistPathFileName in playlistPathFileNameLst) {
      dynamic currentPlaylist = JsonDataService.loadFromFile(
          jsonPathFileName: playlistPathFileName, type: Playlist);
      // is null if json file not exist
      _listOfPlaylist.add(currentPlaylist);
    }

    notifyListeners();
  }

  Future<Playlist?> addPlaylist({
    required String playlistUrl,
  }) async {
    // those two variables are used by the
    // ExpandablePlaylistListView UI to show a message
    _warningMessageVM.updatedPlaylistTitle = '';
    _warningMessageVM.addedPlaylistTitle = '';
    _warningMessageVM.isPlaylistUrlInvalid = false;

    if (!playlistUrl.contains('list=')) {
      // the case if the url is a video url and the user
      // clicked on the Add button instead of the Download
      // button or if the String pasted to the url text field
      // is not a valid Youtube playlist url.
      _warningMessageVM.isPlaylistUrlInvalid = true;
      return null;
    }

    // get Youtube playlist
    String? playlistId;
    yt.Playlist youtubePlaylist;
    _youtubeExplode = yt.YoutubeExplode();

    playlistId = yt.PlaylistId.parsePlaylistId(playlistUrl);

    try {
      youtubePlaylist = await _youtubeExplode.playlists.get(playlistId);
    } on SocketException catch (e) {
      _notifyDownloadError(
        errorType: ErrorType.noInternet,
        errorMessage: e.toString(),
      );
      return null;
    } catch (e) {
      _warningMessageVM.isPlaylistUrlInvalid = true;
      return null;
    }

    String playlistTitle = youtubePlaylist.title;

    int playlistIndex = _listOfPlaylist
        .indexWhere((playlist) => playlist.title == playlistTitle);

    if (playlistIndex != -1) {
      // This means that the playlist was not added, but
      // that its url was updated. The case when a new
      // playlist with the same title is created in order
      // to replace the old one which contains too many
      // audios.
      Playlist updatedPlaylist = _listOfPlaylist[playlistIndex];
      updatedPlaylist.url = playlistUrl;
      updatedPlaylist.id = playlistId!;
      _warningMessageVM.updatedPlaylistTitle = playlistTitle;

      JsonDataService.saveToFile(
        model: updatedPlaylist,
        path: updatedPlaylist.getPlaylistDownloadFilePathName(),
      );

      return updatedPlaylist;
    }

    // Adding the playlist to the application

    Playlist addedPlaylist = await _addPlaylistIfNotExist(
      playlistUrl: playlistUrl,
      youtubePlaylist: youtubePlaylist,
    );

    JsonDataService.saveToFile(
      model: addedPlaylist,
      path: addedPlaylist.getPlaylistDownloadFilePathName(),
    );

    _warningMessageVM.addedPlaylistTitle = addedPlaylist.title;

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

    try {
      youtubePlaylist = await _youtubeExplode.playlists.get(playlistId);
    } on SocketException catch (e) {
      _notifyDownloadError(
        errorType: ErrorType.noInternet,
        errorMessage: e.toString(),
      );
      return;
    } catch (e) {
      _notifyDownloadError(
        errorType: ErrorType.downloadAudioYoutubeError,
        errorMessage: e.toString(),
      );
      return;
    }

    Playlist currentPlaylist = await _addPlaylistIfNotExist(
      playlistUrl: playlistUrl,
      youtubePlaylist: youtubePlaylist,
    );

    // get already downloaded audio file names
    String playlistDownloadFilePathName =
        currentPlaylist.getPlaylistDownloadFilePathName();

    final List<String> downloadedAudioOriginalVideoTitleLst =
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

      final bool alreadyDownloaded = downloadedAudioOriginalVideoTitleLst.any(
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
        _notifyDownloadError(
          errorType: ErrorType.downloadAudioYoutubeError,
          errorMessage: e.toString(),
        );
        continue;
      }

      stopwatch.stop();

      audio.downloadDuration = stopwatch.elapsed;

      currentPlaylist.addDownloadedAudio(audio);

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

  _notifyDownloadError({
    required ErrorType errorType,
    String? errorMessage,
  }) {
    _isDownloading = false;
    _downloadProgress = 0.0;
    _lastSecondDownloadSpeed = 0;
    _audioDownloadError = true;

    _warningMessageVM.setError(
      errorType: errorType,
      errorMessage: errorMessage,
    );

    notifyListeners();
  }

  void stopDownload() {
    _stopDownloadPressed = true;
  }

  Future<Playlist> _addPlaylistIfNotExist({
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

    final yt.VideoId videoId;

    try {
      videoId = yt.VideoId(videoUrl);
    } on SocketException catch (e) {
      _notifyDownloadError(
        errorType: ErrorType.noInternet,
        errorMessage: e.toString(),
      );
      return;
    } catch (e) {
      _warningMessageVM.isSingleVideoUrlInvalid = true;
      return;
    }

    yt.Video youtubeVideo;

    try {
      youtubeVideo = await _youtubeExplode.videos.get(videoId);
    } on SocketException catch (e) {
      _notifyDownloadError(
        errorType: ErrorType.noInternet,
        errorMessage: e.toString(),
      );
      return;
    } catch (e) {
      _notifyDownloadError(
        errorType: ErrorType.downloadAudioYoutubeError,
        errorMessage: e.toString(),
      );
      return;
    }

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

    final File file = File(audio.filePathName);

    if (file.existsSync()) {
      _notifyDownloadError(
        errorType: ErrorType.downloadAudioFileAlreadyOnAudioDirectory,
        errorMessage: DirUtil.removeAudioDownloadHomePathFromPathFileName(
            pathFileName: audio.filePathName),
      );

      return;
    }

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
      _notifyDownloadError(
        errorType: ErrorType.downloadAudioYoutubeError,
        errorMessage: e.toString(),
      );
      return;
    }

    stopwatch.stop();

    audio.downloadDuration = stopwatch.elapsed;
    _isDownloading = false;
    _youtubeExplode.close();

    notifyListeners();
  }

  /// Physically deletes the audio file from the audio playlist 
  /// directory.
  void deleteAudio({
    required Audio audio,
  }) {
    DirUtil.deleteFileIfExist(audio.filePathName);

    // since the audio mp3 file has been deleted, the audio is no 
    // longer in the playlist playable audio list
    audio.enclosingPlaylist!.removePlayableAudio(audio);
  }

  /// User selected the audio menu item "Delete audio
  /// from playlist aswell". This method deletes the audio
  /// from the playlist json file and from the audio playlist
  /// directory.
  void deleteAudioFromPlaylistAswell({
    required Audio audio,
  }) {
    DirUtil.deleteFileIfExist(audio.filePathName);

    Playlist? enclosingPlaylist = audio.enclosingPlaylist;

    // if (enclosingPlaylist != null) {
    enclosingPlaylist!.removeDownloadedAudio(audio);

    JsonDataService.saveToFile(
      model: enclosingPlaylist,
      path: enclosingPlaylist.getPlaylistDownloadFilePathName(),
    );
    // }

    _warningMessageVM.setDeleteAudioFromPlaylistAswellTitle(
        deleteAudioFromPlaylistAswellTitle: enclosingPlaylist!.title,
        deleteAudioFromPlaylistAswellAudioVideoTitle: audio.originalVideoTitle);
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
        '$_playlistsHomePath${Platform.pathSeparator}$playlistTitle';

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
      _notifyDownloadError(
        errorType: ErrorType.downloadAudioYoutubeError,
        errorMessage: e.toString(),
      );
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
