// dart file located in lib\viewmodels

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as path;

// importing youtube_explode_dart as yt enables to name the app Model
// playlist class as Playlist so it does not conflict with
// youtube_explode_dart Playlist class name.
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;
import 'package:audioplayers/audioplayers.dart';

import '../services/json_data_service.dart';
import '../models/audio.dart';
import '../models/playlist.dart';
import '../utils/dir_util.dart';
import 'warning_message_vm.dart';

class AudioDownloadVM extends ChangeNotifier {
  List<Playlist> _listOfPlaylist = [];
  List<Playlist> get listOfPlaylist => _listOfPlaylist;

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

  bool isHighQuality = false;

  bool _stopDownloadPressed = false;
  bool get isDownloadStopping => _stopDownloadPressed;

  bool _audioDownloadError = false;
  bool get audioDownloadError => _audioDownloadError;

  final WarningMessageVM _warningMessageVM;

  /// Passing true for {isTest} has the effect that the windows
  /// test directory is used as playlist root directory. This
  /// directory is located in the test directory of the project.
  ///
  /// Otherwise, the windows or smartphone audio root directory
  /// is used and the value of the kUniquePlaylistTitle constant
  /// is used to load the playlist json file.
  AudioDownloadVM({
    required WarningMessageVM warningMessageVM,
    bool isTest = false,
  }) : _warningMessageVM = warningMessageVM {
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

  Future<Playlist?> addPlaylist({
    String playlistUrl = '',
    String localPlaylistTitle = '',
    required PlaylistQuality playlistQuality,
  }) async {
    return addPlaylistCallableByMock(
      playlistUrl: playlistUrl,
      localPlaylistTitle: localPlaylistTitle,
      playlistQuality: playlistQuality,
    );
  }

  /// This method has been created in order for the
  /// MockAudioDownloadVM addPlaylist() method to be able
  /// to use the AudioDownloadVM.addPlaylist() logic.
  ///
  /// Additionally, since the method is called by the
  /// AudioDownloadVM, it contains the logic to add a
  /// playlist and so, if this logic is modified, it
  /// will be modified in only one place and will be
  /// tested by the integration test.
  ///
  /// Since the MockAudioDownloadVM exists because when
  /// executing integration tests, using YoutubeExplode
  /// to get a Youtube playlist in order to obtain the
  /// playlist title is not possible, the
  /// {mockYoutubePlaylistTitle} is passed to the method if
  /// the method is called by the MockAudioDownloadVM.
  Future<Playlist?> addPlaylistCallableByMock({
    String playlistUrl = '',
    String localPlaylistTitle = '',
    required PlaylistQuality playlistQuality,
    String? mockYoutubePlaylistTitle,
  }) async {
    Playlist addedPlaylist;

    // those two variables are used by the
    // ExpandablePlaylistListView UI to show a message
    _warningMessageVM.updatedPlaylistTitle = '';
    _warningMessageVM.isPlaylistUrlInvalid = false;

    if (localPlaylistTitle.isNotEmpty) {
      addedPlaylist = Playlist(
        id: localPlaylistTitle, // necessary since the id is used to
        //                         identify the playlist in the list
        //                         of playlist
        title: localPlaylistTitle,
        playlistType: PlaylistType.local,
        playlistQuality: playlistQuality,
      );

      await _setPlaylistPath(
        playlistTitle: localPlaylistTitle,
        playlist: addedPlaylist,
      );

      JsonDataService.saveToFile(
        model: addedPlaylist,
        path: addedPlaylist.getPlaylistDownloadFilePathName(),
      );

      // if the local playlist is not added to the list of
      // playlist, then it will not be displayed at the end
      // of the list of playlist in the UI ! This is because
      // ExpandablePlaylistListVM.getUpToDateSelectablePlaylists()
      // obtains the list of playlist from the AudioDownloadVM.
      _listOfPlaylist.add(addedPlaylist);
      _warningMessageVM.setAddPlaylist(
        playlistTitle: localPlaylistTitle,
        playlistQuality: playlistQuality,
      );

      return addedPlaylist;
    } else if (!playlistUrl.contains('list=')) {
      // the case if the url is a video url and the user
      // clicked on the Add button instead of the Download
      // button or if the String pasted to the url text field
      // is not a valid Youtube playlist url.
      _warningMessageVM.isPlaylistUrlInvalid = true;

      return null;
    } else {
      // get Youtube playlist
      String? playlistId;
      yt.Playlist youtubePlaylist;
      _youtubeExplode = yt.YoutubeExplode();

      playlistId = yt.PlaylistId.parsePlaylistId(playlistUrl);

      String playlistTitle;

      if (mockYoutubePlaylistTitle == null) {
        // the method is called by AudioDownloadVM.addPlaylist()
        try {
          youtubePlaylist = await _youtubeExplode.playlists.get(playlistId);
        } on SocketException catch (e) {
          _notifyDownloadError(
            errorType: ErrorType.noInternet,
            errorArgOne: e.toString(),
          );

          return null;
        } catch (e) {
          _warningMessageVM.isPlaylistUrlInvalid = true;

          return null;
        }

        playlistTitle = youtubePlaylist.title;
      } else {
        // the method is called by MockAudioDownloadVM.addPlaylist()
        playlistTitle = mockYoutubePlaylistTitle;
      }

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

      addedPlaylist = await _addPlaylistIfNotExist(
        playlistUrl: playlistUrl,
        playlistQuality: playlistQuality,
        playlistTitle: playlistTitle,
        playlistId: playlistId!,
      );

      JsonDataService.saveToFile(
        model: addedPlaylist,
        path: addedPlaylist.getPlaylistDownloadFilePathName(),
      );
    }

    _warningMessageVM.setAddPlaylist(
      playlistTitle: addedPlaylist.title,
      playlistQuality: playlistQuality,
    );

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
        errorArgOne: e.toString(),
      );
      return;
    } catch (e) {
      _notifyDownloadError(
        errorType: ErrorType.downloadAudioYoutubeError,
        errorArgOne: e.toString(),
      );
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
        in _youtubeExplode.playlists.getVideos(playlistId)) {
      _audioDownloadError = false;
      final Duration? audioDuration = youtubeVideo.duration;
      final String videoAuthor = youtubeVideo.author;
      DateTime? videoUploadDate =
          (await _youtubeExplode.videos.get(youtubeVideo.id.value)).uploadDate;

      videoUploadDate ??= DateTime(00, 1, 1);

      String videoDescription =
          (await _youtubeExplode.videos.get(youtubeVideo.id.value)).description;

      String compactVideoDescription = _createCompactVideoDescription(
        videoDescription: videoDescription,
        videoAuthor: videoAuthor,
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
        _notifyDownloadError(
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
    _youtubeExplode.close();

    notifyListeners();
  }

  void updatePlaylistSelection({
    required String playlistId,
    required bool isPlaylistSelected,
  }) {
    Playlist playlist =
        _listOfPlaylist.firstWhere((element) => element.id == playlistId);

    bool isPlaylistSelectionChanged = playlist.isSelected != isPlaylistSelected;

    if (isPlaylistSelectionChanged) {
      playlist.isSelected = isPlaylistSelected;

      // if the playlist is selected, the audio quality checkbox will be
      // checked or not according to the selected playlist quality
      if (isPlaylistSelected) {
        isHighQuality = playlist.playlistQuality == PlaylistQuality.music;
      }

      // saving the playlist since its isSelected property has been updated
      JsonDataService.saveToFile(
        model: playlist,
        path: playlist.getPlaylistDownloadFilePathName(),
      );
    }
  }

  _notifyDownloadError({
    required ErrorType errorType,
    String? errorArgOne,
    String? errorArgTwo,
    String? errorArgThree,
  }) {
    _isDownloading = false;
    _downloadProgress = 0.0;
    _lastSecondDownloadSpeed = 0;
    _audioDownloadError = true;

    _warningMessageVM.setError(
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

  /// {singleVideoTargetPlaylist} is the playlist to which the single video
  /// will be added
  Future<void> downloadSingleVideoAudio({
    required String videoUrl,
    required Playlist singleVideoTargetPlaylist,
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
        errorArgOne: e.toString(),
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
        errorArgOne: e.toString(),
      );
      return;
    } catch (e) {
      _notifyDownloadError(
        errorType: ErrorType.downloadAudioYoutubeError,
        errorArgOne: e.toString(),
      );
      return;
    }

    final Duration? audioDuration = youtubeVideo.duration;
    final String videoAuthor = youtubeVideo.author;
    DateTime? videoUploadDate =
        (await _youtubeExplode.videos.get(youtubeVideo.id.value)).uploadDate;

    videoUploadDate ??= DateTime(00, 1, 1);

    String videoDescription =
        (await _youtubeExplode.videos.get(youtubeVideo.id.value)).description;

    String compactVideoDescription = _createCompactVideoDescription(
      videoDescription: videoDescription,
      videoAuthor: videoAuthor,
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
      String firstMatch = downloadedAudioFileNameLst
          .firstWhere((fileName) => fileName.contains(audio.validVideoTitle));
      _notifyDownloadError(
        errorType: ErrorType.downloadAudioFileAlreadyOnAudioDirectory,
        errorArgOne: audio.validVideoTitle,
        errorArgTwo: firstMatch,
        errorArgThree: singleVideoTargetPlaylist.title,
      );

      return;
    } catch (e) {
      // file was not found in the downloaded audio directory
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
        errorArgOne: e.toString(),
      );
      return;
    }

    stopwatch.stop();

    audio.downloadDuration = stopwatch.elapsed;
    _isDownloading = false;
    _youtubeExplode.close();

    singleVideoTargetPlaylist.addDownloadedAudio(audio);

    // fixed bug which caused the playlist including the single
    // video audio to be not saved and so the audio was not
    // displayed in the playlist after restarting the app
    JsonDataService.saveToFile(
      model: singleVideoTargetPlaylist,
      path: singleVideoTargetPlaylist.getPlaylistDownloadFilePathName(),
    );

    notifyListeners();
  }

  /// This method verifies if the user selected a single playlist
  /// to download a single video audio. If the user selected more
  /// than one playlistor if the user did not select any playlist,
  /// then a warning message is displayed.
  Playlist? obtainSingleVideoPlaylist(List<Playlist> selectedPlaylists) {
    if (selectedPlaylists.length == 1) {
      return selectedPlaylists[0];
    } else if (selectedPlaylists.isEmpty) {
      _warningMessageVM.isNoPlaylistSelectedForSingleVideoDownload = true;
      return null;
    } else {
      _warningMessageVM.isTooManyPlaylistSelectedForSingleVideoDownload = true;
      return null;
    }
  }

  void moveAudioToPlaylist(
      {required Audio audio,
      required Playlist targetPlaylist,
      required bool keepAudioDataInSourcePlaylist}) {
    Playlist fromPlaylist = audio.enclosingPlaylist!;

    bool wasFileMoved = DirUtil.moveFileToDirectorySync(
      sourceFilePathName: audio.filePathName,
      targetDirectoryPath: targetPlaylist.downloadPath,
    );

    if (!wasFileMoved) {
      _warningMessageVM.setAudioNotMovedFromToPlaylistTitles(
          movedAudioValidVideoTitle: audio.validVideoTitle,
          movedFromPlaylistTitle: fromPlaylist.title,
          movedToPlaylistTitle: targetPlaylist.title);

      return;
    }

    if (keepAudioDataInSourcePlaylist) {
      // Keeping audio data in source playlist downloadedAudioLst
      // means that the audio will not be redownloaded if the
      // Download All is applyed to the source playlist. But since
      // the audio is moved to the target playlist, it will has to
      // be removed from the source playlist playableAudioLst.
      fromPlaylist.removeDownloadedAudioFromPlayableAudioLstOnly(
        downloadedAudio: audio,
      );
    } else {
      fromPlaylist.removeDownloadedAudioFromDownloadAndPlayableAudioLst(
        downloadedAudio: audio,
      );
    }

    targetPlaylist.addDownloadedAudio(audio);

    JsonDataService.saveToFile(
      model: fromPlaylist,
      path: fromPlaylist.getPlaylistDownloadFilePathName(),
    );

    JsonDataService.saveToFile(
      model: targetPlaylist,
      path: targetPlaylist.getPlaylistDownloadFilePathName(),
    );

    _warningMessageVM.setAudioMovedFromToPlaylistTitles(
        movedAudioValidVideoTitle: audio.validVideoTitle,
        movedFromPlaylistTitle: fromPlaylist.title,
        movedFromPlaylistType: fromPlaylist.playlistType,
        movedToPlaylistTitle: targetPlaylist.title,
        keepAudioDataInSourcePlaylist: keepAudioDataInSourcePlaylist);
  }

  void copyAudioToPlaylist({
    required Audio audio,
    required Playlist targetPlaylist,
  }) {
    bool wasFileCopied = DirUtil.copyFileToDirectorySync(
      sourceFilePathName: audio.filePathName,
      targetDirectoryPath: targetPlaylist.downloadPath,
    );

    String fromPlaylistTitle = audio.enclosingPlaylist!.title;

    if (!wasFileCopied) {
      _warningMessageVM.setAudioNotCopiedFromToPlaylistTitles(
          copiedAudioValidVideoTitle: audio.validVideoTitle,
          copiedFromPlaylistTitle: fromPlaylistTitle,
          copiedToPlaylistTitle: targetPlaylist.title);

      return;
    }

    targetPlaylist.addDownloadedAudio(audio);

    JsonDataService.saveToFile(
      model: targetPlaylist,
      path: targetPlaylist.getPlaylistDownloadFilePathName(),
    );

    _warningMessageVM.setAudioCopiedFromToPlaylistTitles(
        copiedAudioValidVideoTitle: audio.validVideoTitle,
        copiedFromPlaylistTitle: fromPlaylistTitle,
        copiedToPlaylistTitle: targetPlaylist.title);
  }

  /// Physically deletes the audio file from the audio playlist
  /// directory and removes the audio from the playlist playable
  /// audio list.
  void deleteAudioMp3({
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
    enclosingPlaylist!.removeDownloadedAudioFromDownloadAndPlayableAudioLst(
      downloadedAudio: audio,
    );

    JsonDataService.saveToFile(
      model: enclosingPlaylist,
      path: enclosingPlaylist.getPlaylistDownloadFilePathName(),
    );
    // }

    if (enclosingPlaylist.playlistType == PlaylistType.youtube) {
      _warningMessageVM.setDeleteAudioFromPlaylistAswellTitle(
          deleteAudioFromPlaylistAswellTitle: enclosingPlaylist.title,
          deleteAudioFromPlaylistAswellAudioVideoTitle:
              audio.originalVideoTitle);
    }
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
      streamManifest = await _youtubeExplode.videos.streamsClient.getManifest(
        youtubeVideoId,
      );
    } catch (e) {
      _notifyDownloadError(
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
