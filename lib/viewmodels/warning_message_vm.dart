import 'package:audio_learn/models/playlist.dart';
import 'package:flutter/material.dart';

enum WarningMessageType {
  none,
  errorMessage, // An error message depending on error type is
  // displayed.

  updatedPlaylistUrlTitle, // This means that the playlist was not added, but
  // that its url was updated. The case when a new
  // playlist with the same title is created in order
  // to replace the old one which contains too many
  // audios.

  addPlaylistTitle, // The playlist with this title is added
  // to the application.

  invalidPlaylistUrl, // The case if the url is a video url and the
  // user clicked on the Add button instead of the Download
  // button or if the String pasted to the url text field
  // is not a valid Youtube playlist url.

  playlistWithUrlAlreadyInListOfPlaylists, // User clicked on Add
  // button but the playlist with this url was already downloaded.

  localPlaylistWithTitleAlreadyInListOfPlaylists, // User clicked on
  // Add button but the local playlist with this title was already
  // created.

  deleteAudioFromPlaylistAswellWarning, // User selected the audio
  // menu item "Delete audio from playlist aswell".

  invalidSingleVideoUUrl, // The case if the url is a playlist url
  // and the Download button was clicked instead of the Add button,
  // or if the String pasted to the url text field is not a valid
  // Youtube video url.

  updatedPlayableAudioLst, // The case if the playable audio list
  // was updated. This happens when the user clicks on the update
  // playable audio list playlist menu item.

  noPlaylistSelectedForSingleVideoDownload, // The case if the user
  // clicks on the single video download button but no playlist
  // to which the downloaded audio will be added is selected.

  tooManyPlaylistSelectedForSingleVideoDownload, // The case if the
  // user clicks on the single video download button but more than
  // one playlist to which the downloaded audio will be added is
  // selected.

  ok, // The case if the user clicks on the OK button after a
  // confirmation message is displayed.

  confirmSingleVideoDownload, // The case if the user clicks on the
  // single video download button after selecting a target playlist.

  audioNotMovedFromToPlaylist, // The case if the user clicks on
  // the move audio to playlist menu item but the audio was not moved
  // from the source playlist to the target playlist since the
  // target playlist already contains the audio.

  audioNotCopiedFromToPlaylist, // The case if the user clicks on
  // the copy audio to playlist menu item but the audio was not copied
  // from the source playlist to the target playlist since the
  // target playlist already contains the audio.

  audioMovedFromToPlaylist, // The case if the user clicks on
  // the move audio to playlist menu item and the audio was moved
  // from the source playlist to the target playlist.

  audioCopiedFromToPlaylist, // The case if the user clicks on
  // the copy audio to playlist menu item and the audio was copied
  // from the source playlist to the target playlist.
}

enum ErrorType {
  none,

  downloadAudioYoutubeError, // In case of a Youtube error.

  downloadAudioFileAlreadyOnAudioDirectory, // In case the audio file
  // is already on the audio directory and will not be redownloaded.

  noInternet, // device not connected. Happens when trying to
  // download a playlist or a single video or to add a new playlist
  // or update an existing playlist.
}

class WarningMessageVM extends ChangeNotifier {
  WarningMessageType _warningMessageType = WarningMessageType.none;
  WarningMessageType get warningMessageType => _warningMessageType;

  /// Called after a warning message is displayed when the user
  /// clicks on the OK button.
  set warningMessageType(WarningMessageType warningMessageType) {
    _warningMessageType = warningMessageType;
  }

  String _errorArgOne = '';
  String get errorArgOne => _errorArgOne;
  String _errorArgTwo = '';
  String get errorArgTwo => _errorArgTwo;
  String _errorArgThree = '';
  String get errorArgThree => _errorArgThree;

  ErrorType _errorType = ErrorType.none;
  ErrorType get errorType => _errorType;
  void setError({
    required ErrorType errorType,
    String? errorArgOne,
    String? errorArgTwo,
    String? errorArgThree,
  }) {
    _errorType = errorType;

    if (errorType != ErrorType.none) {
      _warningMessageType = WarningMessageType.errorMessage;

      if (errorArgOne != null) {
        _errorArgOne = errorArgOne;
      }

      if (errorArgTwo != null) {
        _errorArgTwo = errorArgTwo;
      }

      if (errorArgThree != null) {
        _errorArgThree = errorArgThree;
      }

      notifyListeners();
    } else {
      _errorArgOne = '';
    }
  }

  String _updatedPlaylistTitle = '';
  String get updatedPlaylistTitle => _updatedPlaylistTitle;
  set updatedPlaylistTitle(String updatedPlaylistTitle) {
    _updatedPlaylistTitle = updatedPlaylistTitle;

    if (updatedPlaylistTitle.isNotEmpty) {
      _warningMessageType = WarningMessageType.updatedPlaylistUrlTitle;

      notifyListeners();
    }
  }

