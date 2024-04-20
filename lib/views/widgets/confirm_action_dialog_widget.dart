import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../views/screen_mixin.dart';
import '../../models/audio.dart';
import '../../models/playlist.dart';
import '../../services/settings_data_service.dart';
import '../../utils/ui_util.dart';
import '../../viewmodels/playlist_list_vm.dart';
import '../../viewmodels/theme_provider_vm.dart';

class ConfirmActionDialogWidget extends StatefulWidget {
  final Function action; // The action to execute on confirmation
  final List<dynamic> actionArgs; // Arguments for the action function
  final String dialogTitle; // Title of the dialog
  final String dialogContent; // Content of the dialog
  final FocusNode focusNode;

  const ConfirmActionDialogWidget({
    required this.action,
    required this.actionArgs,
    required this.dialogTitle,
    required this.dialogContent,
    required this.focusNode,
    Key? key,
  }) : super(key: key);

  @override
  State<ConfirmActionDialogWidget> createState() =>
      _ConfirmActionDialogWidgetState();
}

class _ConfirmActionDialogWidgetState extends State<ConfirmActionDialogWidget>
    with ScreenMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeProviderVM themeProviderVM = Provider.of<ThemeProviderVM>(context);

    return KeyboardListener(
      // Using FocusNode to enable clicking on Enter to close
      // the dialog
      focusNode: widget.focusNode,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.numpadEnter) {
            // executing the same code as in the 'Delete'
            // TextButton onPressed callback
            Function.apply(widget.action,
                widget.actionArgs); // Execute the action with arguments
            Navigator.of(context).pop();
          }
        }
      },
      child: AlertDialog(
        title: Text(widget.dialogTitle),
        content: Text(widget.dialogContent),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Function.apply(widget.action,
                  widget.actionArgs); // Execute the action with arguments
              Navigator.of(context).pop();
            },
            child: Text(
              AppLocalizations.of(context)!.confirmButton,
              style: (themeProviderVM.currentTheme == AppTheme.dark)
                  ? kTextButtonStyleDarkMode
                  : kTextButtonStyleLightMode,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Cancel the action
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: (themeProviderVM.currentTheme == AppTheme.dark)
                  ? kTextButtonStyleDarkMode
                  : kTextButtonStyleLightMode,
            ),
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
