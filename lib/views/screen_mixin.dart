import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';

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

  Widget createTitleCommentRowFunction({
    required BuildContext context,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            child: Text(
              value,
              style: kDialogTextFieldStyle,
            ),
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

  Widget createInfoRowFunction({
    Key? valueTextWidgetKey, // key set to the Text widget displaying the value
    required BuildContext context,
    required String label,
    required String value,
  }) {
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
              child: Text(
                key: valueTextWidgetKey,
                value,
              ),
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

  Widget createEditableRowFunction({
    Key? valueTextFieldWidgetKey, // key set to the TextField widget
    // containing the value
    required BuildContext context,
    required String label,
    required String value,
    required TextEditingController controller,
    FocusNode? textFieldFocusNode,
  }) {
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
              child: TextField(
                key: valueTextFieldWidgetKey,
                controller: controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                focusNode: textFieldFocusNode,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget createCheckboxRowFunction({
    Key? checkBoxWidgetKey, // key set to the CheckBox widget
    required BuildContext context,
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(label),
          Checkbox(
            key: checkBoxWidgetKey,
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
