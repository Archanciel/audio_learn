import 'package:audio_learn/services/settings_data_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../viewmodels/theme_provider_vm.dart';
import 'application_settings_dialog_widget.dart';

enum AppBarPopupMenu {
  openSettingsDialog,
  option2,
}

/// The AppBarLeadingPopupMenuWidget is used to display the leading
/// popup menu icon of the AppBar. The displayed items are specific
/// to the currently displayed screen.
class AppBarLeadingPopupMenuWidget extends StatelessWidget {
  final ThemeProviderVM themeProvider;
  final SettingsDataService settingsDataService;

  const AppBarLeadingPopupMenuWidget({
    super.key,
    required this.themeProvider,
    required this.settingsDataService,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AppBarPopupMenu>(
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem<AppBarPopupMenu>(
            key: const Key('appBarMenuOpenSettingsDialog'),
            value: AppBarPopupMenu.openSettingsDialog,
            child: Text(AppLocalizations.of(context)!.appBarMenuOpenSettingsDialog),
          ),
        ];
      },
      icon: const Icon(Icons.menu),
      onSelected: (AppBarPopupMenu value) {
        switch (value) {
          case AppBarPopupMenu.openSettingsDialog:
                  // Using FocusNode to enable clicking on Enter to close
                  // the dialog
                  final FocusNode focusNode = FocusNode();
                  showDialog<void>(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return ApplicationSettingsDialogWidget(
                        settingsDataService: settingsDataService,
                        focusNode: focusNode,
                      );
                    },
                  );
                  // required so that clicking on Enter to close the dialog
                  // works. This intruction must be located after the
                  // .then() method of the showDialog() method !
                  focusNode.requestFocus();
            break;
          default:
            break;
        }
      },
    );
  }
}
