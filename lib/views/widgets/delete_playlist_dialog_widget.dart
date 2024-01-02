import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../views/screen_mixin.dart';
import '../../models/audio.dart';
import '../../models/playlist.dart';
import '../../services/settings_data_service.dart';
import '../../utils/ui_util.dart';
import '../../viewmodels/playlist_list_vm.dart';
import '../../viewmodels/theme_provider_vm.dart';

class DeletePlaylistDialogWidget extends StatefulWidget {
  final Playlist playlistToDelete;
  final FocusNode focusNode;

  const DeletePlaylistDialogWidget({
    required this.playlistToDelete,
    required this.focusNode,
    super.key,
  });

  @override
  State<DeletePlaylistDialogWidget> createState() =>
      _DeletePlaylistDialogWidgetState();
}

class _DeletePlaylistDialogWidgetState extends State<DeletePlaylistDialogWidget>
    with ScreenMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeProviderVM themeProviderVM = Provider.of<ThemeProviderVM>(context);

    return RawKeyboardListener(
      // Using FocusNode to enable clicking on Enter to close
      // the dialog
      focusNode: widget.focusNode,
      onKey: (event) {
        if (event.isKeyPressed(LogicalKeyboardKey.enter) ||
            event.isKeyPressed(LogicalKeyboardKey.numpadEnter)) {
          // executing the same code as in the 'Delete'
          // TextButton onPressed callback
          _deletePlaylist(context);
          Navigator.of(context).pop();
        }
      },
      child: AlertDialog(
        title: Text(
          key: const Key('playlistDeleteConfirmDialogTitleKey'),
          _createDeletePlaylistDialogTitle(),
        ),
        actionsPadding:
            // reduces the top vertical space between the buttons
            // and the content
            const EdgeInsets.fromLTRB(
                10, 0, 10, 10), // Adjust the value as needed
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              createTitleCommentRowFunction(
                titleTextWidgetKey:
                    const Key('playlistDeleteTitleCommentConfirmDialogKey'),
                context: context,
                commentStr:
                    AppLocalizations.of(context)!.deletePlaylistDialogComment,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            key: const Key('deletePlaylistConfirmDialogDeleteButton'),
            onPressed: () {
              _deletePlaylist(context);
              Navigator.of(context).pop();
            },
            child: Text(
              AppLocalizations.of(context)!.delete,
              style: (themeProviderVM.currentTheme == AppTheme.dark)
                  ? kTextButtonStyleDarkMode
                  : kTextButtonStyleLightMode,
            ),
          ),
          TextButton(
            key: const Key('deletePlaylistConfirmDialogCancelButton'),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: (themeProviderVM.currentTheme == AppTheme.dark)
                  ? kTextButtonStyleDarkMode
                  : kTextButtonStyleLightMode,
            ),
          ),
        ],
      ),
    );
  }

  String _createDeletePlaylistDialogTitle() {
    String deletePlaylistDialogTitle;

    if (widget.playlistToDelete.url.isNotEmpty) {
      deletePlaylistDialogTitle = AppLocalizations.of(context)!
          .deleteYoutubePlaylistDialogTitle(widget.playlistToDelete.title);
    } else {
      deletePlaylistDialogTitle = AppLocalizations.of(context)!
          .deleteLocalPlaylistDialogTitle(widget.playlistToDelete.title);
    }

    return deletePlaylistDialogTitle;
  }

  void _deletePlaylist(BuildContext context) {
    PlaylistListVM expandablePlaylistListVM =
        Provider.of<PlaylistListVM>(context, listen: false);

    expandablePlaylistListVM.deletePlaylist(
      playlistToDelete: widget.playlistToDelete,
    );
  }

  String formatDownloadSpeed({
    required BuildContext context,
    required Audio audio,
  }) {
    int audioDownloadSpeed = audio.audioDownloadSpeed;
    String audioDownloadSpeedStr;

    if (audioDownloadSpeed.isInfinite) {
      audioDownloadSpeedStr =
          AppLocalizations.of(context)!.infiniteBytesPerSecond;
    } else {
      audioDownloadSpeedStr =
          '${UiUtil.formatLargeIntValue(context: context, value: audioDownloadSpeed)}/sec';
    }

    return audioDownloadSpeedStr;
  }
}
