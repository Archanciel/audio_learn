import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/playlist.dart';
import '../../viewmodels/expandable_playlist_list_vm.dart';

class PlaylistOneSelectableDialogWidget extends StatefulWidget {
  final FocusNode focusNode;
  final Playlist? excludedPlaylist;

  // Displaying the audio only checkbox is useful when the dialog is used
  // in order to move an Audio file to a destination playlist.
  //
  // Setting the checkbox to true has the effect that the Audio entry in
  // the source playlist is not deleted, which has the advantage that it
  // is not necessary to remove the Audio video link from the Youtube
  // source playlist in order to avoid to redownload it the next time
  // download all is applyed to the source playlist.
  //
  // In any case, the moved Audio playlist entry is added to the
  // destination playlist.
  final bool isAudioOnlyCheckboxDisplayed;

  const PlaylistOneSelectableDialogWidget({
    super.key,
    required this.focusNode,
    this.excludedPlaylist,
    this.isAudioOnlyCheckboxDisplayed = false,
  });

  @override
  _PlaylistOneSelectableDialogWidgetState createState() =>
      _PlaylistOneSelectableDialogWidgetState();
}

class _PlaylistOneSelectableDialogWidgetState
    extends State<PlaylistOneSelectableDialogWidget> {
  Playlist? _selectedPlaylist;

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpandablePlaylistListVM>(
      builder: (context, expandablePlaylistVM, _) {
        List<Playlist> upToDateSelectablePlaylists;

        if (widget.excludedPlaylist == null) {
          upToDateSelectablePlaylists =
              expandablePlaylistVM.getUpToDateSelectablePlaylists();
        } else {
          upToDateSelectablePlaylists =
              expandablePlaylistVM.getUpToDateSelectablePlaylistsExceptPlaylist(
                  excludedPlaylist: widget.excludedPlaylist!);
        }

        return RawKeyboardListener(
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
                itemCount: upToDateSelectablePlaylists.length,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return RadioListTile<Playlist>(
                    title: Text(upToDateSelectablePlaylists[index].title),
                    value: upToDateSelectablePlaylists[index],
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
              Text(AppLocalizations.of(context)!.keepAudioEntryInSourcePlaylist),
              Checkbox(
                value: true,
                onChanged: (bool? newValue) {
                  setState(() {
                    // _ignoreCase = newValue!;
                  });
                  // now clicking on Enter works since the
                  // Checkbox is not focused anymore
                  // _audioTitleSubStringFocusNode.requestFocus();
                },
              ),
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
        );
      },
    );
  }
}
