import 'package:flutter/material.dart';

import '../models/audio.dart';
import '../models/playlist.dart';
import '../services/json_data_service.dart';
import '../services/settings_data_service.dart';
import 'audio_download_vm.dart';
import 'warning_message_vm.dart';

/// List view model used in ExpandableListView
class ExpandablePlaylistListVM extends ChangeNotifier {
  bool _isListExpanded = false;
  bool _isButtonDownloadSelPlaylistsEnabled = false;
  bool _isButtonMoveUpPlaylistEnabled = false;
  bool _isButtonDownPlaylistEnabled = false;
  bool _isButtonAudioPopupMenuEnabled = false;

  bool get isListExpanded => _isListExpanded;
  bool get isButtonDownloadSelPlaylistsEnabled =>
      _isButtonDownloadSelPlaylistsEnabled;
  bool get isButtonMoveUpPlaylistEnabled => _isButtonMoveUpPlaylistEnabled;
  bool get isButtonDownPlaylistEnabled => _isButtonDownPlaylistEnabled;
  bool get isButtonAudioPopupMenuEnabled => _isButtonAudioPopupMenuEnabled;

  final AudioDownloadVM _audioDownloadVM;
  final WarningMessageVM _warningMessageVM;
  final SettingsDataService _settingsDataService;

  bool _isPlaylistSelected = true;
  List<Playlist> _listOfSelectablePlaylists = [];
  List<Audio>? _sortedFilteredSelectedPlaylistsPlayableAudios;

  Playlist? _uniqueSelectedPlaylist;
  Playlist? get uniqueSelectedPlaylist => _uniqueSelectedPlaylist;

  ExpandablePlaylistListVM({
    required WarningMessageVM warningMessageVM,
    required AudioDownloadVM audioDownloadVM,
    required SettingsDataService settingsDataService,
  })  : _warningMessageVM = warningMessageVM,
        _audioDownloadVM = audioDownloadVM,
        _settingsDataService = settingsDataService;

  List<Playlist> getUpToDateSelectablePlaylistsExceptPlaylist({
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
      _isPlaylistSelected = true;

      // required so that the TextField keyed by 
      // 'selectedPlaylistTextField' below the playlist URL TextField
      // is initialized at app startup
      _uniqueSelectedPlaylist = _listOfSelectablePlaylists[selectedPlaylistIndex];

      _enableAllButtonsIfOnePlaylistIsSelectedAndPlaylistListIsExpanded(
        selectedPlaylist: _listOfSelectablePlaylists[selectedPlaylistIndex],
      );
    } else {
      _isPlaylistSelected = false;

      // required so that the TextField keyed by 
      // 'selectedPlaylistTextField' below the playlist URL TextField
      // is initialized at app startup
      _uniqueSelectedPlaylist = null;

      _disableAllButtonsIfNoPlaylistIsSelected();
    }

    return _listOfSelectablePlaylists;
  }

  Future<void> addPlaylist({
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
        return;
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
        return;
      } catch (_) {
        // If the playlist with this title is not found, it means that
        // the playlist must be added.
      }
    } else {
      // If both playlistUrl and localPlaylistTitle are empty, it means
      // that the user clicked on the Add button without entering any
      // playlist url or local playlist title. So, we don't add the
      // playlist.
      return;
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
  }

