import 'package:flutter/material.dart';

import '../constants.dart';
import '../models/audio.dart';
import '../models/playlist.dart';
import '../services/audio_sort_filter_service.dart';
import '../services/json_data_service.dart';
import '../services/settings_data_service.dart';
import '../services/sort_filter_parameters.dart';
import 'audio_download_vm.dart';
import 'warning_message_vm.dart';

/// This VM (View Model) class is part of the MVVM architecture.
///
/// It is used in the PlaylistDownloadView screen in order to
/// provide the list of selectable playlists. Once a playlist
/// is selected, it can be moved up or down by clicking on the
/// corresponding button. The PlaylistListVM stores the list
/// of selectable playlists in the order they are displayed.
///
/// The PlaylistListVM also stores the selected playlist.
/// It manages as well the filtered and sorted selected
/// playlist audios. Using the general playlist menu located
/// at right of the PlaylistDownloadView screen, the user can
/// sort and filter the selected playlist audios. When the
/// selected playlist audio is asked to the PlaylistListVM,
/// either the full playable audio list of the selected playlist
/// or the filtered and sorted audio list is returned.
///
/// The class is also used in the AudioPlayerVM to obtain the
/// next or previous playable audio.
///
/// It is also used by several widgets in order to display or
/// manage the playlists.
class PlaylistListVM extends ChangeNotifier {
  bool _isListExpanded = false;
  bool _isButtonDownloadSelPlaylistsEnabled = false;
  bool _isButtonMoveUpPlaylistEnabled = false;
  bool _isButtonMoveDownPlaylistEnabled = false;
  bool _isButtonAudioPopupMenuEnabled = false;

  bool get isListExpanded => _isListExpanded;
  bool get isButtonDownloadSelPlaylistsEnabled =>
      _isButtonDownloadSelPlaylistsEnabled;
  bool get isButtonMoveUpPlaylistEnabled => _isButtonMoveUpPlaylistEnabled;
  bool get isButtonMoveDownPlaylistEnabled => _isButtonMoveDownPlaylistEnabled;
  bool get isButtonAudioPopupMenuEnabled => _isButtonAudioPopupMenuEnabled;

  final AudioDownloadVM _audioDownloadVM;
  final WarningMessageVM _warningMessageVM;
  final SettingsDataService _settingsDataService;

  bool _isOnePlaylistSelected = true;
  List<Playlist> _listOfSelectablePlaylists = [];
  List<Audio>? _sortedFilteredSelectedPlaylistsPlayableAudios;
  List<Audio>? get sortedFilteredSelectedPlaylistsPlayableAudios =>
      _sortedFilteredSelectedPlaylistsPlayableAudios;
  AudioSortFilterParameters? _audioSortFilterParameters;

  Playlist? _uniqueSelectedPlaylist;
  Playlist? get uniqueSelectedPlaylist => _uniqueSelectedPlaylist;

  final AudioSortFilterService _audioSortFilterService =
      AudioSortFilterService();

  PlaylistListVM({
    required WarningMessageVM warningMessageVM,
    required AudioDownloadVM audioDownloadVM,
    required SettingsDataService settingsDataService,
  })  : _warningMessageVM = warningMessageVM,
        _audioDownloadVM = audioDownloadVM,
        _settingsDataService = settingsDataService;

  List<Playlist> getUpToDateSelectablePlaylistsExceptExcludedPlaylist({
    required Playlist excludedPlaylist,
  }) {
    List<Playlist> upToDateSelectablePlaylists =
        getUpToDateSelectablePlaylists();

    List<Playlist> listOfSelectablePlaylistsCopy =
        List.from(upToDateSelectablePlaylists);

    listOfSelectablePlaylistsCopy.remove(excludedPlaylist);

    return listOfSelectablePlaylistsCopy;
  }

