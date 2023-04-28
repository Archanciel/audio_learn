// dart file located in lib

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
import 'views/expandable_playlist_list_view.dart';

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

  if (myArgs.isNotEmpty) {
    if (myArgs.contains("delAppDir")) {
      deleteAppDir = true;
    }
  }

  if (deleteAppDir) {
    await DirUtil.createAppDirIfNotExist(isAppDirToBeDeleted: true);
    print('***** $kDownloadAppDir mp3 files deleted *****');
  }

  final SettingsDataService appSettings = SettingsDataService();
  appSettings.loadSettingsFromFile(
    jsonPathFileName:
        '${DirUtil.getPlaylistDownloadHomePath()}${Platform.pathSeparator}$kSettingsFileName',
  );

  runApp(MainApp(appSettings: appSettings));
}

class MainApp extends StatelessWidget {
  final SettingsDataService _appSettings;

  const MainApp({
    required SettingsDataService appSettings,
    super.key,
  }) : _appSettings = appSettings;

  @override
  Widget build(BuildContext context) {
    AudioDownloadVM audioDownloadVM = AudioDownloadVM();
    ExpandablePlaylistListVM expandablePlaylistListVM =
        ExpandablePlaylistListVM(audioDownloadVM: audioDownloadVM);

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
                  appSettings: _appSettings,
                )),
        ChangeNotifierProvider(
            create: (_) => LanguageProvider(
                  appSettings: _appSettings,
                )),
        ChangeNotifierProvider(create: (_) => expandablePlaylistListVM),
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
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.title),
        actions: [
          IconButton(
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
            icon: Icon(themeProvider.currentTheme == AppTheme.dark
                ? Icons.light_mode
                : Icons.dark_mode),
          ),
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'en' || value == 'fr') {
                Locale newLocale = Locale(value);
                AppLocalizations.delegate.load(newLocale).then((localizations) {
                  Provider.of<LanguageProvider>(context, listen: false)
                      .changeLocale(newLocale);
                });
              } else if (value == 'about') {
                showAboutDialog(
                  context: context,
                  applicationName: AppLocalizations.of(context)!.title,
                  applicationVersion: kApplicationVersion,
                  // applicationIcon: Image.asset('assets/images/Audio_Lesson-512.png'),
                  children: <Widget>[
                    const Text('Author:'),
                    const Text('Jean-Pierre Schnyder / Switzerland'),
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text('Some description about your app'),
                    ),
                  ],
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  key: const Key('appBarMenuEnglish'),
                  value: 'en',
                  child: Text(AppLocalizations.of(context)!
                      .translate(AppLocalizations.of(context)!.english)),
                ),
                PopupMenuItem<String>(
                  key: const Key('appBarMenuFrench'),
                  value: 'fr',
                  child: Text(AppLocalizations.of(context)!
                      .translate(AppLocalizations.of(context)!.french)),
                ),
                PopupMenuItem<String>(
                  key: const Key('appBarMenuAbout'),
                  value: 'about',
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
