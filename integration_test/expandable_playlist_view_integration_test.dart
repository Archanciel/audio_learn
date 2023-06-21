import 'package:audio_learn/models/audio.dart';
import 'package:audio_learn/models/playlist.dart';
import 'package:audio_learn/services/json_data_service.dart';
import 'package:audio_learn/viewmodels/audio_download_vm.dart';
import 'package:audio_learn/viewmodels/audio_player_vm.dart';
import 'package:audio_learn/viewmodels/expandable_playlist_list_vm.dart';
import 'package:audio_learn/viewmodels/language_provider.dart';
import 'package:audio_learn/viewmodels/theme_provider.dart';
import 'package:audio_learn/viewmodels/warning_message_vm.dart';
import 'package:audio_learn/views/expandable_playlist_list_view.dart';
import 'package:audio_learn/views/widgets/playlist_list_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;

import 'package:audio_learn/constants.dart';
import 'package:audio_learn/services/settings_data_service.dart';
import 'package:audio_learn/utils/dir_util.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

const String youtubePlaylistUrl =
    'https://youtube.com/playlist?list=PLzwWSJNcZTMTSAE8iabVB6BCAfFGHHfah';
// url used in integration_test/audio_download_vm_integration_test.dart
// which works:
// 'https://youtube.com/playlist?list=PLzwWSJNcZTMRB9ILve6fEIS_OHGrV5R2o';
const String youtubePlaylistTitle = 'audio_learn_new_youtube_playlist_test';

class MockAudioDownloadVM extends ChangeNotifier implements AudioDownloadVM {
  final List<Playlist> _playlistLst = [];
  final WarningMessageVM _warningMessageVM;

  MockAudioDownloadVM({
    required WarningMessageVM warningMessageVM,
    bool isTest = false,
  }) : _warningMessageVM = warningMessageVM;

  @override
  Future<void> downloadPlaylistAudios({
    required String playlistUrl,
  }) async {
    List<Audio> audioLst = [
      Audio(
          enclosingPlaylist: _playlistLst[0],
          originalVideoTitle: 'Audio 1',
          videoUrl: 'https://example.com/video2',
          audioDownloadDateTime: DateTime(2023, 3, 25),
          videoUploadDate: DateTime.now(),
          audioDuration: const Duration(minutes: 3, seconds: 42),
          compactVideoDescription: 'Video Description 1'),
      Audio(
          enclosingPlaylist: _playlistLst[0],
          originalVideoTitle: 'Audio 2',
          videoUrl: 'https://example.com/video2',
          audioDownloadDateTime: DateTime(2023, 3, 25),
          videoUploadDate: DateTime.now(),
          audioDuration: const Duration(minutes: 5, seconds: 21),
          compactVideoDescription: 'Video Description 2'),
      Audio(
          enclosingPlaylist: _playlistLst[0],
          originalVideoTitle: 'Audio 3',
          videoUrl: 'https://example.com/video2',
          audioDownloadDateTime: DateTime(2023, 3, 25),
          videoUploadDate: DateTime.now(),
          audioDuration: const Duration(minutes: 2, seconds: 15),
          compactVideoDescription: 'Video Description 3'),
    ];

    int i = 1;
    int speed = 100000;
    int size = 900000;

    for (Audio audio in audioLst) {
      audio.audioDownloadSpeed = speed * i;
      audio.audioFileSize = size * i;
      i++;
    }

    _playlistLst[0].downloadedAudioLst = audioLst;
    _playlistLst[0].playableAudioLst = audioLst;

    notifyListeners();
  }

  @override
  late yt.YoutubeExplode youtubeExplode;

  @override
  Future<Playlist?> addPlaylist({
    String playlistUrl = '',
    String localPlaylistTitle = '',
    required PlaylistQuality playlistQuality,
  }) async {
    // in the real app, the playlist title is retrieved by
    // yt.YoutubeExplode using the youtube playlist id obtained
    // using the youtube playlist url. Since integration test
    // cannot access the internet, we use the MockAudioDownloadVM !
    String playlistTitle;
    PlaylistType playlistType;

    if ((localPlaylistTitle == '')) {
      playlistTitle = youtubePlaylistTitle;
      playlistType = PlaylistType.youtube;
    } else {
      playlistTitle = localPlaylistTitle;
      playlistType = PlaylistType.local;
    }

    Playlist addedPlaylist = Playlist(
      url: playlistUrl,
      title: playlistTitle,
      playlistType: playlistType,
      playlistQuality: playlistQuality,
    );

    // _warningMessageVM.setAddPlaylist(
    //   playlistTitle: addedPlaylist.title,
    //   playlistQuality: playlistQuality,
    // );

    _playlistLst.add(addedPlaylist);

    return addedPlaylist;
  }