  /// Method called when the user choose the update playlist
  /// json file menu item.
  void updateSettingsAndPlaylistJsonFiles() {
    _audioDownloadVM.loadExistingPlaylists();

    _audioDownloadVM.updatePlaylistJsonFiles();

    List<Playlist> listOfPlaylist = _audioDownloadVM.listOfPlaylist;

    for (Playlist playlist in listOfPlaylist) {
      if (!_listOfSelectablePlaylists
          .any((element) => element.title == playlist.title)) {
        // the case if the playlist dir was added to the app
        // audio dir
        _listOfSelectablePlaylists.add(playlist);
      }
    }

    List<Playlist> copyOfList = List<Playlist>.from(_listOfSelectablePlaylists);

    for (Playlist playlist in copyOfList) {
      if (!listOfPlaylist.any((element) => element.title == playlist.title)) {
        // the case if the playlist dir was removed from the app
        // audio dir
        _listOfSelectablePlaylists.remove(playlist);
      }
    }

    _updateAndSavePlaylistOrder();

    notifyListeners();
  }

  /// Thanks to this method, when restarting the app, the playlists
  /// are displayed in the same order as when the app was closed. This
  /// is done by saving the playlist order in the settings file.
  List<Playlist> getUpToDateSelectablePlaylists() {
    List<Playlist> audioDownloadVMlistOfPlaylist =
        _audioDownloadVM.listOfPlaylist;
    List<dynamic>? orderedPlaylistTitleLst = _settingsDataService.get(
      settingType: SettingType.playlists,
      settingSubType: Playlists.orderedTitleLst,
    );

    if (orderedPlaylistTitleLst == null) {
      // If orderedPlaylistTitleLst is null, it means that the
      // user has not yet modified the order of the playlists.
      // So, we use the default order.
      _listOfSelectablePlaylists = audioDownloadVMlistOfPlaylist;
    } else {
      bool doUpdateSettings = false;
      _listOfSelectablePlaylists = [];

      for (String playlistTitle in orderedPlaylistTitleLst) {
        try {
          _listOfSelectablePlaylists.add(audioDownloadVMlistOfPlaylist
              .firstWhere((playlist) => playlist.title == playlistTitle));
        } catch (_) {
          // If the playlist with this title is not found, it means that
          // the playlist json file has been deleted. So, we don't add it
          // to the selectable playlist list and we will remove it from
          // the ordered playlist title list and update the settings data.
          doUpdateSettings = true;
        }
      }

      if (doUpdateSettings) {
        // Once some playlists have been deleted from the audio app root
        // dir, the next time the app is started, the ordered playlist
        // title list in the settings json file will be updated.
        _updateAndSavePlaylistOrder();
      }
    }

    int selectedPlaylistIndex = _getSelectedIndex();

    if (selectedPlaylistIndex != -1) {
      _isOnePlaylistSelected = true;

      // required so that the TextField keyed by
      // 'selectedPlaylistTextField' below the playlist URL TextField
      // is initialized at app startup
      _uniqueSelectedPlaylist =
          _listOfSelectablePlaylists[selectedPlaylistIndex];

      _setPlaylistButtonsStateIfOnePlaylistIsSelected(
        selectedPlaylist: _listOfSelectablePlaylists[selectedPlaylistIndex],
      );
    } else {
      _isOnePlaylistSelected = false;

      // required so that the TextField keyed by
      // 'selectedPlaylistTextField' below the playlist URL TextField
      // is initialized (emptied) at app startup
      _uniqueSelectedPlaylist = null;

      _disableAllButtonsIfNoPlaylistIsSelected();
    }

    return _listOfSelectablePlaylists;
  }

