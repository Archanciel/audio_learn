import 'package:flutter/material.dart';

import '../models/audio.dart';
import '../models/playlist.dart';
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

  bool _isPlaylistSelected = true;
  List<Playlist> _selectablePlaylistLst = [];
  List<Audio>? _sortedFilteredSelectedPlaylistsPlayableAudios;

  ExpandablePlaylistListVM({required WarningMessageVM warningMessageVM, required AudioDownloadVM audioDownloadVM,})
      : _warningMessageVM = warningMessageVM, _audioDownloadVM = audioDownloadVM;

  List<Playlist> getUpToDateSelectablePlaylists() {
    _selectablePlaylistLst = _audioDownloadVM.listOfPlaylist;

    if (_getSelectedIndex() != -1) {
      _isPlaylistSelected = true;
      _enableAllButtonsIfAtLeastOnePlaylistIsSelected();
    } else {
      _isPlaylistSelected = false;
      _disableAllButtonsIfNoPlaylistIsSelected();
    }

    return _selectablePlaylistLst;
  }

  Future<void> addPlaylist({required String playlistUrl}) async {
    final bool playlistWithThisUrlAlreadyDownloaded =
        _selectablePlaylistLst.any((playlist) => playlist.url == playlistUrl);

    if (playlistWithThisUrlAlreadyDownloaded) {
      _warningMessageVM.isPlaylistWithThisUrlAlreadyDownloaded = true;
      
      return;
    }

    Playlist? addedPlaylist =
        await _audioDownloadVM.addPlaylist(playlistUrl: playlistUrl);

    if (addedPlaylist != null) {
      // if addedPlaylist is null, it means that the 
      // passed url is not a valid playlist url
      notifyListeners();
    }
  }

  void toggleList() {
    _isListExpanded = !_isListExpanded;

    if (!_isListExpanded) {
      _disableEpandedListButtons();
    } else {
      if (_getSelectedIndex() != -1) {
        _enableAllButtonsIfAtLeastOnePlaylistIsSelected();
      } else {
        _disableAllButtonsIfNoPlaylistIsSelected();
      }
    }

    notifyListeners();
  }

  void setPlaylistSelection({
    required int playlistIndex,
    required bool isPlaylistSelected,
  }) {
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
      _enableAllButtonsIfAtLeastOnePlaylistIsSelected();
    }

    notifyListeners();
  }

  void deleteSelectedItem(BuildContext context) {
    int selectedIndex = _getSelectedIndex();

    if (selectedIndex != -1) {
      deleteItem(selectedIndex);
      _disableAllButtonsIfNoPlaylistIsSelected();

      notifyListeners();
    }
  }

  void moveSelectedItemUp() {
    int selectedIndex = _getSelectedIndex();
    if (selectedIndex != -1) {
      moveItemUp(selectedIndex);
      notifyListeners();
    }
  }

  void moveSelectedItemDown() {
    int selectedIndex = _getSelectedIndex();
    if (selectedIndex != -1) {
      moveItemDown(selectedIndex);
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

  List<Audio> getSelectedPlaylistsPlayableAudios() {
    if (_sortedFilteredSelectedPlaylistsPlayableAudios != null) {
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

  void setSortedFilteredSelectedPlaylistsPlayableAudios(
      List<Audio> sortedFilteredSelectedPlaylistsPlayableAudios) {
    _sortedFilteredSelectedPlaylistsPlayableAudios =
        sortedFilteredSelectedPlaylistsPlayableAudios;

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

  void _enableAllButtonsIfAtLeastOnePlaylistIsSelected() {
    _isButtonDownloadSelPlaylistsEnabled = true;
    _isButtonMoveUpPlaylistEnabled = true;
    _isButtonDownPlaylistEnabled = true;
    _isButtonAudioPopupMenuEnabled = true;
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
    _selectablePlaylistLst.forEach((playlist) {
      playlist.isSelected = false;
      _audioDownloadVM.updatePlaylistSelection(
        playlistId: playlist.id,
        isPlaylistSelected: false,
      );
    });

    _selectablePlaylistLst[playlistIndex].isSelected = isPlaylistSelected;

    _isPlaylistSelected = _selectablePlaylistLst[playlistIndex].isSelected;

    return _isPlaylistSelected;
  }

  void deleteItem(int index) {
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
