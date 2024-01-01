import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

import '../constants.dart';
import '../services/settings_data_service.dart';
import '../utils/dir_util.dart';
import '../viewmodels/audio_player_vm.dart';
import '../viewmodels/theme_provider_vm.dart';

enum MultipleIconType { iconOne, iconTwo, iconThree }

// This global variable is initialized when instanciating the
// unique AudioGlobalPlayerVM instance. The reason why this
// variable is global is that it is used in the
// onPageChangedFunction which is set to the PageView widget
// responsible for handling screen dragging. It would not be
// possible to pass the AudioGlobalPlayerVM instance to the
// PageView widget since the onPageChangedFunction must have
// only an int parameter.
late AudioPlayerVM globalAudioGlobalPlayerVM;

mixin ScreenMixin {
  final MaterialStateProperty<RoundedRectangleBorder>
      appElevatedButtonRoundedShape =
      MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(kRoundedButtonBorderRadius),
  ));

  static const double CHECKBOX_WIDTH_HEIGHT = 20.0;
  static const int PLAYLIST_DOWNLOAD_VIEW_DRAGGABLE_INDEX = 0;
  static const int AUDIO_PLAYER_VIEW_DRAGGABLE_INDEX = 1;
  static const int MEDIA_PLAYER_VIEW_DRAGGABLE_INDEX = 2;

  static const double screenIconSizeLightTheme = 30.0;
  static const double screenIconSizeDarkTheme = 29.0;

  // Defining custom icon themes for light theme
  final IconThemeData activeScreenIconLightTheme = const IconThemeData(
    color: kSliderThumbColorInLightMode,
    size: screenIconSizeLightTheme,
  );
  final IconThemeData inactiveScreenIconLightTheme = const IconThemeData(
    color: Colors.grey,
    size: screenIconSizeLightTheme,
  );

  // Defining custom icon themes for dark theme
  final IconThemeData activeScreenIconDarkTheme = const IconThemeData(
    color: kSliderThumbColorInDarkMode,
    size: screenIconSizeDarkTheme,
  );
  final IconThemeData inactiveScreenIconDarkTheme = const IconThemeData(
    color: Colors.grey,
    size: screenIconSizeDarkTheme,
  );

  static ThemeData themeDataDark = ThemeData.dark().copyWith(
    colorScheme: ThemeData.dark().colorScheme.copyWith(
          background: Colors.black,
          surface: Colors.black,
        ),
    primaryColor: Colors.black,
    scaffoldBackgroundColor: Colors.black,
    iconTheme: ThemeData.dark().iconTheme.copyWith(
          color: kDarkAndLightIconColor, // Set icon color in dark mode
        ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kButtonColor, // Set button color in dark mode
        foregroundColor: Colors.white, // Set button text color in dark mode
      ),
    ),
    // WARNING: The following code does not work: all TextButton are
    // replaced by ElevatedButton. This is a bug in Flutter.
    // textButtonTheme: TextButtonThemeData(
    //   style: TextButton.styleFrom(
    //     backgroundColor: kButtonColor, // Set button color in dark mode
    //     foregroundColor: Colors.white, // Set button text color in dark mode
    //   ),
    // ),
    textTheme: ThemeData.dark().textTheme.copyWith(
          bodyMedium: ThemeData.dark()
              .textTheme
              .bodyMedium!
              .copyWith(color: Colors.white),
          titleMedium: ThemeData.dark()
              .textTheme
              .titleMedium!
              .copyWith(color: Colors.white),
        ),
    checkboxTheme: ThemeData.dark().checkboxTheme.copyWith(
          checkColor: MaterialStateProperty.all(
            Colors.white, // Set Checkbox fill color
          ),
          fillColor: MaterialStateProperty.all(
            kDarkAndLightIconColor, // Set Checkbox check color
          ),
        ),
    // determines the background color and border of
    // TextField
    inputDecorationTheme: const InputDecorationTheme(
      // fillColor: Colors.grey[900],
      fillColor: Colors.black,
      filled: true,
      border: OutlineInputBorder(),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Colors.white,
      selectionColor: Colors.white.withOpacity(0.3),
      selectionHandleColor: Colors.white.withOpacity(0.5),
    ),
  );

  static ThemeData themeDataLight = ThemeData.light().copyWith(
    colorScheme: ThemeData.light().colorScheme.copyWith(
          background: Colors.white,
          surface: Colors.white,
        ),
    primaryColor: Colors.white,
    scaffoldBackgroundColor: Colors.white,
    iconTheme: ThemeData.light().iconTheme.copyWith(
          color: kDarkAndLightIconColor, // Set icon color in light mode
        ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kButtonColor, // Set button color in light mode
        foregroundColor: Colors.white, // Set button text color in light mode
      ),
    ),
    // WARNING: The following code does not work: all TextButton are
    // replaced by ElevatedButton. This is a bug in Flutter.
    // textButtonTheme: TextButtonThemeData(
    //   style: TextButton.styleFrom(
    //     backgroundColor: kButtonColor, // Set button color in light mode
    //     foregroundColor: Colors.white, // Set button text color in light mode
    //   ),
    // ),
    textTheme: ThemeData.light().textTheme.copyWith(
          bodyMedium: ThemeData.light()
              .textTheme
              .bodyMedium!
              .copyWith(color: kButtonColor),
          titleMedium: ThemeData.light()
              .textTheme
              .titleMedium!
              .copyWith(color: Colors.black),
        ),
    checkboxTheme: ThemeData.light().checkboxTheme.copyWith(
          checkColor: MaterialStateProperty.all(
            Colors.white, // Set Checkbox fill color
          ),
          fillColor: MaterialStateProperty.all(
            kDarkAndLightIconColor, // Set Checkbox check color
          ),
        ),
    // determines the background color and border of
    // TextField
    inputDecorationTheme: const InputDecorationTheme(
      // fillColor: Colors.grey[900],
      fillColor: Colors.white,
      filled: true,
      border: OutlineInputBorder(),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Colors.black,
      selectionColor: Colors.grey.withOpacity(0.3),
      selectionHandleColor: Colors.grey.withOpacity(0.5),
    ),
    // is required so that the icon color of the
    // ListTile items are correct. In dark mode, this
    // is specification is not required, I don't know why.
    listTileTheme: ThemeData.light().listTileTheme.copyWith(
          iconColor: kDarkAndLightIconColor, // Set icon color in light mode
        ),
    // Add any other customizations for light mode
  );

  /// Returns the icon theme data based on the theme currently applyed
  /// and the [MultipleIconType] enum value passed as parameter.
  ///
  /// The IconThemeData is used to wrap the icon widget.
  ///
  /// Example for the icon button:
  ///
  /// IconButton(
  ///   onPressed: () {
  ///   },
  ///   icon: IconTheme(
  ///     data: getIconThemeData(
  ///             themeProviderVM: themeProvider,
  ///             iconType: MultipleIconType.iconTwo,
  ///           ),
  ///     child: const Icon(Icons.download_outline, size: 35),
  ///   ),
  /// ),
  IconThemeData getIconThemeData({
    required ThemeProviderVM themeProviderVM,
    required MultipleIconType iconType,
  }) {
    switch (iconType) {
      case MultipleIconType.iconOne:
        return themeProviderVM.currentTheme == AppTheme.dark
            ? activeScreenIconDarkTheme
            : activeScreenIconLightTheme;
      case MultipleIconType.iconTwo:
        return themeProviderVM.currentTheme == AppTheme.dark
            ? inactiveScreenIconDarkTheme
            : inactiveScreenIconLightTheme;
      default:
        ThemeData currentTheme = themeProviderVM.currentTheme == AppTheme.dark
            ? themeDataDark
            : themeDataLight;
        return currentTheme.iconTheme; // Default icon theme
    }
  }

  /// Lightens a color by a given percentage [0-1]
  static Color lighten(Color color, double amount) {
    assert(amount >= 0 && amount <= 1, 'Amount should be between 0 and 1');
    int r = color.red + ((255 - color.red) * amount).toInt();
    int g = color.green + ((255 - color.green) * amount).toInt();
    int b = color.blue + ((255 - color.blue) * amount).toInt();
    return Color.fromARGB(color.alpha, r, g, b);
  }

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
    Key? titleTextWidgetKey, // key set to the Text widget displaying the title
    required BuildContext context,
    required String commentStr,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            child: Text(
              key: titleTextWidgetKey,
              commentStr,
              style: kDialogTextFieldStyle,
            ),
            onTap: () {
              Clipboard.setData(
                ClipboardData(text: commentStr),
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
    bool isTextBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isTextBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              child: Text(
                key: valueTextWidgetKey,
                value,
                style: TextStyle(
                  fontWeight: isTextBold ? FontWeight.bold : FontWeight.normal,
                ),
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
    required TextEditingController controller,
    FocusNode? textFieldFocusNode,
  }) {
    // Set the cursor position at the start of the TextField
    controller.value = controller.value.copyWith(
      selection: const TextSelection.collapsed(offset: 0),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label),
          ),
          Expanded(
            child: TextField(
              key: valueTextFieldWidgetKey,
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.all(8),
              ),
              focusNode: textFieldFocusNode,
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

  void writeToLogFile({
    required String message,
  }) {
    String filePathName =
        '${DirUtil.getPlaylistDownloadHomePath()}${Platform.pathSeparator}audio_learn_app_log.txt';
    if (File(filePathName).existsSync()) {
      // Append the new line to the existing content
      File(filePathName).writeAsStringSync(
        '${DateTime.now().toString()} $message\n',
        mode: FileMode.append,
      );
    } else {
      // Create the file
      File(filePathName).writeAsStringSync(
        '${DateTime.now().toString()} $message\n',
        mode: FileMode.write,
      );
    }
  }
}
