import 'package:flutter/material.dart';

/// The AppBarApplicationLeadingIconMenuWidget is used to display the
/// leading icon of the AppBar. When the icon is clicked, a menu is
/// displayed. Curently, the menu is not used.
class AppBarLeadingIconMenuWidget extends StatelessWidget {
  const AppBarLeadingIconMenuWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu),
      onPressed: () {
        // currently not used
        showMenu(
          context: context,
          position: const RelativeRect.fromLTRB(0, 50, 0, 0),
          items: [
            const PopupMenuItem<String>(
              key: Key('leadingMenuOption1'),
              value: 'option1',
              child: Text('Option 1'),
            ),
            const PopupMenuItem<String>(
              key: Key('leadingMenuOption2'),
              value: 'option2',
              child: Text('Option 2'),
            ),
          ],
          elevation: 8,
        ).then((value) {
          if (value != null) {
            print('Selected: $value');
            // Handle menu item selection here
          }
        });
      },
    );
  }
}
