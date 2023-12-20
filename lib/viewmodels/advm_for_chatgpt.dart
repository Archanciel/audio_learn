import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as path;

// importing youtube_explode_dart as yt enables to name the app Model
// playlist class as Playlist so it does not conflict with
// youtube_explode_dart Playlist class name.
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

import '../services/json_data_service.dart';
import '../models/audio.dart';
import '../models/playlist.dart';
import '../utils/dir_util.dart';
import 'warning_message_vm.dart';

// global variables used by the AudioDownloadVM in order
// to avoid multiple downloads of the same playlist
List<String> downloadingPlaylistUrls = [];

/// This VM (View Model) class is part of the MVVM architecture.
///
/// It is responsible of connecting to Youtube in order to download
/// the audio of the videos referenced in the Youtube playlists.
/// It can also download the audio of a single video.
///
/// It is also responsible of creating and deleting application
/// Playlist's, either Youtube app Playlist's or local app
/// Playlist's.
///
/// Another responsibility of this class is to move or copy
/// audio files from one Playlist to another as well as to
/// rename or delete audio files or update their playing
/// speed.
class AudioDownloadVM extends ChangeNotifier {
  List<Playlist> _listOfPlaylist = [];
  List<Playlist> get listOfPlaylist => _listOfPlaylist;

  yt.YoutubeExplode? _youtubeExplode;
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

  bool isHighQuality = false;

  bool _stopDownloadPressed = false;
  bool get isDownloadStopping => _stopDownloadPressed;

  bool _audioDownloadError = false;
  bool get audioDownloadError => _audioDownloadError;

  final WarningMessageVM warningMessageVM;

  /// Passing true for {isTest} has the effect that the windows
  /// test directory is used as playlist root directory. This
  /// directory is located in the test directory of the project.
  ///
  /// Otherwise, the windows or smartphone audio root directory
  /// is used and the value of the kUniquePlaylistTitle constant
  /// is used to load the playlist json file.
  AudioDownloadVM({
    required this.warningMessageVM,
    bool isTest = false,
  }) {
    _playlistsHomePath = DirUtil.getPlaylistDownloadHomePath(isTest: isTest);

    loadExistingPlaylists();
  }

  void loadExistingPlaylists() {
    // reinitializing the list of playlist is necessary since
    // loadExistingPlaylists() is also called by ExpandablePlaylistVM.
    // updateSettingsAndPlaylistJsonFiles() method.
    _listOfPlaylist = [];

    List<String> playlistPathFileNameLst = DirUtil.listPathFileNamesInSubDirs(
      path: _playlistsHomePath,
      extension: 'json',
    );

    for (String playlistPathFileName in playlistPathFileNameLst) {
      Playlist currentPlaylist = JsonDataService.loadFromFile(
        jsonPathFileName: playlistPathFileName,
        type: Playlist,
      );
      _listOfPlaylist.add(currentPlaylist);

      // if the playlist is selected, the audio quality checkbox will be
      // checked or not according to the selected playlist quality
      if (currentPlaylist.isSelected) {
        isHighQuality =
            currentPlaylist.playlistQuality == PlaylistQuality.music;
      }
    }

//    notifyListeners(); not necessary since the unique
//                       Consumer<AudioDownloadVM> is not concerned
//                       by the _listOfPlaylist changes
  }

