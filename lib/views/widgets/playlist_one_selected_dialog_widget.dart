import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/playlist.dart';
import '../../viewmodels/expandable_playlist_list_vm.dart';

class PlaylistOneSelectedDialogWidget extends StatefulWidget {
  final FocusNode focusNode;

  const PlaylistOneSelectedDialogWidget({
    super.key,
    required this.focusNode,
  });

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
      builder: (context, expandablePlaylistVM, _) => RawKeyboardListener(
        focusNode: widget.focusNode,
        onKey: (event) {
          if (event.isKeyPressed(LogicalKeyboardKey.enter) ||
              event.isKeyPressed(LogicalKeyboardKey.numpadEnter)) {
            // executing the same code as in the 'Confirm' ElevatedButton
            // onPressed callback
            expandablePlaylistVM.setUniqueSelectedPlaylist(
              selectedPlaylist: _selectedPlaylist,
            );
            Navigator.of(context).pop();
          }
        },
        child: AlertDialog(
          title: Text(
              AppLocalizations.of(context)!.playlistOneSelectedDialogTitle),
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
              child: Text(AppLocalizations.of(context)!.confirmButton),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
          ],
        ),
      ),
    );
  }
}
