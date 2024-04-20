import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../views/screen_mixin.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/theme_provider_vm.dart';

class ConfirmActionDialogWidget extends StatefulWidget {
  final Function actionFunction; // The action to execute on confirmation
  final List<dynamic> actionFunctionArgs; // Arguments for the action function
  final String dialogTitle; // Title of the dialog
  final String dialogContent; // Content of the dialog
  final FocusNode focusNode;
  final Function? warningFunction; // The action to execute on confirmation
  final List<dynamic> warningFunctionArgs; // Arguments for the action function

  const ConfirmActionDialogWidget({
    required this.actionFunction,
    required this.actionFunctionArgs,
    required this.dialogTitle,
    required this.dialogContent,
    required this.focusNode,
    this.warningFunction,
    this.warningFunctionArgs = const [],
    super.key,
  });

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
            Function.apply(widget.actionFunction,
                widget.actionFunctionArgs); // Execute the action with arguments
            Navigator.of(context).pop();
          }
        }
      },
      child: AlertDialog(
        title: Text(
          widget.dialogTitle,
          key: const Key('confirmDialogTitleKey'),
        ),
        content: Text(widget.dialogContent),
        actions: <Widget>[
          TextButton(
            key: const Key('confirmButtonKey'),
            onPressed: () {
               // Execute the action function with arguments
              Function.apply(widget.actionFunction, widget.actionFunctionArgs);

              if (widget.warningFunction != null) {
                // If the warning function was passed, execute it with
                // arguments
                Function.apply(
                    widget.warningFunction!, widget.warningFunctionArgs);
              }

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
            key: const Key('cancelButtonKey'),
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
}
