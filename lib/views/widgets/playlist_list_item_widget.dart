import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../models/playlist.dart';
import '../../viewmodels/expandable_playlist_list_vm.dart';
import '../screen_mixin.dart';

enum PlaylistPopupMenuAction {
  openYoutubePlaylist,
  copyYoutubePlaylistUrl,
  displayPlaylistInfo,
}

class PlaylistListItemWidget extends StatelessWidget with ScreenMixin {
  final Playlist playlist;
  final int index;
  final TextEditingController _playlistUrlController = TextEditingController();

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
                ],
                elevation: 8,
              ).then((value) {
                if (value != null) {
                  switch (value) {
                    case PlaylistPopupMenuAction.openYoutubePlaylist:
                      openUrlInExternalApp(url: playlist.url);
                      break;
                    case PlaylistPopupMenuAction.copyYoutubePlaylistUrl:
                      break;
                    case PlaylistPopupMenuAction.displayPlaylistInfo:
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
              _playlistUrlController.text = playlist.url;
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
