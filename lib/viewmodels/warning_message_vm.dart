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

  youtubePlaylistWithTitleAlreadyInListOfPlaylists, // User clicked on
  // Add button but a Youtube playlist with a title equal to the title
  // of the new local playlist already exits.

  deleteAudioFromPlaylistAswellWarning, // User selected the audio
  // menu item "Delete audio from playlist aswell".

  invalidSingleVideoUrl, // The case if the url is a playlist url
  // and the Download button was clicked instead of the Add button,
  // or if the String pasted to the url text field is not a valid
  // Youtube video url.

  updatedPlayableAudioLst, // The case if the playable audio list
  // was updated. This happens when the user clicks on the update
  // playable audio list playlist menu item.

  noSortFilterSaveAsName, // The case if the user clicks on the
  // save as button after selecting the sort and filter options
  // but the name of the new sort and filter is empty.

  noSortFilterParameterWasModified, // The case if the user clicks
  // on the apply button without having set a sort/filter
  // parameter.

  deletedHistoricalSortFilterParameterNotExist, // The case if the user clicks
  // on the delete button after having set a sort/filter parameter
  // which does not exist in the sort/filter parameter history.

  historicalSortFilterParameterWasDeleted, // The case if the user clicks
  // on the delete button after having selected an historical sort/filter
  // parameter which does  exist in the sort/filter parameter history.

  allHistoricalSortFilterParameterWereDeleted, // The case if the user clicks
  // on the delete all historical sort/filter button located in the sort/filter
  // dialog at right of the Filter options title

  noPlaylistSelectedForSingleVideoDownload, // The case if the user
  // clicks on the single video download button but no playlist
  // to which the downloaded audio will be added is selected.

  isNoPlaylistSelectedForAudioCopy, // The case if the user
  // clicks on the single video download button but no playlist
  // to which the downloaded audio will be copied is selected.

  isNoPlaylistSelectedForAudioMove, // The case if the user
  // clicks on the single video download button but no playlist
  // to which the downloaded audio will be moved is selected.

  tooManyPlaylistSelectedForSingleVideoDownload, // The case if the
  // user clicks on the single video download button but more than
  // one playlist to which the downloaded audio will be added is
  // selected.

  ok, // The case if the user clicks on the Ok button after a
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

  downloadAudioYoutubeErrorDueToLiveVideoInPlaylist, // In case of a
  // Youtube error caused by the fact that the playlist contains a
  // live video.

  downloadAudioFileAlreadyOnAudioDirectory, // In case the audio file
  // is already on the audio directory and will not be redownloaded.

  noInternet, // device not connected. Happens when trying to
  // download a playlist or a single video or to add a new playlist
  // or update an existing playlist.

  errorInPlaylistJsonFile, // Error in the playlist json file.
}

/// This VM (View Model) class is part of the MVVM architecture.
///
class WarningMessageVM extends ChangeNotifier {
  WarningMessageType _warningMessageType = WarningMessageType.none;
  WarningMessageType get warningMessageType => _warningMessageType;

  /// Called after a warning message is displayed when the user
  /// clicks on the Ok button.
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

  String _invalidPlaylistUrl = '';
  String get invalidPlaylistUrl => _invalidPlaylistUrl;
  set invalidPlaylistUrl(String invalidPlaylistUrl) {
    _invalidPlaylistUrl = invalidPlaylistUrl;
    _warningMessageType = WarningMessageType.invalidPlaylistUrl;

    notifyListeners();
  }

  bool _isSingleVideoUrlInvalid = false;
  bool get isSingleVideoUrlInvalid => _isSingleVideoUrlInvalid;
  set isSingleVideoUrlInvalid(bool isSingleVideoUrlInvalid) {
    _isSingleVideoUrlInvalid = isSingleVideoUrlInvalid;

    if (isSingleVideoUrlInvalid) {
      _warningMessageType = WarningMessageType.invalidSingleVideoUrl;

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
    required PlaylistType playlistType,
  }) {
    _localPlaylistAlreadyCreatedTitle = playlistTitle;

    if (playlistType == PlaylistType.local) {
      _warningMessageType =
          WarningMessageType.localPlaylistWithTitleAlreadyInListOfPlaylists;
    } else {
      _warningMessageType =
          WarningMessageType.youtubePlaylistWithTitleAlreadyInListOfPlaylists;
    }

    notifyListeners();
  }

  String _sortFilterSaveAsName = '';
  String get sortFilterSaveAsName => _sortFilterSaveAsName;
  set sortFilterSaveAsName(String sortFilterSaveAsName) {
    _sortFilterSaveAsName = sortFilterSaveAsName;

    if (sortFilterSaveAsName.isEmpty) {
      _warningMessageType = WarningMessageType.noSortFilterSaveAsName;

      notifyListeners();
    }
  }

  void noSortFilterParameterWasModified() {
    _warningMessageType = WarningMessageType.noSortFilterParameterWasModified;

    notifyListeners();
  }

  void deletedHistoricalSortFilterParameterNotExist() {
    _warningMessageType =
        WarningMessageType.deletedHistoricalSortFilterParameterNotExist;

    notifyListeners();
  }

