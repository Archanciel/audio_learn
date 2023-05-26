import 'package:flutter/material.dart';

import '../models/audio.dart';
import '../models/playlist.dart';
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
  List<Playlist> _selectablePlaylistLst = [];
  List<Audio>? _sortedFilteredSelectedPlaylistsPlayableAudios;

  ExpandablePlaylistListVM({
    required WarningMessageVM warningMessageVM,
    required AudioDownloadVM audioDownloadVM,
    required SettingsDataService settingsDataService,
  })  : _warningMessageVM = warningMessageVM,
        _audioDownloadVM = audioDownloadVM,
        _settingsDataService = settingsDataService;

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
      _selectablePlaylistLst = audioDownloadVMlistOfPlaylist;
    } else {
      _selectablePlaylistLst = [];
      for (String playlistTitle in orderedPlaylistTitleLst) {
        try {
          _selectablePlaylistLst.add(audioDownloadVMlistOfPlaylist
              .firstWhere((playlist) => playlist.title == playlistTitle));
        } catch (e) {
          // If the playlist with this title is not found, it means that
          // the playlist json file has been deleted. So, we don't add it
          // to the selectable playlist list.
        }
      }
    }

    if (_getSelectedIndex() != -1) {
      _isPlaylistSelected = true;
      _enableAllButtonsIfAtLeastOnePlaylistIsSelectedAndPlaylistListIsExpanded();
    } else {
      _isPlaylistSelected = false;
      _disableAllButtonsIfNoPlaylistIsSelected();
    }

    return _selectablePlaylistLst;
  }

  Future<void> addPlaylist({
    String playlistUrl = '',
    String localPlaylistTitle = '',
    required PlaylistQuality playlistQuality,
  }) async {
    if (localPlaylistTitle.isEmpty && playlistUrl.isNotEmpty) {
      try {
        final Playlist playlistWithThisUrlAlreadyDownloaded =
            _selectablePlaylistLst
                .firstWhere((element) => element.url == playlistUrl);
        // User clicked on Add button but the playlist with this url
        // was already downloaded
        _warningMessageVM.setPlaylistAlreadyDownloadedTitle(
            playlistTitle: playlistWithThisUrlAlreadyDownloaded.title);
        return;
      } catch (e) {
        // If the playlist with this url is not found, it means that
        // the playlist must be added.
      }
    }

    Playlist? addedPlaylist = await _audioDownloadVM.addPlaylist(
      playlistUrl: playlistUrl,
      localPlaylistTitle: localPlaylistTitle,
      playlistQuality: playlistQuality,
    );

    if (addedPlaylist != null) {
      // if addedPlaylist is null, it means that the
      // passed url is not a valid playlist url
      _selectablePlaylistLst.add(addedPlaylist);
      _updateAndSavePlaylistOrder();

      notifyListeners();
    }
  }

  void toggleList() {
    _isListExpanded = !_isListExpanded;

    if (!_isListExpanded) {
      _disableEpandedListButtons();
    } else {
      if (_getSelectedIndex() != -1) {
        _enableAllButtonsIfAtLeastOnePlaylistIsSelectedAndPlaylistListIsExpanded();
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

  void setPlaylistSelection({
    required int playlistIndex,
    required bool isPlaylistSelected,
  }) {
    // selecting another playlist displays the audio list of this
    // playlist and nullifies the filtered and sorted audio list
    _sortedFilteredSelectedPlaylistsPlayableAudios = null;

    _audioDownloadVM.updatePlaylistSelection(
      playlistId: _selectablePlaylistLst[playlistIndex].id,
      isPlaylistSelected: isPlaylistSelected,
    );

    bool isOneItemSelected = _doSelectUniquePlaylist(
      playlistIndex: playlistIndex,
      isPlaylistSelected: isPlaylistSelected,
    );

    if (!isOneItemSelected) {
      _disableAllButtonsIfNoPlaylistIsSelected();
    } else {
      _enableAllButtonsIfAtLeastOnePlaylistIsSelectedAndPlaylistListIsExpanded();
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

  /// Thanks to this method, when restarting the app, the playlists
  /// are displayed in the same order as when the app was closed. This
  /// is done by saving the playlist order in the settings file.
  void _updateAndSavePlaylistOrder() {
    List<String> playlistOrder =
        _selectablePlaylistLst.map((playlist) => playlist.title).toList();

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
    return _selectablePlaylistLst
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

      for (Playlist playlist in _selectablePlaylistLst) {
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

  /// Physically deletes the audio file from the audio playlist
  /// directory.
  void deleteAudio({
    required Audio audio,
  }) {
    _audioDownloadVM.deleteAudio(audio: audio);

    _removeAudioFromSortedFilteredPlayableAudioList(audio);

    notifyListeners();
  }

  int updatePlayableAudioLst({
    required Playlist playlist,
  }) {
    int removedPlayableAudioNumber = playlist.updatePlayableAudioLst();

    if (removedPlayableAudioNumber > 0) {
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
    for (int i = 0; i < _selectablePlaylistLst.length; i++) {
      if (_selectablePlaylistLst[i].isSelected) {
        return i;
      }
    }
    return -1;
  }

  void
      _enableAllButtonsIfAtLeastOnePlaylistIsSelectedAndPlaylistListIsExpanded() {
    if (_isListExpanded) {
      _enableExpandedListButtons();
    }
    _isButtonAudioPopupMenuEnabled = true;
  }

  void _enableExpandedListButtons() {
    _isButtonDownloadSelPlaylistsEnabled = true;
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

  bool _doSelectUniquePlaylist({
    required int playlistIndex,
    required bool isPlaylistSelected,
  }) {
    for (var playlist in _selectablePlaylistLst) {
      playlist.isSelected = false;
      _audioDownloadVM.updatePlaylistSelection(
        playlistId: playlist.id,
        isPlaylistSelected: false,
      );
    }

    _selectablePlaylistLst[playlistIndex].isSelected = isPlaylistSelected;

    _isPlaylistSelected = _selectablePlaylistLst[playlistIndex].isSelected;

    return _isPlaylistSelected;
  }

  void _deleteItem(int index) {
    _selectablePlaylistLst.removeAt(index);
    _isPlaylistSelected = false;
  }

  void moveItemUp(int index) {
    int newIndex = (index - 1 + _selectablePlaylistLst.length) %
        _selectablePlaylistLst.length;
    Playlist item = _selectablePlaylistLst.removeAt(index);
    _selectablePlaylistLst.insert(newIndex, item);

    notifyListeners();
  }

  void moveItemDown(int index) {
    int newIndex = (index + 1) % _selectablePlaylistLst.length;
    Playlist item = _selectablePlaylistLst.removeAt(index);
    _selectablePlaylistLst.insert(newIndex, item);

    notifyListeners();
  }
}
