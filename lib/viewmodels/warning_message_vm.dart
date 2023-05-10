import 'package:flutter/material.dart';

enum WarningMessageType {
  none,
  errorMessage,
  infoMessage,
  successMessage,
  updatePlayListTitle,
  addPlayListTitle,
  invalidPlaylistUrl,
  playlistWithUrlAlreadyInListOfPlaylists,
  playlistWithThisUrlAlreadyDownloadedAndUpdated,
  playlistWithThisUrlAlreadyDownloadedAndAdded,
  deleteAudioFromPlaylistAswellWarning,
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
  set errorMessage(String errorMessage) {
    _errorMessage = errorMessage;

    if (errorMessage.isNotEmpty) {
      _warningMessageType = WarningMessageType.errorMessage;

      notifyListeners();
    }
  }

  String _updatedPlaylistTitle = '';
  String get updatedPlaylistTitle => _updatedPlaylistTitle;
  set updatedPlaylistTitle(String updatedPlaylistTitle) {
    _updatedPlaylistTitle = updatedPlaylistTitle;

    if (updatedPlaylistTitle.isNotEmpty) {
      _warningMessageType = WarningMessageType.updatePlayListTitle;

      notifyListeners();
    }
  }

  String _addedPlaylistTitle = '';
  String get addedPlaylistTitle => _addedPlaylistTitle;
  set addedPlaylistTitle(String addedPlaylistTitle) {
    _addedPlaylistTitle = addedPlaylistTitle;

    if (addedPlaylistTitle.isNotEmpty) {
      _warningMessageType = WarningMessageType.addPlayListTitle;

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

  bool _isPlaylistWithThisUrlAlreadyDownloaded = false;
  bool get isPlaylistWithThisUrlAlreadyDownloaded =>
      _isPlaylistWithThisUrlAlreadyDownloaded;
  set isPlaylistWithThisUrlAlreadyDownloaded(
      bool isPlaylistWithThisUrlAlreadyDownloaded) {
    _isPlaylistWithThisUrlAlreadyDownloaded =
        isPlaylistWithThisUrlAlreadyDownloaded;

    if (isPlaylistWithThisUrlAlreadyDownloaded) {
      _warningMessageType =
          WarningMessageType.playlistWithUrlAlreadyInListOfPlaylists;

      notifyListeners();
    }
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
  setDeleteAudioFromPlaylistAswellTitle(
      {required String deleteAudioFromPlaylistAswellTitle,
      required String deleteAudioFromPlaylistAswellAudioVideoTitle}) {
    _deleteAudioFromPlaylistAswellTitle = deleteAudioFromPlaylistAswellTitle;
    _deleteAudioFromPlaylistAswellAudioVideoTitle =
        deleteAudioFromPlaylistAswellAudioVideoTitle;

    if (deleteAudioFromPlaylistAswellTitle.isNotEmpty) {
      _warningMessageType =
          WarningMessageType.deleteAudioFromPlaylistAswellWarning;

      notifyListeners();
    }
  }
}
