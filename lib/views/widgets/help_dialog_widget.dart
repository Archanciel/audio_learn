import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../models/help_item.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/theme_provider_vm.dart';
import '../screen_mixin.dart';

class HelpDialog extends StatelessWidget with ScreenMixin {
  final List<HelpItem> helpItems;

  HelpDialog({
    super.key,
    required this.helpItems,
  });

  @override
  Widget build(BuildContext context) {
    ThemeProviderVM themeProviderVM = Provider.of<ThemeProviderVM>(context);

    int number = 1;
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.helpDialogTitle),
      actionsPadding: kDialogActionsPadding,
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            for (var item in helpItems) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        "${number++}. ${item.titleLocalKey}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(item.contentLocalKey),
              ),
            ],
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          key: const Key('audioInfoOkButtonKey'),
          child: Text(
            AppLocalizations.of(context)!.closeTextButton,
            style: (themeProviderVM.currentTheme == AppTheme.dark)
                ? kTextButtonStyleDarkMode
                : kTextButtonStyleLightMode,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
