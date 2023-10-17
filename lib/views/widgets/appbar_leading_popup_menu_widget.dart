import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../viewmodels/theme_provider.dart';

enum AppBarPopupMenu { option1, option2 }

/// The AppBarLeadingPopupMenuWidget is used to display the leading
/// popup menu icon of the AppBar. The displayed items are specific
/// to the currently displayed screen. Curently, the menu is not used.
class AppBarLeadingPopupMenuWidget extends StatelessWidget {
  const AppBarLeadingPopupMenuWidget({
    super.key,
    required this.themeProvider,
  });

  final ThemeProvider themeProvider;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AppBarPopupMenu>(
      onSelected: (AppBarPopupMenu value) {
        switch (value) {
          case AppBarPopupMenu.option1:
            print('option1');
            break;
          case AppBarPopupMenu.option2:
            print('option2');
            break;
          default:
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem<AppBarPopupMenu>(
            key: const Key('appBarMenuOption1'),
            value: AppBarPopupMenu.option1,
            child: Text(AppLocalizations.of(context)!
                .translate(AppLocalizations.of(context)!.option1)),
          ),
          PopupMenuItem<AppBarPopupMenu>(
            key: const Key('appBarMenuOption1'),
            value: AppBarPopupMenu.option2,
            child: Text(AppLocalizations.of(context)!
                .translate(AppLocalizations.of(context)!.option2)),
          ),
        ];
      },
    );
  }
}