  /// Returns true if the playlist was added, false otherwise.
  Future<bool> addPlaylist({
    String playlistUrl = '',
    String localPlaylistTitle = '',
    required PlaylistQuality playlistQuality,
  }) async {
    if (localPlaylistTitle.isEmpty && playlistUrl.isNotEmpty) {
      try {
        final Playlist playlistWithThisUrlAlreadyDownloaded =
            _listOfSelectablePlaylists
                .firstWhere((element) => element.url == playlistUrl);
        // User clicked on Add button but the playlist with this url
        // was already downloaded since it is in the selectable playlist
        // list. Since orElse is not defined, firstWhere throws an error
        // if the playlist with this url is not found.
        _warningMessageVM.setPlaylistAlreadyDownloadedTitle(
            playlistTitle: playlistWithThisUrlAlreadyDownloaded.title);
        return false;
      } catch (_) {
        // If the playlist with this url is not found, it means that
        // the playlist must be added.
      }
    } else if (localPlaylistTitle.isNotEmpty) {
      try {
        final Playlist playlistWithThisTitleAlreadyDownloaded =
            _listOfSelectablePlaylists
                .firstWhere((element) => element.title == localPlaylistTitle);
        // User clicked on Add button but the playlist with this title
        // was already defined since it is in the selectable playlist
        // list. Since orElse is not defined, firstWhere throws an error
        // if the playlist with this title is not found.
        _warningMessageVM.setLocalPlaylistAlreadyCreatedTitle(
            playlistTitle: playlistWithThisTitleAlreadyDownloaded.title);
        return false;
      } catch (_) {
        // If the playlist with this title is not found, it means that
        // the playlist must be added.
      }
    } else {
      // If both playlistUrl and localPlaylistTitle are empty, it means
      // that the user clicked on the Add button without entering any
      // playlist url or local playlist title. So, we don't add the
      // playlist.
      return false;
    }

    Playlist? addedPlaylist = await _audioDownloadVM.addPlaylist(
      playlistUrl: playlistUrl,
      localPlaylistTitle: localPlaylistTitle,
      playlistQuality: playlistQuality,
    );

    if (addedPlaylist != null) {
      // if addedPlaylist is null, it means that the
      // passed url is not a valid playlist url
      _listOfSelectablePlaylists.add(addedPlaylist);
      _updateAndSavePlaylistOrder();

      notifyListeners();
    }

    return true;
  }

  void toggleList() {
    _isListExpanded = !_isListExpanded;

    if (!_isListExpanded) {
      _disableExpandedListButtons();
    } else {
      int selectedPlaylistIndex = _getSelectedIndex();
      if (selectedPlaylistIndex != -1) {
        _setPlaylistButtonsStateIfOnePlaylistIsSelected(
          selectedPlaylist: _listOfSelectablePlaylists[selectedPlaylistIndex],
        );
      } else {
        _disableAllButtonsIfNoPlaylistIsSelected();
      }
    }

    notifyListeners();
  }

  /// To be called before asking to download audios of selected
  /// playlists so that the currently displayed audio list is not
  /// sorted or/and filtered. This way, the newly downloaded
  /// audio will be added at top of the displayed audio list.
  void disableSortedFilteredPlayableAudioLst() {
    _sortedFilteredSelectedPlaylistsPlayableAudios = null;

    notifyListeners();
  }

  /// Method used by PlaylistOneSelectedDialogWidget to select
  /// only one playlist to which the audios will be moved or
  /// copied.
  void setUniqueSelectedPlaylist({
    Playlist? selectedPlaylist,
  }) {
    _uniqueSelectedPlaylist = selectedPlaylist;

    notifyListeners();
  }

