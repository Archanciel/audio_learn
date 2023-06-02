import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/playlist.dart';
import '../../viewmodels/expandable_playlist_list_vm.dart';

class PlaylistOneSelectedDialogWidget extends StatefulWidget {
  const PlaylistOneSelectedDialogWidget({super.key});

  @override
  _PlaylistOneSelectedDialogWidgetState createState() =>
      _PlaylistOneSelectedDialogWidgetState();
}

class _PlaylistOneSelectedDialogWidgetState
    extends State<PlaylistOneSelectedDialogWidget> {
  Playlist? _selectedPlaylist;

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpandablePlaylistListVM>(
      builder: (context, expandablePlaylistVM, _) => AlertDialog(
        title: const Text('Select a Playlist'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            itemCount:
                expandablePlaylistVM.getUpToDateSelectablePlaylists().length,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return RadioListTile<Playlist>(
                title: Text(expandablePlaylistVM
                    .getUpToDateSelectablePlaylists()[index]
                    .title),
                value: expandablePlaylistVM
                    .getUpToDateSelectablePlaylists()[index],
                groupValue: _selectedPlaylist,
                onChanged: (Playlist? value) {
                  setState(() {
                    _selectedPlaylist = value;
                  });
                },
              );
            },
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              expandablePlaylistVM.setUniqueSelectedPlaylist(
                selectedPlaylist: _selectedPlaylist,
              );
              Navigator.of(context).pop();
            },
            child: const Text('Apply'),
          ),
          ElevatedButton(
            onPressed: () {
              expandablePlaylistVM.setUniqueSelectedPlaylist(
                selectedPlaylist: null,
              );
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