  void toggleList() {
    _isListExpanded = !_isListExpanded;

    if (!_isListExpanded) {
      _disableEpandedListButtons();
    } else {
      int selectedPlaylistIndex = _getSelectedIndex();
      if (selectedPlaylistIndex != -1) {
        _enableAllButtonsIfOnePlaylistIsSelectedAndPlaylistListIsExpanded(
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
  /// {isPlaylistSelected} is true.
  void setPlaylistSelection({
    required int playlistIndex,
    required bool isPlaylistSelected,
  }) {
    // selecting another playlist or unselecting the currently
    // selected playlist nullifies the filtered and sorted audio list
    _sortedFilteredSelectedPlaylistsPlayableAudios = null;

    Playlist playlistSelectedOrUnselected =
        _listOfSelectablePlaylists[playlistIndex];
    String playlistSelectedOrUnselectedId = playlistSelectedOrUnselected.id;

    if (isPlaylistSelected) {
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
    _isPlaylistSelected = isPlaylistSelected;

    if (!_isPlaylistSelected) {
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
      // the playlist URL TextField is updated
      _uniqueSelectedPlaylist = null;
    } else {
      _enableAllButtonsIfOnePlaylistIsSelectedAndPlaylistListIsExpanded(
        selectedPlaylist: playlistSelectedOrUnselected,
      );

      // required so that the TextField keyed by
      // 'selectedPlaylistTextField' below
      // the playlist URL TextField is updated
      _uniqueSelectedPlaylist = playlistSelectedOrUnselected;
    }

    notifyListeners();
  }

  /// Method called when the user selected a playlist item and clicked
  /// on the Delete playlist button. But the Delete playlist button is
  /// no longer present.
  void deleteSelectedItem(BuildContext context) {
    int selectedIndex = _getSelectedIndex();

    if (selectedIndex != -1) {
      _deleteItem(selectedIndex);
      _updateAndSavePlaylistOrder();
      _disableAllButtonsIfNoPlaylistIsSelected();

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

  Future<void> downloadSelectedPlaylists(BuildContext context) async {
    List<Playlist> selectedPlaylists = getSelectedPlaylists();

    for (Playlist playlist in selectedPlaylists) {
      await _audioDownloadVM.downloadPlaylistAudios(playlistUrl: playlist.url);
    }
  }

  List<Playlist> getSelectedPlaylists() {
    return _listOfSelectablePlaylists
        .where((playlist) => playlist.isSelected)
        .toList();
  }

  /// Returns the selected playlist audio list. If the user
  /// clicked on the Apply button in the
  /// SortAndFilterAudioDialogWidget, then the filtered and
  /// sorted audio list is returned.
  ///
  /// [subFilterAndSort] is true by default. Being true, it
  /// means that the filtered and sorted audio list is
  /// returned if it exists. If false, the full playable
  /// audio list of the selected playlists is returned.
  List<Audio> getSelectedPlaylistsPlayableAudios({
    bool subFilterAndSort = true,
  }) {
    if (subFilterAndSort &&
        _sortedFilteredSelectedPlaylistsPlayableAudios != null) {
      // the case if the user clicked on the Apply button in the
      // SortAndFilterAudioDialogWidget
      return _sortedFilteredSelectedPlaylistsPlayableAudios!;
    } else {
      List<Audio> selectedPlaylistsAudios = [];

      for (Playlist playlist in _listOfSelectablePlaylists) {
        if (playlist.isSelected) {
          selectedPlaylistsAudios.addAll(playlist.playableAudioLst);
        }
      }

      return selectedPlaylistsAudios;
    }
  }

  /// Used to display the audio list of the selected playlist
  /// starting at the beginning.
  bool isAudioListFilteredAndSorted() {
    return _sortedFilteredSelectedPlaylistsPlayableAudios != null;
  }

  /// Called after the user clicked on the Apply button
  /// contained in the SortAndFilterAudioDialogWidget.
  void setSortedFilteredSelectedPlaylistsPlayableAudios(
      List<Audio> sortedFilteredSelectedPlaylistsPlayableAudios) {
    _sortedFilteredSelectedPlaylistsPlayableAudios =
        sortedFilteredSelectedPlaylistsPlayableAudios;

    notifyListeners();
  }

  void moveAudioToPlaylist({
    required Audio audio,
    required Playlist targetPlaylist,
  }) {
    _audioDownloadVM.moveAudioToPlaylist(
      audio: audio,
      targetPlaylist: targetPlaylist,
    );

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
  void deleteAudioMp3({
    required Audio audio,
  }) {
    // delete the audio file from the audio playlist directory
    // and removes the audio from the its playlist playable audio list
    _audioDownloadVM.deleteAudioMp3(audio: audio);

    _removeAudioFromSortedFilteredPlayableAudioList(audio);

    notifyListeners();
  }

  /// Method called when the user selected a playlist item
  /// PlaylistPopupMenuAction.updatePlaylistPlayableAudios menu
  /// item. This method updates the playlist playable audio list
  /// by removing the audios that are no longer present in the
  /// audio playlist directory.
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

  void _removeAudioFromSortedFilteredPlayableAudioList(Audio audio) {
    if (_sortedFilteredSelectedPlaylistsPlayableAudios != null) {
      _sortedFilteredSelectedPlaylistsPlayableAudios!
          .removeWhere((audioInList) => audioInList.videoUrl == audio.videoUrl);
    }
  }

  /// User selected the audio menu item "Delete audio
  /// from playlist aswell". This method deletes the audio
  /// from the playlist json file and from the audio playlist
  /// directory.
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

  void _enableAllButtonsIfOnePlaylistIsSelectedAndPlaylistListIsExpanded({
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

    _isButtonAudioPopupMenuEnabled = true;
  }

  void _enableExpandedListButtons() {
    _isButtonMoveUpPlaylistEnabled = true;
    _isButtonDownPlaylistEnabled = true;
  }

  void _disableAllButtonsIfNoPlaylistIsSelected() {
    _disableEpandedListButtons();
    _isButtonAudioPopupMenuEnabled = false;
  }

  void _disableEpandedListButtons() {
    _isButtonDownloadSelPlaylistsEnabled = false;
    _isButtonMoveUpPlaylistEnabled = false;
    _isButtonDownPlaylistEnabled = false;
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
    _isPlaylistSelected = isPlaylistSelected;
  }

  void _deleteItem(int index) {
    _listOfSelectablePlaylists.removeAt(index);
    _isPlaylistSelected = false;
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
}
