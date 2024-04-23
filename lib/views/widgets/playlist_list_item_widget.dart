import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../models/playlist.dart';
import '../../services/json_data_service.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/playlist_list_vm.dart';
import '../../viewmodels/warning_message_vm.dart';
import '../screen_mixin.dart';
import 'confirm_action_dialog_widget.dart';
import 'playlist_info_dialog_widget.dart';
import 'set_audio_speed_dialog_widget.dart';

enum PlaylistPopupMenuAction {
  openYoutubePlaylist,
  copyYoutubePlaylistUrl,
  displayPlaylistInfo,
  updatePlaylistPlayableAudios, // useful if playlist audio files were
  //                               deleted from the app dir
  setPlaylistAudioPlaySpeed,
  deletePlaylist,
}

/// This widget is used to display a playlist in the
/// PlaylistDownloadView list of playlists. At left of the
/// playlist title, a menu button is displayed with menu items
/// created by this class. At right of the playlist title, a
/// checkbox is displayed to select the playlist.
class PlaylistListItemWidget extends StatelessWidget with ScreenMixin {
  final SettingsDataService settingsDataService;
  final Playlist playlist;
  final int index;

  PlaylistListItemWidget({
    required this.settingsDataService,
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
                    key: const Key('popup_menu_set_audio_play_speed'),
                    value: PlaylistPopupMenuAction.setPlaylistAudioPlaySpeed,
                    child: Tooltip(
                      message: AppLocalizations.of(context)!
                          .updatePlaylistPlayableAudioListTooltip,
                      child:
                          Text(AppLocalizations.of(context)!.setAudioPlaySpeed),
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
                            settingsDataService: settingsDataService,
                            playlist: playlist,
                            playlistJsonFileSize: expandablePlaylistListVM
                                .getPlaylistJsonFileSize(playlist: playlist),
                            focusNode: focusNode,
                          );
                        },
                      );
                      // required so that clicking on Enter to close the dialog
                      // works. This intruction must be located after the
                      // .then() method of the showDialog() method !
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
                    case PlaylistPopupMenuAction.setPlaylistAudioPlaySpeed:
                      // Using FocusNode to enable clicking on Enter to close
                      // the dialog
                      final FocusNode focusNode = FocusNode();
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext context) {
                          return SetAudioSpeedDialogWidget(
                            audioPlaySpeed: (playlist.audioPlaySpeed != 0)
                                ? playlist.audioPlaySpeed
                                : settingsDataService.get(
                                        settingType: SettingType.playlists,
                                        settingSubType: Playlists.playSpeed) ??
                                    1.0,
                            displayApplyToAudioAlreadyDownloaded: true,
                          );
                        },
                      ).then((value) {
                        // not null value is boolean
                        if (value != null) {
                          // value is null if clicking on Cancel or if the dialog
                          // is dismissed by clicking outside the dialog.

                          if (value[1]) {
                            playlist.setAudioPlaySpeedToAllAudios(
                              audioPlaySpeed: value[0] as double,
                            );
                          } else {
                            playlist.audioPlaySpeed = value[0] as double;
                          }

                          JsonDataService.saveToFile(
                            model: playlist,
                            path: playlist.getPlaylistDownloadFilePathName(),
                          );
                        }
                      });
                      // required so that clicking on Enter to close the dialog
                      // works. This intruction must be located after the
                      // .then() method of the showDialog() method !
                      focusNode.requestFocus();
                      break;
                    case PlaylistPopupMenuAction.deletePlaylist:
                      // Using FocusNode to enable clicking on Enter to close
                      // the dialog
                      final FocusNode focusNode = FocusNode();
                      showDialog<void>(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext context) {
                          return ConfirmActionDialogWidget(
                            actionFunction: deletePlaylist,
                            actionFunctionArgs: [
                              expandablePlaylistListVM,
                              playlist
                            ],
                            dialogTitle:
                                _createDeletePlaylistDialogTitle(context),
                            dialogContent: AppLocalizations.of(context)!
                                .deletePlaylistDialogComment,
                            focusNode: focusNode,
                          );
                        },
                      );
                      // required so that clicking on Enter to close the dialog
                      // works. This intruction must be located after the
                      // .then() method of the showDialog() method !
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

  void deletePlaylist(
    PlaylistListVM expandablePlaylistListVM,
    Playlist playlistToDelete,
  ) {
    expandablePlaylistListVM.deletePlaylist(
      playlistToDelete: playlistToDelete,
    );
  }

  String _createDeletePlaylistDialogTitle(
    BuildContext context,
  ) {
    String deletePlaylistDialogTitle;

    if (playlist.url.isNotEmpty) {
      deletePlaylistDialogTitle = AppLocalizations.of(context)!
          .deleteYoutubePlaylistDialogTitle(playlist.title);
    } else {
      deletePlaylistDialogTitle = AppLocalizations.of(context)!
          .deleteLocalPlaylistDialogTitle(playlist.title);
    }

    return deletePlaylistDialogTitle;
  }
}
