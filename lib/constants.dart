import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum PlaylistPopupMenuButton {
  defineSortFilterAudiosSettings,
  saveSortFilterAudiosSettingsToPlaylist,
  updatePlaylistJson,
  updateAppPlaylistsList,
}

const String kApplicationName = "Audio Learn";
const String kApplicationVersion = '0.9.1';
const String kDownloadAppDir = '/storage/emulated/0/Download/audiolear';
const String kDownloadAppTestDir =
    '/storage/emulated/0/Download/test/audiolear';
const String kSettingsFileName = 'settings.json';
// not working: getDownloadedAudioNameLst() returns empty list !
//const String kDownloadAppDir = '/storage/9016-4EF8/Audio';

const String kDownloadAppDirWindows =
    // 'C:\\Users\\Jean-Pierre\\Downloads\\Audio';
    // 'C:\\Users\\Jean-Pierre\\Downloads\\copy_move_audio_integr_test_data';
    "C:\\Users\\Jean-Pierre\\Development\\Flutter\\audio_learn\\test\\data\\audio";

// Tests are run on Windows only. Files in this local test dir are stored in project test_data dir updated
// on GitHub
const String kDownloadAppTestSavedDataDir =
    "C:\\Users\\Jean-Pierre\\Development\\Flutter\\audio_learn\\test\\data\\saved";

// files in this local test dir are stored in project test_data dir updated
// on GitHub
const String kDownloadAppTestDirWindows =
    "C:\\Users\\Jean-Pierre\\Development\\Flutter\\audio_learn\\test\\data\\audio";

const String kTranslationFileDirWindows =
    "C:\\Users\\Jean-Pierre\\Development\\Flutter\\audio_learn\\lib\\l10n";

// this constant enables to download a playlist in the emulator in which
// pasting a URL is not possible. The constant is used in
// _ExpandablePlaylistListViewState.initState().
// const String kPastedPlaylistUrl =
//     'https://youtube.com/playlist?list=PLzwWSJNcZTMSOMooR_y9PtJlJLpEKWbAv&si=LJ7w9Ms_ymqwJdT';

// usefull to delete all files in the audio dir of the emulator
const bool kDeleteAppDir = false;

const double kAudioDefaultPlaySpeed = 1.25;

const String kSecretClientCodeJsonFileName =
    'code_secret_client_923487935936-po8d733kjvrnee3l3ik3r5mebe8ebhr7.apps.googleusercontent.com.json';

const String kGoogleApiKey = 'AIzaSyDhywmh5EKopsNsaszzMkLJ719aQa2NHBw';

/// A constant that is true if the application was compiled to run on
/// the web. Its value determines if requesting storage permission must
/// be performed.
const bool kIsWeb = bool.fromEnvironment('dart.library.js_util');

const double kRowSmallWidthSeparator = 3.0;
const double kRowButtonGroupWidthSeparator = 30.0;
const double kUpDownButtonSize = 50.0;
const double kGreaterButtonWidth = 78.0;
const double kNormalButtonWidth = 75.0;
const double kSmallButtonWidth = 48.0;
const double kSmallestButtonWidth = 40.0;
const double kSmallButtonInsidePadding = 3.0;
const double kDefaultMargin = 5.0;
const double kRoundedButtonBorderRadius = 11.0;
const Color kDarkAndLightIconColor =
    Color.fromARGB(246, 44, 61, 255); // rgba(44, 61, 246, 255)
final Color kDarkAndLightDisabledIconColorOnDialog = Colors.grey.shade600;
const Color kButtonColor = Color(0xFF3D3EC2);
const Color kScreenButtonColor = kSliderThumbColorInDarkMode;
const double kAudioDefaultPlayVolume = 0.5;

DateFormat englishDateTimeFormat = DateFormat("yyyy-MM-dd HH:mm");
DateFormat frenchDateTimeFormat = DateFormat("dd-MM-yyyy HH:mm");
DateFormat englishDateFormat = DateFormat("yyyy-MM-dd");
DateFormat frenchDateFormat = DateFormat("dd-MM-yyyy");

const TextStyle kDialogTitlesStyle = TextStyle(
  fontSize: 17,
  fontWeight: FontWeight.bold,
);

const TextStyle kDialogLabelStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.bold,
);

const TextStyle kDialogTextFieldStyle = TextStyle(
  fontSize: 13,
);

const double kDialogTextFieldHeight = 32.0;

const String kYoutubeUrl = 'https://www.youtube.com/';

// true makes sense if audios are played in
// Smart AudioBook app
const bool kAudioFileNamePrefixIncludeTime = true;

const kPositionButtonTextStyle = TextStyle(
  // the color is the one defined in textTheme bodyMedium
  // specified in the ScreenMixin theme's
  fontSize: 17.0,
  color: kButtonColor,
);

const Color kSliderThumbColorInDarkMode = Color(0xffd0bcff);
const Color kSliderThumbColorInLightMode = Color(0xff6750a4);

const double kTextButtonFontSize = 18.0;
const double kTextButtonSmallerFontSize = 16.0;

const kTextButtonStyleDarkMode = TextStyle(
  // the color is the one defined in textTheme bodyMedium
  // specified in the ScreenMixin theme's
  fontSize: kTextButtonFontSize,
  color: kSliderThumbColorInDarkMode,
);

const kTextButtonStyleLightMode = TextStyle(
  // the color is the one defined in textTheme bodyMedium
  // specified in the ScreenMixin theme's
  fontSize: kTextButtonFontSize,
  color: kSliderThumbColorInLightMode,
);

const kTextButtonSmallStyleDarkMode = TextStyle(
  // the color is the one defined in textTheme bodyMedium
  // specified in the ScreenMixin theme's
  fontSize: kTextButtonSmallerFontSize,
  color: kSliderThumbColorInDarkMode,
);

const kTextButtonSmallStyleLightMode = TextStyle(
  // the color is the one defined in textTheme bodyMedium
  // specified in the ScreenMixin theme's
  fontSize: kTextButtonSmallerFontSize,
  color: kSliderThumbColorInLightMode,
);

const kSliderValueTextStyle = TextStyle(
  // the color is the one defined in textTheme bodyMedium
  // specified in the ScreenMixin theme's
  fontSize: kTitleFontSize,
  color: kButtonColor,
);

const kSliderThickness = 2.0;

const double kTitleFontSize = 15.0;

const kAudioExtractorExtractPositionStyle = TextStyle(
  fontSize: 14.0,
);
