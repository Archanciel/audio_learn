import 'package:flutter/material.dart';

import '../constants.dart';
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

  final AudioDownloadVM audioDownloadVM = AudioDownloadVM();
  List<Playlist> get playlistList => audioDownloadVM.listOfPlaylist;

  bool _isPlaylistSelected = false;

  bool get isPlaylistSelected => _isPlaylistSelected;
  set isPlaylistSelected(bool value) => _isPlaylistSelected = value;

  List<Playlist> items = [];

  List<Playlist> getPlaylists() {
    items = audioDownloadVM.listOfPlaylist;

    return items;
  }

  Future<void> addPlaylist({required String playlistUrl}) async {
    final bool alreadyDownloaded =
        items.any((playlist) => playlist.url == playlistUrl);

    if (alreadyDownloaded) {
      return;
    }

    Playlist addedPlaylist =
        await audioDownloadVM.addPlaylist(playlistUrl: playlistUrl);
    items.insert(0, addedPlaylist);

    notifyListeners();
  }

  void toggleList() {
    _isListExpanded = !_isListExpanded;

    if (!_isListExpanded) {
      _disableButtons();
    } else {
      if (isPlaylistSelected) {
        _enableButtons();
      } else {
        _disableButtons();
      }
    }

    notifyListeners();
  }

  void selectItem(BuildContext context, int index) {
    bool isOneItemSelected = doSelectItem(index);

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

    for (int i = 0; i < items.length; i++) {
      if (items[i].isSelected) {
        selectedPlaylists.add(items[i]);
      }
    }

    return selectedPlaylists;
  }

  int _getSelectedIndex() {
    for (int i = 0; i < items.length; i++) {
      if (items[i].isSelected) {
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

  bool doSelectItem(int index) {
    for (int i = 0; i < items.length; i++) {
      if (i == index) {
        items[i].isSelected = !items[i].isSelected;
      } else {
        items[i].isSelected = false;
      }
    }

    _isPlaylistSelected = items[index].isSelected;

    return _isPlaylistSelected;
  }

  void deleteItem(int index) {
    items.removeAt(index);
    _isPlaylistSelected = false;
  }

  void moveItemUp(int index) {
    if (index == 0) {
      Playlist item = items.removeAt(index);
      items.add(item);
    } else {
      Playlist item = items.removeAt(index);
      items.insert(index - 1, item);
    }
    notifyListeners();
  }

  void moveItemDown(int index) {
    if (index == items.length - 1) {
      Playlist item = items.removeAt(index);
      items.insert(0, item);
    } else {
      Playlist item = items.removeAt(index);
      items.insert(index + 1, item);
    }
    notifyListeners();
  }
}
