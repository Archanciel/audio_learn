import 'package:flutter/material.dart';

class WarningMessageVM extends ChangeNotifier {
  String _errorMessage = '';
  String get errorMessage => _errorMessage;
  set errorMessage(String errorMessage) {
    _errorMessage = errorMessage;

    if (errorMessage.isNotEmpty) {
      notifyListeners();
    }
  }

  String _updatedPlaylistTitle = '';
  String get updatedPlaylistTitle => _updatedPlaylistTitle;
  set updatedPlaylistTitle(String updatedPlaylistTitle) {
    _updatedPlaylistTitle = updatedPlaylistTitle;

    if (updatedPlaylistTitle.isNotEmpty) {
      notifyListeners();
    }
  }

  String _adddedPlaylistTitle = '';
  String get addedPlaylistTitle => _adddedPlaylistTitle;
  set addedPlaylistTitle(String addedPlaylistTitle) {
    _adddedPlaylistTitle = addedPlaylistTitle;

    if (addedPlaylistTitle.isNotEmpty) {
      notifyListeners();
    }
  }

  bool _isPlaylistUrlInvalid = false;
  bool get isPlaylistUrlInvalid => _isPlaylistUrlInvalid;
  set isPlaylistUrlInvalid(bool isPlaylistUrlInvalid) {
    _isPlaylistUrlInvalid = isPlaylistUrlInvalid;

    if (isPlaylistUrlInvalid) {
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
      notifyListeners();
    }
  }

  bool _playlistWithThisUrlAlreadyDownloaded = false;
  bool get playlistWithThisUrlAlreadyDownloaded =>
      _playlistWithThisUrlAlreadyDownloaded;}
