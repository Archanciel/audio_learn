import 'package:flutter/material.dart';

enum WarningMessageType {
  none,
  errorMessage, // An error message depending on error type is
  // displayed

  infoMessage, // Not used yet

  successMessage, // Not used yet

  updatedPlaylistUrlTitle, // This means that the playlist was not added, but
  // that its url was updated. The case when a new
  // playlist with the same title is created in order
  // to replace the old one which contains too many
  // audios.

  addPlaylistTitle, // The playlist with this title is added
  // to the application

  invalidPlaylistUrl, // The case if the url is a video url and the
  // user clicked on the Add button instead of the Download
  // button or if the String pasted to the url text field
  // is not a valid Youtube playlist url.

  playlistWithUrlAlreadyInListOfPlaylists, // User clicked on Add
  // button but the playlist with this url was already downloaded

  playlistWithThisUrlAlreadyDownloadedAndUpdated, // Not used yet

  playlistWithThisUrlAlreadyDownloadedAndAdded, // Not used yet

  deleteAudioFromPlaylistAswellWarning, // User selected the audio
  // menu item "Delete audio from playlist aswell"

  invalidSingleVideoUUrl, // The case if the url is a playlist url
  // and the Download button was clicked instead of the Add button,
  // or if the String pasted to the url text field is not a valid
  // Youtube video url.

  updatedPlayableAudioLst, // The case if the playable audio list
  // was updated. This happens when the user clicks on the update
  // playable audio list playlist menu item.
}

enum ErrorType {
  none,
  downloadAudioYoutubeError, // In case of a Youtube error
  downloadAudioFileAlreadyOnAudioDirectory, // In case the audio file
  // is already on the audio directory and will not be redownloaded
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

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  ErrorType _errorType = ErrorType.none;
  ErrorType get errorType => _errorType;
  void setError({
    required ErrorType errorType,
    String? errorMessage,
  }) {
    _errorType = errorType;

    if (errorType != ErrorType.none) {
      _warningMessageType = WarningMessageType.errorMessage;

      if (errorMessage != null) {
        _errorMessage = errorMessage;
      }

      notifyListeners();
    } else {
      _errorMessage = '';
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
  set addedPlaylistTitle(String addedPlaylistTitle) {
    _addedPlaylistTitle = addedPlaylistTitle;

    if (addedPlaylistTitle.isNotEmpty) {
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

  bool _isPlaylistWithThisUrlAlreadyDownloadedAndUpdated = false;
  bool get isPlaylistWithThisUrlAlreadyDownloadedAndUpdated =>
      _isPlaylistWithThisUrlAlreadyDownloadedAndUpdated;
  set isPlaylistWithThisUrlAlreadyDownloadedAndUpdated(
      bool isPlaylistWithThisUrlAlreadyDownloadedAndUpdated) {
    _isPlaylistWithThisUrlAlreadyDownloadedAndUpdated =
        isPlaylistWithThisUrlAlreadyDownloadedAndUpdated;

    if (isPlaylistWithThisUrlAlreadyDownloadedAndUpdated) {
      _warningMessageType =
          WarningMessageType.playlistWithThisUrlAlreadyDownloadedAndUpdated;

      notifyListeners();
    }
  }

  bool _isPlaylistWithThisUrlAlreadyDownloadedAndAdded = false;
  bool get isPlaylistWithThisUrlAlreadyDownloadedAndAdded =>
      _isPlaylistWithThisUrlAlreadyDownloadedAndAdded;
  set isPlaylistWithThisUrlAlreadyDownloadedAndAdded(
      bool isPlaylistWithThisUrlAlreadyDownloadedAndAdded) {
    _isPlaylistWithThisUrlAlreadyDownloadedAndAdded =
        isPlaylistWithThisUrlAlreadyDownloadedAndAdded;

    if (isPlaylistWithThisUrlAlreadyDownloadedAndAdded) {
      _warningMessageType =
          WarningMessageType.playlistWithThisUrlAlreadyDownloadedAndAdded;

      notifyListeners();
    }
  }

  bool _playlistWithThisUrlAlreadyDownloaded = false;
  bool get playlistWithThisUrlAlreadyDownloaded =>
      _playlistWithThisUrlAlreadyDownloaded;

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