  String _addedPlaylistTitle = '';
  String get addedPlaylistTitle => _addedPlaylistTitle;

  PlaylistQuality _addedPlaylistQuality = PlaylistQuality.voice;
  PlaylistQuality get addedPlaylistQuality => _addedPlaylistQuality;

  void setAddPlaylist({
    required String playlistTitle,
    required PlaylistQuality playlistQuality,
  }) {
    _addedPlaylistTitle = playlistTitle;
    _addedPlaylistQuality = playlistQuality;

    if (playlistTitle.isNotEmpty) {
      _warningMessageType = WarningMessageType.addPlaylistTitle;

      notifyListeners();
    }
  }

  bool _isPlaylistUrlInvalid = false;
  bool get isPlaylistUrlInvalid => _isPlaylistUrlInvalid;
  set isPlaylistUrlInvalid(bool isPlaylistUrlInvalid) {
    _isPlaylistUrlInvalid = isPlaylistUrlInvalid;

    if (isPlaylistUrlInvalid) {
      _warningMessageType = WarningMessageType.invalidPlaylistUrl;

      notifyListeners();
    }
  }

  bool _isSingleVideoUrlInvalid = false;
  bool get isSingleVideoUrlInvalid => _isSingleVideoUrlInvalid;
  set isSingleVideoUrlInvalid(bool isSingleVideoUrlInvalid) {
    _isSingleVideoUrlInvalid = isPlaylistUrlInvalid;

    if (isSingleVideoUrlInvalid) {
      _warningMessageType = WarningMessageType.invalidSingleVideoUUrl;

      notifyListeners();
    }
  }

  String _playlistAlreadyDownloadedTitle = '';
  String get playlistAlreadyDownloadedTitle => _playlistAlreadyDownloadedTitle;
  void setPlaylistAlreadyDownloadedTitle({
    required String playlistTitle,
  }) {
    _playlistAlreadyDownloadedTitle = playlistTitle;

    _warningMessageType =
        WarningMessageType.playlistWithUrlAlreadyInListOfPlaylists;

    notifyListeners();
  }

  String _localPlaylistAlreadyCreatedTitle = '';
  String get localPlaylistAlreadyCreatedTitle =>
      _localPlaylistAlreadyCreatedTitle;
  void setLocalPlaylistAlreadyCreatedTitle({
    required String playlistTitle,
  }) {
    _localPlaylistAlreadyCreatedTitle = playlistTitle;

    _warningMessageType =
        WarningMessageType.localPlaylistWithTitleAlreadyInListOfPlaylists;

    notifyListeners();
  }

  bool _isNoPlaylistSelectedForSingleVideoDownload = false;
  bool get isNoPlaylistSelectedForSingleVideoDownload =>
      _isNoPlaylistSelectedForSingleVideoDownload;
  set isNoPlaylistSelectedForSingleVideoDownload(
      bool isNoPlaylistSelectedForSingleVideoDownload) {
    _isNoPlaylistSelectedForSingleVideoDownload =
        isNoPlaylistSelectedForSingleVideoDownload;

    if (isNoPlaylistSelectedForSingleVideoDownload) {
      _warningMessageType =
          WarningMessageType.noPlaylistSelectedForSingleVideoDownload;

      notifyListeners();
    }
  }

  bool _isTooManyPlaylistSelectedForSingleVideoDownload = false;
  bool get isTooManyPlaylistSelectedForSingleVideoDownload =>
      _isTooManyPlaylistSelectedForSingleVideoDownload;
  set isTooManyPlaylistSelectedForSingleVideoDownload(
      bool isTooManyPlaylistSelectedForSingleVideoDownload) {
    _isTooManyPlaylistSelectedForSingleVideoDownload =
        isTooManyPlaylistSelectedForSingleVideoDownload;

    if (isTooManyPlaylistSelectedForSingleVideoDownload) {
      _warningMessageType =
          WarningMessageType.tooManyPlaylistSelectedForSingleVideoDownload;

      notifyListeners();
    }
  }

