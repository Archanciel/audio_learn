// dart file located in lib

// ignore_for_file: avoid_print

import 'dart:io';

import 'package:audio_learn/services/settings_data_service.dart';
import 'package:audio_learn/viewmodels/expandable_playlist_list_vm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:audio_learn/constants.dart';
import 'package:audio_learn/utils/dir_util.dart';
import 'package:audio_learn/viewmodels/audio_download_vm.dart';
import 'viewmodels/audio_player_vm.dart';
import 'viewmodels/language_provider.dart';
import 'viewmodels/theme_provider.dart';
import 'viewmodels/warning_message_vm.dart';
import 'views/expandable_playlist_list_view.dart';
import 'views/screen_mixin.dart';

enum AppBarPopupMenu { en, fr, about }

Future<void> main(List<String> args) async {
  List<String> myArgs = [];

  if (args.isNotEmpty) {
    myArgs = args;
  } else {
    // myArgs = ["delAppDir"]; // used to empty dir on emulator
    //                            app dir
  }

  // two methods which could not be declared async !
  //
  // Setting the TransferDataViewModel transfer data Map
  bool deleteAppDir = kDeleteAppDir;
  bool isTest = false;

  if (myArgs.isNotEmpty) {
    if (myArgs.contains("delAppDir")) {
      deleteAppDir = true;
    } else if (myArgs.contains("test")) {
      isTest = true;
    }
  }

  if (deleteAppDir) {
    await DirUtil.createAppDirIfNotExist(isAppDirToBeDeleted: true);
    print('***** $kDownloadAppDir mp3 files deleted *****');
  }

  // check if app dir exists and create it if not. This is case the first
  // time the app is run.
  String playlistDownloadHomePath =
      DirUtil.getPlaylistDownloadHomePath(isTest: isTest);
  Directory dir = Directory(playlistDownloadHomePath);

  if (!dir.existsSync()) {
    dir.createSync();
  }

  final SettingsDataService settingsDataService =
      SettingsDataService(isTest: isTest);
  settingsDataService.loadSettingsFromFile(
    jsonPathFileName:
        '$playlistDownloadHomePath${Platform.pathSeparator}$kSettingsFileName',
  );

  runApp(MainApp(
    settingsDataService: settingsDataService,
    isTest: isTest,
  ));
}

class MainApp extends StatelessWidget {
  final SettingsDataService _settingsDataService;
  final bool _isTest;

  const MainApp({
    required SettingsDataService settingsDataService,
    bool isTest = false,
    super.key,
  }) : _isTest = isTest, _settingsDataService = settingsDataService;

  @override
  Widget build(BuildContext context) {
    WarningMessageVM warningMessageVM = WarningMessageVM();
    AudioDownloadVM audioDownloadVM = AudioDownloadVM(
      warningMessageVM: warningMessageVM,
      isTest: _isTest,
    );
    ExpandablePlaylistListVM expandablePlaylistListVM =
        ExpandablePlaylistListVM(
      warningMessageVM: warningMessageVM,
      audioDownloadVM: audioDownloadVM,
      settingsDataService: _settingsDataService,
    );

    // calling getUpToDateSelectablePlaylists() loads all the
    // playlist json files from the app dir and so enables
    // expandablePlaylistListVM to know which playlists are
    // selected and which are not
    expandablePlaylistListVM.getUpToDateSelectablePlaylists();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => audioDownloadVM),
        ChangeNotifierProvider(create: (_) => AudioPlayerVM()),
        ChangeNotifierProvider(
            create: (_) => ThemeProvider(
                  appSettings: _settingsDataService,
                )),
        ChangeNotifierProvider(
            create: (_) => LanguageProvider(
                  appSettings: _settingsDataService,
                )),
        ChangeNotifierProvider(create: (_) => expandablePlaylistListVM),
        ChangeNotifierProvider(create: (_) => warningMessageVM),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, child) {
          return MaterialApp(
            title: 'AudioLearn',
            locale: languageProvider.currentLocale,
            // title: AppLocalizations.of(context)!.title,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: themeProvider.currentTheme == AppTheme.dark
                ? ThemeData.dark().copyWith(
                    colorScheme: ThemeData.dark().colorScheme.copyWith(
                          background: Colors.black,
                          surface: Colors.black,
                        ),
                    primaryColor: Colors.black,
                    scaffoldBackgroundColor: Colors.black,
                    iconTheme: ThemeData.dark().iconTheme.copyWith(
                          color: kIconColor, // Set icon color in dark mode
                        ),
                    elevatedButtonTheme: ElevatedButtonThemeData(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            kButtonColor, // Set button color in dark mode
                        foregroundColor:
                            Colors.white, // Set button text color in dark mode
                      ),
                    ),
                    textTheme: ThemeData.dark().textTheme.copyWith(
                          bodyMedium: ThemeData.dark()
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: kButtonColor),
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
                            kIconColor, // Set Checkbox check color
                          ),
                        ),
                    inputDecorationTheme: InputDecorationTheme(
                      fillColor: Colors.grey[900],
                      filled: true,
                      border: const OutlineInputBorder(),
                    ),
                    textSelectionTheme: TextSelectionThemeData(
                      cursorColor: Colors.white,
                      selectionColor: Colors.white.withOpacity(0.3),
                      selectionHandleColor: Colors.white.withOpacity(0.5),
                    ),
                  )
                : ThemeData.light().copyWith(
                    primaryColor: Colors.white,
                    scaffoldBackgroundColor: Colors.white,
                    iconTheme: ThemeData.light().iconTheme.copyWith(
                          color: kIconColor, // Set icon color in light mode
                        ),
                    elevatedButtonTheme: ElevatedButtonThemeData(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            kButtonColor, // Set button color in light mode
                        foregroundColor:
                            Colors.white, // Set button text color in light mode
                      ),
                    ),
                    checkboxTheme: ThemeData.light().checkboxTheme.copyWith(
                          checkColor: MaterialStateProperty.all(
                            Colors.white, // Set Checkbox fill color
                          ),
                          fillColor: MaterialStateProperty.all(
                            kIconColor, // Set Checkbox check color
                          ),
                        ),
                    listTileTheme: ThemeData.light().listTileTheme.copyWith(
                          iconColor: kIconColor, // Set icon color in light mode
                        ),
                    // Add any other customizations for light mode
                  ),
            home: const MyHomePage(),
          );
        },
      ),
    );
  }
}

