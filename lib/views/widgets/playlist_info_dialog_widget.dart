import 'package:audio_learn/utils/time_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../constants.dart';
import '../../models/playlist.dart';
import '../../utils/ui_util.dart';

class PlaylistInfoDialogWidget extends StatelessWidget {
  final Playlist playlist;
  final FocusNode focusNode;

  const PlaylistInfoDialogWidget({
    required this.playlist,
    required this.focusNode,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime? lastDownloadDateTime = playlist.getLastDownloadDateTime();
    String lastDownloadDateTimeStr = (lastDownloadDateTime != null)
        ? frenchDateTimeFormat.format(lastDownloadDateTime)
        : '';
    return RawKeyboardListener(
      // Enables to close the dialog with the keyboard
      focusNode: focusNode,
      onKey: (event) {
        if (event.isKeyPressed(LogicalKeyboardKey.enter) ||
            event.isKeyPressed(LogicalKeyboardKey.numpadEnter)) {
          Navigator.of(context).pop();
        }
      },
      child: AlertDialog(
        title: Text(AppLocalizations.of(context)!.playlistInfoDialogTitle),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              infoRow(context, AppLocalizations.of(context)!.playlistTitleLabel,
                  playlist.title),
              infoRow(context, AppLocalizations.of(context)!.playlistIdLabel,
                  playlist.id),
              infoRow(context, AppLocalizations.of(context)!.playlistUrlLabel,
                  playlist.url),
              infoRow(
                  context,
                  AppLocalizations.of(context)!.playlistDownloadPathLabel,
                  playlist.downloadPath),
              infoRow(
                  context,
                  AppLocalizations.of(context)!
                      .playlistLastDownloadDateTimeLabel,
                  lastDownloadDateTimeStr),
              infoRow(
                  context,
                  AppLocalizations.of(context)!.playlistIsSelectedLabel,
                  (playlist.isSelected)
                      ? AppLocalizations.of(context)!.yes
                      : AppLocalizations.of(context)!.no),
              infoRow(
                  context,
                  AppLocalizations.of(context)!.playlistTotalAudioNumberLabel,
                  playlist.downloadedAudioLst.length.toString()),
              infoRow(
                  context,
                  AppLocalizations.of(context)!
                      .playlistPlayableAudioNumberLabel,
                  playlist.playableAudioLst.length.toString()),
              infoRow(
                  context,
                  AppLocalizations.of(context)!
                      .playlistPlayableAudioTotalDurationLabel,
                  playlist.getPlayableAudioLstTotalDuration().HHmmss()),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(AppLocalizations.of(context)!.audioInfoDialogOk),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget infoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label),
          ),
          Expanded(
            child: InkWell(
              child: Text(value),
              onTap: () {
                Clipboard.setData(
                  ClipboardData(text: value),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