  /// Method called by PlaylistItemWidget when the user clicks on
  /// the playlist item checkbox to select or unselect the playlist.
  ///
  /// Since currently only one playlist can be selected at a time,
  /// this method unselects all the other playlists if
  /// {isUniquePlaylistSelected} is true.
  void setPlaylistSelection({
    required int playlistIndex,
    required bool isUniquePlaylistSelected,
  }) {
    // selecting another playlist or unselecting the currently
    // selected playlist nullifies the filtered and sorted audio list
    _sortedFilteredSelectedPlaylistsPlayableAudios = null;
    _audioSortFilterParameters = null; // required to reset the sort and
    //                                    filter parameters, otherwise
    //                                    the previous sort and filter
    //                                    parameters will be applioed to
    //                                    the newly selected playlist

    Playlist playlistSelectedOrUnselected =
        _listOfSelectablePlaylists[playlistIndex];
    String playlistSelectedOrUnselectedId = playlistSelectedOrUnselected.id;

    if (isUniquePlaylistSelected) {
      // since only one playlist can be selected at a time, we
      // unselect all the other playlists
      for (Playlist playlist in _listOfSelectablePlaylists) {
        if (playlist.id == playlistSelectedOrUnselectedId) {
          _audioDownloadVM.updatePlaylistSelection(
            playlistId: playlistSelectedOrUnselectedId,
            isPlaylistSelected: true,
          );
        } else {
          _audioDownloadVM.updatePlaylistSelection(
            playlistId: playlist.id,
            isPlaylistSelected: false,
          );
        }
      }
    }

    // BUG FIX: when the user unselects the playlist, the
    // playlist json file will not be updated in the AudioDownloadVM
    // updatePlaylistSelection method if the following line is not
    // commented out
    // _listOfSelectablePlaylists[playlistIndex].isSelected = isPlaylistSelected;
    _isOnePlaylistSelected = isUniquePlaylistSelected;

    if (!_isOnePlaylistSelected) {
      _disableAllButtonsIfNoPlaylistIsSelected();

      // if no playlist is selected, the quality checkbox is
      // disabled and so must be unchecked
      _audioDownloadVM.isHighQuality = false;

      // BUG FIX: when the user unselects the playlist, the
      // playlist json file must be updated !
      _audioDownloadVM.updatePlaylistSelection(
        playlistId: playlistSelectedOrUnselected.id,
        isPlaylistSelected: false,
      );

      // required so that the TextField keyed by
      // 'selectedPlaylistTextField' below
      // the playlist URL TextField is updated (emptied)
      _uniqueSelectedPlaylist = null;
    } else {
      _setPlaylistButtonsStateIfOnePlaylistIsSelected(
        selectedPlaylist: playlistSelectedOrUnselected,
      );

      // required so that the TextField keyed by
      // 'selectedPlaylistTextField' below
      // the playlist URL TextField is updated
      _uniqueSelectedPlaylist = playlistSelectedOrUnselected;

      // TODO fix handling the right app view !!!
      // if (_uniqueSelectedPlaylist!.applySortFilterParmsForAudioPlayerView) {
      //   _audioSortFilterParameters =
      //       _uniqueSelectedPlaylist!.audioSortFilterParmsForAudioPlayerView;
      // }
    }

    notifyListeners();
  }

  /// Method called when the user confirms deleting the playlist.
  void deletePlaylist({
    required Playlist playlistToDelete,
  }) {
    // if the playlist to delete is local, then its id is its title ...
    int playlistToDeleteIndex = _listOfSelectablePlaylists
        .indexWhere((playlist) => playlist.id == playlistToDelete.id);

    if (playlistToDeleteIndex != -1) {
      if (playlistToDelete.isSelected) {
        _isOnePlaylistSelected = false;

        // required so that the TextField keyed by
        // 'selectedPlaylistTextField' below
        // the playlist URL TextField is updated (emptied)
        _uniqueSelectedPlaylist = null;
      }

      _audioDownloadVM.deletePlaylist(
        playlistToDelete: playlistToDelete,
      );
      _listOfSelectablePlaylists.removeAt(playlistToDeleteIndex);
      _updateAndSavePlaylistOrder();

      if (!_isOnePlaylistSelected) {
        _disableAllButtonsIfNoPlaylistIsSelected();
      }

      notifyListeners();
    }
  }

  void moveSelectedItemUp() {
    int selectedIndex = _getSelectedIndex();
    if (selectedIndex != -1) {
      moveItemUp(selectedIndex);
      _updateAndSavePlaylistOrder();
      notifyListeners();
    }
  }

  int getPlaylistJsonFileSize({
    required Playlist playlist,
  }) {
    return _audioDownloadVM.getPlaylistJsonFileSize(
      playlist: playlist,
    );
  }

  /// Thanks to this method, when restarting the app, the playlists
  /// are displayed in the same order as when the app was closed. This
  /// is done by saving the playlist order in the settings file.
  void _updateAndSavePlaylistOrder() {
    List<String> playlistOrder =
        _listOfSelectablePlaylists.map((playlist) => playlist.title).toList();

    _settingsDataService.savePlaylistOrder(playlistOrder: playlistOrder);
  }

