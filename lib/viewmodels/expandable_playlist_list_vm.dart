import 'package:flutter/material.dart';

import '../models/playlist.dart';
import 'audio_download_vm.dart';

/// List view model used in ExpandableListView
class ExpandablePlaylistListVM extends ChangeNotifier {
  bool _isListExpanded = false;
  bool _isButton1Enabled = false;
  bool _isButton2Enabled = false;
  bool _isButton3Enabled = false;

  bool get isListExpanded => _isListExpanded;
  bool get isButton1Enabled => _isButton1Enabled;
  bool get isButton2Enabled => _isButton2Enabled;
  bool get isButton3Enabled => _isButton3Enabled;

  final AudioDownloadVM _audioDownloadVM;
  bool _isPlaylistSelected = true;
  List<Playlist> _selectablePlaylistLst = [];

  ExpandablePlaylistListVM({required AudioDownloadVM audioDownloadVM})
      : _audioDownloadVM = audioDownloadVM;

  List<Playlist> getUpToDateSelectablePlaylists() {
    _selectablePlaylistLst = _audioDownloadVM.listOfPlaylist;

    if (_getSelectedIndex() != -1) {
      _isPlaylistSelected = true;
      _enableButtons();
    } else {
      _isPlaylistSelected = false;
      _disableButtons();
    }

    notifyListeners();

    return _selectablePlaylistLst;
  }

  Future<void> addPlaylist({required String playlistUrl}) async {
    final bool alreadyDownloaded =
        _selectablePlaylistLst.any((playlist) => playlist.url == playlistUrl);

    if (alreadyDownloaded) {
      return;
    }

    Playlist addedPlaylist =
        await _audioDownloadVM.addPlaylist(playlistUrl: playlistUrl);
    // items.add(addedPlaylist);

    notifyListeners();
  }

  void toggleList() {
    _isListExpanded = !_isListExpanded;

    if (!_isListExpanded) {
      _disableButtons();
    } else {
      if (_isPlaylistSelected) {
        _enableButtons();
      } else {
        _disableButtons();
      }
    }

    notifyListeners();
  }

  void setPlaylistSelection({
    required int playlistIndex,
    required bool isPlaylistSelected,
  }) {
    _audioDownloadVM.updatePlaylistSelection(
      playlistId: _selectablePlaylistLst[playlistIndex].id,
      isPlaylistSelected: isPlaylistSelected,
    );

    bool isOneItemSelected = _doSelectUniquePlaylist(
      playlistIndex: playlistIndex,
      isPlaylistSelected: isPlaylistSelected,
    );

    if (!isOneItemSelected) {
      _disableButtons();
    } else {
      _enableButtons();
    }

    notifyListeners();
  }

  void deleteSelectedItem(BuildContext context) {
    int selectedIndex = _getSelectedIndex();

    if (selectedIndex != -1) {
      deleteItem(selectedIndex);
      _disableButtons();

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
    List<Playlist> selectedPlaylists = [];

    for (int i = 0; i < _selectablePlaylistLst.length; i++) {
      if (_selectablePlaylistLst[i].isSelected) {
        selectedPlaylists.add(_selectablePlaylistLst[i]);
      }
    }

    return selectedPlaylists;
  }

  int _getSelectedIndex() {
    for (int i = 0; i < _selectablePlaylistLst.length; i++) {
      if (_selectablePlaylistLst[i].isSelected) {
        return i;
      }
    }
    return -1;
  }

  void _enableButtons() {
    _isButton1Enabled = true;
    _isButton2Enabled = true;
    _isButton3Enabled = true;
  }

  void _disableButtons() {
    _isButton1Enabled = false;
    _isButton2Enabled = false;
    _isButton3Enabled = false;
  }

  bool _doSelectUniquePlaylist({
    required int playlistIndex,
    required bool isPlaylistSelected,
  }) {
    for (int i = 0; i < _selectablePlaylistLst.length; i++) {
      if (i == playlistIndex) {
        _selectablePlaylistLst[i].isSelected = isPlaylistSelected;
      } else {
        Playlist playlist = _selectablePlaylistLst[i];
        playlist.isSelected = false;
        _audioDownloadVM.updatePlaylistSelection(
          playlistId: _selectablePlaylistLst[i].id,
          isPlaylistSelected: false,
        );
      }
    }

    _isPlaylistSelected = _selectablePlaylistLst[playlistIndex].isSelected;

    return _isPlaylistSelected;
  }

  void deleteItem(int index) {
    _selectablePlaylistLst.removeAt(index);
    _isPlaylistSelected = false;
  }

  void moveItemUp(int index) {
    if (index == 0) {
      Playlist item = _selectablePlaylistLst.removeAt(index);
      _selectablePlaylistLst.add(item);
    } else {
      Playlist item = _selectablePlaylistLst.removeAt(index);
      _selectablePlaylistLst.insert(index - 1, item);
    }
    notifyListeners();
  }

  void moveItemDown(int index) {
    if (index == _selectablePlaylistLst.length - 1) {
      Playlist item = _selectablePlaylistLst.removeAt(index);
      _selectablePlaylistLst.insert(0, item);
    } else {
      Playlist item = _selectablePlaylistLst.removeAt(index);
      _selectablePlaylistLst.insert(index + 1, item);
    }
    notifyListeners();
  }
}
