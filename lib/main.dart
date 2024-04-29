import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart';

import 'constants.dart';
import 'services/permission_requester_service.dart';
import 'viewmodels/playlist_list_vm.dart';
import 'viewmodels/audio_download_vm.dart';
import 'viewmodels/audio_player_vm.dart';
import 'viewmodels/language_provider_vm.dart';
import 'viewmodels/theme_provider_vm.dart';
import 'viewmodels/warning_message_vm.dart';
import 'services/settings_data_service.dart';
import 'utils/dir_util.dart';
import 'views/my_home_page.dart';
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
  bool deleteAppDir = kDeleteAppDirOnEmulator;
  bool isTest = false;

  if (myArgs.isNotEmpty) {
    if (myArgs.contains("delAppDir")) {
      deleteAppDir = true;
    } else if (myArgs.contains("test")) {
      isTest = true;
    }
  }

  if (deleteAppDir) {
    DirUtil.deleteAppDirOnEmulatorIfExist();
    print('***** $kPlaylistDownloadRootPath mp3 files deleted *****');
  }

  final SettingsDataService settingsDataService =
      SettingsDataService(isTest: isTest);

  // create the app dir if it does not exist
  String applicationPath = await DirUtil.getApplicationPath(isTest: isTest);
  
  await settingsDataService.loadSettingsFromFile(
    jsonPathFileName:
        '${applicationPath}${Platform.pathSeparator}$kSettingsFileName',
  );

  // If app runs on Windows, Linux or MacOS, set the app size
  // and position
  await setWindowsAppSizeAndPosition();

  runApp(MainApp(
    settingsDataService: settingsDataService,
    isTest: isTest,
  ));
}

/// If app runs on Windows, Linux or MacOS, set the app size
/// and position.
Future<void> setWindowsAppSizeAndPosition() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    await getScreenList().then((List<Screen> screens) {
      // Assumez que vous voulez utiliser le premier écran (principal)
      final Screen screen = screens.first;
      final Rect screenRect = screen.visibleFrame;

      // Définissez la largeur et la hauteur de votre fenêtre
      const double windowWidth = 900;
      const double windowHeight = 1300;

      // Calculez la position X pour placer la fenêtre sur le côté droit de l'écran
      final double posX = screenRect.right - windowWidth;
      // Optionnellement, ajustez la position Y selon vos préférences
      final double posY = (screenRect.height - windowHeight) / 2;

      final Rect windowRect =
          Rect.fromLTWH(posX, posY, windowWidth, windowHeight);
      setWindowFrame(windowRect);
    });
  }
}

Future<void> setWindowsAppVersionSize() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(600, 715),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    // keeping Windows title bar enables to move the app window
    // titleBarStyle: TitleBarStyle.hidden,
    // windowButtonVisibility: false,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
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
    PermissionRequesterService.requestMultiplePermissions();

    WarningMessageVM warningMessageVM = WarningMessageVM();

    AudioDownloadVM audioDownloadVM = AudioDownloadVM(
      warningMessageVM: warningMessageVM,
      settingsDataService: _settingsDataService,
      isTest: _isTest,
    );

    PlaylistListVM expandablePlaylistListVM = PlaylistListVM(
      warningMessageVM: warningMessageVM,
      audioDownloadVM: audioDownloadVM,
      settingsDataService: _settingsDataService,
    );

    // the globalAudioPlayerVM ScreenMixin variable is created
    // here since it needs expandablePlaylistListVM which is
    // created above
    globalAudioPlayerVM = AudioPlayerVM(
      playlistListVM: expandablePlaylistListVM,
    );

    // calling getUpToDateSelectablePlaylists() loads all the
    // playlist json files from the app dir and so enables
    // expandablePlaylistListVM to know which playlists are
    // selected and which are not
    expandablePlaylistListVM.getUpToDateSelectablePlaylists();

    // must be called after
    // expandablePlaylistListVM.getUpToDateSelectablePlaylists()
    // otherwise the list of selected playlists is empty instead
    // of containing one selected playlist (as valid now)

    // not necessary
    // globalAudioPlayerVM.setCurrentAudioFromSelectedPlaylist();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => audioDownloadVM),
        ChangeNotifierProvider(
          create: (_) {
            return globalAudioPlayerVM;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProviderVM(
            appSettings: _settingsDataService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => LanguageProviderVM(
            appSettings: _settingsDataService,
          ),
        ),
        ChangeNotifierProvider(create: (_) => expandablePlaylistListVM),
        ChangeNotifierProvider(create: (_) => warningMessageVM),
      ],
      child: Consumer2<ThemeProviderVM, LanguageProviderVM>(
        builder: (context, themeProvider, languageProvider, child) {
          return MaterialApp(
            title: 'AudioLearn',
            // title: AppLocalizations.of(context)!.title,
            locale: languageProvider.currentLocale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: themeProvider.currentTheme == AppTheme.dark
                ? ScreenMixin.themeDataDark
                : ScreenMixin.themeDataLight,
            home: MyHomePage(
              settingsDataService: _settingsDataService,
            ),
          );
        },
      ),
    );
  }
}