  void moveSelectedItemDown() {
    int selectedIndex = _getSelectedIndex();
    if (selectedIndex != -1) {
      moveItemDown(selectedIndex);
      _updateAndSavePlaylistOrder();
      notifyListeners();
    }
  }

  Future<void> downloadSelectedPlaylist(BuildContext context) async {
    List<Playlist> selectedPlaylists = getSelectedPlaylists();

    for (Playlist playlist in selectedPlaylists) {
      await _audioDownloadVM.downloadPlaylistAudios(playlistUrl: playlist.url);
    }
  }

  /// Currently, only one playlist is selectable. So, this method
  /// returns a list of Playlists containing the unique selected
  /// playlist.
  List<Playlist> getSelectedPlaylists() {
    return _listOfSelectablePlaylists
        .where((playlist) => playlist.isSelected)
        .toList();
  }

  /// Returns the selected playlist audio list. If the user
  /// clicked on the Apply button in the
  /// SortAndFilterAudioDialogWidget, then the filtered and
  /// sorted audio list is returned.
  List<Audio> getSelectedPlaylistPlayableAudiosApplyingSortFilterParameters(
    AudioLearnAppViewType audioLearnAppViewType,
  ) {
    List<Playlist> selectedPlaylists = getSelectedPlaylists();

    if (selectedPlaylists.isEmpty) {
      return [];
    }

    Playlist selectedPlaylist =
        selectedPlaylists[0]; // currently, only one playlist can be selected
    List<Audio> selectedPlaylistsAudios = selectedPlaylist.playableAudioLst;

    _audioSortFilterParameters = null;

    switch (audioLearnAppViewType) {
      case AudioLearnAppViewType.playlistDownloadView:
        if (selectedPlaylist
            .applyAutomaticallySortFilterParmsForPlaylistDownloadView) {
          _audioSortFilterParameters =
              selectedPlaylist.audioSortFilterParmsForPlaylistDownloadView;
        }
        break;
      case AudioLearnAppViewType.audioPlayerView:
        if (selectedPlaylist
            .applyAutomaticallySortFilterParmsForAudioPlayerView) {
          _audioSortFilterParameters =
              selectedPlaylist.audioSortFilterParmsForAudioPlayerView;
        }
        break;
      default:
        break;
    }

    _sortedFilteredSelectedPlaylistsPlayableAudios =
        _audioSortFilterService.filterAndSortAudioLst(
      audioLst: selectedPlaylistsAudios,
      audioSortFilterParameters: _audioSortFilterParameters ??
          createDefaultAudioSortFilterParameters(),
    );

    // currently, only one playlist can be selected at a time !
    // so, the following code is not useful
    //
    // for (Playlist playlist in _listOfSelectablePlaylists) {
    //   if (playlist.isSelected) {
    //     selectedPlaylistsAudios.addAll(playlist.playableAudioLst);
    //   }
    // }

    return _sortedFilteredSelectedPlaylistsPlayableAudios!;
  }

  List<Audio>
      getSelectedPlaylistNotFullyPlayedAudiosApplyingSortFilterParameters(
    AudioLearnAppViewType audioLearnAppViewType,
  ) {
    List<Audio> playlistPlayableAudioLst =
        getSelectedPlaylistPlayableAudiosApplyingSortFilterParameters(
      audioLearnAppViewType,
    );

    return playlistPlayableAudioLst
        .where((audio) => !audio.wasFullyListened())
        .toList();
  }

  /// Used to display the audio list of the selected playlist
  /// starting at the beginning.
  bool isAudioListFilteredAndSorted() {
    return _sortedFilteredSelectedPlaylistsPlayableAudios != null;
  }

  /// Called after the user clicked on the Apply button
  /// contained in the SortAndFilterAudioDialogWidget.
  ///
  /// {audioSortFilterParameters} is the sort and filter
  /// parameters selected by the user in the
  /// SortAndFilterAudioDialogWidget.
  void setSortedFilteredSelectedPlaylistPlayableAudiosAndParms(
      List<Audio> sortedFilteredSelectedPlaylistsPlayableAudios,
      AudioSortFilterParameters audioSortFilterParameters) {
    _sortedFilteredSelectedPlaylistsPlayableAudios =
        sortedFilteredSelectedPlaylistsPlayableAudios;
    _audioSortFilterParameters = audioSortFilterParameters;

    notifyListeners();
  }

