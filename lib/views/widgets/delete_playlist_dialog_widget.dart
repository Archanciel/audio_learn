import 'package:audio_learn/views/screen_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../models/audio.dart';
import '../../models/playlist.dart';
import '../../utils/ui_util.dart';
import '../../viewmodels/playlist_list_vm.dart';

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
  final TextEditingController _localPlaylistTitleTextEditingController =
      TextEditingController();
  final FocusNode _localPlaylistTitleFocusNode = FocusNode();

  bool _isChecked = false;

  @override
  void initState() {
    super.initState();

    // Add this line to request focus on the TextField after the build
    // method has been called
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(
        _localPlaylistTitleFocusNode,
      );
    });
  }

  @override
  void dispose() {
    _localPlaylistTitleTextEditingController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      // Using FocusNode to enable clicking on Enter to close
      // the dialog
      focusNode: widget.focusNode,
      onKey: (event) {
        if (event.isKeyPressed(LogicalKeyboardKey.enter) ||
            event.isKeyPressed(LogicalKeyboardKey.numpadEnter)) {
          // executing the same code as in the 'Add'
          // ElevatedButton onPressed callback
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
          ElevatedButton(
            key: const Key('deletePlaylistConfirmDialogDeleteButton'),
            onPressed: () {
              _deletePlaylist(context);
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.delete),
          ),
          ElevatedButton(
            key: const Key('deletePlaylistConfirmDialogCancelButton'),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.cancel),
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
    String localPlaylistTitle = _localPlaylistTitleTextEditingController.text;
    PlaylistListVM expandablePlaylistListVM =
        Provider.of<PlaylistListVM>(context, listen: false);

    if (localPlaylistTitle.isNotEmpty) {
      // if the local playlist title is not empty, then add the local
      // playlist
      expandablePlaylistListVM.addPlaylist(
        localPlaylistTitle: localPlaylistTitle,
        playlistQuality:
            _isChecked ? PlaylistQuality.music : PlaylistQuality.voice,
      );
    } else {
      // if the local playlist title is empty, then add the Youtube
      // playlist if the Youtube playlist URL is not empty
      if (widget.playlistToDelete.url.isNotEmpty) {
        expandablePlaylistListVM.addPlaylist(
          playlistUrl: widget.playlistToDelete.url,
          playlistQuality:
              _isChecked ? PlaylistQuality.music : PlaylistQuality.voice,
        );
      }
    }
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
