import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/audio.dart';

class AudioInfoDialog extends StatelessWidget {
  final Audio audio;

  const AudioInfoDialog({required this.audio, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.audioInfoDialogTitle),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            infoRow(context, AppLocalizations.of(context)!.originalVideoTitleLabel, audio.originalVideoTitle),
            infoRow(context, AppLocalizations.of(context)!.validVideoTitleLabel, audio.validVideoTitle),
            infoRow(context, AppLocalizations.of(context)!.videoUrlLabel, audio.videoUrl),
            infoRow(context, AppLocalizations.of(context)!.audioDownloadDateTimeLabel, audio.audioDownloadDateTime.toString()),
            infoRow(context, AppLocalizations.of(context)!.audioDownloadDurationLabel, audio.audioDownloadDuration.toString()),
            infoRow(context, AppLocalizations.of(context)!.audioDownloadSpeedLabel, '${audio.audioDownloadSpeed} bytes/sec'),
            infoRow(context, AppLocalizations.of(context)!.videoUploadDateLabel, audio.videoUploadDate.toString()),
            infoRow(context, AppLocalizations.of(context)!.audioDurationLabel, audio.audioDuration.toString()),
            infoRow(context, AppLocalizations.of(context)!.audioFileNameLabel, audio.audioFileName),
            infoRow(context, AppLocalizations.of(context)!.audioFileSizeLabel, '${audio.audioFileSize} bytes'),
            infoRow(context, AppLocalizations.of(context)!.isMusicQualityLabel, audio.isMusicQuality.toString()),
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
    );
  }

  Widget infoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
