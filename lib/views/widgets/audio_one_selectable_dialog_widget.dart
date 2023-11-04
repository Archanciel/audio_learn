import 'package:audio_learn/views/screen_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../constants.dart';
import '../../models/audio.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/audio_global_player_vm.dart';
import '../../viewmodels/playlist_list_vm.dart';
import '../../viewmodels/theme_provider.dart';
import 'audio_info_dialog_widget.dart';
import 'audio_list_item_widget.dart';
import 'rename_audio_file_dialog_widget.dart';

/// This dialog is used to select a single playlist among the
/// displayed playlists.
class AudioOneSelectableDialogWidget extends StatefulWidget {
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

  const AudioOneSelectableDialogWidget({
    super.key,
    this.isAudioOnlyCheckboxDisplayed = false,
  });

  @override
  _AudioOneSelectableDialogWidgetState createState() =>
      _AudioOneSelectableDialogWidgetState();
}

class _AudioOneSelectableDialogWidgetState
    extends State<AudioOneSelectableDialogWidget> with ScreenMixin {
  // Using FocusNode to enable clicking on Enter to close
  // the dialog
  final FocusNode _focusNode = FocusNode();

  Audio? _selectedAudio;
  bool _keepAudioDataInSourcePlaylist = true;

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
    AudioGlobalPlayerVM audioGlobalPlayerVM =
        Provider.of<AudioGlobalPlayerVM>(context, listen: false);
    Audio currentAudio = audioGlobalPlayerVM.currentAudio!;
    TextStyle currentAudioTextStyle = TextStyle(
      color: (isDarkTheme)
          ? ScreenMixin.lighten(kDarkAndLightIconColor, 0.4)
          : kDarkAndLightIconColor,
      fontWeight: FontWeight.bold,
    );

    List<Audio> playableAudioLst = audioGlobalPlayerVM
        .getPlayableAudiosContainedInCurrentAudioEnclosingPlaylist();

    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: (event) async {
        if (event.isKeyPressed(LogicalKeyboardKey.enter) ||
            event.isKeyPressed(LogicalKeyboardKey.numpadEnter)) {
          // executing the same code as in the 'Confirm' ElevatedButton
          // onPressed callback
          await audioGlobalPlayerVM.setCurrentAudio(_selectedAudio!);
          Navigator.of(context).pop(_selectedAudio);
        }
      },
      child: AlertDialog(
        title: Text(AppLocalizations.of(context)!.audioOneSelectedDialogTitle),
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
                  itemCount: playableAudioLst.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    Audio audio = playableAudioLst[index];
                    return ListTile(
                      // leading: IconButton(
                      //   icon: const Icon(Icons.menu),
                      //   onPressed: () {
                      //     final RenderBox listTileBox =
                      //         context.findRenderObject() as RenderBox;
                      //     final Offset listTilePosition =
                      //         listTileBox.localToGlobal(Offset.zero);

                      //     showMenu(
                      //       context: context,
                      //       position: RelativeRect.fromLTRB(
                      //         listTilePosition.dx - listTileBox.size.width,
                      //         listTilePosition.dy,
                      //         0,
                      //         0,
                      //       ),
                      //       items: [
                      //         PopupMenuItem<AudioPopupMenuAction>(
                      //           key: const Key('popup_menu_open_youtube_video'),
                      //           value: AudioPopupMenuAction.openYoutubeVideo,
                      //           child: Text(AppLocalizations.of(context)!
                      //               .openYoutubeVideo),
                      //         ),
                      //         PopupMenuItem<AudioPopupMenuAction>(
                      //           key: const Key('popup_copy_youtube_video_url'),
                      //           value: AudioPopupMenuAction.copyYoutubeVideoUrl,
                      //           child: Text(AppLocalizations.of(context)!
                      //               .copyYoutubeVideoUrl),
                      //         ),
                      //         PopupMenuItem<AudioPopupMenuAction>(
                      //           key: const Key('popup_menu_display_audio_info'),
                      //           value: AudioPopupMenuAction.displayAudioInfo,
                      //           child: Text(AppLocalizations.of(context)!
                      //               .displayAudioInfo),
                      //         ),
                      //         PopupMenuItem<AudioPopupMenuAction>(
                      //           key: const Key('popup_menu_rename_audio_file'),
                      //           value: AudioPopupMenuAction.renameAudioFile,
                      //           child: Text(AppLocalizations.of(context)!
                      //               .renameAudioFile),
                      //         ),
                      //         PopupMenuItem<AudioPopupMenuAction>(
                      //           key: const Key('popup_menu_delete_audio'),
                      //           value: AudioPopupMenuAction.deleteAudio,
                      //           child: Text(
                      //               AppLocalizations.of(context)!.deleteAudio),
                      //         ),
                      //         PopupMenuItem<AudioPopupMenuAction>(
                      //           key: const Key(
                      //               'popup_menu_delete_audio_from_playlist_aswell'),
                      //           value: AudioPopupMenuAction
                      //               .deleteAudioFromPlaylistAswell,
                      //           child: Text(AppLocalizations.of(context)!
                      //               .deleteAudioFromPlaylistAswell),
                      //         ),
                      //       ],
                      //       elevation: 8,
                      //     ).then((value) {
                      //       if (value != null) {
                      //         switch (value) {
                      //           case AudioPopupMenuAction.openYoutubeVideo:
                      //             openUrlInExternalApp(url: audio.videoUrl);
                      //             break;
                      //           case AudioPopupMenuAction.copyYoutubeVideoUrl:
                      //             Clipboard.setData(
                      //                 ClipboardData(text: audio.videoUrl));
                      //             break;
                      //           case AudioPopupMenuAction.displayAudioInfo:
                      //             // Using FocusNode to enable clicking on Enter to close
                      //             // the dialog
                      //             final FocusNode focusNode = FocusNode();
                      //             showDialog<void>(
                      //               context: context,
                      //               barrierDismissible: true,
                      //               builder: (BuildContext context) {
                      //                 return AudioInfoDialogWidget(
                      //                   audio: audio,
                      //                   focusNode: focusNode,
                      //                 );
                      //               },
                      //             );
                      //             focusNode.requestFocus();
                      //             break;
                      //           case AudioPopupMenuAction.renameAudioFile:
                      //             // Using FocusNode to enable clicking on Enter to close
                      //             // the dialog
                      //             final FocusNode focusNode = FocusNode();
                      //             showDialog<void>(
                      //               context: context,
                      //               barrierDismissible: true,
                      //               builder: (BuildContext context) {
                      //                 return RenameAudioFileDialogWidget(
                      //                   audio: audio,
                      //                   focusNode: focusNode,
                      //                 );
                      //               },
                      //             );
                      //             focusNode.requestFocus();
                      //             break;
                      //           case AudioPopupMenuAction.deleteAudio:
                      //             Provider.of<PlaylistListVM>(
                      //               context,
                      //               listen: false,
                      //             ).deleteAudioMp3(audio: audio);
                      //             break;
                      //           case AudioPopupMenuAction
                      //                 .deleteAudioFromPlaylistAswell:
                      //             Provider.of<PlaylistListVM>(
                      //               context,
                      //               listen: false,
                      //             ).deleteAudioFromPlaylistAswell(audio: audio);
                      //             break;
                      //           default:
                      //             break;
                      //         }
                      //       }
                      //     });
                      //   },
                      // ),
                      title: GestureDetector(
                        onTap: () async {
                          await audioGlobalPlayerVM.setCurrentAudio(audio);
                          Navigator.of(context).pop(audio);
                        },
                        child: Text(
                          audio.validVideoTitle,
                          style: (audio == currentAudio)
                              ? currentAudioTextStyle
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
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
            ],
          ),
        ),
        actions: [
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
