import 'package:audio_learn/utils/time_util.dart';
import 'package:audio_learn/views/screen_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../constants.dart';
import '../../models/audio.dart';
import '../../utils/ui_util.dart';

class AudioInfoDialogWidget extends StatelessWidget with ScreenMixin {
  final Audio audio;
  final FocusNode focusNode;

  const AudioInfoDialogWidget({
    required this.audio,
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
        title: Text(AppLocalizations.of(context)!.audioInfoDialogTitle),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              createInfoRowFunction(
                  context: context,
                  label: AppLocalizations.of(context)!.originalVideoTitleLabel,
                  value: audio.originalVideoTitle),
              createInfoRowFunction(
                  context: context,
                  label: AppLocalizations.of(context)!.compactVideoDescription,
                  value: audio.compactVideoDescription),
              createInfoRowFunction(
                  context: context,
                  label: AppLocalizations.of(context)!.validVideoTitleLabel,
                  value: audio.validVideoTitle),
              createInfoRowFunction(
                  context: context,
                  label: AppLocalizations.of(context)!.videoUrlLabel,
                  value: audio.videoUrl),
              createInfoRowFunction(
                  context: context,
                  label:
                      AppLocalizations.of(context)!.audioDownloadDateTimeLabel,
                  value:
                      frenchDateTimeFormat.format(audio.audioDownloadDateTime)),
              createInfoRowFunction(
                  context: context,
                  label:
                      AppLocalizations.of(context)!.audioDownloadDurationLabel,
                  value: audio.audioDownloadDuration!.HHmmss()),
              createInfoRowFunction(
                  context: context,
                  label: AppLocalizations.of(context)!.audioDownloadSpeedLabel,
                  value: formatDownloadSpeed(
                    context: context,
                    audio: audio,
                  )),
              createInfoRowFunction(
                  context: context,
                  label: AppLocalizations.of(context)!.videoUploadDateLabel,
                  value: frenchDateFormat.format(audio.videoUploadDate)),
              createInfoRowFunction(
                  context: context,
                  label: AppLocalizations.of(context)!.audioDurationLabel,
                  value: audio.audioDuration!.HHmmss()),
              createInfoRowFunction(
                  context: context,
                  label: AppLocalizations.of(context)!.audioFileNameLabel,
                  value: audio.audioFileName),
              createInfoRowFunction(
                  context: context,
                  label: AppLocalizations.of(context)!.audioFileSizeLabel,
                  value: UiUtil.formatLargeIntValue(
                    context: context,
                    value: audio.audioFileSize,
                  )),
              createInfoRowFunction(
                  context: context,
                  label: AppLocalizations.of(context)!.isMusicQualityLabel,
                  value: (audio.isMusicQuality)
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
}