  /// Method called when the user clicks on the playlist menu
  /// item "Sort and filter playlist audios" in the
  /// PlaylistDownloadView screen or in the AudioPlayerView
  /// screen.
  AudioSortFilterParameters getSelectedPlaylistAudioSortFilterParamForView(
    AudioLearnAppViewType audioLearnAppViewType,
  ) {
    Playlist selectedPlaylist = getSelectedPlaylists()[0];
    AudioSortFilterParameters? playlistAudioSortFilterParameters;

    switch (audioLearnAppViewType) {
      case AudioLearnAppViewType.playlistDownloadView:
        playlistAudioSortFilterParameters =
            selectedPlaylist.audioSortFilterParmsForPlaylistDownloadView;
        break;
      case AudioLearnAppViewType.audioPlayerView:
        playlistAudioSortFilterParameters =
            selectedPlaylist.audioSortFilterParmsForAudioPlayerView;
        break;
      default:
        break;
    }

    if (playlistAudioSortFilterParameters != null) {
      return playlistAudioSortFilterParameters;
    }

    // if the user has not yet selected sort and filter parameters,
    // then the default sort and filter parameters which don't
    // filter and only sort by audio download date descending
    // are returned.
    return createDefaultAudioSortFilterParameters();
  }

  AudioSortFilterParameters createDefaultAudioSortFilterParameters() {
    return AudioSortFilterParameters(
      selectedSortItemLst: [_audioSortFilterService.getDefaultSortingItem()],
      filterSentenceLst: const [],
      sentencesCombination: SentencesCombination.AND,
    );
  }

  void moveAudioToPlaylist({
    required Audio audio,
    required Playlist targetPlaylist,
    required bool keepAudioInSourcePlaylistDownloadedAudioLst,
  }) {
    _audioDownloadVM.moveAudioToPlaylist(
        audio: audio,
        targetPlaylist: targetPlaylist,
        keepAudioInSourcePlaylistDownloadedAudioLst:
            keepAudioInSourcePlaylistDownloadedAudioLst);

    _removeAudioFromSortedFilteredPlayableAudioList(audio);

    notifyListeners();
  }

  void copyAudioToPlaylist({
    required Audio audio,
    required Playlist targetPlaylist,
  }) {
    _audioDownloadVM.copyAudioToPlaylist(
      audio: audio,
      targetPlaylist: targetPlaylist,
    );

    notifyListeners();
  }

  /// Physically deletes the audio file from the audio playlist
  /// directory.
  ///
  /// playableAudioLst order: [available audio last downloaded, ...,
  ///                          available audio first downloaded]
  void deleteAudioMp3({
    required Audio audio,
  }) {
    // delete the audio file from the audio playlist directory
    // and removes the audio from the its playlist playable audio list
    _audioDownloadVM.deleteAudioMp3(audio: audio);

    _removeAudioFromSortedFilteredPlayableAudioList(audio);

    _setButtonAudioPopupMenuState(
      buttonStateIfAudiosAvailable: true,
      selectedPlaylist: audio.enclosingPlaylist!,
    );

    notifyListeners();
  }

  /// Method called when the user selected the Update playable
  /// audio list menu displayed by the playlist item menu button.
  /// This method updates the playlist playable audio list
  /// by removing the audios that are no longer present in the
  /// audio playlist directory.
  ///
  /// The method is useful when the user has deleted some audio
  /// mp3 files from the audio playlist directory.
  int updatePlayableAudioLst({
    required Playlist playlist,
  }) {
    int removedPlayableAudioNumber = playlist.updatePlayableAudioLst();

    if (removedPlayableAudioNumber > 0) {
      JsonDataService.saveToFile(
        model: playlist,
        path: playlist.getPlaylistDownloadFilePathName(),
      );

      _sortedFilteredSelectedPlaylistsPlayableAudios = null;

      notifyListeners();
    }

    return removedPlayableAudioNumber;
  }

