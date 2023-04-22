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

  final AudioDownloadVM audioDownloadVM;
  bool _isPlaylistSelected = false;
  List<Playlist> _selectablePlaylistLst = [];

  ExpandablePlaylistListVM({required this.audioDownloadVM});

  List<Playlist> getUpToDateSelectablePlaylists() {
    _selectablePlaylistLst = audioDownloadVM.listOfPlaylist;

    return _selectablePlaylistLst;
  }

  Future<void> addPlaylist({required String playlistUrl}) async {
    final bool alreadyDownloaded =
        _selectablePlaylistLst.any((playlist) => playlist.url == playlistUrl);

    if (alreadyDownloaded) {
      return;
    }

    Playlist addedPlaylist =
        await audioDownloadVM.addPlaylist(playlistUrl: playlistUrl);
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

  void selectItem(BuildContext context, int index) {
    bool isOneItemSelected = _doSelectItem(index);

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
      await audioDownloadVM.downloadPlaylistAudios(playlistUrl: playlist.url);
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

  bool _doSelectItem(int index) {
    for (int i = 0; i < _selectablePlaylistLst.length; i++) {
      if (i == index) {
        _selectablePlaylistLst[i].isSelected =
            !_selectablePlaylistLst[i].isSelected;
      } else {
        _selectablePlaylistLst[i].isSelected = false;
      }
    }

    _isPlaylistSelected = _selectablePlaylistLst[index].isSelected;

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
