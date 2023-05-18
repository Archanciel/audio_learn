import 'package:audio_learn/utils/time_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../constants.dart';
import '../../models/audio.dart';
import '../../utils/ui_util.dart';

class AudioInfoDialog extends StatelessWidget {
  final Audio audio;
  final FocusNode focusNode;

  const AudioInfoDialog({
    required this.audio,
    required this.focusNode,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        title: Text(AppLocalizations.of(context)!.audioInfoDialogTitle),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              infoRow(
                  context,
                  AppLocalizations.of(context)!.originalVideoTitleLabel,
                  audio.originalVideoTitle),
              infoRow(
                  context,
                  AppLocalizations.of(context)!.compactVideoDescription,
                  audio.compactVideoDescription),
              infoRow(
                  context,
                  AppLocalizations.of(context)!.validVideoTitleLabel,
                  audio.validVideoTitle),
              infoRow(context, AppLocalizations.of(context)!.videoUrlLabel,
                  audio.videoUrl),
              infoRow(
                  context,
                  AppLocalizations.of(context)!.audioDownloadDateTimeLabel,
                  frenchDateTimeFormat.format(audio.audioDownloadDateTime)),
              infoRow(
                  context,
                  AppLocalizations.of(context)!.audioDownloadDurationLabel,
                  audio.audioDownloadDuration!.HHmmss()),
              infoRow(
                  context,
                  AppLocalizations.of(context)!.audioDownloadSpeedLabel,
                  formatDownloadSpeed(
                    context: context,
                    audio: audio,
                  )),
              infoRow(
                  context,
                  AppLocalizations.of(context)!.videoUploadDateLabel,
                  frenchDateFormat.format(audio.videoUploadDate)),
              infoRow(context, AppLocalizations.of(context)!.audioDurationLabel,
                  audio.audioDuration!.HHmmss()),
              infoRow(context, AppLocalizations.of(context)!.audioFileNameLabel,
                  audio.audioFileName),
              infoRow(
                  context,
                  AppLocalizations.of(context)!.audioFileSizeLabel,
                  UiUtil.formatLargeIntValue(
                    context: context,
                    value: audio.audioFileSize,
                  )),
              infoRow(
                  context,
                  AppLocalizations.of(context)!.isMusicQualityLabel,
                  (audio.isMusicQuality)
                      ? AppLocalizations.of(context)!.yes
                      : AppLocalizations.of(context)!.no),
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