  void historicalSortFilterParameterWasDeleted() {
    _warningMessageType =
        WarningMessageType.historicalSortFilterParameterWasDeleted;

    notifyListeners();
  }

  void allHistoricalSortFilterParametersWereDeleted() {
    _warningMessageType =
        WarningMessageType.allHistoricalSortFilterParameterWereDeleted;

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

  bool _isNoPlaylistSelectedForAudioCopy = false;
  bool get isNoPlaylistSelectedForAudioCopy =>
      _isNoPlaylistSelectedForAudioCopy;
  set isNoPlaylistSelectedForAudioCopy(bool isNoPlaylistSelectedForAudioCopy) {
    _isNoPlaylistSelectedForAudioCopy = isNoPlaylistSelectedForAudioCopy;

    if (isNoPlaylistSelectedForAudioCopy) {
      _warningMessageType = WarningMessageType.isNoPlaylistSelectedForAudioCopy;

      notifyListeners();
    }
  }

  bool _isNoPlaylistSelectedForAudioMove = false;
  bool get isNoPlaylistSelectedForAudioMove =>
      _isNoPlaylistSelectedForAudioMove;
  set isNoPlaylistSelectedForAudioMove(bool isNoPlaylistSelectedForAudioMove) {
    _isNoPlaylistSelectedForAudioMove = isNoPlaylistSelectedForAudioMove;

    if (isNoPlaylistSelectedForAudioMove) {
      _warningMessageType = WarningMessageType.isNoPlaylistSelectedForAudioMove;

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
  bool _keepAudioDataInSourcePlaylist = true;
  bool get keepAudioDataInSourcePlaylist => _keepAudioDataInSourcePlaylist;
  String _movedToPlaylistTitle = '';
  String get movedToPlaylistTitle => _movedToPlaylistTitle;
  void setAudioNotMovedFromToPlaylistTitles({
    required String movedAudioValidVideoTitle,
    required String movedFromPlaylistTitle,
    required PlaylistType movedFromPlaylistType,
    required String movedToPlaylistTitle,
    required PlaylistType movedToPlaylistType,
  }) {
    _movedAudioValidVideoTitle = movedAudioValidVideoTitle;
    _movedFromPlaylistTitle = movedFromPlaylistTitle;
    _movedFromPlaylistType = movedFromPlaylistType;
    _movedToPlaylistType = movedToPlaylistType;
    _movedToPlaylistTitle = movedToPlaylistTitle;

    _warningMessageType = WarningMessageType.audioNotMovedFromToPlaylist;

    notifyListeners();
  }

  late PlaylistType _movedFromPlaylistType;
  PlaylistType get movedFromPlaylistType => _movedFromPlaylistType;
  late PlaylistType _movedToPlaylistType;
  PlaylistType get movedToPlaylistType => _movedToPlaylistType;
  void setAudioMovedFromToPlaylistTitles({
    required String movedAudioValidVideoTitle,
    required String movedFromPlaylistTitle,
    required PlaylistType movedFromPlaylistType,
    required String movedToPlaylistTitle,
    required PlaylistType movedToPlaylistType,
    required bool keepAudioDataInSourcePlaylist,
  }) {
    _movedAudioValidVideoTitle = movedAudioValidVideoTitle;
    _movedFromPlaylistTitle = movedFromPlaylistTitle;
    _keepAudioDataInSourcePlaylist = keepAudioDataInSourcePlaylist;
    _movedFromPlaylistType = movedFromPlaylistType;
    _movedToPlaylistType = movedToPlaylistType;
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
  late PlaylistType _copiedFromPlaylistType;
  PlaylistType get copiedFromPlaylistType => _copiedFromPlaylistType;
  late PlaylistType _copiedToPlaylistType;
  PlaylistType get copiedToPlaylistType => _copiedToPlaylistType;
  void setAudioNotCopiedFromToPlaylistTitles({
    required String copiedAudioValidVideoTitle,
    required String copiedFromPlaylistTitle,
    required PlaylistType copiedFromPlaylistType,
    required String copiedToPlaylistTitle,
    required PlaylistType copiedToPlaylistType,
  }) {
    _copiedAudioValidVideoTitle = copiedAudioValidVideoTitle;
    _copiedFromPlaylistTitle = copiedFromPlaylistTitle;
    _copiedFromPlaylistType = copiedFromPlaylistType;
    _copiedToPlaylistTitle = copiedToPlaylistTitle;
    _copiedToPlaylistType = copiedToPlaylistType;

    _warningMessageType = WarningMessageType.audioNotCopiedFromToPlaylist;

    notifyListeners();
  }

  void setAudioCopiedFromToPlaylistTitles({
    required String copiedAudioValidVideoTitle,
    required String copiedFromPlaylistTitle,
    required PlaylistType copiedFromPlaylistType,
    required String copiedToPlaylistTitle,
    required PlaylistType copiedToPlaylistType,
  }) {
    _copiedAudioValidVideoTitle = copiedAudioValidVideoTitle;
    _copiedFromPlaylistTitle = copiedFromPlaylistTitle;
    _copiedToPlaylistTitle = copiedToPlaylistTitle;
    _copiedFromPlaylistType = copiedFromPlaylistType;
    _copiedToPlaylistType = copiedToPlaylistType;

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
