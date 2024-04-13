import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../models/playlist.dart';
import '../../viewmodels/playlist_list_vm.dart';
import '../../viewmodels/warning_message_vm.dart';
import '../screen_mixin.dart';
import 'delete_playlist_dialog_widget.dart';
import 'playlist_info_dialog_widget.dart';

enum PlaylistPopupMenuAction {
  openYoutubePlaylist,
  copyYoutubePlaylistUrl,
  displayPlaylistInfo,
  updatePlaylistPlayableAudios, // useful if playlist audio files were
  //                               deleted from the app dir
  deletePlaylist,
}

/// This widget is used to display a playlist in the
/// PlaylistDownloadView list of playlists. At left of the
/// playlist title, a menu button is displayed with menu items
/// created by this class. At right of the playlist title, a
/// checkbox is displayed to select the playlist.
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
    return Consumer<PlaylistListVM>(
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
                  if (playlist.playlistType == PlaylistType.youtube) ...[
                    PopupMenuItem<PlaylistPopupMenuAction>(
                      key: const Key('popup_menu_open_youtube_playlist'),
                      value: PlaylistPopupMenuAction.openYoutubePlaylist,
                      child: Text(
                          AppLocalizations.of(context)?.openYoutubePlaylist ??
                              'Open YouTube Playlist'),
                    ),
                    PopupMenuItem<PlaylistPopupMenuAction>(
                      key: const Key('popup_copy_youtube_video_url'),
                      value: PlaylistPopupMenuAction.copyYoutubePlaylistUrl,
                      child: Text(AppLocalizations.of(context)
                              ?.copyYoutubePlaylistUrl ??
                          'Copy YouTube Playlist URL'),
                    ),
                  ],
                  PopupMenuItem<PlaylistPopupMenuAction>(
                    key: const Key('popup_menu_display_playlist_info'),
                    value: PlaylistPopupMenuAction.displayPlaylistInfo,
                    child:
                        Text(AppLocalizations.of(context)!.displayPlaylistInfo),
                  ),
                  PopupMenuItem<PlaylistPopupMenuAction>(
                    key: const Key('popup_menu_update_playable_audio_list'),
                    value: PlaylistPopupMenuAction.updatePlaylistPlayableAudios,
                    child: Tooltip(
                      message: AppLocalizations.of(context)!
                          .updatePlaylistPlayableAudioListTooltip,
                      child: Text(AppLocalizations.of(context)!
                          .updatePlaylistPlayableAudioList),
                    ),
                  ),
                  PopupMenuItem<PlaylistPopupMenuAction>(
                    key: const Key('popup_menu_delete_playlist'),
                    value: PlaylistPopupMenuAction.deletePlaylist,
                    child: Text(AppLocalizations.of(context)!.deletePlaylist),
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
                            playlistJsonFileSize: expandablePlaylistListVM
                                .getPlaylistJsonFileSize(playlist: playlist),
                            focusNode: focusNode,
                          );
                        },
                      );
                      // required so that clicking on Enter to close the dialog works
                      focusNode.requestFocus();
                      break;
                    case PlaylistPopupMenuAction.updatePlaylistPlayableAudios:
                      int removedPlayableAudioNumber =
                          expandablePlaylistListVM.updatePlayableAudioLst(
                        playlist: playlist,
                      );

                      if (removedPlayableAudioNumber > 0) {
                        Provider.of<WarningMessageVM>(context, listen: false)
                            .setUpdatedPlayableAudioLstPlaylistTitle(
                                updatedPlayableAudioLstPlaylistTitle:
                                    playlist.title,
                                removedPlayableAudioNumber:
                                    removedPlayableAudioNumber);
                      }
                      break;
                    case PlaylistPopupMenuAction.deletePlaylist:
                      // Using FocusNode to enable clicking on Enter to close
                      // the dialog
                      final FocusNode focusNode = FocusNode();
                      showDialog<void>(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext context) {
                          return DeletePlaylistDialogWidget(
                            playlistToDelete: playlist,
                            focusNode: focusNode,
                          );
                        },
                      );
                      // required so that clicking on Enter to close the dialog works
                      focusNode.requestFocus();
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