  @override
  // TODO: implement currentDownloadingAudio
  Audio get currentDownloadingAudio => _playlistLst[0].downloadedAudioLst[0];

  @override
  // TODO: implement downloadProgress
  double get downloadProgress => 0.5;

  @override
  // TODO: implement isDownloading
  bool get isDownloading => false;

  @override
  // TODO: implement isHighQuality
  bool get isHighQuality => false;

  @override
  // TODO: implement lastSecondDownloadSpeed
  int get lastSecondDownloadSpeed => 100000;

  @override
  // TODO: implement listOfPlaylist
  List<Playlist> get listOfPlaylist => _playlistLst;

  @override
  void setAudioQuality({required bool isHighQuality}) {
    // TODO: implement setAudioQuality
  }

  @override
  Future<void> downloadSingleVideoAudio({
    required String videoUrl,
    required Playlist singleVideoPlaylist,
  }) async {
    // TODO: implement downloadSingleVideoAudio
    throw UnimplementedError();
  }

  @override
  void stopDownload() {
    // TODO: implement stopDownload
  }

  @override
  // TODO: implement audioDownloadError
  bool get audioDownloadError => throw UnimplementedError();

  @override
  // TODO: implement isDownloadStopping
  bool get isDownloadStopping => throw UnimplementedError();

  @override
  void updatePlaylistSelection(
      {required String playlistId, required bool isPlaylistSelected}) {
    // TODO: implement updatePlaylistSelection
  }

  @override
  void deleteAudio({required Audio audio}) {
    // TODO: implement deleteAudio
  }

  @override
  void deleteAudioFromPlaylistAswell({required Audio audio}) {
    // TODO: implement deleteAudioFromPlaylistAswell
  }

  @override
  void copyAudioToPlaylist(
      {required Audio audio, required Playlist targetPlaylist}) {
    // TODO: implement copyAudioToPlaylist
  }

  @override
  int getPlaylistJsonFileSize({required Playlist playlist}) {
    // TODO: implement getPlaylistJsonFileSize
    throw UnimplementedError();
  }

  @override
  set isHighQuality(bool isHighQuality) {
    // TODO: implement isHighQuality
  }

  @override
  void moveAudioToPlaylist(
      {required Audio audio, required Playlist targetPlaylist}) {
    // TODO: implement moveAudioToPlaylist
  }

  @override
  Playlist? obtainSingleVideoPlaylist(List<Playlist> selectedPlaylists) {
    // TODO: implement obtainSingleVideoPlaylist
    throw UnimplementedError();
  }

  @override
  void updatePlaylistJsonFiles() {
    // TODO: implement updatePlaylistJsonFiles
  }
}

