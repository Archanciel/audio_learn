import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../models/playlist.dart';
import '../../viewmodels/expandable_playlist_list_vm.dart';
import '../../viewmodels/warning_message_vm.dart';
import '../screen_mixin.dart';
import 'playlist_info_dialog_widget.dart';

enum PlaylistPopupMenuAction {
  openYoutubePlaylist,
  copyYoutubePlaylistUrl,
  displayPlaylistInfo,
  updatePlaylistPlayableAudios, // useful if playlist audio files were
  // deleted
}

class PlaylistListItemWidget extends StatelessWidget with ScreenMixin {
  final Playlist playlist;
  final int index;

  PlaylistListItemWidget({
    required this.playlist,
    required this.index,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpandablePlaylistListVM>(
      builder: (context, expandablePlaylistListVM, child) {
        return ListTile(
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              final RenderBox listTileBox =
                  context.findRenderObject() as RenderBox;
              final Offset listTilePosition =
                  listTileBox.localToGlobal(Offset.zero);
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(
                  listTilePosition.dx - listTileBox.size.width,
                  listTilePosition.dy,
                  0,
                  0,
                ),
                items: [
                  PopupMenuItem<PlaylistPopupMenuAction>(
                    key: const Key('popup_menu_open_youtube_playlist'),
                    value: PlaylistPopupMenuAction.openYoutubePlaylist,
                    child:
                        Text(AppLocalizations.of(context)!.openYoutubePlaylist),
                  ),
                  PopupMenuItem<PlaylistPopupMenuAction>(
                    key: const Key('popup_copy_youtube_video_url'),
                    value: PlaylistPopupMenuAction.copyYoutubePlaylistUrl,
                    child: Text(
                        AppLocalizations.of(context)!.copyYoutubePlaylistUrl),
                  ),
                  PopupMenuItem<PlaylistPopupMenuAction>(
                    key: const Key('popup_menu_display_audio_info'),
                    value: PlaylistPopupMenuAction.displayPlaylistInfo,
                    child:
                        Text(AppLocalizations.of(context)!.displayPlaylistInfo),
                  ),
                  PopupMenuItem<PlaylistPopupMenuAction>(
                    key: const Key(
                        'popup_menu_display_update_playable_audio_list'),
                    value: PlaylistPopupMenuAction.updatePlaylistPlayableAudios,
                    child: Text(AppLocalizations.of(context)!
                        .updatePlaylistPlayableAudioList),
                  ),
                ],
                elevation: 8,
              ).then((value) {
                if (value != null) {
                  switch (value) {
                    case PlaylistPopupMenuAction.openYoutubePlaylist:
                      openUrlInExternalApp(url: playlist.url);
                      break;
                    case PlaylistPopupMenuAction.copyYoutubePlaylistUrl:
                      Clipboard.setData(ClipboardData(text: playlist.url));
                      break;
                    case PlaylistPopupMenuAction.displayPlaylistInfo:
                      // Using FocusNode to enable clicking on Enter to close
                      // the dialog
                      final FocusNode focusNode = FocusNode();
                      showDialog<void>(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext context) {
                          return PlaylistInfoDialogWidget(
                            playlist: playlist,
                            focusNode: focusNode,
                          );
                        },
                      );
                      focusNode.requestFocus();
                      break;
                    case PlaylistPopupMenuAction.updatePlaylistPlayableAudios:
                      int removedPlayableAudioNumber =
                          expandablePlaylistListVM.updatePlayableAudioLst(playlist: playlist,);

                      if (removedPlayableAudioNumber > 0) {
                        Provider.of<WarningMessageVM>(context, listen: false)
                            .setUpdatedPlayableAudioLstPlaylistTitle(
                                updatedPlayableAudioLstPlaylistTitle:
                                    playlist.title,
                                    removedPlayableAudioNumber: removedPlayableAudioNumber);
                      }
                      break;
                    default:
                      break;
                  }
                }
              });
            },
          ),
          title: Text(playlist.title),
          trailing: Checkbox(
            value: playlist.isSelected,
            onChanged: (value) {
              expandablePlaylistListVM.setPlaylistSelection(
                playlistIndex: index,
                isPlaylistSelected: value!,
              );
            },
          ),
        );
      },
    );
  }
}
