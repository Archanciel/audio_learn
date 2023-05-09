import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../constants.dart';
import '../viewmodels/warning_message_vm.dart';

class ScreenMixin {
  Future<void> openUrlInExternalApp({
    required String url,
  }) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not launch $kYoutubeUrl';
    }
  }

  /// Located in ScreenMixin in order to be usable in any screen.
  void displayWarningDialog({
    required BuildContext context,
    required String message,
    required WarningMessageVM warningMessageVM,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.warning),
        content: Text(
          message,
          style: kDialogTextFieldStyle,
        ),
        actions: [
          TextButton(
            child: const Text('Ok'),
            onPressed: () {
              warningMessageVM.warningMessageType = WarningMessageType.none;
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