void main() {
  const String testPlaylistDir =
      '$kDownloadAppTestDir\\audio_learn_new_youtube_playlist_test';

  // Necessary to avoid FatalFailureException (FatalFailureException: Failed
  // to perform an HTTP request to YouTube due to a fatal failure. In most
  // cases, this error indicates that YouTube most likely changed something,
  // which broke the library.
  // If this issue persists, please report it on the project's GitHub page.
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Expandable Playlist View test', () {
    testWidgets('Add Youtube playlist', (tester) async {
      // Delete the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      SettingsDataService settingsDataService = SettingsDataService();
      WarningMessageVM warningMessageVM = WarningMessageVM();
      MockAudioDownloadVM mockAudioDownloadVM = MockAudioDownloadVM(
        warningMessageVM: warningMessageVM,
        isTest: true,
      );
      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        isTest: true,
      );
      ExpandablePlaylistListVM expandablePlaylistListVM =
          ExpandablePlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: mockAudioDownloadVM,
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // expandablePlaylistListVM to know which playlists are
      // selected and which are not
      expandablePlaylistListVM.getUpToDateSelectablePlaylists();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => audioDownloadVM),
            ChangeNotifierProvider(create: (_) => AudioPlayerVM()),
            ChangeNotifierProvider(
                create: (_) => ThemeProvider(
                      appSettings: settingsDataService,
                    )),
            ChangeNotifierProvider(
                create: (_) => LanguageProvider(
                      appSettings: settingsDataService,
                    )),
            ChangeNotifierProvider(create: (_) => expandablePlaylistListVM),
            ChangeNotifierProvider(create: (_) => warningMessageVM),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: Scaffold(body: ExpandablePlaylistListView()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // The playlist list and audio list should exist now but be
      // empty (no ListTile widgets)
      expect(find.byType(ListView), findsNWidgets(2));
      expect(find.byType(ListTile), findsNothing);

      // Add a new Youtube playlist
      await tester.enterText(
        find.byKey(const Key('playlistUrlTextField')),
        youtubePlaylistUrl,
      );

      // Ensure the url text field contains the entered url
      TextField urlTextField =
          tester.widget(find.byKey(const Key('playlistUrlTextField')));
      expect(urlTextField.controller!.text, youtubePlaylistUrl);

      await tester.tap(find.byKey(const Key('addPlaylistButton')));
      await tester.pumpAndSettle();

      // Ensure the dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);

      // Check the value of the AlertDialog url Text
      Text confirmUrlText =
          tester.widget(find.byKey(const Key('playlistUrlConfirmDialogText')));
      expect(confirmUrlText.data, youtubePlaylistUrl);

      // Confirm the addition by tapping the confirmation button in
      // the AlertDialog
      await tester
          .tap(find.byKey(const Key('addPlaylistConfirmDialogAddButton')));
      await tester.pumpAndSettle();

      // The list of Playlist should have one item now
      expect(find.byType(ListTile), findsOneWidget);

      expect(
          find.descendant(
              of: find.byType(ListTile).first,
              matching: find.text(
                youtubePlaylistTitle,
              )),
          findsOneWidget);

      // Delete the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
    testWidgets('Add local playlist', (tester) async {
      // Delete the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      SettingsDataService settingsDataService = SettingsDataService();
      WarningMessageVM warningMessageVM = WarningMessageVM();
      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        isTest: true,
      );
      ExpandablePlaylistListVM expandablePlaylistListVM =
          ExpandablePlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // expandablePlaylistListVM to know which playlists are
      // selected and which are not
      expandablePlaylistListVM.getUpToDateSelectablePlaylists();

      const String youtubePlaylistUrl = '';
      const String localPlaylistTitle = 'audio_learn_local_playlist_test';

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => audioDownloadVM),
            ChangeNotifierProvider(create: (_) => AudioPlayerVM()),
            ChangeNotifierProvider(
                create: (_) => ThemeProvider(
                      appSettings: settingsDataService,
                    )),
            ChangeNotifierProvider(
                create: (_) => LanguageProvider(
                      appSettings: settingsDataService,
                    )),
            ChangeNotifierProvider(create: (_) => expandablePlaylistListVM),
            ChangeNotifierProvider(create: (_) => warningMessageVM),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: Scaffold(body: ExpandablePlaylistListView()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // The playlist list and audio list should exist now but be
      // empty (no ListTile widgets)
      expect(find.byType(ListView), findsNWidgets(2));
      expect(find.byType(ListTile), findsNothing);

      // Open the add playlist dialog by tapping the add playlist
      // button
      await tester.tap(find.byKey(const Key('addPlaylistButton')));
      await tester.pumpAndSettle();

      // Ensure the dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);

      // Check that the value of the AlertDialog url Text is empty
      Text confirmUrlText =
          tester.widget(find.byKey(const Key('playlistUrlConfirmDialogText')));
      expect(confirmUrlText.data, '');

      // Enter the title of the local playlist
      await tester.enterText(
        find.byKey(const Key('playlistLocalTitleConfirmDialogTextField')),
        localPlaylistTitle,
      );

      // Check the value of the AlertDialog local playlist title
      // TextField
      TextField localPlaylistTitleTextField = tester.widget(
          find.byKey(const Key('playlistLocalTitleConfirmDialogTextField')));
      expect(
        localPlaylistTitleTextField.controller!.text,
        localPlaylistTitle,
      );

      // Confirm the addition by tapping the confirmation button in
      // the AlertDialog
      await tester
          .tap(find.byKey(const Key('addPlaylistConfirmDialogAddButton')));
      await tester.pumpAndSettle();

      // The list should have one item now
      expect(find.byType(ListTile), findsOneWidget);

      // Check if the added item is displayed correctly
      final playlistTile = find.byType(ListTile).first;
      expect(
          find.descendant(
              of: playlistTile, matching: find.text(localPlaylistTitle)),
          findsOneWidget);

      // Check the saved local playlist values

      final newPlaylistPathName = path.join(
        kDownloadAppTestDirWindows,
        localPlaylistTitle,
      );

      final newPlaylistFilePathName = path.join(
        newPlaylistPathName,
        '$localPlaylistTitle.json',
      );

      // Load playlist from the json file
      Playlist loadedNewPlaylist = JsonDataService.loadFromFile(
        jsonPathFileName: newPlaylistFilePathName,
        type: Playlist,
      );

      expect(loadedNewPlaylist.title, localPlaylistTitle);
      expect(loadedNewPlaylist.id, '');
      expect(loadedNewPlaylist.url, '');
      expect(loadedNewPlaylist.playlistType, PlaylistType.local);
      expect(loadedNewPlaylist.playlistQuality, PlaylistQuality.voice);
      expect(loadedNewPlaylist.downloadedAudioLst.length, 0);
      expect(loadedNewPlaylist.playableAudioLst.length, 0);
      expect(loadedNewPlaylist.isSelected, false);
      expect(loadedNewPlaylist.downloadPath, newPlaylistPathName);

      // Delete the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
  });
}
