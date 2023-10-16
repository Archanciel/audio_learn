import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const String kApplicationName = "Audio Learn";
const String kApplicationVersion = '0.6.95';
const String kDownloadAppDir = '/storage/emulated/0/Download/audiolear';
const String kSettingsFileName = 'settings.json';
// not working: getDownloadedAudioNameLst() returns empty list !
//const String kDownloadAppDir = '/storage/9016-4EF8/Audio';

const String kDownloadAppDirWindows =
    'C:\\Users\\Jean-Pierre\\Downloads\\Audio';

// Tests are run on Windows only. Files in this local test dir are stored in project test_data dir updated
// on GitHub
const String kDownloadAppTestDir =
    "C:\\Users\\Jean-Pierre\\Development\\Flutter\\audio_learn\\test\\data\\audio";
const String kDownloadAppTestSavedDataDir =
    "C:\\Users\\Jean-Pierre\\Development\\Flutter\\audio_learn\\test\\data\\saved";

// files in this local test dir are stored in project test_data dir updated
// on GitHub
const String kDownloadAppTestDirWindows =
    "C:\\Users\\Jean-Pierre\\Development\\Flutter\\audio_learn\\test\\data\\audio";

// this constant enables to download a playlist in the emulator in which
// pasting a URL is not possible. The constant is used in
// _ExpandablePlaylistListViewState.initState().
// const String kPastedPlaylistUrl =
//     'https://youtube.com/playlist?list=PLzwWSJNcZTMSOMooR_y9PtJlJLpEKWbAv&si=LJ7w9Ms_ymqwJdT';

// usefull to delete all files in the audio dir of the emulator
const bool kDeleteAppDir = false;

const double kAudioDefaultSpeed = 1.0;

const String kSecretClientCodeJsonFileName =
    'code_secret_client_923487935936-po8d733kjvrnee3l3ik3r5mebe8ebhr7.apps.googleusercontent.com.json';

const String kGoogleApiKey = 'AIzaSyDhywmh5EKopsNsaszzMkLJ719aQa2NHBw';

/// A constant that is true if the application was compiled to run on
/// the web. Its value determines if requesting storage permission must
/// be performed.
const bool kIsWeb = bool.fromEnvironment('dart.library.js_util');

const double kVerticalFieldDistance = 23.0;
const double kVerticalFieldDistanceAddSubScreen = 1.0;
const double kResetButtonBottomDistance = 5.0;
const double kRowWidthSeparator = 3.0;
const double kRowHeightSeparator = 3.0;
const double kSmallestButtonWidth = 40.0;
const double kSmallButtonWidth = 48.0;
const double kSmallButtonInsidePadding = 3.0;
const double kDefaultMargin = 15.0;
const kFlushbarEdgeInsets = EdgeInsets.fromLTRB(15, 78, 15, 0);
const double kRoundedButtonBorderRadius = 11.0;
const Color kIconColor =
    Color.fromARGB(246, 44, 61, 255); // rgba(44, 61, 246, 255)
const Color kButtonColor = Color(0xFF3D3EC2);

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