  void savePlaylistAudioSortFilterParmsToPlaylist(
    AudioLearnAppViewType audioLearnAppView,
    bool isSortFilterParmsApplicationAutomatic,
  ) {
    Playlist playlist = getSelectedPlaylists()[0];

    if (audioLearnAppView == AudioLearnAppViewType.playlistDownloadView) {
      playlist.audioSortFilterParmsForPlaylistDownloadView =
          _audioSortFilterParameters;
      playlist.applyAutomaticallySortFilterParmsForPlaylistDownloadView =
          isSortFilterParmsApplicationAutomatic;
    } else {
      playlist.audioSortFilterParmsForAudioPlayerView =
          _audioSortFilterParameters;
      playlist.applyAutomaticallySortFilterParmsForAudioPlayerView =
          isSortFilterParmsApplicationAutomatic;
    }

    JsonDataService.saveToFile(
      model: playlist,
      path: playlist.getPlaylistDownloadFilePathName(),
    );
  }

  /// playableAudioLst order: [available audio last downloaded, ...,
  ///                          available audio first downloaded]
  void _removeAudioFromSortedFilteredPlayableAudioList(Audio audio) {
    if (_sortedFilteredSelectedPlaylistsPlayableAudios != null) {
      _sortedFilteredSelectedPlaylistsPlayableAudios!
          .removeWhere((audioInList) => audioInList == audio);
    }
  }

  /// User selected the audio menu item "Delete audio
  /// from playlist aswell". This method deletes the audio
  /// from the playlist json file and from the audio playlist
  /// directory.
  ///
  /// playableAudioLst order: [available audio last downloaded, ...,
  ///                          available audio first downloaded]
  void deleteAudioFromPlaylistAswell({
    required Audio audio,
  }) {
    _audioDownloadVM.deleteAudioFromPlaylistAswell(audio: audio);

    _removeAudioFromSortedFilteredPlayableAudioList(audio);

    notifyListeners();
  }

  int _getSelectedIndex() {
    for (int i = 0; i < _listOfSelectablePlaylists.length; i++) {
      if (_listOfSelectablePlaylists[i].isSelected) {
        return i;
      }
    }

    return -1;
  }

  void _setPlaylistButtonsStateIfOnePlaylistIsSelected({
    required Playlist selectedPlaylist,
  }) {
    if (_isListExpanded) {
      _enableExpandedListButtons();
    }

    if (selectedPlaylist.playlistType == PlaylistType.local) {
      _isButtonDownloadSelPlaylistsEnabled = false;
    } else {
      _isButtonDownloadSelPlaylistsEnabled = true;
    }

    _setButtonAudioPopupMenuState(
      buttonStateIfAudiosAvailable: true,
      selectedPlaylist: selectedPlaylist,
    );
  }

  /// If the selected playlist has no audio, then the
  /// button is disabled.
  void _setButtonAudioPopupMenuState({
    required bool buttonStateIfAudiosAvailable,
    Playlist? selectedPlaylist,
  }) {
    if (buttonStateIfAudiosAvailable) {
      if (selectedPlaylist != null &&
          selectedPlaylist.playableAudioLst.isNotEmpty) {
        _isButtonAudioPopupMenuEnabled = true;
      } else {
        _isButtonAudioPopupMenuEnabled = false;
      }
    } else {
      _isButtonAudioPopupMenuEnabled = false;
    }
  }

  void _enableExpandedListButtons() {
    _isButtonMoveUpPlaylistEnabled = true;
    _isButtonMoveDownPlaylistEnabled = true;
  }

  void _disableAllButtonsIfNoPlaylistIsSelected() {
    _disableExpandedListButtons();
    _setButtonAudioPopupMenuState(
      buttonStateIfAudiosAvailable: false,
    );
  }

