import 'package:audio_learn/utils/time_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../constants.dart';
import '../../models/playlist.dart';
import '../screen_mixin.dart';

class PlaylistInfoDialogWidget extends StatelessWidget with ScreenMixin {
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
        title: Text(AppLocalizations.of(context)!.playlistInfoDialogTitle),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              createInfoRowFunction(
                  context: context,
                  label: AppLocalizations.of(context)!.playlistTitleLabel,
                  value: playlist.title),
              createInfoRowFunction(
                  context: context,
                  label: AppLocalizations.of(context)!.playlistTypeLabel,
                  value: (playlist.playlistType == PlaylistType.local)
                      ? AppLocalizations.of(context)!.playlistTypeLocal
                      : AppLocalizations.of(context)!.playlistTypeYoutube),
              createInfoRowFunction(
                  context: context,
                  label: AppLocalizations.of(context)!.playlistIdLabel,
                  value: playlist.id),
              createInfoRowFunction(
                  context: context,
                  label: AppLocalizations.of(context)!.playlistUrlLabel,
                  value: playlist.url),
              createInfoRowFunction(
                  context: context,
                  label:
                      AppLocalizations.of(context)!.playlistDownloadPathLabel,
                  value: playlist.downloadPath),
              createInfoRowFunction(
                  context: context,
                  label: AppLocalizations.of(context)!
                      .playlistLastDownloadDateTimeLabel,
                  value: lastDownloadDateTimeStr),
              createInfoRowFunction(
                  context: context,
                  label: AppLocalizations.of(context)!.playlistQualityLabel,
                  value: (playlist.playlistQuality == PlaylistQuality.music)
                      ? AppLocalizations.of(context)!.playlistQualityMusic
                      : AppLocalizations.of(context)!.playlistQualityVoice),
              createInfoRowFunction(
                  context: context,
                  label: AppLocalizations.of(context)!.playlistIsSelectedLabel,
                  value: (playlist.isSelected)
                      ? AppLocalizations.of(context)!.yes
                      : AppLocalizations.of(context)!.no),
              createInfoRowFunction(
                  context: context,
                  label: AppLocalizations.of(context)!
                      .playlistTotalAudioNumberLabel,
                  value: playlist.downloadedAudioLst.length.toString()),
              createInfoRowFunction(
                  context: context,
                  label: AppLocalizations.of(context)!
                      .playlistPlayableAudioNumberLabel,
                  value: playlist.playableAudioLst.length.toString()),
              createInfoRowFunction(
                  context: context,
                  label: AppLocalizations.of(context)!
                      .playlistPlayableAudioTotalDurationLabel,
                  value: playlist.getPlayableAudioLstTotalDuration().HHmmss()),
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
}
