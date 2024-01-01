import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../utils/duration_expansion.dart';
import '../../views/screen_mixin.dart';
import '../../constants.dart';
import '../../models/audio.dart';
import '../../utils/ui_util.dart';

/// This dialog is used to display audio informations. It is used
/// in the AudioListItemWidget left (leading:) menu.
class AudioInfoDialogWidget extends StatelessWidget with ScreenMixin {
  final Audio audio;
  final FocusNode focusNode;

  AudioInfoDialogWidget({
    required this.audio,
    required this.focusNode,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      // Using FocusNode to enable clicking on Enter to close
      // the dialog
      focusNode: focusNode,
      onKey: (event) {
        if (event.isKeyPressed(LogicalKeyboardKey.enter) ||
            event.isKeyPressed(LogicalKeyboardKey.numpadEnter)) {
          // executing the same code as in the 'OK'
          // ElevatedButton onPressed callback
          Navigator.of(context).pop();
        }
      },
      child: AlertDialog(
        title: Text(AppLocalizations.of(context)!.audioInfoDialogTitle),
        actionsPadding:
            // reduces the top vertical space between the buttons
            // and the content
            const EdgeInsets.fromLTRB(
                10, 0, 10, 10), // Adjust the value as needed
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              createInfoRowFunction(
                  context: context,
                  label: AppLocalizations.of(context)!.originalVideoTitleLabel,
                  value: audio.originalVideoTitle),
              createInfoRowFunction(
                  context: context,
                  label: AppLocalizations.of(context)!.videoUrlLabel,
                  value: audio.videoUrl),
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
                  label: AppLocalizations.of(context)!.videoUploadDateLabel,
                  value: frenchDateFormat.format(audio.videoUploadDate)),
              createInfoRowFunction(
                  valueTextWidgetKey: const Key('enclosingPlaylistTitleKey'),
                  context: context,
                  label: AppLocalizations.of(context)!.enclosingPlaylistLabel,
                  value: (audio.enclosingPlaylist == null)
                      ? ''
                      : audio.enclosingPlaylist!.title),
              createInfoRowFunction(
                  valueTextWidgetKey: const Key('movedFromPlaylistTitleKey'),
                  context: context,
                  label: AppLocalizations.of(context)!.movedFromPlaylistLabel,
                  value: (audio.movedFromPlaylistTitle == null)
                      ? ''
                      : audio.movedFromPlaylistTitle!),
              createInfoRowFunction(
                  valueTextWidgetKey: const Key('movedToPlaylistTitleKey'),
                  context: context,
                  label: AppLocalizations.of(context)!.movedToPlaylistLabel,
                  value: (audio.movedToPlaylistTitle == null)
                      ? ''
                      : audio.movedToPlaylistTitle!),
              createInfoRowFunction(
                  valueTextWidgetKey: const Key('copiedFromPlaylistTitleKey'),
                  context: context,
                  label: AppLocalizations.of(context)!.copiedFromPlaylistLabel,
                  value: (audio.copiedFromPlaylistTitle == null)
                      ? ''
                      : audio.copiedFromPlaylistTitle!),
              createInfoRowFunction(
                  valueTextWidgetKey: const Key('copiedToPlaylistTitleKey'),
                  context: context,
                  label: AppLocalizations.of(context)!.copiedToPlaylistLabel,
                  value: (audio.copiedToPlaylistTitle == null)
                      ? ''
                      : audio.copiedToPlaylistTitle!),
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
                  label: AppLocalizations.of(context)!.audioDurationLabel,
                  value: audio.audioDuration!.HHmmss()),
              createInfoRowFunction(
                  context: context,
                  label: AppLocalizations.of(context)!.audioPositionLabel,
                  value:
                      Duration(seconds: audio.audioPositionSeconds).HHmmss()),
              createInfoRowFunction(
                  context: context,
                  label: AppLocalizations.of(context)!.audioStateLabel,
                  value: defineAudioStateStr(
                    context: context,
                    audio: audio,
                  )),
              createInfoRowFunction(
                  context: context,
                  label: AppLocalizations.of(context)!.audioPausedDateTimeLabel,
                  value: (audio.audioPausedDateTime != null)
                      ? frenchDateTimeFormat.format(audio.audioPausedDateTime!)
                      : ''),
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
              createInfoRowFunction(
                  context: context,
                  label: AppLocalizations.of(context)!.audioPlaySpeedLabel,
                  value: audio.audioPlaySpeed.toString()),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            key: const Key('audioInfoOkButtonKey'),
            child: const Text('OK'),
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

  String defineAudioStateStr({
    required BuildContext context,
    required Audio audio,
  }) {
    if (audio.audioPositionSeconds == 0) {
      return AppLocalizations.of(context)!.audioStateNotStarted;
    } else if (audio.audioPositionSeconds == audio.audioDuration!.inSeconds) {
      return AppLocalizations.of(context)!.audioStateStopped;
    } else if (audio.isPaused) {
      return AppLocalizations.of(context)!.audioStatePaused;
    } else {
      return AppLocalizations.of(context)!.audioStatePlaying;
    }
  }
}