  /// Downloads the audio of the videos referenced in the passed
  /// playlist.
  Future<void> downloadPlaylistAudios({
    required String playlistUrl,
  }) async {
    // if the playlist is already being downloaded, then
    // the method is not executed. This avoids that the
    // audios of the playlist are downloaded multiple times
    // if the user clicks multiple times on the download
    // button.
    if (downloadingPlaylistUrls.contains(playlistUrl)) {
      return;
    } else {
      downloadingPlaylistUrls.add(playlistUrl);
    }

    _stopDownloadPressed = false;
    _youtubeExplode ??= yt.YoutubeExplode();

    // get Youtube playlist
    String? playlistId;
    yt.Playlist youtubePlaylist;

    playlistId = yt.PlaylistId.parsePlaylistId(playlistUrl);

    try {
      youtubePlaylist = await _youtubeExplode!.playlists.get(playlistId);
    } on SocketException catch (e) {
      notifyDownloadError(
        errorType: ErrorType.noInternet,
        errorArgOne: e.toString(),
      );

      // removing the playlist url from the downloadingPlaylistUrls
      // list since the playlist download has failed
      downloadingPlaylistUrls.remove(playlistUrl);

      return;
    } catch (e) {
      notifyDownloadError(
        errorType: ErrorType.downloadAudioYoutubeError,
        errorArgOne: e.toString(),
      );

      // removing the playlist url from the downloadingPlaylistUrls
      // list since the playlist download has failed
      downloadingPlaylistUrls.remove(playlistUrl);

      return;
    }

    String playlistTitle = youtubePlaylist.title;

    Playlist currentPlaylist = await _addPlaylistIfNotExist(
      playlistUrl: playlistUrl,
      playlistQuality: PlaylistQuality.voice,
      playlistTitle: playlistTitle,
      playlistId: playlistId!,
    );

    // get already downloaded audio file names
    String playlistDownloadFilePathName =
        currentPlaylist.getPlaylistDownloadFilePathName();

    final List<String> downloadedAudioValidVideoTitleLst =
        await _getPlaylistDownloadedAudioValidVideoTitleLst(
            currentPlaylist: currentPlaylist);

    await for (yt.Video youtubeVideo
        in _youtubeExplode!.playlists.getVideos(playlistId)) {
      _audioDownloadError = false;
      final Duration? audioDuration = youtubeVideo.duration;

      // using youtubeVideo.uploadDate is not correct since it
      // it is null !
      DateTime? videoUploadDate =
          (await _youtubeExplode!.videos.get(youtubeVideo.id.value)).uploadDate;

      videoUploadDate ??= DateTime(00, 1, 1);

      // using youtubeVideo.description is not correct since it
      // it is empty !
      String videoDescription =
          (await _youtubeExplode!.videos.get(youtubeVideo.id.value))
              .description;

      String compactVideoDescription = _createCompactVideoDescription(
        videoDescription: videoDescription,
        videoAuthor: youtubeVideo.author,
      );

      final Audio audio = Audio(
        enclosingPlaylist: currentPlaylist,
        originalVideoTitle: youtubeVideo.title,
        compactVideoDescription: compactVideoDescription,
        videoUrl: youtubeVideo.url,
        audioDownloadDateTime: DateTime.now(),
        videoUploadDate: videoUploadDate,
        audioDuration: audioDuration!,
      );

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
        notifyDownloadError(
          errorType: ErrorType.downloadAudioYoutubeError,
          errorArgOne: e.toString(),
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

      // should avoid that the last downloaded audio is
      // re-downloaded
      downloadedAudioValidVideoTitleLst.add(audio.validVideoTitle);

      notifyListeners();
    }

    _isDownloading = false;
    _youtubeExplode!.close();
    _youtubeExplode = null;

    // removing the playlist url from the downloadingPlaylistUrls
    // list since the playlist download has finished
    downloadingPlaylistUrls.remove(playlistUrl);

    notifyListeners();
  }

  notifyDownloadError({
    required ErrorType errorType,
    String? errorArgOne,
    String? errorArgTwo,
    String? errorArgThree,
  }) {
    _isDownloading = false;
    _downloadProgress = 0.0;
    _lastSecondDownloadSpeed = 0;
    _audioDownloadError = true;

    warningMessageVM.setError(
      errorType: errorType,
      errorArgOne: errorArgOne,
      errorArgTwo: errorArgTwo,
      errorArgThree: errorArgThree,
    );

    notifyListeners();
  }

  void stopDownload() {
    _stopDownloadPressed = true;
  }

  /// I think this method is not used anymore
  Future<Playlist> _addPlaylistIfNotExist({
    required String playlistUrl,
    required PlaylistQuality playlistQuality,
    required String playlistTitle,
    required String playlistId,
  }) async {
    Playlist addedPlaylist;
    int existingPlaylistIndex =
        _listOfPlaylist.indexWhere((element) => element.url == playlistUrl);

    if (existingPlaylistIndex == -1) {
      // playlist was never downloaded or was deleted and recreated, which
      // associates it to a new url

      addedPlaylist = await _createYoutubePlaylist(
        playlistUrl: playlistUrl,
        playlistQuality: playlistQuality,
        playlistTitle: playlistTitle,
        playlistId: playlistId,
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
    isHighQuality = isHighQuality;

    notifyListeners();
  }

  /// Method called by ExpandablePlaylistVM when the user selects the update playlist
  /// JSON files menu item.
  void updatePlaylistJsonFiles() {
    List<Playlist> copyOfList = List<Playlist>.from(_listOfPlaylist);

    for (Playlist playlist in copyOfList) {
      bool isPlaylistDownloadPathUpdated = false;

      if (!Directory(playlist.downloadPath).existsSync()) {
        // the case if the playlist dir has been deleted by the user
        // or by another app
        _listOfPlaylist.remove(playlist);
        continue;
      }

      String currentPlaylistDownloadHomePath =
          path.dirname(playlist.downloadPath);

      if (currentPlaylistDownloadHomePath != _playlistsHomePath) {
        // the case if the playlist dir obtained from another audio
        // dir was copied on the app audio dir. Then, it must be
        // updated to the app audio dir
        playlist.downloadPath =
            _playlistsHomePath + path.separator + playlist.title;
        isPlaylistDownloadPathUpdated = true;
      }

      // remove the audios from the playlable audio list which are no
      // longer in the playlist directory
      int removedPlayableAudioNumber = playlist.updatePlayableAudioLst();

      // update validVideoTitle of the playlists audios. This is useful
      // when the method computing the validVideoTitle has been improved
      bool isAnAudioValidVideoTitleChanged = false;

      for (Audio audio in playlist.downloadedAudioLst) {
        String reCreatedValidVideoTitle =
            Audio.createValidVideoTitle(audio.originalVideoTitle);

        if (reCreatedValidVideoTitle != audio.validVideoTitle) {
          audio.validVideoTitle = reCreatedValidVideoTitle;
          isAnAudioValidVideoTitleChanged = true;
        }
      }

      if (isPlaylistDownloadPathUpdated ||
          removedPlayableAudioNumber > 0 ||
          isAnAudioValidVideoTitleChanged) {
        JsonDataService.saveToFile(
          model: playlist,
          path: playlist.getPlaylistDownloadFilePathName(),
        );
      }
    }
  }

  int getPlaylistJsonFileSize({
    required Playlist playlist,
  }) {
    return File(playlist.getPlaylistDownloadFilePathName()).lengthSync();
  }

  String _createCompactVideoDescription({
    required String videoDescription,
    required String videoAuthor,
  }) {
    // Extraire les 3 premières lignes de la description
    List<String> videoDescriptionLinesLst = videoDescription.split('\n');
    String firstThreeLines = videoDescriptionLinesLst.take(3).join('\n');

    // Extraire les noms propres qui ne se trouvent pas dans les 3 premières lignes
    String linesAfterFirstThreeLines =
        videoDescriptionLinesLst.skip(3).join('\n');
    linesAfterFirstThreeLines =
        _removeTimestampLines('$linesAfterFirstThreeLines\n');
    final List<String> linesAfterFirstThreeLinesWordsLst =
        linesAfterFirstThreeLines.split(RegExp(r'[ \n]'));

    // Trouver les noms propres consécutifs (au moins deux)
    List<String> consecutiveProperNames = [];

    for (int i = 0; i < linesAfterFirstThreeLinesWordsLst.length - 1; i++) {
      if (linesAfterFirstThreeLinesWordsLst[i].isNotEmpty &&
          _isEnglishOrFrenchUpperCaseLetter(
              linesAfterFirstThreeLinesWordsLst[i][0]) &&
          linesAfterFirstThreeLinesWordsLst[i + 1].isNotEmpty &&
          _isEnglishOrFrenchUpperCaseLetter(
              linesAfterFirstThreeLinesWordsLst[i + 1][0])) {
        consecutiveProperNames.add(
            '${linesAfterFirstThreeLinesWordsLst[i]} ${linesAfterFirstThreeLinesWordsLst[i + 1]}');
        i++; // Pour ne pas prendre en compte les noms propres suivants qui font déjà partie d'une paire consécutive
      }
    }

    // Combiner firstThreeLines et consecutiveProperNames en une seule chaîne
    final String compactVideoDescription;

    if (consecutiveProperNames.isEmpty) {
      compactVideoDescription = '$videoAuthor\n\n$firstThreeLines ...';
    } else {
      compactVideoDescription =
          '$videoAuthor\n\n$firstThreeLines ...\n\n${consecutiveProperNames.join(', ')}';
    }

    return compactVideoDescription;
  }

  bool _isEnglishOrFrenchUpperCaseLetter(String letter) {
    // Expression régulière pour vérifier si la lettre est une lettre
    // majuscule valide en anglais ou en français
    RegExp validLetterRegex = RegExp(r'[A-ZÀ-ÿ]');
    // Expression régulière pour vérifier si le caractère n'est pas
    // un chiffre
    RegExp notDigitRegex = RegExp(r'\D');

    return validLetterRegex.hasMatch(letter) && notDigitRegex.hasMatch(letter);
  }

  String _removeTimestampLines(String text) {
    // Expression régulière pour identifier les lignes de texte de la vidéo formatées comme les timestamps
    RegExp timestampRegex = RegExp(r'^\d{1,2}:\d{2} .+\n', multiLine: true);

    // Supprimer les lignes correspondantes
    return text.replaceAll(timestampRegex, '').trim();
  }

  Future<Playlist> _createYoutubePlaylist({
    required String playlistUrl,
    required PlaylistQuality playlistQuality,
    required String playlistTitle,
    required String playlistId,
  }) async {
    Playlist playlist = Playlist(
      url: playlistUrl,
      id: playlistId,
      title: playlistTitle,
      playlistType: PlaylistType.youtube,
      playlistQuality: playlistQuality,
    );

    _listOfPlaylist.add(playlist);

    return await _setPlaylistPath(
      playlistTitle: playlistTitle,
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

    return playlistDownloadedAudioLst
        .map((downloadedAudio) => downloadedAudio.validVideoTitle)
        .toList();
  }

  Future<void> _downloadAudioFile({
    required yt.VideoId youtubeVideoId,
    required Audio audio,
  }) async {
    _currentDownloadingAudio = audio;
    final yt.StreamManifest streamManifest;

    try {
      streamManifest = await _youtubeExplode!.videos.streamsClient.getManifest(
        youtubeVideoId,
      );
    } catch (e) {
      notifyDownloadError(
        errorType: ErrorType.downloadAudioYoutubeError,
        errorArgOne: e.toString(),
      );

      return;
    }

    final yt.AudioOnlyStreamInfo audioStreamInfo;

    if (isHighQuality) {
      audioStreamInfo = streamManifest.audioOnly.withHighestBitrate();
    } else {
      audioStreamInfo = streamManifest.audioOnly.first;
    }

    audio.isMusicQuality = isHighQuality;
    final int audioFileSize = audioStreamInfo.size.totalBytes;
    audio.audioFileSize = audioFileSize;

    await _youtubeDownloadAudioFile(
      audio,
      audioStreamInfo,
      audioFileSize,
    );
  }

  Future<void> _youtubeDownloadAudioFile(
    Audio audio,
    yt.AudioOnlyStreamInfo audioStreamInfo,
    int audioFileSize,
  ) async {
    final File file = File(audio.filePathName);
    final IOSink audioFileSink = file.openWrite();
    final Stream<List<int>> audioStream =
        _youtubeExplode!.videos.streamsClient.get(audioStreamInfo);
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

  /// Returns a map containing the chapters names and their HH:mm:ss
  /// time position in the audio.
  Map<String, String> getVideoDescriptionChapters({
    required String videoDescription,
  }) {
    // Extract the "TIME CODE" section from the description.
    String timeCodeSection = videoDescription.split('TIME CODE :').last;

    // Define a pattern to match time codes and chapter names.
    RegExp pattern = RegExp(r'(\d{1,2}:\d{2}(?::\d{2})?)\s+(.+)');

    // Use the pattern to find matches in the time code section.
    Iterable<RegExpMatch> matches = pattern.allMatches(timeCodeSection);

    // Create a map to hold the time codes and chapter names.
    Map<String, String> chapters = <String, String>{};

    for (var match in matches) {
      var timeCode = match.group(1)!;
      var chapterName = match.group(2)!;
      chapters[chapterName] = timeCode;
    }

    return chapters;
  }





  /// {singleVideoTargetPlaylist} is the playlist to which the single
  /// video will be added.
  ///
  /// If the audio of the single video is correctly downloaded and
  /// is added to a playlist, then true is returned, false otherwise.
  ///
  /// Returning true will cause the single video url text field to be
  /// cleared.
  Future<bool> downloadSingleVideoAudio({
    required String videoUrl,
    required Playlist singleVideoTargetPlaylist,
  }) async {
    _audioDownloadError = false;
    _stopDownloadPressed = false;
    _youtubeExplode ??= yt.YoutubeExplode();

    yt.VideoId? videoId = _getVideoId(videoUrl);

    if (videoId == null) {
      return false;
    }

    yt.Video youtubeVideo;

    try {
      youtubeVideo = await _youtubeExplode!.videos.get(videoId);
    } on SocketException catch (e) {
      notifyDownloadError(
        errorType: ErrorType.noInternet,
        errorArgOne: e.toString(),
      );

      return false;
    } catch (e) {
      notifyDownloadError(
        errorType: ErrorType.downloadAudioYoutubeError,
        errorArgOne: e.toString(),
      );

      return false;
    }

    final Duration? audioDuration = youtubeVideo.duration;
    DateTime? videoUploadDate = youtubeVideo.uploadDate;

    videoUploadDate ??= DateTime(00, 1, 1);

    String compactVideoDescription = _createCompactVideoDescription(
      videoDescription: youtubeVideo.description,
      videoAuthor: youtubeVideo.author,
    );

    final Audio audio = Audio(
      enclosingPlaylist: singleVideoTargetPlaylist,
      originalVideoTitle: youtubeVideo.title,
      compactVideoDescription: compactVideoDescription,
      videoUrl: youtubeVideo.url,
      audioDownloadDateTime: DateTime.now(),
      videoUploadDate: videoUploadDate,
      audioDuration: audioDuration!,
    );

    final List<String> downloadedAudioFileNameLst = DirUtil.listFileNamesInDir(
      path: singleVideoTargetPlaylist.downloadPath,
      extension: 'mp3',
    );

    try {
      String existingAudioFileName = downloadedAudioFileNameLst
          .firstWhere((fileName) => fileName.contains(audio.validVideoTitle));
      notifyDownloadError(
        errorType: ErrorType.downloadAudioFileAlreadyOnAudioDirectory,
        errorArgOne: audio.validVideoTitle,
        errorArgTwo: existingAudioFileName,
        errorArgThree: singleVideoTargetPlaylist.title,
      );

      return false;
    } catch (_) {
      // file was not found in the downloaded audio directory
    }

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
      _youtubeExplode!.close();
      _youtubeExplode = null;

      notifyDownloadError(
        errorType: ErrorType.downloadAudioYoutubeError,
        errorArgOne: e.toString(),
      );

      return false;
    }

    stopwatch.stop();

    audio.downloadDuration = stopwatch.elapsed;
    _isDownloading = false;
    _youtubeExplode!.close();
    _youtubeExplode = null;

    singleVideoTargetPlaylist.addDownloadedAudio(audio);

    // fixed bug which caused the playlist including the single
    // video audio to be not saved and so the audio was not
    // displayed in the playlist after restarting the app
    JsonDataService.saveToFile(
      model: singleVideoTargetPlaylist,
      path: singleVideoTargetPlaylist.getPlaylistDownloadFilePathName(),
    );

    notifyListeners();

    return true;
  }

  yt.VideoId? _getVideoId(String videoUrl) {
    yt.VideoId? videoId;

    try {
      videoId = yt.VideoId(videoUrl);
    } on SocketException catch (e) {
      notifyDownloadError(
        errorType: ErrorType.noInternet,
        errorArgOne: e.toString(),
      );
    
      videoId = null;
    } catch (e) {
      // since trying to get the video id from the live video url failed,
      // the url is modified to its value when the video is referenced
      // in a playlist
      videoUrl = videoUrl.replaceFirst('youtube.com/live', 'youtu.be');
      try {
        videoId = yt.VideoId(videoUrl);
      } catch (_) {
        warningMessageVM.isSingleVideoUrlInvalid = true;
      videoId = null;
      }
    }
    
    return videoId;
  }

}