/// Before enclosing Scaffold in MyHomePage, this exception was
/// thrown:
///
/// Exception has occurred.
/// _CastError (Null check operator used on a null value)
///
/// if the AppBar title is obtained that way:
///
///            home: Scaffold(
///              appBar: AppBar(
///                title: Text(AppLocalizations.of(context)!.title),
///
/// The issue occurs because the context provided to the
/// AppLocalizations.of(context) is not yet aware of the
/// localization configuration, as it's being accessed within
/// the same MaterialApp widget where you define the localization
/// delegates and the locale.
///
/// To fix this issue, you can wrap your Scaffold in a new widget,
/// like MyHomePage, which will have access to the correct context.
class MyHomePage extends StatelessWidget with ScreenMixin {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          // mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.title),
            InkWell(
              key: const Key('image_open_youtube'),
              onTap: () async {
                await openUrlInExternalApp(
                  url: kYoutubeUrl,
                );
              },
              child: Image.asset('assets/images/youtube-logo-png-2069.png',
                  height: 47),
            ),
          ],
        ),
        leading: IconButton(
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
        ),
        actions: [
          IconButton(
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
            icon: Icon(themeProvider.currentTheme == AppTheme.dark
                ? Icons.light_mode
                : Icons.dark_mode),
          ),
          PopupMenuButton<AppBarPopupMenu>(
            onSelected: (AppBarPopupMenu value) {
              switch (value) {
                case AppBarPopupMenu.en:
                  Locale newLocale = const Locale('en');
                  AppLocalizations.delegate
                      .load(newLocale)
                      .then((localizations) {
                    Provider.of<LanguageProvider>(context, listen: false)
                        .changeLocale(newLocale);
                  });
                  break;
                case AppBarPopupMenu.fr:
                  Locale newLocale = const Locale('fr');
                  AppLocalizations.delegate
                      .load(newLocale)
                      .then((localizations) {
                    Provider.of<LanguageProvider>(context, listen: false)
                        .changeLocale(newLocale);
                  });
                  break;
                case AppBarPopupMenu.about:
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          textTheme: const TextTheme(
                            bodyMedium: TextStyle(
                                color:
                                    Colors.white), // or another color you need
                          ),
                        ),
                        child: AboutDialog(
                          applicationName: kApplicationName,
                          applicationVersion: kApplicationVersion,
                          applicationIcon: Image.asset(
                              'assets/images/ic_launcher_cleaner_72.png'),
                          children: <Widget>[
                            Text(AppLocalizations.of(context)!.author),
                            Text(AppLocalizations.of(context)!.authorName),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(AppLocalizations.of(context)!
                                  .aboutAppDescription),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                  break;
                default:
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<AppBarPopupMenu>(
                  key: const Key('appBarMenuEnglish'),
                  value: AppBarPopupMenu.en,
                  child: Text(AppLocalizations.of(context)!
                      .translate(AppLocalizations.of(context)!.english)),
                ),
                PopupMenuItem<AppBarPopupMenu>(
                  key: const Key('appBarMenuFrench'),
                  value: AppBarPopupMenu.fr,
                  child: Text(AppLocalizations.of(context)!
                      .translate(AppLocalizations.of(context)!.french)),
                ),
                PopupMenuItem<AppBarPopupMenu>(
                  key: const Key('appBarMenuAbout'),
                  value: AppBarPopupMenu.about,
                  child: Text(AppLocalizations.of(context)!.about),
                ),
              ];
            },
          ),
        ],
      ),
      body: ExpandablePlaylistListView(),
    );
  }
}