  String _deleteAudioFromPlaylistAswellAudioVideoTitle = '';
  String get deleteAudioFromPlaylistAswellAudioVideoTitle =>
      _deleteAudioFromPlaylistAswellAudioVideoTitle;
  String _deleteAudioFromPlaylistAswellTitle = '';
  String get deleteAudioFromPlaylistAswellTitle =>
      _deleteAudioFromPlaylistAswellTitle;
  void setDeleteAudioFromPlaylistAswellTitle({
    required String deleteAudioFromPlaylistAswellTitle,
    required String deleteAudioFromPlaylistAswellAudioVideoTitle,
  }) {
    _deleteAudioFromPlaylistAswellTitle = deleteAudioFromPlaylistAswellTitle;
    _deleteAudioFromPlaylistAswellAudioVideoTitle =
        deleteAudioFromPlaylistAswellAudioVideoTitle;

    if (deleteAudioFromPlaylistAswellTitle.isNotEmpty) {
      _warningMessageType =
          WarningMessageType.deleteAudioFromPlaylistAswellWarning;

      notifyListeners();
    }
  }

  String _movedAudioValidVideoTitle = '';
  String get movedAudioValidVideoTitle => _movedAudioValidVideoTitle;
  String _movedFromPlaylistTitle = '';
  String get movedFromPlaylistTitle => _movedFromPlaylistTitle;
  String _movedToPlaylistTitle = '';
  String get movedToPlaylistTitle => _movedToPlaylistTitle;
  void setAudioNotMovedFromToPlaylistTitles(
      {required String movedAudioValidVideoTitle,
      required String movedFromPlaylistTitle,
      required String movedToPlaylistTitle}) {
    _movedAudioValidVideoTitle = movedAudioValidVideoTitle;
    _movedFromPlaylistTitle = movedFromPlaylistTitle;
    _movedToPlaylistTitle = movedToPlaylistTitle;

    _warningMessageType = WarningMessageType.audioNotMovedFromToPlaylist;

    notifyListeners();
  }

  PlaylistType _movedFromPlaylistType = PlaylistType.youtube;
  PlaylistType get movedFromPlaylistType => _movedFromPlaylistType;
  void setAudioMovedFromToPlaylistTitles(
      {required String movedAudioValidVideoTitle,
      required String movedFromPlaylistTitle,
      required PlaylistType movedFromPlaylistType,
      required String movedToPlaylistTitle}) {
    _movedAudioValidVideoTitle = movedAudioValidVideoTitle;
    _movedFromPlaylistTitle = movedFromPlaylistTitle;
    _movedFromPlaylistType = movedFromPlaylistType;
    _movedToPlaylistTitle = movedToPlaylistTitle;

    _warningMessageType = WarningMessageType.audioMovedFromToPlaylist;

    notifyListeners();
  }

  String _copiedAudioValidVideoTitle = '';
  String get copiedAudioValidVideoTitle => _copiedAudioValidVideoTitle;
  String _copiedFromPlaylistTitle = '';
  String get copiedFromPlaylistTitle => _copiedFromPlaylistTitle;
  String _copiedToPlaylistTitle = '';
  String get copiedToPlaylistTitle => _copiedToPlaylistTitle;
  void setAudioNotCopiedFromToPlaylistTitles(
      {required String copiedAudioValidVideoTitle,
      required String copiedFromPlaylistTitle,
      required String copiedToPlaylistTitle}) {
    _copiedAudioValidVideoTitle = copiedAudioValidVideoTitle;
    _copiedFromPlaylistTitle = copiedFromPlaylistTitle;
    _copiedToPlaylistTitle = copiedToPlaylistTitle;

    _warningMessageType = WarningMessageType.audioNotCopiedFromToPlaylist;

    notifyListeners();
  }

  void setAudioCopiedFromToPlaylistTitles(
      {required String copiedAudioValidVideoTitle,
      required String copiedFromPlaylistTitle,
      required String copiedToPlaylistTitle}) {
    _copiedAudioValidVideoTitle = copiedAudioValidVideoTitle;
    _copiedFromPlaylistTitle = copiedFromPlaylistTitle;
    _copiedToPlaylistTitle = copiedToPlaylistTitle;

    _warningMessageType = WarningMessageType.audioCopiedFromToPlaylist;

    notifyListeners();
  }

  String _updatedPlayableAudioLstPlaylistTitle = '';
  String get updatedPlayableAudioLstPlaylistTitle =>
      _updatedPlayableAudioLstPlaylistTitle;
  int _removedPlayableAudioNumber = 0;
  int get removedPlayableAudioNumber => _removedPlayableAudioNumber;
  setUpdatedPlayableAudioLstPlaylistTitle({
    required String updatedPlayableAudioLstPlaylistTitle,
    required int removedPlayableAudioNumber,
  }) {
    _updatedPlayableAudioLstPlaylistTitle =
        updatedPlayableAudioLstPlaylistTitle;
    _removedPlayableAudioNumber = removedPlayableAudioNumber;

    if (removedPlayableAudioNumber > 0) {
      _warningMessageType = WarningMessageType.updatedPlayableAudioLst;

      notifyListeners();
    }
  }
}
