// dart file located in lib

// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:audio_learn/services/settings_data_service.dart';
import 'package:audio_learn/viewmodels/playlist_list_vm.dart';
import 'package:audio_learn/constants.dart';
import 'package:audio_learn/utils/dir_util.dart';
import 'package:audio_learn/viewmodels/audio_download_vm.dart';
import 'viewmodels/audio_player_vm.dart';
import 'viewmodels/language_provider.dart';
import 'viewmodels/theme_provider.dart';
import 'viewmodels/warning_message_vm.dart';
import 'views/playlist_list_view.dart';
import 'views/widgets/appbar_leading_icon_menu_widget.dart';
import 'views/widgets/appbar_application_right_popup_menu_widget.dart';
import 'views/screen_mixin.dart';

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

class MainApp extends StatelessWidget with ScreenMixin {
  final SettingsDataService _settingsDataService;
  final bool _isTest;

  MainApp({
    required SettingsDataService settingsDataService,
    bool isTest = false,
    super.key,
  })  : _isTest = isTest,
        _settingsDataService = settingsDataService;

  @override
  Widget build(BuildContext context) {
    WarningMessageVM warningMessageVM = WarningMessageVM();
    AudioDownloadVM audioDownloadVM = AudioDownloadVM(
      warningMessageVM: warningMessageVM,
      isTest: _isTest,
    );
    PlaylistListVM expandablePlaylistListVM = PlaylistListVM(
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
                ? ScreenMixin.themeDataDark
                : ScreenMixin.themeDataLight,
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
class MyHomePage extends StatefulWidget with ScreenMixin {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<IconData> _screenNavigationIconLst = [
    Icons.timer,
    Icons.book,
    Icons.list,
  ];

  // contains a list of widgets which build the AppBar title. Each
  // widget is specific to the screen currently displayed.
  final List<Widget> _appBarTitleWidgetLst = [];

  @override
  void initState() {
    super.initState();

    _appBarTitleWidgetLst.add(
      AppBarTitleForPlaylistView(playlistViewHomePage: widget),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider = Provider.of<ThemeProvider>(
      context,
      listen: false,
    );

    // This list is used to display the application action icons
    // located in in the AppBar after the AppBar title. The
    // content of the list is the same for all displayable screens
    // since it enables to select the light or dark theme and to
    // select the app language.
    List<Widget> appBarApplicationActionLst = [
      IconButton(
        onPressed: () {
          themeProvider.toggleTheme();
        },
        icon: Icon(themeProvider.currentTheme == AppTheme.dark
            ? Icons.light_mode
            : Icons.dark_mode),
      ),
      AppBarApplicationRightPopupMenuWidget(themeProvider: themeProvider),
    ];

    return Scaffold(
      appBar: AppBar(
        title: _appBarTitleWidgetLst[_currentIndex],
        leading: AppBarLeadingIconMenuWidget(themeProvider: themeProvider),
        actions: appBarApplicationActionLst,
      ),
      body: PlaylistListView(),
    );
  }
}

/// When the PlaylistView screen is displayed, the AppBarTitlePlaylistView
/// is displayed in the AppBar title:
class AppBarTitleForPlaylistView extends StatelessWidget {
  const AppBarTitleForPlaylistView({
    super.key,
    required this.playlistViewHomePage,
  });

  final MyHomePage playlistViewHomePage;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Flexible(
          child: Text(
            AppLocalizations.of(context)!.title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 17),
          ),
        ),
        InkWell(
          key: const Key('image_open_youtube'),
          onTap: () async {
            await playlistViewHomePage.openUrlInExternalApp(
              url: kYoutubeUrl,
            );
          },
          child: Image.asset('assets/images/youtube-logo-png-2069.png',
              height: 38),
        ),
      ],
    );
  }
}
