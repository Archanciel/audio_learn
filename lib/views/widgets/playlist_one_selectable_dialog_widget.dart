import 'package:audio_learn/views/screen_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/playlist.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/playlist_list_vm.dart';
import '../../viewmodels/theme_provider.dart';

enum PlaylistOneSelectableDialogUsedFor {
  downloadSingleVideoAudio,
  moveAudioToPlaylist,
  copyAudioToPlaylist,
}

/// This dialog is used to select a single playlist among the
/// displayed playlists.
class PlaylistOneSelectableDialogWidget extends StatefulWidget {
  final PlaylistOneSelectableDialogUsedFor usedFor;
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
    required this.usedFor,
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
  bool _keepAudioDataInSourcePlaylist = true;

  // Using FocusNode to enable clicking on Enter to close
  // the dialog
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Request focus when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    // Dispose the focus node when the widget is disposed
    _focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkTheme = themeProvider.currentTheme == AppTheme.dark;
    PlaylistListVM expandablePlaylistVM = Provider.of<PlaylistListVM>(
      context,
      listen: false,
    );
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
      focusNode: _focusNode,
      onKey: (event) {
        if (event.isKeyPressed(LogicalKeyboardKey.enter) ||
            event.isKeyPressed(LogicalKeyboardKey.numpadEnter)) {
          // executing the same code as in the 'Confirm' ElevatedButton
          // onPressed callback
          if (widget.usedFor ==
              PlaylistOneSelectableDialogUsedFor.downloadSingleVideoAudio) {
            expandablePlaylistVM.setUniqueSelectedPlaylist(
              selectedPlaylist: _selectedPlaylist,
            );
          }

          Map<String, dynamic> resultMap = {
            'selectedPlaylist': _selectedPlaylist,
            'keepAudioDataInSourcePlaylist': _keepAudioDataInSourcePlaylist,
          };

          Navigator.of(context).pop(resultMap);
        }
      },
      child: AlertDialog(
        title:
            Text(AppLocalizations.of(context)!.playlistOneSelectedDialogTitle),
        actionsPadding:
            // reduces the top vertical space between the buttons
            // and the content
            const EdgeInsets.fromLTRB(
                10, 0, 10, 10), // Adjust the value as needed
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min, // Use minimum space
            children: [
              Expanded(
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
              (widget.usedFor ==
                          PlaylistOneSelectableDialogUsedFor
                              .moveAudioToPlaylist &&
                      widget.excludedPlaylist!.playlistType ==
                          PlaylistType.youtube) // when moving an audio
                  //                               from a playlist, the
                  //                               excluded playlist is
                  //                               the source playlist
                  ? Row(
                      // in this case, the audio is moved from a Youtube
                      // playlist and so the keep audio entry in source
                      // playlist checkbox is displayed
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!
                                .keepAudioEntryInSourcePlaylist,
                            style: TextStyle(
                              color: isDarkTheme ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: ScreenMixin.CHECKBOX_WIDTH_HEIGHT,
                          height: ScreenMixin.CHECKBOX_WIDTH_HEIGHT,
                          child: Checkbox(
                            value: _keepAudioDataInSourcePlaylist,
                            onChanged: (bool? newValue) {
                              setState(() {
                                _keepAudioDataInSourcePlaylist = newValue!;
                              });
                              // now clicking on Enter works since the
                              // Checkbox is not focused anymore
                              // _audioTitleSubStringFocusNode.requestFocus();
                            },
                          ),
                        ),
                      ],
                    )
                  : Container(), // here, we are moving an audio from a
              //                    local playlist, or we are copying an
              //                    audio or downloading the audio of a
              //                    single video. In those situations,
              //                    displaying the keep audio entry in
              //                    source playlist checkbox is not
              //                    useful.
            ],
          ),
        ),
        actions: [
          // situation of downloading a single video
          // audio. This is tested by 'Bug fix
          // verification with partial download single
          // video audio' integration test
          ElevatedButton(
            key: const Key('confirmButton'),
            onPressed: () {
              if (widget.usedFor ==
                  PlaylistOneSelectableDialogUsedFor.downloadSingleVideoAudio) {
                expandablePlaylistVM.setUniqueSelectedPlaylist(
                  selectedPlaylist: _selectedPlaylist,
                );
              }

              Map<String, dynamic> resultMap = {
                'selectedPlaylist': _selectedPlaylist,
                'keepAudioDataInSourcePlaylist': _keepAudioDataInSourcePlaylist,
              };

              Navigator.of(context).pop(resultMap);
            },
            child: Text(AppLocalizations.of(context)!.confirmButton),
          ),
          ElevatedButton(
            key: const Key('cancelButton'),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
        ],
      ),
    );
  }
}