  /// If the selected playlist is local, then the download
  /// playlist audios button is disabled.
  ///
  /// If the selected playlist is remote, then the download
  /// playlist audios button is enabled.
  ///
  /// If no playlist is selected, then the download playlist
  /// audios button is disabled.
  ///
  /// Finally, the move up and down buttons are disabled.
  void _disableExpandedListButtons() {
    if (_isOnePlaylistSelected) {
      Playlist selectedPlaylist =
          _listOfSelectablePlaylists[_getSelectedIndex()];
      if (selectedPlaylist.playlistType == PlaylistType.local) {
        // if the selected playlist is local, the download
        // playlist audios button is disabled
        _isButtonDownloadSelPlaylistsEnabled = false;
      } else {
        _isButtonDownloadSelPlaylistsEnabled = true;
      }
    } else {
      // if no playlist is selected, the download playlist
      // audios button is disabled
      _isButtonDownloadSelPlaylistsEnabled = false;
    }

    _isButtonMoveUpPlaylistEnabled = false;
    _isButtonMoveDownPlaylistEnabled = false;
  }

  void _doSelectUniquePlaylist({
    required int playlistIndex,
    required String playlistId,
    required bool isPlaylistSelected,
  }) {
    for (Playlist playlist in _listOfSelectablePlaylists) {
      if (playlist.id != playlistId) {
        _audioDownloadVM.updatePlaylistSelection(
          playlistId: playlist.id,
          isPlaylistSelected: false,
        );
      }
    }

    _listOfSelectablePlaylists[playlistIndex].isSelected = isPlaylistSelected;
    _isOnePlaylistSelected = isPlaylistSelected;
  }

  void _deleteItem(int index) {
    _listOfSelectablePlaylists.removeAt(index);
    _isOnePlaylistSelected = false;
  }

  void moveItemUp(int index) {
    int newIndex = (index - 1 + _listOfSelectablePlaylists.length) %
        _listOfSelectablePlaylists.length;
    Playlist item = _listOfSelectablePlaylists.removeAt(index);
    _listOfSelectablePlaylists.insert(newIndex, item);

    notifyListeners();
  }

  void moveItemDown(int index) {
    int newIndex = (index + 1) % _listOfSelectablePlaylists.length;
    Playlist item = _listOfSelectablePlaylists.removeAt(index);
    _listOfSelectablePlaylists.insert(newIndex, item);

    notifyListeners();
  }

  /// Returns the audio contained in the playableAudioLst which
  /// has been downloaded right after the current audio.
  Audio? getSubsequentlyDownloadedNotFullyPlayedAudio({
    required Audio currentAudio,
  }) {
    // this test is required, otherwise the method will be
    // executed so much time that the last downloaded audio
    // will be selected
    if (!currentAudio.wasFullyListened()) {
      return null;
    }

    // playableAudioLst order: [available audio last downloaded, ...,
    //                          available audio first downloaded]
    List<Audio> playableAudioLst =
        currentAudio.enclosingPlaylist!.playableAudioLst;

    int currentAudioIndex = playableAudioLst.indexWhere(
        (audio) => audio == currentAudio); // using Audio == operator

    if (currentAudioIndex == -1) {
      return null;
    }

    if (currentAudioIndex == 0) {
      // means the current audio is the last downloaded audio
      // available in the playableAudioLst and so there is no
      // subsequently downloaded audio !
      return null;
    }

    for (int i = currentAudioIndex - 1; i >= 0; i--) {
      Audio audio = playableAudioLst[i];
      if (audio.wasFullyListened()) {
        continue;
      } else {
        return audio;
      }
    }

    return null;
  }

  /// Returns the audio contained in the playableAudioLst which
  /// has been downloaded right before the current audio.
  Audio? getPreviouslyDownloadedPlayableAudio({
    required Audio currentAudio,
  }) {
    List<Audio> playableAudioLst =
        currentAudio.enclosingPlaylist!.playableAudioLst;

    int currentAudioIndex = playableAudioLst.indexWhere(
        (audio) => audio == currentAudio); // using Audio == operator

    if (currentAudioIndex == -1) {
      return null;
    }

    if (currentAudioIndex == playableAudioLst.length - 1) {
      // means the current audio is the oldest downloaded audio available
      // in the playableAudioLst
      return null;
    }

    return playableAudioLst[currentAudioIndex + 1];
  }
}
