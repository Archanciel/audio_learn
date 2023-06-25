import 'package:audio_learn/models/playlist.dart';
import 'package:audio_learn/services/json_data_service.dart';
import 'package:audio_learn/viewmodels/audio_download_vm.dart';
import 'package:audio_learn/viewmodels/audio_player_vm.dart';
import 'package:audio_learn/viewmodels/expandable_playlist_list_vm.dart';
import 'package:audio_learn/viewmodels/language_provider.dart';
import 'package:audio_learn/viewmodels/theme_provider.dart';
import 'package:audio_learn/viewmodels/warning_message_vm.dart';
import 'package:audio_learn/views/expandable_playlist_list_view.dart';
import 'package:audio_learn/views/widgets/display_message_widget.dart';
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

import '../test/viewmodels/mock_audio_download_vm.dart';

void main() {
  const String youtubePlaylistId = 'PLzwWSJNcZTMTSAE8iabVB6BCAfFGHHfah';
  const String youtubePlaylistUrl =
      'https://youtube.com/playlist?list=$youtubePlaylistId';
// url used in integration_test/audio_download_vm_integration_test.dart
// which works:
// 'https://youtube.com/playlist?list=PLzwWSJNcZTMRB9ILve6fEIS_OHGrV5R2o';
  const String youtubePlaylistTitle = 'audio_learn_new_youtube_playlist_test';

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
      // Purge the test playlist directory if it exists so that the
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
      mockAudioDownloadVM.youtubePlaylistTitle = youtubePlaylistTitle;

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        isTest: true,
      );

      // using the mockAudioDownloadVM to add the playlist
      // because YoutubeExplode can not access to internet
      // in integration tests in order to download the playlist
      // and so obtain the playlist title
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

      await _launchExpandablePlaylistListView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        expandablePlaylistListVM: expandablePlaylistListVM,
        warningMessageVM: warningMessageVM,
      );

      // Tap the 'Toggle List' button to show the list
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // The playlist list and audio list should exist now but be
      // empty (no ListTile widgets)
      expect(find.byType(ListView), findsNWidgets(2));
      expect(find.byType(ListTile), findsNothing);

      // Enter the new Youtube playlist URL into the url text field
      await tester.enterText(
        find.byKey(const Key('playlistUrlTextField')),
        youtubePlaylistUrl,
      );

      // Ensure the url text field contains the entered url
      TextField urlTextField =
          tester.widget(find.byKey(const Key('playlistUrlTextField')));
      expect(urlTextField.controller!.text, youtubePlaylistUrl);

      // Open the add playlist dialog by tapping the add playlist
      // button
      await tester.tap(find.byKey(const Key('addPlaylistButton')));
      await tester.pumpAndSettle();

      // Ensure the dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);

      // Check the value of the AlertDialog url Text
      Text confirmUrlText =
          tester.widget(find.byKey(const Key('playlistUrlConfirmDialogText')));
      expect(confirmUrlText.data, youtubePlaylistUrl);

      // Check that the AlertDialog local playlist title
      // TextField is empty
      TextField localPlaylistTitleTextField = tester.widget(
          find.byKey(const Key('playlistLocalTitleConfirmDialogTextField')));
      expect(
        localPlaylistTitleTextField.controller!.text,
        '',
      );

      // Confirm the addition by tapping the confirmation button in
      // the AlertDialog
      await tester
          .tap(find.byKey(const Key('addPlaylistConfirmDialogAddButton')));
      await tester.pumpAndSettle();

      // Ensure the warning dialog is shown
      expect(find.byType(DisplayMessageWidget), findsOneWidget);

      // Check the value of the warning dialog title
      Text warningDialogTitle =
          tester.widget(find.byKey(const Key('warningDialogTitle')));
      expect(warningDialogTitle.data, 'WARNING');

      // Check the value of the warning dialog message
      Text warningDialogMessage =
          tester.widget(find.byKey(const Key('warningDialogMessage')));
      expect(warningDialogMessage.data,
          'Playlist "$youtubePlaylistTitle" of audio quality added at end of list of playlists.');

      // Close the warning dialog by tapping on the OK button
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // The list of Playlist's should have one item now
      expect(find.byType(ListTile), findsOneWidget);

      // Check if the added item is displayed correctly
      final PlaylistListItemWidget playlistListItemWidget =
          tester.widget(find.byType(PlaylistListItemWidget).first);
      expect(playlistListItemWidget.playlist.title, youtubePlaylistTitle);

      // Find the ListTile representing the added playlist

      final Finder firstListTileFinder = find.byType(ListTile).first;

      // Retrieve the ListTile widget
      final ListTile firstPlaylistListTile =
          tester.widget<ListTile>(firstListTileFinder);

      // Ensure that the title is a Text widget and check its data
      expect(firstPlaylistListTile.title, isA<Text>());
      expect((firstPlaylistListTile.title as Text).data, youtubePlaylistTitle);

      // Alternatively, find the ListTile by its title
      expect(
          find.descendant(
              of: firstListTileFinder,
              matching: find.text(
                youtubePlaylistTitle,
              )),
          findsOneWidget);

      // Check the saved local playlist values in the json file

      final newPlaylistPath = path.join(
        kDownloadAppTestDirWindows,
        youtubePlaylistTitle,
      );

      final newPlaylistFilePathName = path.join(
        newPlaylistPath,
        '$youtubePlaylistTitle.json',
      );

      // Load playlist from the json file
      Playlist loadedNewPlaylist = JsonDataService.loadFromFile(
        jsonPathFileName: newPlaylistFilePathName,
        type: Playlist,
      );

      expect(loadedNewPlaylist.title, youtubePlaylistTitle);
      expect(loadedNewPlaylist.id, youtubePlaylistId);
      expect(loadedNewPlaylist.url, youtubePlaylistUrl);
      expect(loadedNewPlaylist.playlistType, PlaylistType.youtube);
      expect(loadedNewPlaylist.playlistQuality, PlaylistQuality.voice);
      expect(loadedNewPlaylist.downloadedAudioLst.length, 0);
      expect(loadedNewPlaylist.playableAudioLst.length, 0);
      expect(loadedNewPlaylist.isSelected, false);
      expect(loadedNewPlaylist.downloadPath, newPlaylistPath);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
    testWidgets('Add local playlist', (tester) async {
      // Purge the test playlist directory if it exists so that the
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

      // mock version of AudioDownloadVM not necessary
      // because its not necessary to download the
      // local playlist in order to get its title
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

      const String localPlaylistTitle = 'audio_learn_local_playlist_test';

      await _launchExpandablePlaylistListView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        expandablePlaylistListVM: expandablePlaylistListVM,
        warningMessageVM: warningMessageVM,
      );

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

      // Set the quality to music
      await tester
          .tap(find.byKey(const Key('playlistQualityConfirmDialogCheckBox')));
      await tester.pumpAndSettle();

      // Confirm the addition by tapping the confirmation button in
      // the AlertDialog
      await tester
          .tap(find.byKey(const Key('addPlaylistConfirmDialogAddButton')));
      await tester.pumpAndSettle();

      // Ensure the warning dialog is shown
      expect(find.byType(DisplayMessageWidget), findsOneWidget);

      // Check the value of the warning dialog title
      Text warningDialogTitle =
          tester.widget(find.byKey(const Key('warningDialogTitle')));
      expect(warningDialogTitle.data, 'WARNING');

      // Check the value of the warning dialog message
      Text warningDialogMessage =
          tester.widget(find.byKey(const Key('warningDialogMessage')));
      expect(warningDialogMessage.data,
          'Playlist "$localPlaylistTitle" of music quality added at end of list of playlists.');

      // Close the warning dialog by tapping on the OK button
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // The list of Playlist's should have one item now
      expect(find.byType(ListTile), findsOneWidget);

      // Check if the added item is displayed correctly
      final PlaylistListItemWidget playlistListItemWidget =
          tester.widget(find.byType(PlaylistListItemWidget).first);
      expect(playlistListItemWidget.playlist.title, localPlaylistTitle);

      // Find the ListTile representing the added playlist

      final Finder firstListTileFinder = find.byType(ListTile).first;

      // Retrieve the ListTile widget
      final ListTile firstPlaylistListTile =
          tester.widget<ListTile>(firstListTileFinder);

      // Ensure that the title is a Text widget and check its data
      expect(firstPlaylistListTile.title, isA<Text>());
      expect((firstPlaylistListTile.title as Text).data, localPlaylistTitle);

      // Alternatively, find the ListTile by its title
      expect(
          find.descendant(
              of: firstListTileFinder,
              matching: find.text(
                localPlaylistTitle,
              )),
          findsOneWidget);

      // Check the saved local playlist values in the json file

      final newPlaylistPath = path.join(
        kDownloadAppTestDirWindows,
        localPlaylistTitle,
      );

      final newPlaylistFilePathName = path.join(
        newPlaylistPath,
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
      expect(loadedNewPlaylist.playlistQuality, PlaylistQuality.music);
      expect(loadedNewPlaylist.downloadedAudioLst.length, 0);
      expect(loadedNewPlaylist.playableAudioLst.length, 0);
      expect(loadedNewPlaylist.isSelected, false);
      expect(loadedNewPlaylist.downloadPath, newPlaylistPath);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
  });
  group('Settings update test', () {
    testWidgets('After closing and restarting app', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}settings_update_test_initial_audio_data",
        destinationRootPath: kDownloadAppTestDirWindows,
      );

      SettingsDataService settingsDataService = SettingsDataService();

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      settingsDataService.loadSettingsFromFile(
          jsonPathFileName:
              "$kDownloadAppTestDirWindows${path.separator}$kSettingsFileName");

      WarningMessageVM warningMessageVM = WarningMessageVM();
      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        isTest: true,
      );

      // mock version of AudioDownloadVM not necessary
      // because its not necessary to download the
      // local playlist which will be added in order to get
      // its title
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

      const String localMusicPlaylistTitle = 'local_music';
      const String localAudioPlaylistTitle = 'local_audio';

      await _launchExpandablePlaylistListView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        expandablePlaylistListVM: expandablePlaylistListVM,
        warningMessageVM: warningMessageVM,
      );

      // Tap the 'Toggle List' button to show the list
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // The playlist list displays two items, but the audio
      // list is empty
      expect(find.byType(ListView), findsNWidgets(2));
      expect(find.byType(ListTile), findsNWidgets(2));

      // Open the add playlist dialog by tapping the add playlist
      // button
      await tester.tap(find.byKey(const Key('addPlaylistButton')));
      await tester.pumpAndSettle();

      // Enter the title of the local playlist
      await tester.enterText(
        find.byKey(const Key('playlistLocalTitleConfirmDialogTextField')),
        localAudioPlaylistTitle,
      );

      // Check the value of the AlertDialog local playlist title
      // TextField
      TextField localPlaylistTitleTextField = tester.widget(
          find.byKey(const Key('playlistLocalTitleConfirmDialogTextField')));
      expect(
        localPlaylistTitleTextField.controller!.text,
        localAudioPlaylistTitle,
      );

      // Confirm the addition by tapping the confirmation button in
      // the AlertDialog
      await tester
          .tap(find.byKey(const Key('addPlaylistConfirmDialogAddButton')));
      await tester.pumpAndSettle();

      // Ensure the warning dialog is shown
      expect(find.byType(DisplayMessageWidget), findsOneWidget);

      // Check the value of the warning dialog message
      Text warningDialogMessage =
          tester.widget(find.byKey(const Key('warningDialogMessage')));
      expect(warningDialogMessage.data,
          'Playlist "$localAudioPlaylistTitle" of audio quality added at end of list of playlists.');

      // Close the warning dialog by tapping on the OK button
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // The list of Playlist's should have three items now
      expect(find.byType(ListTile), findsNWidgets(3));

      // Check if the added item is displayed correctly
      final PlaylistListItemWidget playlistListItemWidget =
          tester.widget(find.byType(PlaylistListItemWidget).first);
      expect(playlistListItemWidget.playlist.title, localMusicPlaylistTitle);

      // Check the saved local playlist values in the json file

      final newPlaylistPath = path.join(
        kDownloadAppTestDirWindows,
        localAudioPlaylistTitle,
      );

      final newPlaylistFilePathName = path.join(
        newPlaylistPath,
        '$localAudioPlaylistTitle.json',
      );

      // Load playlist from the json file
      Playlist loadedNewPlaylist = JsonDataService.loadFromFile(
        jsonPathFileName: newPlaylistFilePathName,
        type: Playlist,
      );

      expect(loadedNewPlaylist.title, localAudioPlaylistTitle);
      expect(loadedNewPlaylist.id, '');
      expect(loadedNewPlaylist.url, '');
      expect(loadedNewPlaylist.playlistType, PlaylistType.local);
      expect(loadedNewPlaylist.playlistQuality, PlaylistQuality.voice);
      expect(loadedNewPlaylist.downloadedAudioLst.length, 0);
      expect(loadedNewPlaylist.playableAudioLst.length, 0);
      expect(loadedNewPlaylist.isSelected, false);
      expect(loadedNewPlaylist.downloadPath, newPlaylistPath);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
  });
}

Future<void> _launchExpandablePlaylistListView({
  required tester,
  required AudioDownloadVM audioDownloadVM,
  required SettingsDataService settingsDataService,
  required ExpandablePlaylistListVM expandablePlaylistListVM,
  required WarningMessageVM warningMessageVM,
}) async {
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
}
