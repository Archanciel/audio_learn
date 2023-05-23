import 'package:audio_learn/views/screen_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../models/audio.dart';
import '../../utils/ui_util.dart';
import '../../viewmodels/expandable_playlist_list_vm.dart';

class AddPlaylistDialogWidget extends StatelessWidget with ScreenMixin {
  final String playlistUrl;
  final FocusNode focusNode;

  const AddPlaylistDialogWidget({
    required this.playlistUrl,
    required this.focusNode,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      // Using FocusNode to enable clicking on Enter to close
      // the dialog
      focusNode: focusNode,
      onKey: (event) {
        if (event.isKeyPressed(LogicalKeyboardKey.enter) ||
            event.isKeyPressed(LogicalKeyboardKey.numpadEnter)) {
          Navigator.of(context).pop();
        }
      },
      child: AlertDialog(
        title: Text(AppLocalizations.of(context)!.addPlaylistDialogTitle),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              titleCommentRow(
                  context,
                  AppLocalizations.of(context)!.addPlaylistDialogComment,
                  ''),
              infoRow(
                  context,
                  AppLocalizations.of(context)!.youtubePlaylistUrlLabel,
                  playlistUrl),
              infoRow(
                  context,
                  AppLocalizations.of(context)!.localPlaylistTitleLabel,
                  ''),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (playlistUrl.isNotEmpty) {
                ExpandablePlaylistListVM expandablePlaylistListVM =
                    Provider.of<ExpandablePlaylistListVM>(context,
                        listen: false);
                expandablePlaylistListVM.addPlaylist(playlistUrl: playlistUrl);
              }
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.apply),
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
