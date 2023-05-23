import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final focusNode = FocusNode();

    showDialog(
      context: context,
      builder: (context) => RawKeyboardListener(
        // Using FocusNode to enable clicking on Enter to close
        // the dialog
        focusNode: focusNode,
        onKey: (event) {
          if (event.isKeyPressed(LogicalKeyboardKey.enter) ||
              event.isKeyPressed(LogicalKeyboardKey.numpadEnter)) {
            warningMessageVM.warningMessageType = WarningMessageType.none;
            Navigator.of(context).pop();
          }
        },
        child: AlertDialog(
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
      ),
    );

    // To automatically focus on the dialog when it appears. If commented,
    // clicking on Enter will not close the dialog.
    focusNode.requestFocus();
  }

  Widget titleCommentRow(BuildContext context, String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          InkWell(
            child: Text(value),
            onTap: () {
              Clipboard.setData(
                ClipboardData(text: value),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget infoRow(BuildContext context, String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          InkWell(
            child: Text(value),
            onTap: () {
              Clipboard.setData(
                ClipboardData(text: value),
              );
            },
          ),
        ],
      ),
    );
  }
}
