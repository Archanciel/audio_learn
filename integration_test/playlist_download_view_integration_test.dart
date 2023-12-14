import 'dart:io';

import 'package:audio_learn/viewmodels/audio_player_vm.dart';
import 'package:audio_learn/viewmodels/single_video_audio_download_vm.dart';
import 'package:audio_learn/views/screen_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;

import 'package:audio_learn/constants.dart';
import 'package:audio_learn/models/playlist.dart';
import 'package:audio_learn/services/json_data_service.dart';
import 'package:audio_learn/viewmodels/audio_download_vm.dart';
import 'package:audio_learn/viewmodels/playlist_list_vm.dart';
import 'package:audio_learn/viewmodels/language_provider_vm.dart';
import 'package:audio_learn/viewmodels/theme_provider_vm.dart';
import 'package:audio_learn/viewmodels/warning_message_vm.dart';
import 'package:audio_learn/views/playlist_download_view.dart';
import 'package:audio_learn/views/widgets/display_message_widget.dart';
import 'package:audio_learn/views/widgets/playlist_list_item_widget.dart';
import 'package:audio_learn/services/settings_data_service.dart';
import 'package:audio_learn/utils/dir_util.dart';
import 'package:audio_learn/main.dart' as app;

import '../test/viewmodels/custom_mock_youtube_explode.dart';
import '../test/viewmodels/mock_audio_download_vm.dart';

void main() {
  const String youtubePlaylistId = 'PLzwWSJNcZTMTSAE8iabVB6BCAfFGHHfah';
  const String youtubePlaylistUrl =
      'https://youtube.com/playlist?list=$youtubePlaylistId';
// url used in integration_test/audio_download_vm_integration_test.dart
// which works:
// 'https://youtube.com/playlist?list=PLzwWSJNcZTMRB9ILve6fEIS_OHGrV5R2o';
  const String youtubeNewPlaylistTitle =
      'audio_learn_new_youtube_playlist_test';

  const String testPlaylistDir =
      '$kDownloadAppTestDir\\audio_learn_new_youtube_playlist_test';

  // Necessary to avoid FatalFailureException (FatalFailureException: Failed
  // to perform an HTTP request to YouTube due to a fatal failure. In most
  // cases, this error indicates that YouTube most likely changed something,
  // which broke the library.
  // If this issue persists, please report it on the project's GitHub page.
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Playlist Download View test', () {
    testWidgets('Add and then delete Youtube playlist', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      // Since we have to use a mock AudioDownloadVM to add the
      // youtube playlist, we can not use app.main() to start the
      // app because app.main() uses the real AudioDownloadVM
      // and we don't want to make the main.dart file dependent
      // of a mock class. So we have to start the app by hand.

      SettingsDataService settingsDataService = SettingsDataService(
        isTest: true,
      );
      WarningMessageVM warningMessageVM = WarningMessageVM();
      MockAudioDownloadVM mockAudioDownloadVM = MockAudioDownloadVM(
        warningMessageVM: warningMessageVM,
        isTest: true,
      );
      mockAudioDownloadVM.youtubePlaylistTitle = youtubeNewPlaylistTitle;

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        isTest: true,
      );

      // using the mockAudioDownloadVM to add the playlist
      // because YoutubeExplode can not access to internet
      // in integration tests in order to download the playlist
      // and so obtain the playlist title
      PlaylistListVM expandablePlaylistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: mockAudioDownloadVM,
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // expandablePlaylistListVM to know which playlists are
      // selected and which are not
      expandablePlaylistListVM.getUpToDateSelectablePlaylists();

      AudioPlayerVM audioPlayerVM = AudioPlayerVM(
        playlistListVM: expandablePlaylistListVM,
      );

      await _launchExpandablePlaylistListView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        expandablePlaylistListVM: expandablePlaylistListVM,
        warningMessageVM: warningMessageVM,
        audioPlayerVM: audioPlayerVM,
      );

      // Tap the 'Toggle List' button to show the list. If the list
      // is not opened, checking that a ListTile with the title of
      // the playlist was added to the list will fail
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

      // Check the value of the AlertDialog dialog title
      Text alertDialogTitle =
          tester.widget(find.byKey(const Key('playlistConfirmDialogTitleKey')));
      expect(alertDialogTitle.data, 'Add Playlist');

      // Check the value of the AlertDialog dialog title comment
      Text alertDialogCommentTitleText = tester.widget(
          find.byKey(const Key('playlistTitleCommentConfirmDialogKey')));
      expect(alertDialogCommentTitleText.data,
          'Adding Youtube playlist referenced by the URL or adding a local playlist whose title must be defined.');

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
          'Playlist "$youtubeNewPlaylistTitle" of audio quality added at end of list of playlists.');

      // Close the warning dialog by tapping on the OK button
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Ensure the URL TextField was emptied
      urlTextField =
          tester.widget(find.byKey(const Key('playlistUrlTextField')));
      expect(urlTextField.controller!.text, '');

      // The list of Playlist's should have one item now
      expect(find.byType(ListTile), findsOneWidget);

      // Check if the added item is displayed correctly
      final PlaylistListItemWidget playlistListItemWidget =
          tester.widget(find.byType(PlaylistListItemWidget).first);
      expect(playlistListItemWidget.playlist.title, youtubeNewPlaylistTitle);

      // Find the ListTile representing the added playlist

      final Finder firstListTileFinder = find.byType(ListTile).first;

      // Retrieve the ListTile widget
      final ListTile firstPlaylistListTile =
          tester.widget<ListTile>(firstListTileFinder);

      // Ensure that the title is a Text widget and check its data
      expect(firstPlaylistListTile.title, isA<Text>());
      expect(
          (firstPlaylistListTile.title as Text).data, youtubeNewPlaylistTitle);

      // Alternatively, find the ListTile by its title
      expect(
          find.descendant(
              of: firstListTileFinder,
              matching: find.text(
                youtubeNewPlaylistTitle,
              )),
          findsOneWidget);

      // Check the saved local playlist values in the json file

      final String newPlaylistPath = path.join(
        kDownloadAppTestDirWindows,
        youtubeNewPlaylistTitle,
      );

      final newPlaylistFilePathName = path.join(
        newPlaylistPath,
        '$youtubeNewPlaylistTitle.json',
      );

      // Load playlist from the json file
      Playlist loadedNewPlaylist = JsonDataService.loadFromFile(
        jsonPathFileName: newPlaylistFilePathName,
        type: Playlist,
      );

      expect(loadedNewPlaylist.title, youtubeNewPlaylistTitle);
      expect(loadedNewPlaylist.id, youtubePlaylistId);
      expect(loadedNewPlaylist.url, youtubePlaylistUrl);
      expect(loadedNewPlaylist.playlistType, PlaylistType.youtube);
      expect(loadedNewPlaylist.playlistQuality, PlaylistQuality.voice);
      expect(loadedNewPlaylist.downloadedAudioLst.length, 0);
      expect(loadedNewPlaylist.playableAudioLst.length, 0);
      expect(loadedNewPlaylist.isSelected, false);
      expect(loadedNewPlaylist.downloadPath, newPlaylistPath);

      // Check that the ordered playlist titles list in the settings
      // data service contains the added playlist title
      expect(
          settingsDataService.get(
            settingType: SettingType.playlists,
            settingSubType: Playlists.orderedTitleLst,
          ),
          [youtubeNewPlaylistTitle]);

      // Now test deleting the playlist

      // Open the delete playlist dialog by clicking on the 'Delete
      // playlist ...' playlist menu item

      // Now find the leading menu icon button of the Playlist ListTile
      // and tap on it
      final Finder firstPlaylistListTileLeadingMenuIconButton = find.descendant(
        of: firstListTileFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(firstPlaylistListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the delete playlist popup menu item and tap on it
      final Finder popupDeletePlaylistMenuItem =
          find.byKey(const Key("popup_menu_delete_playlist"));

      await tester.tap(popupDeletePlaylistMenuItem);
      await tester.pumpAndSettle(); // Wait for tap action to complete

      // Now verifying the confirm dialog message

      final Text deletePlaylistDialogTitleWidget = tester.widget<Text>(
          find.byKey(const Key('playlistDeleteConfirmDialogTitleKey')));

      expect(deletePlaylistDialogTitleWidget.data,
          'Delete Youtube Playlist "$youtubeNewPlaylistTitle"');

      // Now find the delete button of the delete playlist confirm
      // dialog and tap on it
      await tester.tap(
          find.byKey(const Key('deletePlaylistConfirmDialogDeleteButton')));
      await tester.pumpAndSettle();

      // Check that the ordered playlist titles list in the settings
      // data service is now empty
      expect(
          settingsDataService.get(
            settingType: SettingType.playlists,
            settingSubType: Playlists.orderedTitleLst,
          ),
          []);

      // Check that the deleted playlist directory no longer exist
      expect(Directory(newPlaylistPath).existsSync(), false);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
    testWidgets('Add Youtube playlist and then add it again with same URL',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      // Since we have to use a mock AudioDownloadVM to add the
      // youtube playlist, we can not use app.main() to start the
      // app because app.main() uses the real AudioDownloadVM
      // and we don't want to make the main.dart file dependent
      // of a mock class. So we have to start the app by hand.

      SettingsDataService settingsDataService = SettingsDataService(
        isTest: true,
      );
      WarningMessageVM warningMessageVM = WarningMessageVM();
      MockAudioDownloadVM mockAudioDownloadVM = MockAudioDownloadVM(
        warningMessageVM: warningMessageVM,
        isTest: true,
      );
      mockAudioDownloadVM.youtubePlaylistTitle = youtubeNewPlaylistTitle;

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        isTest: true,
      );

      // using the mockAudioDownloadVM to add the playlist
      // because YoutubeExplode can not access to internet
      // in integration tests in order to download the playlist
      // and so obtain the playlist title
      PlaylistListVM expandablePlaylistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: mockAudioDownloadVM,
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // expandablePlaylistListVM to know which playlists are
      // selected and which are not
      expandablePlaylistListVM.getUpToDateSelectablePlaylists();

      AudioPlayerVM audioPlayerVM = AudioPlayerVM(
        playlistListVM: expandablePlaylistListVM,
      );

      await _launchExpandablePlaylistListView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        expandablePlaylistListVM: expandablePlaylistListVM,
        warningMessageVM: warningMessageVM,
        audioPlayerVM: audioPlayerVM,
      );

      // Tap the 'Toggle List' button to show the list. If the list
      // is not opened, checking that a ListTile with the title of
      // the playlist was added to the list will fail
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

      // Check the value of the AlertDialog dialog title
      Text alertDialogTitle =
          tester.widget(find.byKey(const Key('playlistConfirmDialogTitleKey')));
      expect(alertDialogTitle.data, 'Add Playlist');

      // Check the value of the AlertDialog dialog title comment
      Text alertDialogCommentTitleText = tester.widget(
          find.byKey(const Key('playlistTitleCommentConfirmDialogKey')));
      expect(alertDialogCommentTitleText.data,
          'Adding Youtube playlist referenced by the URL or adding a local playlist whose title must be defined.');

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
          'Playlist "$youtubeNewPlaylistTitle" of audio quality added at end of list of playlists.');

      // Close the warning dialog by tapping on the OK button
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Ensure the URL TextField was emptied
      urlTextField =
          tester.widget(find.byKey(const Key('playlistUrlTextField')));
      expect(urlTextField.controller!.text, '');

      // Check the saved local playlist values in the json file

      final String newPlaylistPath = path.join(
        kDownloadAppTestDirWindows,
        youtubeNewPlaylistTitle,
      );

      final newPlaylistFilePathName = path.join(
        newPlaylistPath,
        '$youtubeNewPlaylistTitle.json',
      );

      // Load playlist from the json file
      Playlist loadedNewPlaylist = JsonDataService.loadFromFile(
        jsonPathFileName: newPlaylistFilePathName,
        type: Playlist,
      );

      expect(loadedNewPlaylist.title, youtubeNewPlaylistTitle);
      expect(loadedNewPlaylist.id, youtubePlaylistId);
      expect(loadedNewPlaylist.url, youtubePlaylistUrl);
      expect(loadedNewPlaylist.playlistType, PlaylistType.youtube);
      expect(loadedNewPlaylist.playlistQuality, PlaylistQuality.voice);
      expect(loadedNewPlaylist.downloadedAudioLst.length, 0);
      expect(loadedNewPlaylist.playableAudioLst.length, 0);
      expect(loadedNewPlaylist.isSelected, false);
      expect(loadedNewPlaylist.downloadPath, newPlaylistPath);

      // Check that the ordered playlist titles list in the settings
      // data service contains the added playlist title
      expect(
          settingsDataService.get(
            settingType: SettingType.playlists,
            settingSubType: Playlists.orderedTitleLst,
          ),
          [youtubeNewPlaylistTitle]);

      // Now test adding the same playlist again

      // Enter the new Youtube playlist URL into the url text field.
      // I don't know why, but the next commented code does not work.

      // await tester.enterText(
      //   find.byKey(const Key('playlistUrlTextField')),
      //   youtubePlaylistUrl,
      // );

      // Solving this putain de problem
      tester
          .widget<TextField>(find.byKey(const Key('playlistUrlTextField')))
          .controller!
          .text = youtubePlaylistUrl;

      await tester.pumpAndSettle();

      // Ensure the url text field contains the entered url
      urlTextField =
          tester.widget(find.byKey(const Key('playlistUrlTextField')));
      expect(urlTextField.controller!.text, youtubePlaylistUrl);

      // Open the add playlist dialog by tapping the add playlist
      // button
      await tester.tap(find.byKey(const Key('addPlaylistButton')));
      await tester.pumpAndSettle();

      // Ensure the dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);

      // Check the value of the AlertDialog dialog title
      alertDialogTitle =
          tester.widget(find.byKey(const Key('playlistConfirmDialogTitleKey')));
      expect(alertDialogTitle.data, 'Add Playlist');

      // Check the value of the AlertDialog dialog title comment
      alertDialogCommentTitleText = tester.widget(
          find.byKey(const Key('playlistTitleCommentConfirmDialogKey')));
      expect(alertDialogCommentTitleText.data,
          'Adding Youtube playlist referenced by the URL or adding a local playlist whose title must be defined.');

      // Check the value of the AlertDialog url Text
      confirmUrlText =
          tester.widget(find.byKey(const Key('playlistUrlConfirmDialogText')));
      expect(confirmUrlText.data, youtubePlaylistUrl);

      // Confirm the addition by tapping the confirmation button in
      // the AlertDialog
      await tester
          .tap(find.byKey(const Key('addPlaylistConfirmDialogAddButton')));
      await tester.pumpAndSettle();

      // Ensure the warning dialog is shown
      expect(find.byType(DisplayMessageWidget), findsOneWidget);

      // Check the value of the warning dialog title
      warningDialogTitle =
          tester.widget(find.byKey(const Key('warningDialogTitle')));
      expect(warningDialogTitle.data, 'WARNING');

      // Check the value of the warning dialog message
      warningDialogMessage =
          tester.widget(find.byKey(const Key('warningDialogMessage')));
      expect(warningDialogMessage.data,
          'Playlist "$youtubeNewPlaylistTitle" with this URL "$youtubePlaylistUrl" is already in the list of playlists and so won\'t be recreated.');

      // Close the warning dialog by tapping on the OK button
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Ensure the URL TextField was not emptied
      urlTextField =
          tester.widget(find.byKey(const Key('playlistUrlTextField')));
      expect(urlTextField.controller!.text, youtubePlaylistUrl);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });

    /// The objective of this integration test is to ensure that
    /// the url text field will not be emptied after clicking on
    /// the Cancel button of the add playlist dialog.
    testWidgets(
        'Open the add playlist dialog to add a Youtube playlist and then click on Cancel button',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      // Since we have to use a mock AudioDownloadVM to add the
      // youtube playlist, we can not use app.main() to start the
      // app because app.main() uses the real AudioDownloadVM
      // and we don't want to make the main.dart file dependent
      // of a mock class. So we have to start the app by hand.

      SettingsDataService settingsDataService = SettingsDataService(
        isTest: true,
      );
      WarningMessageVM warningMessageVM = WarningMessageVM();
      MockAudioDownloadVM mockAudioDownloadVM = MockAudioDownloadVM(
        warningMessageVM: warningMessageVM,
        isTest: true,
      );
      mockAudioDownloadVM.youtubePlaylistTitle = youtubeNewPlaylistTitle;

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        isTest: true,
      );

      // using the mockAudioDownloadVM to add the playlist
      // because YoutubeExplode can not access to internet
      // in integration tests in order to download the playlist
      // and so obtain the playlist title
      PlaylistListVM expandablePlaylistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: mockAudioDownloadVM,
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // expandablePlaylistListVM to know which playlists are
      // selected and which are not
      expandablePlaylistListVM.getUpToDateSelectablePlaylists();

      AudioPlayerVM audioPlayerVM = AudioPlayerVM(
        playlistListVM: expandablePlaylistListVM,
      );

      await _launchExpandablePlaylistListView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        expandablePlaylistListVM: expandablePlaylistListVM,
        warningMessageVM: warningMessageVM,
        audioPlayerVM: audioPlayerVM,
      );

      // Tap the 'Toggle List' button to show the list. If the list
      // is not opened, checking that a ListTile with the title of
      // the playlist was added to the list will fail
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

      // Check the value of the AlertDialog dialog title
      Text alertDialogTitle =
          tester.widget(find.byKey(const Key('playlistConfirmDialogTitleKey')));
      expect(alertDialogTitle.data, 'Add Playlist');

      // Check the value of the AlertDialog dialog title comment
      Text alertDialogCommentTitleText = tester.widget(
          find.byKey(const Key('playlistTitleCommentConfirmDialogKey')));
      expect(alertDialogCommentTitleText.data,
          'Adding Youtube playlist referenced by the URL or adding a local playlist whose title must be defined.');

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

      // Cancel the addition by tapping the Cancel button in the
      // AlertDialog
      await tester
          .tap(find.byKey(const Key('addPlaylistConfirmDialogCancelButton')));
      await tester.pumpAndSettle();

      // Ensure the URL TextField was not emptied
      urlTextField =
          tester.widget(find.byKey(const Key('playlistUrlTextField')));
      expect(urlTextField.controller!.text, youtubePlaylistUrl);

      // The list of Playlist's should have 0 item
      expect(find.byType(ListTile), findsNothing);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
    testWidgets('Add and then delete local playlist with empty playlist URL',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      const String localPlaylistTitle = 'audio_learn_local_playlist_test';

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list. If the list
      // is not opened, checking that a ListTile with the title of
      // the playlist was added to the list will fail
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

      // Check the value of the AlertDialog dialog title
      Text alertDialogTitle =
          tester.widget(find.byKey(const Key('playlistConfirmDialogTitleKey')));
      expect(alertDialogTitle.data, 'Add Playlist');

      // Check the value of the AlertDialog dialog title comment
      Text alertDialogCommentTitleText = tester.widget(
          find.byKey(const Key('playlistTitleCommentConfirmDialogKey')));
      expect(alertDialogCommentTitleText.data,
          'Adding Youtube playlist referenced by the URL or adding a local playlist whose title must be defined.');

      // Check that the AlertDialog url Text is not displayed since
      // a local playlist is added with the playlist URL text field
      // empty
      expect(
        find.byKey(const Key('playlistUrlConfirmDialogText')),
        findsNothing,
      );

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

      final String newPlaylistPath = path.join(
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
      expect(loadedNewPlaylist.id, localPlaylistTitle);
      expect(loadedNewPlaylist.url, '');
      expect(loadedNewPlaylist.playlistType, PlaylistType.local);
      expect(loadedNewPlaylist.playlistQuality, PlaylistQuality.music);
      expect(loadedNewPlaylist.downloadedAudioLst.length, 0);
      expect(loadedNewPlaylist.playableAudioLst.length, 0);
      expect(loadedNewPlaylist.isSelected, false);
      expect(loadedNewPlaylist.downloadPath, newPlaylistPath);

      SettingsDataService settingsDataService = SettingsDataService(
        isTest: true,
      );

      final settingsPathFileName = path.join(
        kDownloadAppTestDirWindows,
        'settings.json',
      );

      settingsDataService.loadSettingsFromFile(
          jsonPathFileName: settingsPathFileName);

      // Check that the ordered playlist titles list in the settings
      // data service contains the added playlist title
      expect(
          settingsDataService.get(
            settingType: SettingType.playlists,
            settingSubType: Playlists.orderedTitleLst,
          ),
          [localPlaylistTitle]);

      // Now test deleting the playlist

      // Open the delete playlist dialog by clicking on the 'Delete
      // playlist ...' playlist menu item

      // Now find the leading menu icon button of the Playlist ListTile
      // and tap on it
      final Finder firstPlaylistListTileLeadingMenuIconButton = find.descendant(
        of: firstListTileFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(firstPlaylistListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the delete playlist popup menu item and tap on it
      final Finder popupDeletePlaylistMenuItem =
          find.byKey(const Key("popup_menu_delete_playlist"));

      await tester.tap(popupDeletePlaylistMenuItem);
      await tester.pumpAndSettle(); // Wait for tap action to complete

      // Now verifying the confirm dialog message

      final Text deletePlaylistDialogTitleWidget = tester.widget<Text>(
          find.byKey(const Key('playlistDeleteConfirmDialogTitleKey')));

      expect(deletePlaylistDialogTitleWidget.data,
          'Delete local Playlist "$localPlaylistTitle"');

      // Now find the delete button of the delete playlist confirm
      // dialog and tap on it
      await tester.tap(
          find.byKey(const Key('deletePlaylistConfirmDialogDeleteButton')));
      await tester.pumpAndSettle();

      // Check that the ordered playlist titles list in the settings
      // data service is now empty

      // Reload the settings data service from the settings json file
      settingsDataService.loadSettingsFromFile(
        jsonPathFileName: settingsPathFileName,
      );

      expect(
          settingsDataService.get(
            settingType: SettingType.playlists,
            settingSubType: Playlists.orderedTitleLst,
          ),
          ['']); // if loading from the settings json file,
      //            the ordered playlist titles list is never
      //            empty. I don't know why, but it is the same
      //            if loading settings from file in add and delete
      //            Youtube playlist !

      // Check that the deleted playlist directory no longer exist
      expect(Directory(newPlaylistPath).existsSync(), false);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });

    /// The objective of this integration test is to ensure that
    /// the url text field will not be emptied after adding a
    /// local playlist, in contrary of what happens after adding
    /// a Youtube playlist.
    testWidgets(
        'Add and then delete local playlist after having entered a Youtube playlist URL',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      const String localPlaylistTitle = 'audio_learn_local_playlist_test';

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list. If the list
      // is not opened, checking that a ListTile with the title of
      // the playlist was added to the list will fail
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // The playlist list and audio list should exist now but be
      // empty (no ListTile widgets)
      expect(find.byType(ListView), findsNWidgets(2));
      expect(find.byType(ListTile), findsNothing);

      // Enter the new Youtube playlist URL into the url text field.
      // The objective is to test that the url text field will not
      // be emptied after adding a local playlist
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

      // Check the value of the AlertDialog dialog title
      Text alertDialogTitle =
          tester.widget(find.byKey(const Key('playlistConfirmDialogTitleKey')));
      expect(alertDialogTitle.data, 'Add Playlist');

      // Check the value of the AlertDialog dialog title comment
      Text alertDialogCommentTitleText = tester.widget(
          find.byKey(const Key('playlistTitleCommentConfirmDialogKey')));
      expect(alertDialogCommentTitleText.data,
          'Adding Youtube playlist referenced by the URL or adding a local playlist whose title must be defined.');

      // Check that the AlertDialog url Text is displayed since the
      // local playlist is added with the playlist URL text field being
      // not empty
      Text confirmUrlText =
          tester.widget(find.byKey(const Key('playlistUrlConfirmDialogText')));
      expect(confirmUrlText.data, youtubePlaylistUrl);

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

      // Ensure the URL TextField was not emptied since the added
      // playlist is a local playlist
      urlTextField =
          tester.widget(find.byKey(const Key('playlistUrlTextField')));
      expect(urlTextField.controller!.text, youtubePlaylistUrl);

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

      final String newPlaylistPath = path.join(
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
      expect(loadedNewPlaylist.id, localPlaylistTitle);
      expect(loadedNewPlaylist.url, '');
      expect(loadedNewPlaylist.playlistType, PlaylistType.local);
      expect(loadedNewPlaylist.playlistQuality, PlaylistQuality.music);
      expect(loadedNewPlaylist.downloadedAudioLst.length, 0);
      expect(loadedNewPlaylist.playableAudioLst.length, 0);
      expect(loadedNewPlaylist.isSelected, false);
      expect(loadedNewPlaylist.downloadPath, newPlaylistPath);

      SettingsDataService settingsDataService = SettingsDataService(
        isTest: true,
      );

      final settingsPathFileName = path.join(
        kDownloadAppTestDirWindows,
        'settings.json',
      );

      settingsDataService.loadSettingsFromFile(
          jsonPathFileName: settingsPathFileName);

      // Check that the ordered playlist titles list in the settings
      // data service contains the added playlist title
      expect(
          settingsDataService.get(
            settingType: SettingType.playlists,
            settingSubType: Playlists.orderedTitleLst,
          ),
          [localPlaylistTitle]);

      // Now test deleting the playlist

      // Open the delete playlist dialog by clicking on the 'Delete
      // playlist ...' playlist menu item

      // Now find the leading menu icon button of the Playlist ListTile
      // and tap on it
      final Finder firstPlaylistListTileLeadingMenuIconButton = find.descendant(
        of: firstListTileFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(firstPlaylistListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the delete playlist popup menu item and tap on it
      final Finder popupDeletePlaylistMenuItem =
          find.byKey(const Key("popup_menu_delete_playlist"));

      await tester.tap(popupDeletePlaylistMenuItem);
      await tester.pumpAndSettle(); // Wait for tap action to complete

      // Now verifying the confirm dialog message

      final Text deletePlaylistDialogTitleWidget = tester.widget<Text>(
          find.byKey(const Key('playlistDeleteConfirmDialogTitleKey')));

      expect(deletePlaylistDialogTitleWidget.data,
          'Delete local Playlist "$localPlaylistTitle"');

      // Now find the delete button of the delete playlist confirm
      // dialog and tap on it
      await tester.tap(
          find.byKey(const Key('deletePlaylistConfirmDialogDeleteButton')));
      await tester.pumpAndSettle();

      // Check that the ordered playlist titles list in the settings
      // data service is now empty

      // Reload the settings data service from the settings json file
      settingsDataService.loadSettingsFromFile(
        jsonPathFileName: settingsPathFileName,
      );

      expect(
          settingsDataService.get(
            settingType: SettingType.playlists,
            settingSubType: Playlists.orderedTitleLst,
          ),
          ['']); // if loading from the settings json file,
      //            the ordered playlist titles list is never
      //            empty. I don't know why, but it is the same
      //            if loading settings from file in add and delete
      //            Youtube playlist !

      // Check that the deleted playlist directory no longer exist
      expect(Directory(newPlaylistPath).existsSync(), false);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
    testWidgets(
        'Entered a Youtube playlist URL. Then switch to AudioPlayerView and then back to PlaylistView',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list of playlist's.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // The playlist list and audio list should exist now but be
      // empty (no ListTile widgets)
      expect(find.byType(ListView), findsNWidgets(2));
      expect(find.byType(ListTile), findsNothing);

      // Enter the new Youtube playlist URL into the url text field.
      // The objective is to test that the url text field will not
      // be emptied after adding a local playlist
      await tester.enterText(
        find.byKey(const Key('playlistUrlTextField')),
        youtubePlaylistUrl,
      );

      await tester.pumpAndSettle();

      // Ensure the url text field contains the entered url
      TextField urlTextField =
          tester.widget(find.byKey(const Key('playlistUrlTextField')));
      expect(urlTextField.controller!.text, youtubePlaylistUrl);

      // Now we tap on the AudioPlayerView icon button to open
      // AudioPlayerView screen

      final audioPlayerNavButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(audioPlayerNavButton);
      await tester.pumpAndSettle();

      // Now we tap on the PlaylistDownloadView icon button to go
      // back to the PlaylistDownloadView screen

      final playlistDownloadNavButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(playlistDownloadNavButton);
      await tester.pumpAndSettle();

      // Ensure the URL TextField was emptied
      urlTextField =
          tester.widget(find.byKey(const Key('playlistUrlTextField')));
      expect(urlTextField.controller!.text, '');

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
    testWidgets('Select then unselect local playlist', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      const String localPlaylistTitle = 'audio_learn_local_playlist_test';

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list of playlist's.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Open the add playlist dialog by tapping the add playlist
      // button
      await tester.tap(find.byKey(const Key('addPlaylistButton')));
      await tester.pumpAndSettle();

      // Enter the title of the local playlist
      await tester.enterText(
        find.byKey(const Key('playlistLocalTitleConfirmDialogTextField')),
        localPlaylistTitle,
      );

      // Confirm the addition by tapping the confirmation button in
      // the AlertDialog
      await tester
          .tap(find.byKey(const Key('addPlaylistConfirmDialogAddButton')));
      await tester.pumpAndSettle();

      // Close the warning dialog by tapping on the OK button
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // The list of Playlist's should have one item now
      expect(find.byType(ListTile), findsOneWidget);

      // Verify that the first ListTile checkbox is not
      // selected
      Checkbox firstListItemCheckbox = tester.widget<Checkbox>(find.descendant(
        of: find.byType(ListTile).first,
        matching: find.byWidgetPredicate((widget) => widget is Checkbox),
      ));
      expect(firstListItemCheckbox.value, isFalse);

      // Verify that the selected playlist TextField is empty
      TextField selectedPlaylistTextField =
          tester.widget(find.byKey(const Key('selectedPlaylistTextField')));
      expect(selectedPlaylistTextField.controller!.text, '');

      // Check the saved local playlist values in the json file,
      // before the playlist will be selected

      final String newPlaylistPath = path.join(
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
      expect(loadedNewPlaylist.id, localPlaylistTitle);
      expect(loadedNewPlaylist.url, '');
      expect(loadedNewPlaylist.playlistType, PlaylistType.local);
      expect(loadedNewPlaylist.playlistQuality, PlaylistQuality.voice);
      expect(loadedNewPlaylist.downloadedAudioLst.length, 0);
      expect(loadedNewPlaylist.playableAudioLst.length, 0);
      expect(loadedNewPlaylist.isSelected, false);
      expect(loadedNewPlaylist.downloadPath, newPlaylistPath);

      // Tap the first ListTile checkbox to select it
      await tester.tap(find.descendant(
        of: find.byType(ListTile).first,
        matching: find.byWidgetPredicate((widget) => widget is Checkbox),
      ));
      await tester.pumpAndSettle();

      // Verify that the selected playlist TextField contains the
      // title of the selected playlist
      selectedPlaylistTextField =
          tester.widget(find.byKey(const Key('selectedPlaylistTextField')));
      expect(selectedPlaylistTextField.controller!.text, localPlaylistTitle);

      // Check the saved local playlist values in the json file

      // Load playlist from the json file
      Playlist reloadedNewPlaylist = JsonDataService.loadFromFile(
        jsonPathFileName: newPlaylistFilePathName,
        type: Playlist,
      );

      expect(reloadedNewPlaylist.title, localPlaylistTitle);
      expect(reloadedNewPlaylist.id, localPlaylistTitle);
      expect(reloadedNewPlaylist.url, '');
      expect(reloadedNewPlaylist.playlistType, PlaylistType.local);
      expect(reloadedNewPlaylist.playlistQuality, PlaylistQuality.voice);
      expect(reloadedNewPlaylist.downloadedAudioLst.length, 0);
      expect(reloadedNewPlaylist.playableAudioLst.length, 0);
      expect(reloadedNewPlaylist.isSelected, true);
      expect(reloadedNewPlaylist.downloadPath, newPlaylistPath);

      // Now tap the first ListTile checkbox to unselect it
      await tester.tap(find.descendant(
        of: find.byType(ListTile).first,
        matching: find.byWidgetPredicate((widget) => widget is Checkbox),
      ));
      await tester.pumpAndSettle();

      // Verify that the selected playlist TextField is empty
      selectedPlaylistTextField =
          tester.widget(find.byKey(const Key('selectedPlaylistTextField')));
      expect(selectedPlaylistTextField.controller!.text, '');

      // Check the saved local playlist values in the json file

      // Load playlist from the json file
      Playlist rereloadedNewPlaylist = JsonDataService.loadFromFile(
        jsonPathFileName: newPlaylistFilePathName,
        type: Playlist,
      );

      expect(rereloadedNewPlaylist.title, localPlaylistTitle);
      expect(rereloadedNewPlaylist.id, localPlaylistTitle);
      expect(rereloadedNewPlaylist.url, '');
      expect(rereloadedNewPlaylist.playlistType, PlaylistType.local);
      expect(rereloadedNewPlaylist.playlistQuality, PlaylistQuality.voice);
      expect(rereloadedNewPlaylist.downloadedAudioLst.length, 0);
      expect(rereloadedNewPlaylist.playableAudioLst.length, 0);
      expect(rereloadedNewPlaylist.isSelected, false);
      expect(rereloadedNewPlaylist.downloadPath, newPlaylistPath);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });

    testWidgets(
        'Add Youtube and local playlist, download the Youtube playlist and restart the app',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      // Since we have to use a mock AudioDownloadVM to add the
      // youtube playlist, we can not use app.main() to start the
      // app because app.main() uses the real AudioDownloadVM
      // and we don't want to make the main.dart file dependent
      // of a mock class. So we have to start the app by hand.

      // Adding the Youtube playlist

      SettingsDataService settingsDataService = SettingsDataService(
        isTest: true,
      );
      WarningMessageVM warningMessageVM = WarningMessageVM();
      MockAudioDownloadVM mockAudioDownloadVM = MockAudioDownloadVM(
        warningMessageVM: warningMessageVM,
        isTest: true,
      );
      mockAudioDownloadVM.youtubePlaylistTitle = youtubeNewPlaylistTitle;

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        isTest: true,
      );

      // using the mockAudioDownloadVM to add the playlist
      // because YoutubeExplode can not access to internet
      // in integration tests in order to download the playlist
      // and so obtain the playlist title
      PlaylistListVM expandablePlaylistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: mockAudioDownloadVM,
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // expandablePlaylistListVM to know which playlists are
      // selected and which are not
      expandablePlaylistListVM.getUpToDateSelectablePlaylists();

      AudioPlayerVM audioPlayerVM = AudioPlayerVM(
        playlistListVM: expandablePlaylistListVM,
      );

      await _launchExpandablePlaylistListView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        expandablePlaylistListVM: expandablePlaylistListVM,
        warningMessageVM: warningMessageVM,
        audioPlayerVM: audioPlayerVM,
      );

      // Tap the 'Toggle List' button to show the list. If the list
      // is not opened, checking that a ListTile with the title of
      // the playlist was added to the list will fail
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

      // Open the add playlist dialog by tapping the add playlist
      // button
      await tester.tap(find.byKey(const Key('addPlaylistButton')));
      await tester.pumpAndSettle();

      // Confirm the addition by tapping the confirmation button in
      // the AlertDialog
      await tester
          .tap(find.byKey(const Key('addPlaylistConfirmDialogAddButton')));
      await tester.pumpAndSettle();

      // Close the warning dialog by tapping on the OK button.
      // If the warning dialog is not closed, tapping on the
      // 'Add playlist button' button will fail
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Adding the local playlist

      const String localPlaylistTitle = 'audio_learn_local_playlist_test';

      // Open the add playlist dialog by tapping the add playlist
      // button
      await tester.tap(find.byKey(const Key('addPlaylistButton')));
      await tester.pumpAndSettle();

      // Enter the title of the local playlist
      await tester.enterText(
        find.byKey(const Key('playlistLocalTitleConfirmDialogTextField')),
        localPlaylistTitle,
      );

      // Confirm the addition by tapping the confirmation button in
      // the AlertDialog
      await tester
          .tap(find.byKey(const Key('addPlaylistConfirmDialogAddButton')));
      await tester.pumpAndSettle();

      // Close the warning dialog by tapping on the OK button
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Tap the first ListTile checkbox to select it
      await tester.tap(find.descendant(
        of: find.byType(ListTile).first,
        matching: find.byWidgetPredicate((widget) => widget is Checkbox),
      ));
      await tester.pumpAndSettle();

      // Tap the 'Download All' button to download the selected playlist.
      // This download fails because YoutubeExplode can not access to
      // internet in integration tests in order to download the
      // audio's.
      await tester.tap(find.byKey(const Key('download_sel_playlists_button')));
      await tester.pumpAndSettle();

      // Downloading the Youtube playlist audio can not be done in
      // integration tests because YoutubeExplode can not access to
      // internet. Instead, the audio file and the playlist json file
      // including the audio are copied from the test save directory
      // to the download directory

      String newYoutubePlaylistTitle = 'audio_learn_new_youtube_playlist_test';
      DirUtil.copyFileToDirectorySync(
          sourceFilePathName:
              "$kDownloadAppTestSavedDataDir${path.separator}$newYoutubePlaylistTitle${path.separator}$newYoutubePlaylistTitle.json",
          targetDirectoryPath: testPlaylistDir,
          overwriteFileIfExist: true);
      DirUtil.copyFileToDirectorySync(
        sourceFilePathName:
            "$kDownloadAppTestSavedDataDir${path.separator}$newYoutubePlaylistTitle${path.separator}230701-224750-audio learn test short video two 23-06-10.mp3",
        targetDirectoryPath: testPlaylistDir,
      );

      // now close the app and then restart it in order to load the
      // copied youtube playlist

      await _launchExpandablePlaylistListView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        expandablePlaylistListVM: expandablePlaylistListVM,
        warningMessageVM: warningMessageVM,
        audioPlayerVM: audioPlayerVM,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
    testWidgets('Add Youtube playlist with invalid URL containing list=',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      // Since we have to use a mock AudioDownloadVM to add the
      // youtube playlist, we can not use app.main() to start the
      // app because app.main() uses the real AudioDownloadVM
      // and we don't want to make the main.dart file dependent
      // of a mock class. So we have to start the app by hand.

      SettingsDataService settingsDataService = SettingsDataService(
        isTest: true,
      );
      WarningMessageVM warningMessageVM = WarningMessageVM();
      MockAudioDownloadVM mockAudioDownloadVM = MockAudioDownloadVM(
        warningMessageVM: warningMessageVM,
        isTest: true,
      );
      mockAudioDownloadVM.youtubePlaylistTitle = youtubeNewPlaylistTitle;

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        isTest: true,
      );

      // using the mockAudioDownloadVM to add the playlist
      // because YoutubeExplode can not access to internet
      // in integration tests in order to download the playlist
      // and so obtain the playlist title
      PlaylistListVM expandablePlaylistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: mockAudioDownloadVM,
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // expandablePlaylistListVM to know which playlists are
      // selected and which are not
      expandablePlaylistListVM.getUpToDateSelectablePlaylists();

      AudioPlayerVM audioPlayerVM = AudioPlayerVM(
        playlistListVM: expandablePlaylistListVM,
      );

      await _launchExpandablePlaylistListView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        expandablePlaylistListVM: expandablePlaylistListVM,
        warningMessageVM: warningMessageVM,
        audioPlayerVM: audioPlayerVM,
      );

      // Tap the 'Toggle List' button to show the list. If the list
      // is not opened, checking that a ListTile with the title of
      // the playlist was added to the list will fail
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // The playlist list and audio list should exist now but be
      // empty (no ListTile widgets)
      expect(find.byType(ListView), findsNWidgets(2));
      expect(find.byType(ListTile), findsNothing);

      const String invalidYoutubePlaylistUrl = 'list=invalid';
      // Enter the invalid Youtube playlist URL into the url text
      // field
      await tester.enterText(
        find.byKey(const Key('playlistUrlTextField')),
        invalidYoutubePlaylistUrl,
      );

      // Ensure the url text field contains the entered url
      TextField urlTextField =
          tester.widget(find.byKey(const Key('playlistUrlTextField')));
      expect(urlTextField.controller!.text, invalidYoutubePlaylistUrl);

      // Open the add playlist dialog by tapping the add playlist
      // button
      await tester.tap(find.byKey(const Key('addPlaylistButton')));
      await tester.pumpAndSettle();

      // Ensure the dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);

      // Check the value of the AlertDialog dialog title
      Text alertDialogTitle =
          tester.widget(find.byKey(const Key('playlistConfirmDialogTitleKey')));
      expect(alertDialogTitle.data, 'Add Playlist');

      // Check the value of the AlertDialog dialog title comment
      Text alertDialogCommentTitleText = tester.widget(
          find.byKey(const Key('playlistTitleCommentConfirmDialogKey')));
      expect(alertDialogCommentTitleText.data,
          'Adding Youtube playlist referenced by the URL or adding a local playlist whose title must be defined.');

      // Check the value of the AlertDialog url Text
      Text confirmUrlText =
          tester.widget(find.byKey(const Key('playlistUrlConfirmDialogText')));
      expect(confirmUrlText.data, invalidYoutubePlaylistUrl);

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
          'Playlist with invalid URL "$invalidYoutubePlaylistUrl" neither added nor modified.');

      // Close the warning dialog by tapping on the OK button
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Ensure the URL TextField was emptied
      urlTextField =
          tester.widget(find.byKey(const Key('playlistUrlTextField')));
      expect(urlTextField.controller!.text, '');

      // The list of Playlist's should have zero item now
      expect(find.byType(ListTile), findsNothing);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
    testWidgets('Add Youtube playlist with invalid URL', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      // Since we have to use a mock AudioDownloadVM to add the
      // youtube playlist, we can not use app.main() to start the
      // app because app.main() uses the real AudioDownloadVM
      // and we don't want to make the main.dart file dependent
      // of a mock class. So we have to start the app by hand.

      SettingsDataService settingsDataService = SettingsDataService(
        isTest: true,
      );
      WarningMessageVM warningMessageVM = WarningMessageVM();
      MockAudioDownloadVM mockAudioDownloadVM = MockAudioDownloadVM(
        warningMessageVM: warningMessageVM,
        isTest: true,
      );
      mockAudioDownloadVM.youtubePlaylistTitle = youtubeNewPlaylistTitle;

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        isTest: true,
      );

      // using the mockAudioDownloadVM to add the playlist
      // because YoutubeExplode can not access to internet
      // in integration tests in order to download the playlist
      // and so obtain the playlist title
      PlaylistListVM expandablePlaylistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: mockAudioDownloadVM,
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // expandablePlaylistListVM to know which playlists are
      // selected and which are not
      expandablePlaylistListVM.getUpToDateSelectablePlaylists();

      AudioPlayerVM audioPlayerVM = AudioPlayerVM(
        playlistListVM: expandablePlaylistListVM,
      );

      await _launchExpandablePlaylistListView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        expandablePlaylistListVM: expandablePlaylistListVM,
        warningMessageVM: warningMessageVM,
        audioPlayerVM: audioPlayerVM,
      );

      const String invalidYoutubePlaylistUrl = 'invalid';

      // Enter the invalid Youtube playlist URL into the url text
      // field
      await tester.enterText(
        find.byKey(const Key('playlistUrlTextField')),
        invalidYoutubePlaylistUrl,
      );

      // Ensure the url text field contains the entered url
      TextField urlTextField =
          tester.widget(find.byKey(const Key('playlistUrlTextField')));
      expect(urlTextField.controller!.text, invalidYoutubePlaylistUrl);

      // Open the add playlist dialog by tapping the add playlist
      // button
      await tester.tap(find.byKey(const Key('addPlaylistButton')));
      await tester.pumpAndSettle();

      // Ensure the dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);

      // Check the value of the AlertDialog dialog title
      Text alertDialogTitle =
          tester.widget(find.byKey(const Key('playlistConfirmDialogTitleKey')));
      expect(alertDialogTitle.data, 'Add Playlist');

      // Check the value of the AlertDialog dialog title comment
      Text alertDialogCommentTitleText = tester.widget(
          find.byKey(const Key('playlistTitleCommentConfirmDialogKey')));
      expect(alertDialogCommentTitleText.data,
          'Adding Youtube playlist referenced by the URL or adding a local playlist whose title must be defined.');

      // Check the value of the AlertDialog url Text
      Text confirmUrlText =
          tester.widget(find.byKey(const Key('playlistUrlConfirmDialogText')));
      expect(confirmUrlText.data, invalidYoutubePlaylistUrl);

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
          'Playlist with invalid URL "$invalidYoutubePlaylistUrl" neither added nor modified.');

      // Close the warning dialog by tapping on the OK button
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Ensure the URL TextField was emptied
      urlTextField =
          tester.widget(find.byKey(const Key('playlistUrlTextField')));
      expect(urlTextField.controller!.text, '');

      // The list of Playlist's should have zero item now
      expect(find.byType(ListTile), findsNothing);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
    testWidgets('Download single video audio with invalid URL', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}copy_move_audio_integr_test_data",
        destinationRootPath: kDownloadAppTestDirWindows,
      );

      const String localAudioPlaylistTitle = 'local_audio_playlist_2';

      SettingsDataService settingsDataService =
          SettingsDataService(isTest: true);

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      settingsDataService.loadSettingsFromFile(
          jsonPathFileName:
              "$kDownloadAppTestDirWindows${path.separator}$kSettingsFileName");

      // Since we have to use a mock AudioDownloadVM to add the
      // youtube playlist, we can not use app.main() to start the
      // app because app.main() uses the real AudioDownloadVM
      // and we don't want to make the main.dart file dependent
      // of a mock class. So we have to start the app by hand.

      WarningMessageVM warningMessageVM = WarningMessageVM();
      MockAudioDownloadVM mockAudioDownloadVM = MockAudioDownloadVM(
        warningMessageVM: warningMessageVM,
        isTest: true,
      );
      mockAudioDownloadVM.youtubePlaylistTitle = youtubeNewPlaylistTitle;

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        isTest: true,
      );

      // using the mockAudioDownloadVM to add the playlist
      // because YoutubeExplode can not access to internet
      // in integration tests in order to download the playlist
      // and so obtain the playlist title
      PlaylistListVM expandablePlaylistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: mockAudioDownloadVM,
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // expandablePlaylistListVM to know which playlists are
      // selected and which are not
      expandablePlaylistListVM.getUpToDateSelectablePlaylists();

      AudioPlayerVM audioPlayerVM = AudioPlayerVM(
        playlistListVM: expandablePlaylistListVM,
      );

      await _launchExpandablePlaylistListView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        expandablePlaylistListVM: expandablePlaylistListVM,
        warningMessageVM: warningMessageVM,
        audioPlayerVM: audioPlayerVM,
      );

      const String invalidSingleVideoUrl = 'invalid';

      // Enter the invalid single video URL into the url text
      // field
      await tester.enterText(
        find.byKey(const Key('playlistUrlTextField')),
        invalidSingleVideoUrl,
      );

      // Ensure the url text field contains the entered url
      TextField urlTextField =
          tester.widget(find.byKey(const Key('playlistUrlTextField')));
      expect(urlTextField.controller!.text, invalidSingleVideoUrl);

      // Open the target playlist selection dialog by tapping the
      // download single video button
      await tester.tap(find.byKey(const Key('downloadSingleVideoButton')));
      await tester.pumpAndSettle();

      // Ensure the dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);

      // Check the value of the select one playlist AlertDialog
      // dialog title
      Text alertDialogTitle = tester
          .widget(find.byKey(const Key('playlistOneSelectableDialogTitleKey')));
      expect(alertDialogTitle.data, 'Select a playlist');

      // Find the RadioListTile target playlist in which the audio
      // will be downloaded

      final Finder radioListTile = find.byWidgetPredicate(
        (Widget widget) =>
            widget is RadioListTile &&
            widget.title is Text &&
            (widget.title as Text).data == localAudioPlaylistTitle,
      );

      // Tap the target playlist RadioListTile to select it
      await tester.tap(radioListTile);
      await tester.pumpAndSettle();

      // Now find the confirm button and tap on it
      await tester.tap(find.byKey(const Key('confirmButton')));
      await tester.pumpAndSettle();

      // Now verifying the confirm warning dialog message

      // Check the value of the select one playlist
      // confirmation dialog title
      Text confirmationDialogTitle =
          tester.widget(find.byKey(const Key('confirmationDialogTitleKey')));
      expect(confirmationDialogTitle.data, 'CONFIRMATION');

      final Text confirmationDialogMessageTextWidget = tester
          .widget<Text>(find.byKey(const Key('confirmationDialogMessageKey')));

      expect(confirmationDialogMessageTextWidget.data,
          'Confirm target playlist "$localAudioPlaylistTitle" for downloading single video audio.');

      // Now find the ok button of the confirm warning dialog
      // and tap on it
      await tester.tap(find.byKey(const Key('okButtonKey')));
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
          'Single video with invalid URL "$invalidSingleVideoUrl" could not be downloaded.');

      // Close the warning dialog by tapping on the OK button
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Ensure the URL TextField containing the invalid single
      // video URL was not emptied
      urlTextField =
          tester.widget(find.byKey(const Key('playlistUrlTextField')));
      expect(urlTextField.controller!.text, invalidSingleVideoUrl);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
  });
  group('AudioDownloadVM using CustomMockYoutubeExplode Tests', () {
    late SingleVideoAudioDownloadVM singleVideoAudioDownloadVM;
    late CustomMockYoutubeExplode mockYoutubeExplode;

    setUp(() {
      mockYoutubeExplode = CustomMockYoutubeExplode();
      singleVideoAudioDownloadVM =
          SingleVideoAudioDownloadVM(youtubeExplode: mockYoutubeExplode);
    });

    test('Échec du téléchargement lorsque le service renvoie une erreur',
        () async {
      Playlist singleVideoTargetPlaylist = Playlist(
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      expect(
        await singleVideoAudioDownloadVM.downloadSingleVideoAudio(
          videoUrl: 'invalid_url',
          singleVideoTargetPlaylist: singleVideoTargetPlaylist,
        ),
        false,
      );
    });

    testWidgets(
        'Download single video audio in playlist already containing the audio',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}copy_move_audio_integr_test_data",
        destinationRootPath: kDownloadAppTestDirWindows,
      );

      SettingsDataService settingsDataService =
          SettingsDataService(isTest: true);

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      settingsDataService.loadSettingsFromFile(
          jsonPathFileName:
              "$kDownloadAppTestDirWindows${path.separator}$kSettingsFileName");

      // Since we have to use a mock AudioDownloadVM to add the
      // youtube playlist, we can not use app.main() to start the
      // app because app.main() uses the real AudioDownloadVM
      // and we don't want to make the main.dart file dependent
      // of a mock class. So we have to start the app by hand.

      WarningMessageVM warningMessageVM = WarningMessageVM();
      // MockAudioDownloadVM mockAudioDownloadVM = MockAudioDownloadVM(
      //   warningMessageVM: warningMessageVM,
      //   isTest: true,
      // );
      // mockAudioDownloadVM.youtubePlaylistTitle = youtubeNewPlaylistTitle;

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        isTest: true,
      );

      audioDownloadVM.youtubeExplode = mockYoutubeExplode;

      PlaylistListVM expandablePlaylistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // expandablePlaylistListVM to know which playlists are
      // selected and which are not
      expandablePlaylistListVM.getUpToDateSelectablePlaylists();

      AudioPlayerVM audioPlayerVM = AudioPlayerVM(
        playlistListVM: expandablePlaylistListVM,
      );

      await _launchExpandablePlaylistListView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        expandablePlaylistListVM: expandablePlaylistListVM,
        warningMessageVM: warningMessageVM,
        audioPlayerVM: audioPlayerVM,
      );

      const String youtubeAudioSourceAndTargetPlaylistTitle =
          'audio_learn_test_download_2_small_videos';
      const String downloadedSingleVideoAudioTitle =
          'audio learn test short video one';

      // Copy the URL of source playlist audio file which wiil
      // be downloaded to the same (source) playlist, causing a
      // warning error to be displayed ...

      // Tap the 'Toggle List' button to show the list of playlist's.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the ListTile Playlist containing the audio to move to
      // the source Youtube playlist

      // First, find the Playlist ListTile Text widget
      final Finder sourcePlaylistListTileTextWidgetFinder =
          find.text(youtubeAudioSourceAndTargetPlaylistTitle);

      // Then obtain the Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      final Finder sourcePlaylistListTileWidgetFinder = find.ancestor(
        of: sourcePlaylistListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      final Finder sourcePlaylistListTileCheckboxWidgetFinder = find.descendant(
        of: sourcePlaylistListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(sourcePlaylistListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Now we want to tap the popup menu of the Audio ListTile
      // "audio learn test short video one"

      // First, find the Audio sublist ListTile Text widget
      final Finder sourceAudioListTileTextWidgetFinder =
          find.text(downloadedSingleVideoAudioTitle);

      // Then obtain the Audio ListTile widget enclosing the Text widget by
      // finding its ancestor
      final Finder sourceAudioListTileWidgetFinder = find.ancestor(
        of: sourceAudioListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the leading menu icon button of the Audio ListTile and tap
      // on it
      final Finder sourceAudioListTileLeadingMenuIconButton = find.descendant(
        of: sourceAudioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(sourceAudioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the copy video URL popup menu item and tap on it
      final Finder popupCopyVideoUrlMenuItem =
          find.byKey(const Key("popup_copy_youtube_video_url"));

      await tester.tap(popupCopyVideoUrlMenuItem);
      await tester.pumpAndSettle(); // Wait for tap action to complete

      ClipboardData? clipboardData =
          await Clipboard.getData(Clipboard.kTextPlain);
      String singleVideoToDownloadUrl = clipboardData?.text ?? '';
      print('***** Single video URL: $singleVideoToDownloadUrl');

      // Enter the single video URL to download into the url text
      // field
      await tester.enterText(
        find.byKey(const Key('playlistUrlTextField')),
        singleVideoToDownloadUrl,
      );

      // Ensure the url text field contains the entered url
      TextField urlTextField =
          tester.widget(find.byKey(const Key('playlistUrlTextField')));
      expect(urlTextField.controller!.text, singleVideoToDownloadUrl);

      // Open the target playlist selection dialog by tapping the
      // download single video button
      await tester.tap(find.byKey(const Key('downloadSingleVideoButton')));
      await tester.pumpAndSettle();

      // Ensure the dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);

      // Check the value of the select one playlist AlertDialog
      // dialog title
      Text alertDialogTitle = tester
          .widget(find.byKey(const Key('playlistOneSelectableDialogTitleKey')));
      expect(alertDialogTitle.data, 'Select a playlist');

      // Find the RadioListTile target playlist to which the audio
      // will be downloaded

      final Finder radioListTile = find.byWidgetPredicate(
        (Widget widget) =>
            widget is RadioListTile &&
            widget.title is Text &&
            (widget.title as Text).data ==
                youtubeAudioSourceAndTargetPlaylistTitle,
      );

      // Tap the target playlist RadioListTile to select it
      await tester.tap(radioListTile);
      await tester.pumpAndSettle();

      // Now find the confirm button and tap on it
      await tester.tap(find.byKey(const Key('confirmButton')));
      await tester.pumpAndSettle();

      // Now verifying the confirm warning dialog message

      // Check the value of the select one playlist
      // confirmation dialog title
      Text confirmationDialogTitle =
          tester.widget(find.byKey(const Key('confirmationDialogTitleKey')));
      expect(confirmationDialogTitle.data, 'CONFIRMATION');

      final Text confirmationDialogMessageTextWidget = tester
          .widget<Text>(find.byKey(const Key('confirmationDialogMessageKey')));

      expect(confirmationDialogMessageTextWidget.data,
          'Confirm target playlist "$youtubeAudioSourceAndTargetPlaylistTitle" for downloading single video audio.');

      // Now find the ok button of the confirm warning dialog
      // and tap on it\
      await tester.tap(find.byKey(const Key('okButtonKey')));
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
      String expectedWarningDialogMessageStr =
          'Audio "$downloadedSingleVideoAudioTitle" is contained in file "230628-033811-audio learn test short video one 23-06-10.mp3" present in the target playlist "$youtubeAudioSourceAndTargetPlaylistTitle" directory and so won\'t be redownloaded.';
      expect(
        warningDialogMessage.data,
        expectedWarningDialogMessageStr,
      );

      // Close the warning dialog by tapping on the OK button
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Ensure the URL TextField containing the invalid single
      // video URL was not emptied
      urlTextField =
          tester.widget(find.byKey(const Key('playlistUrlTextField')));
      expect(urlTextField.controller!.text, singleVideoToDownloadUrl);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
  });
  group('Settings update test', () {
    testWidgets('After moving down a playlist item', (tester) async {
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

      SettingsDataService settingsDataService =
          SettingsDataService(isTest: true);

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      settingsDataService.loadSettingsFromFile(
          jsonPathFileName:
              "$kDownloadAppTestDirWindows${path.separator}$kSettingsFileName");

      expect(
          settingsDataService.get(
            settingType: SettingType.playlists,
            settingSubType: Playlists.orderedTitleLst,
          ),
          ['local_music', 'audio_learn_new_youtube_playlist_test']);

      const String localMusicPlaylistTitle = 'local_music';
      const String localAudioPlaylistTitle = 'local_audio';

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list. If the list
      // is not opened, checking that a ListTile with the title of
      // the playlist was added to the list will fail
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

      // Enter the title of the local playlist to add
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

      final String newPlaylistPath = path.join(
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
      expect(loadedNewPlaylist.id, localAudioPlaylistTitle);
      expect(loadedNewPlaylist.url, '');
      expect(loadedNewPlaylist.playlistType, PlaylistType.local);
      expect(loadedNewPlaylist.playlistQuality, PlaylistQuality.voice);
      expect(loadedNewPlaylist.downloadedAudioLst.length, 0);
      expect(loadedNewPlaylist.playableAudioLst.length, 0);
      expect(loadedNewPlaylist.isSelected, false);
      expect(loadedNewPlaylist.downloadPath, newPlaylistPath);

      // reload the settings from the json file to verify it was
      // updated correctly

      settingsDataService.loadSettingsFromFile(
          jsonPathFileName:
              "$kDownloadAppTestDirWindows${path.separator}$kSettingsFileName");

      expect(
          settingsDataService.get(
            settingType: SettingType.playlists,
            settingSubType: Playlists.orderedTitleLst,
          ),
          [
            'local_music',
            'audio_learn_new_youtube_playlist_test',
            'local_audio',
          ]);

      // now move down the added playlist to the second position
      // in the list

      // Find and select the ListTile to move'
      const String playlistToMoveDownTitle = 'local_audio';

      await findThenSelectAndTestListTileCheckbox(
        tester: tester,
        itemTextStr: playlistToMoveDownTitle,
      );

      Finder dowButtonFinder =
          find.widgetWithIcon(IconButton, Icons.arrow_drop_down);
      IconButton downButton = tester.widget<IconButton>(dowButtonFinder);
      expect(downButton.onPressed, isNotNull);

      // Tap the move down button twice
      await tester.tap(dowButtonFinder);
      await tester.pump();
      await tester.tap(dowButtonFinder);
      await tester.pump();

      // reload the settings from the json file to verify it was
      // updated correctly

      settingsDataService.loadSettingsFromFile(
          jsonPathFileName:
              "$kDownloadAppTestDirWindows${path.separator}$kSettingsFileName");

      expect(
          settingsDataService.get(
            settingType: SettingType.playlists,
            settingSubType: Playlists.orderedTitleLst,
          ),
          [
            'local_music',
            'local_audio',
            'audio_learn_new_youtube_playlist_test',
          ]);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
  });
  group('Copy or move audio test', () {
    testWidgets('Copy audio twice, then 3rd time click on cancel button',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}copy_move_audio_integr_test_data",
        destinationRootPath: kDownloadAppTestDirWindows,
      );

      const String youtubeAudioSourcePlaylistTitle =
          'audio_learn_test_download_2_small_videos';
      const String localAudioPlaylistTitle = 'local_audio_playlist_2';
      const String copiedAudioTitle = 'audio learn test short video one';

      SettingsDataService settingsDataService =
          SettingsDataService(isTest: true);

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      settingsDataService.loadSettingsFromFile(
          jsonPathFileName:
              "$kDownloadAppTestDirWindows${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list. If the list
      // is not opened, checking that a ListTile with the title of
      // the playlist was added to the list will fail
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the ListTile Playlist containing the audio to copy to
      // the target local playlist

      // First, find the Playlist ListTile Text widget
      final Finder sourcePlaylistListTileTextWidgetFinder =
          find.text(youtubeAudioSourcePlaylistTitle);

      // Then obtain the Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      final Finder sourcePlaylistListTileWidgetFinder = find.ancestor(
        of: sourcePlaylistListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      final Finder sourcePlaylistListTileCheckboxWidgetFinder = find.descendant(
        of: sourcePlaylistListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(sourcePlaylistListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Now we want to tap the popup menu of the Audio ListTile
      // "audio learn test short video one"

      // First, find the Audio sublist ListTile Text widget
      final Finder sourceAudioListTileTextWidgetFinder =
          find.text(copiedAudioTitle);

      // Then obtain the Audio ListTile widget enclosing the Text widget by
      // finding its ancestor
      final Finder sourceAudioListTileWidgetFinder = find.ancestor(
        of: sourceAudioListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the leading menu icon button of the Audio ListTile
      // and tap on it
      final Finder sourceAudioListTileLeadingMenuIconButton = find.descendant(
        of: sourceAudioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(sourceAudioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the copy audio popup menu item and tap on it
      final Finder popupCopyMenuItem =
          find.byKey(const Key("popup_menu_copy_audio_to_playlist"));

      await tester.tap(popupCopyMenuItem);
      await tester.pumpAndSettle(); // Wait for tap action to complete

      // Check the value of the select one playlist AlertDialog
      // dialog title
      Text alertDialogTitle = tester
          .widget(find.byKey(const Key('playlistOneSelectableDialogTitleKey')));
      expect(alertDialogTitle.data, 'Sélectionnez une playlist');

      // Find the RadioListTile target playlist to which the audio
      // will be copied

      final Finder radioListTile = find.byWidgetPredicate(
        (Widget widget) =>
            widget is RadioListTile &&
            widget.title is Text &&
            (widget.title as Text).data == localAudioPlaylistTitle,
      );

      // Tap the target playlist RadioListTile to select it
      await tester.tap(radioListTile);
      await tester.pumpAndSettle();

      // Now find the confirm button and tap on it
      await tester.tap(find.byKey(const Key('confirmButton')));
      await tester.pumpAndSettle();

      // Now verifying the confirm warning dialog message

      final Text warningDialogMessageTextWidget =
          tester.widget<Text>(find.byKey(const Key('warningDialogMessage')));

      expect(warningDialogMessageTextWidget.data,
          'Audio "audio learn test short video one" copié de la playlist Youtube "audio_learn_test_download_2_small_videos" vers la playlist locale "local_audio_playlist_2".');

      // Now find the ok button of the confirm warning dialog
      // and tap on it
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Now verifying the selected playlist TextField still
      // contains the title of the source playlist

      final TextField selectedPlaylistTextField = tester.widget<TextField>(
          find.byKey(const Key('selectedPlaylistTextField')));

      expect(selectedPlaylistTextField.controller!.text,
          youtubeAudioSourcePlaylistTitle);

      List<String> sourcePlaylistMp3Lst = DirUtil.listFileNamesInDir(
        path:
            '$kDownloadAppTestDirWindows${path.separator}$youtubeAudioSourcePlaylistTitle',
        extension: 'mp3',
      );

      List<String> targetPlaylistMp3Lst = DirUtil.listFileNamesInDir(
        path:
            '$kDownloadAppTestDirWindows${path.separator}$localAudioPlaylistTitle',
        extension: 'mp3',
      );

      expect(sourcePlaylistMp3Lst, [
        "230628-033811-audio learn test short video one 23-06-10.mp3",
        "230628-033813-audio learn test short video two 23-06-10.mp3",
      ]);
      expect(targetPlaylistMp3Lst,
          ["230628-033811-audio learn test short video one 23-06-10.mp3"]);

      // Find the target ListTile Playlist containing the audio copied
      // from the source playlist

      // First, find the Playlist ListTile Text widget
      final Finder targetPlaylistListTileTextWidgetFinder =
          find.text(localAudioPlaylistTitle);

      // Then obtain the Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      final Finder targetPlaylistListTileWidgetFinder = find.ancestor(
        of: targetPlaylistListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      final Finder targetPlaylistListTileCheckboxWidgetFinder = find.descendant(
        of: targetPlaylistListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(targetPlaylistListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Now we want to tap the popup menu of the Audio ListTile
      // "audio learn test short video one"

      // First, find the Audio sublist ListTile Text widget
      final Finder targetAudioListTileTextWidgetFinder =
          find.text(copiedAudioTitle);

      // Then obtain the Audio ListTile widget enclosing the Text widget by
      // finding its ancestor
      final Finder targetAudioListTileWidgetFinder = find.ancestor(
        of: targetAudioListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the leading menu icon button of the Audio ListTile and tap
      // on it
      final Finder targetAudioListTileLeadingMenuIconButton = find.descendant(
        of: targetAudioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(targetAudioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the popup menu item and tap on it
      final Finder popupDisplayAudioInfoMenuItem =
          find.byKey(const Key("popup_menu_display_audio_info"));

      await tester.tap(popupDisplayAudioInfoMenuItem);
      await tester.pumpAndSettle(); // Wait for tap action to complete

      // Now verifying the display audio info audio copied dialog
      // elements

      // Verify the enclosing playlist title of the copied audio

      final Text enclosingPlaylistTitleTextWidget = tester
          .widget<Text>(find.byKey(const Key('enclosingPlaylistTitleKey')));

      expect(enclosingPlaylistTitleTextWidget.data, localAudioPlaylistTitle);

      // Verify the copied from playlist title of the copied audio

      final Text copiedFromPlaylistTitleTextWidget = tester
          .widget<Text>(find.byKey(const Key('copiedFromPlaylistTitleKey')));

      expect(copiedFromPlaylistTitleTextWidget.data,
          youtubeAudioSourcePlaylistTitle);

      // Verify the copied to playlist title of the copied audio

      final Text copiedToPlaylistTitleTextWidget = tester
          .widget<Text>(find.byKey(const Key('copiedToPlaylistTitleKey')));

      expect(copiedToPlaylistTitleTextWidget.data, '');

      // Now find the ok button of the confirm warning dialog
      // and tap on it
      await tester.tap(find.byKey(const Key('audioInfoOkButtonKey')));
      await tester.pumpAndSettle();

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
    testWidgets('Copy audio from Youtube to local playlist, then from local to other Youtube playlist. Then delete the audio from the other Youtube playlist. No warning.',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}2_youtube_2_local_playlists_integr_test_data",
        destinationRootPath: kDownloadAppTestDirWindows,
      );

      const String youtubeAudioSourcePlaylistTitle =
          'audio_learn_test_download_2_small_videos';
      const String localAudioTargetSourcePlaylistTitle = 'local_audio_playlist_2';
      const String copiedAudioTitle = 'audio learn test short video one';
      const String youtubeAudioTargetPlaylistTitle =
          'audio_player_view_2_shorts_test';

      SettingsDataService settingsDataService =
          SettingsDataService(isTest: true);

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      settingsDataService.loadSettingsFromFile(
          jsonPathFileName:
              "$kDownloadAppTestDirWindows${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // *** First test part: Copy audio from Youtube to local
      // playlist

      // Tap the 'Toggle List' button to show the list. If the list
      // is not opened, checking that a ListTile with the title of
      // the playlist was added to the list will fail
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the ListTile Playlist containing the audio to copy to
      // the target local playlist

      // First, find the Youtube source playlist ListTile Text widget
      final Finder youtubeAudioSourcePlaylistListTileTextWidgetFinder =
          find.text(youtubeAudioSourcePlaylistTitle);

      // Then obtain the Youtube source playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      final Finder youtubeAudioSourcePlaylistListTileWidgetFinder = find.ancestor(
        of: youtubeAudioSourcePlaylistListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the playlist ListTile
      // and tap on it to select the playlist
      final Finder sourcePlaylistListTileCheckboxWidgetFinder = find.descendant(
        of: youtubeAudioSourcePlaylistListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile playlist checkbox to select it
      await tester.tap(sourcePlaylistListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Now we want to tap the popup menu of the Audio ListTile
      // "audio learn test short video one"

      // First, find the Audio sublist ListTile Text widget
      final Finder sourceAudioListTileTextWidgetFinder =
          find.text(copiedAudioTitle);

      // Then obtain the Audio ListTile widget enclosing the Text widget by
      // finding its ancestor
      final Finder sourceAudioListTileWidgetFinder = find.ancestor(
        of: sourceAudioListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the leading menu icon button of the Audio ListTile
      // and tap on it
      final Finder sourceAudioListTileLeadingMenuIconButton = find.descendant(
        of: sourceAudioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(sourceAudioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the copy audio popup menu item and tap on it
      final Finder popupCopyMenuItem =
          find.byKey(const Key("popup_menu_copy_audio_to_playlist"));

      await tester.tap(popupCopyMenuItem);
      await tester.pumpAndSettle(); // Wait for tap action to complete

      // Check the value of the select one playlist AlertDialog
      // dialog title
      Text alertDialogTitle = tester
          .widget(find.byKey(const Key('playlistOneSelectableDialogTitleKey')));
      expect(alertDialogTitle.data, 'Sélectionnez une playlist');

      // Find the RadioListTile target playlist to which the audio
      // will be copied

      final Finder radioListTile = find.byWidgetPredicate(
        (Widget widget) =>
            widget is RadioListTile &&
            widget.title is Text &&
            (widget.title as Text).data == localAudioTargetSourcePlaylistTitle,
      );

      // Tap the target playlist RadioListTile to select it
      await tester.tap(radioListTile);
      await tester.pumpAndSettle();

      // Now find the confirm button and tap on it
      await tester.tap(find.byKey(const Key('confirmButton')));
      await tester.pumpAndSettle();

      // Now verifying the confirm warning dialog message

      Text warningDialogMessageTextWidget =
          tester.widget<Text>(find.byKey(const Key('warningDialogMessage')));

      expect(warningDialogMessageTextWidget.data,
          'Audio "$copiedAudioTitle" copié de la playlist Youtube "$youtubeAudioSourcePlaylistTitle" vers la playlist locale "$localAudioTargetSourcePlaylistTitle".');

      // Now find the ok button of the confirm warning dialog
      // and tap on it
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Now verifying the selected playlist TextField still
      // contains the title of the source playlist

      TextField selectedPlaylistTextField = tester.widget<TextField>(
          find.byKey(const Key('selectedPlaylistTextField')));

      expect(selectedPlaylistTextField.controller!.text,
          youtubeAudioSourcePlaylistTitle);

      // Now verifying the audio was physically copied to the target
      // playlist directory.

      List<String> sourcePlaylistMp3Lst = DirUtil.listFileNamesInDir(
        path:
            '$kDownloadAppTestDirWindows${path.separator}$youtubeAudioSourcePlaylistTitle',
        extension: 'mp3',
      );

      List<String> targetPlaylistMp3Lst = DirUtil.listFileNamesInDir(
        path:
            '$kDownloadAppTestDirWindows${path.separator}$localAudioTargetSourcePlaylistTitle',
        extension: 'mp3',
      );

      // Verify the Youtube source playlist directory content
      expect(sourcePlaylistMp3Lst, [
        "230628-033811-audio learn test short video one 23-06-10.mp3",
        "230628-033813-audio learn test short video two 23-06-10.mp3",
      ]);

      // Verify the local target playlist directory content
      expect(targetPlaylistMp3Lst,
          ["230628-033811-audio learn test short video one 23-06-10.mp3"]);

      // Find the target ListTile Playlist containing the audio copied
      // from the source playlist

      // First, find the Playlist ListTile Text widget
      final Finder targetPlaylistListTileTextWidgetFinder =
          find.text(localAudioTargetSourcePlaylistTitle);

      // Then obtain the Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      final Finder targetPlaylistListTileWidgetFinder = find.ancestor(
        of: targetPlaylistListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      final Finder targetPlaylistListTileCheckboxWidgetFinder = find.descendant(
        of: targetPlaylistListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(targetPlaylistListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Now we want to tap the popup menu of the Audio ListTile
      // "audio learn test short video one"

      // First, find the Audio sublist ListTile Text widget
      final Finder targetAudioListTileTextWidgetFinder =
          find.text(copiedAudioTitle);

      // Then obtain the Audio ListTile widget enclosing the Text widget by
      // finding its ancestor
      final Finder targetAudioListTileWidgetFinder = find.ancestor(
        of: targetAudioListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the leading menu icon button of the Audio ListTile and tap
      // on it
      final Finder targetAudioListTileLeadingMenuIconButton = find.descendant(
        of: targetAudioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(targetAudioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the popup menu item and tap on it
      Finder popupDisplayAudioInfoMenuItem =
          find.byKey(const Key("popup_menu_display_audio_info"));

      await tester.tap(popupDisplayAudioInfoMenuItem);
      await tester.pumpAndSettle(); // Wait for tap action to complete

      // Now verifying the display audio info audio copied dialog
      // elements

      // Verify the enclosing playlist title of the copied audio

      Text enclosingPlaylistTitleTextWidget = tester
          .widget<Text>(find.byKey(const Key('enclosingPlaylistTitleKey')));

      expect(enclosingPlaylistTitleTextWidget.data, localAudioTargetSourcePlaylistTitle);

      // Verify the copied from playlist title of the copied audio

      Text copiedFromPlaylistTitleTextWidget = tester
          .widget<Text>(find.byKey(const Key('copiedFromPlaylistTitleKey')));

      expect(copiedFromPlaylistTitleTextWidget.data,
          youtubeAudioSourcePlaylistTitle);

      // Verify the copied to playlist title of the copied audio

      Text copiedToPlaylistTitleTextWidget = tester
          .widget<Text>(find.byKey(const Key('copiedToPlaylistTitleKey')));

      expect(copiedToPlaylistTitleTextWidget.data, '');

      // Now find the ok button of the confirm warning dialog
      // and tap on it
      await tester.tap(find.byKey(const Key('audioInfoOkButtonKey')));
      await tester.pumpAndSettle();

      // """ Second test part: Copy audio from local playlist to
      // other Youtube playlist

      // Currently, the local audio target source playlist is selected

      // Now we want to tap the popup menu of the Audio ListTile
      // "audio learn test short video one"

      // First, find the Audio sublist ListTile Text widget
      final Finder localSourceAudioListTileTextWidgetFinder =
          find.text(copiedAudioTitle);

      // Then obtain the Audio ListTile widget enclosing the Text widget by
      // finding its ancestor
      final Finder localSourceAudioListTileWidgetFinder = find.ancestor(
        of: localSourceAudioListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the leading menu icon button of the Audio ListTile
      // and tap on it
      final Finder localSourceAudioListTileLeadingMenuIconButton = find.descendant(
        of: localSourceAudioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(localSourceAudioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the copy audio popup menu item and tap on it
      final Finder localSourceAudioPopupCopyMenuItem =
          find.byKey(const Key("popup_menu_copy_audio_to_playlist"));

      await tester.tap(localSourceAudioPopupCopyMenuItem);
      await tester.pumpAndSettle(); // Wait for tap action to complete

      // Find the RadioListTile target playlist to which the audio
      // will be copied

      final Finder secondYoutubeTargetRadioListTile = find.byWidgetPredicate(
        (Widget widget) =>
            widget is RadioListTile &&
            widget.title is Text &&
            (widget.title as Text).data == youtubeAudioTargetPlaylistTitle,
      );

      // Tap the target playlist RadioListTile to select it
      await tester.tap(secondYoutubeTargetRadioListTile);
      await tester.pumpAndSettle();

      // Now find the confirm button and tap on it
      await tester.tap(find.byKey(const Key('confirmButton')));
      await tester.pumpAndSettle();

      // Now verifying the confirm warning dialog message

      warningDialogMessageTextWidget =
          tester.widget<Text>(find.byKey(const Key('warningDialogMessage')));

      expect(warningDialogMessageTextWidget.data,
          'Audio "$copiedAudioTitle" copié de la playlist locale "$localAudioTargetSourcePlaylistTitle" vers la playlist Youtube "$youtubeAudioTargetPlaylistTitle".');

      // Now find the ok button of the confirm warning dialog
      // and tap on it
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Now verifying the selected playlist TextField still
      // contains the title of the source playlist

      selectedPlaylistTextField = tester.widget<TextField>(
          find.byKey(const Key('selectedPlaylistTextField')));

      expect(selectedPlaylistTextField.controller!.text,
          localAudioTargetSourcePlaylistTitle);

      // Now verifying the audio was physically copied to the target
      // playlist directory.

      sourcePlaylistMp3Lst = DirUtil.listFileNamesInDir(
        path:
            '$kDownloadAppTestDirWindows${path.separator}$localAudioTargetSourcePlaylistTitle',
        extension: 'mp3',
      );

      targetPlaylistMp3Lst = DirUtil.listFileNamesInDir(
        path:
            '$kDownloadAppTestDirWindows${path.separator}$youtubeAudioTargetPlaylistTitle',
        extension: 'mp3',
      );

      // Verify the local source playlist directory content
      expect(sourcePlaylistMp3Lst,
          ["230628-033811-audio learn test short video one 23-06-10.mp3"]);

      // Verify the Youtube target playlist directory content
      expect(targetPlaylistMp3Lst, [
        "230628-033811-audio learn test short video one 23-06-10.mp3",
        "231117-002826-Really short video 23-07-01.mp3",
        "231117-002828-morning _ cinematic video 23-07-01.mp3",
      ]);

      // Find the target Youtube ListTile Playlist containing the audio
      // copied from the local source playlist

      // First, find the Youtube target playlist ListTile Text widget
      final Finder youtubeAudioTargetPlaylistListTileTextWidgetFinder =
          find.text(youtubeAudioTargetPlaylistTitle);

      // Then obtain the Youtube target playlist ListTile widget enclosing
      // the Text widget by finding its ancestor
      final Finder youtubeAudioTargetPlaylistListTileWidgetFinder = find.ancestor(
        of: youtubeAudioTargetPlaylistListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the playlist ListTile
      // and tap on it to select the playlist
      final Finder youtubeAudioTargetPlaylistListTileCheckboxWidgetFinder = find.descendant(
        of: youtubeAudioTargetPlaylistListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile playlist checkbox to select it
      await tester.tap(youtubeAudioTargetPlaylistListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Now we want to tap the popup menu of the Audio ListTile
      // "audio learn test short video one"

      // First, find the Audio sublist ListTile Text widget
      final Finder youtubeTargetAudioListTileTextWidgetFinder =
          find.text(copiedAudioTitle);

      // Then obtain the Audio ListTile widget enclosing the Text widget by
      // finding its ancestor
      final Finder youtubeTargetAudioListTileWidgetFinder = find.ancestor(
        of: youtubeTargetAudioListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the leading menu icon button of the Audio ListTile
      // and tap on it
      final Finder youtubeTargetAudioListTileLeadingMenuIconButton = find.descendant(
        of: youtubeTargetAudioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(youtubeTargetAudioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the popup menu item and tap on it
      popupDisplayAudioInfoMenuItem =
          find.byKey(const Key("popup_menu_display_audio_info"));

      await tester.tap(popupDisplayAudioInfoMenuItem);
      await tester.pumpAndSettle(); // Wait for tap action to complete

      // Now verifying the display audio info audio copied dialog
      // elements

      // Verify the enclosing playlist title of the copied audio

      enclosingPlaylistTitleTextWidget = tester
          .widget<Text>(find.byKey(const Key('enclosingPlaylistTitleKey')));

      expect(enclosingPlaylistTitleTextWidget.data, youtubeAudioTargetPlaylistTitle);

      // Verify the copied from playlist title of the copied audio

      copiedFromPlaylistTitleTextWidget = tester
          .widget<Text>(find.byKey(const Key('copiedFromPlaylistTitleKey')));

      expect(copiedFromPlaylistTitleTextWidget.data,
          localAudioTargetSourcePlaylistTitle);

      // Verify the copied to playlist title of the copied audio

      copiedToPlaylistTitleTextWidget = tester
          .widget<Text>(find.byKey(const Key('copiedToPlaylistTitleKey')));

      expect(copiedToPlaylistTitleTextWidget.data, '');

      // Now find the ok button of the confirm warning dialog
      // and tap on it
      await tester.tap(find.byKey(const Key('audioInfoOkButtonKey')));
      await tester.pumpAndSettle();






      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
    testWidgets(
        'Move audio from Youtube to local playlist, then move it back, then remove it, then remove it back',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}copy_move_audio_integr_test_data",
        destinationRootPath: kDownloadAppTestDirWindows,
      );

      const String youtubeAudioSourcePlaylistTitle =
          'audio_learn_test_download_2_small_videos';
      const String localAudioPlaylistTitle = 'local_audio_playlist_2';
      const String movedAudioTitle = 'audio learn test short video one';

      SettingsDataService settingsDataService =
          SettingsDataService(isTest: true);

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      settingsDataService.loadSettingsFromFile(
          jsonPathFileName:
              "$kDownloadAppTestDirWindows${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list of playlist's.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the ListTile Playlist containing the audio to move to
      // the source Youtube playlist

      // First, find the Playlist ListTile Text widget
      final Finder sourcePlaylistListTileTextWidgetFinder =
          find.text(youtubeAudioSourcePlaylistTitle);

      // Then obtain the Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      final Finder sourcePlaylistListTileWidgetFinder = find.ancestor(
        of: sourcePlaylistListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      final Finder sourcePlaylistListTileCheckboxWidgetFinder = find.descendant(
        of: sourcePlaylistListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(sourcePlaylistListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Now we want to tap the popup menu of the Audio ListTile
      // "audio learn test short video one"

      // First, find the Audio sublist ListTile Text widget
      final Finder sourceAudioListTileTextWidgetFinder =
          find.text(movedAudioTitle);

      // Then obtain the Audio ListTile widget enclosing the Text widget by
      // finding its ancestor
      final Finder sourceAudioListTileWidgetFinder = find.ancestor(
        of: sourceAudioListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the leading menu icon button of the Audio ListTile and tap
      // on it
      final Finder sourceAudioListTileLeadingMenuIconButton = find.descendant(
        of: sourceAudioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(sourceAudioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the move audio popup menu item and tap on it
      final Finder popupMoveMenuItem =
          find.byKey(const Key("popup_menu_move_audio_to_playlist"));

      await tester.tap(popupMoveMenuItem);
      await tester.pumpAndSettle(); // Wait for tap action to complete

      // Check the value of the select one playlist AlertDialog
      // dialog title
      Text alertDialogTitle = tester
          .widget(find.byKey(const Key('playlistOneSelectableDialogTitleKey')));
      expect(alertDialogTitle.data, 'Sélectionnez une playlist');

      // Find the RadioListTile target playlist to which the audio
      // will be moved

      final Finder radioListTile = find.byWidgetPredicate(
        (Widget widget) =>
            widget is RadioListTile &&
            widget.title is Text &&
            (widget.title as Text).data == localAudioPlaylistTitle,
      );

      // Tap the target playlist RadioListTile to select it
      await tester.tap(radioListTile);
      await tester.pumpAndSettle();

      // Now find the confirm button and tap on it
      await tester.tap(find.byKey(const Key('confirmButton')));
      await tester.pumpAndSettle();

      // Now verifying the confirm warning dialog message

      final Text warningDialogMessageTextWidget =
          tester.widget<Text>(find.byKey(const Key('warningDialogMessage')));

      expect(warningDialogMessageTextWidget.data,
          'Audio "audio learn test short video one" déplacé de la playlist Youtube "audio_learn_test_download_2_small_videos" vers la playlist locale "local_audio_playlist_2".');

      // Now find the ok button of the confirm warning dialog
      // and tap on it
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Now verifying the selected playlist TextField still
      // contains the title of the source playlist

      final TextField selectedPlaylistTextField = tester.widget<TextField>(
          find.byKey(const Key('selectedPlaylistTextField')));

      expect(selectedPlaylistTextField.controller!.text,
          youtubeAudioSourcePlaylistTitle);

      // TODO: Verify that the audio was moved to the target playlist
      // and verify the source and target playlist json file content.
      //
      // Then move back and remove and remove back ...
      //
      // Then test moving moved audio to a different playlist

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub

      // Testing that the audio was moved from the source to the target
      // playlist directory

      List<String> sourcePlaylistMp3Lst = DirUtil.listFileNamesInDir(
        path:
            '$kDownloadAppTestDirWindows${path.separator}$youtubeAudioSourcePlaylistTitle',
        extension: 'mp3',
      );

      List<String> targetPlaylistMp3Lst = DirUtil.listFileNamesInDir(
        path:
            '$kDownloadAppTestDirWindows${path.separator}$localAudioPlaylistTitle',
        extension: 'mp3',
      );

      expect(sourcePlaylistMp3Lst,
          ["230628-033813-audio learn test short video two 23-06-10.mp3"]);
      expect(targetPlaylistMp3Lst,
          ["230628-033811-audio learn test short video one 23-06-10.mp3"]);

      // Find the target ListTile Playlist containing the audio moved
      // from the source playlist

      // First, find the Playlist ListTile Text widget
      final Finder targetPlaylistListTileTextWidgetFinder =
          find.text(localAudioPlaylistTitle);

      // Then obtain the Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      final Finder targetPlaylistListTileWidgetFinder = find.ancestor(
        of: targetPlaylistListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      final Finder targetPlaylistListTileCheckboxWidgetFinder = find.descendant(
        of: targetPlaylistListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(targetPlaylistListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Now we want to tap the popup menu of the Audio ListTile
      // "audio learn test short video one"

      // First, find the Audio sublist ListTile Text widget
      final Finder targetAudioListTileTextWidgetFinder =
          find.text(movedAudioTitle);

      // Then obtain the Audio ListTile widget enclosing the Text widget by
      // finding its ancestor
      final Finder targetAudioListTileWidgetFinder = find.ancestor(
        of: targetAudioListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the leading menu icon button of the Audio ListTile and tap
      // on it
      final Finder targetAudioListTileLeadingMenuIconButton = find.descendant(
        of: targetAudioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(targetAudioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the popup menu item and tap on it
      final Finder popupDisplayAudioInfoMenuItem =
          find.byKey(const Key("popup_menu_display_audio_info"));

      await tester.tap(popupDisplayAudioInfoMenuItem);
      await tester.pumpAndSettle(); // Wait for tap action to complete

      // Now verifying the display audio info audio moved dialog
      // elements

      // Verify the enclosing playlist title of the moved audio

      final Text enclosingPlaylistTitleTextWidget = tester
          .widget<Text>(find.byKey(const Key('enclosingPlaylistTitleKey')));

      expect(enclosingPlaylistTitleTextWidget.data, localAudioPlaylistTitle);

      // Verify the moved from playlist title of the moved audio

      final Text movedFromPlaylistTitleTextWidget = tester
          .widget<Text>(find.byKey(const Key('movedFromPlaylistTitleKey')));

      expect(movedFromPlaylistTitleTextWidget.data,
          youtubeAudioSourcePlaylistTitle);

      // Verify the moved to playlist title of the moved audio

      final Text movedToPlaylistTitleTextWidget =
          tester.widget<Text>(find.byKey(const Key('movedToPlaylistTitleKey')));

      expect(movedToPlaylistTitleTextWidget.data, '');

      // Now find the ok button of the confirm warning dialog
      // and tap on it
      await tester.tap(find.byKey(const Key('audioInfoOkButtonKey')));
      await tester.pumpAndSettle();

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
  });
  group('Bug fix tests', () {
    testWidgets('Verifying with partial download of single video audio',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}copy_move_audio_integr_test_data",
        destinationRootPath: kDownloadAppTestDirWindows,
      );

      String singleVideoUrl = 'https://youtu.be/uv3VQoWSjBE';

      SettingsDataService settingsDataService =
          SettingsDataService(isTest: true);

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      settingsDataService.loadSettingsFromFile(
          jsonPathFileName:
              "$kDownloadAppTestDirWindows${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // Enter the single video URL into the url text field
      await tester.enterText(
        find.byKey(const Key('playlistUrlTextField')),
        singleVideoUrl,
      );
      await tester.pumpAndSettle();

      // Ensure the url text field contains the entered url
      TextField urlTextField =
          tester.widget(find.byKey(const Key('playlistUrlTextField')));
      expect(urlTextField.controller!.text, singleVideoUrl);

      // Tap the 'Download single video button' button. Before fixing
      // the bug, this caused an exception to be thrown
      await tester.tap(find.byKey(const Key('downloadSingleVideoButton')));
      await tester.pumpAndSettle();

      // Now find the cancel button and tap on it since the audio
      // download can not be done in the test environment
      await tester.tap(find.byKey(const Key('cancelButton')));
      await tester.pumpAndSettle();

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
    testWidgets(
        'Verifying execution of "Delete audio from playlist as well" playlist menu item',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}delete_audio_from_audio_learn_short_data",
        destinationRootPath: kDownloadAppTestDirWindows,
      );

      const String youtubeAudioPlaylistTitle = 'audio_learn_short';
      const String audioToDeleteTitle =
          '15 minutes de Janco pour retourner un climatosceptique';

      SettingsDataService settingsDataService =
          SettingsDataService(isTest: true);

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      settingsDataService.loadSettingsFromFile(
          jsonPathFileName:
              "$kDownloadAppTestDirWindows${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list of playlist's.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the ListTile Playlist containing the audio to move to
      // the target local playlist

      // First, find the Playlist ListTile Text widget
      final Finder sourcePlaylistListTileTextWidgetFinder =
          find.text(youtubeAudioPlaylistTitle);

      // Then obtain the Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      final Finder sourcePlaylistListTileWidgetFinder = find.ancestor(
        of: sourcePlaylistListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      final Finder sourcePlaylistListTileCheckboxWidgetFinder = find.descendant(
        of: sourcePlaylistListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(sourcePlaylistListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Now we want to tap the popup menu of the Audio ListTile
      // "audio learn test short video one"

      // First, find the Audio sublist ListTile Text widget
      final Finder sourceAudioListTileTextWidgetFinder =
          find.text(audioToDeleteTitle).first;

      // Then obtain the Audio ListTile widget enclosing the Text widget by
      // finding its ancestor
      final Finder sourceAudioListTileWidgetFinder = find.ancestor(
        of: sourceAudioListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the leading menu icon button of the Audio ListTile and tap
      // on it
      final Finder sourceAudioListTileLeadingMenuIconButton = find.descendant(
        of: sourceAudioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(sourceAudioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the popup menu item and tap on it
      final Finder popupDeleteAudioFromPlaylistAsWellMenuItem =
          find.byKey(const Key("popup_menu_delete_audio_from_playlist_aswell"));

      await tester.tap(popupDeleteAudioFromPlaylistAsWellMenuItem);
      await tester.pumpAndSettle(); // Wait for tap action to complete

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
          'If the deleted audio video "$audioToDeleteTitle" remains in the "$youtubeAudioPlaylistTitle" Youtube playlist, it will be downloaded again the next time you download the playlist !');

      // Close the warning dialog by tapping on the OK button
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Check the saved youtube audio playlist values in the json file

      final youtubeAudioPlaylistPath = path.join(
        kDownloadAppTestDirWindows,
        youtubeAudioPlaylistTitle,
      );

      final youtubeAudioPlaylistFilePathName = path.join(
        youtubeAudioPlaylistPath,
        '$youtubeAudioPlaylistTitle.json',
      );

      // Load playlist from the json file
      Playlist loadedYoutubeAudioPlaylist = JsonDataService.loadFromFile(
        jsonPathFileName: youtubeAudioPlaylistFilePathName,
        type: Playlist,
      );

      final expectedAudioPlaylistFilePathName = path.join(
        youtubeAudioPlaylistPath,
        '${youtubeAudioPlaylistTitle}_expected.json',
      );

      // Load playlist from the json file
      Playlist loadedExpectedAudioPlaylist = JsonDataService.loadFromFile(
        jsonPathFileName: expectedAudioPlaylistFilePathName,
        type: Playlist,
      );

      int loadedDownloadedAudioLastItemIndex =
          loadedYoutubeAudioPlaylist.downloadedAudioLst.length - 1;
      expect(
        loadedYoutubeAudioPlaylist
            .downloadedAudioLst[loadedDownloadedAudioLastItemIndex]
            .audioFileName,
        loadedYoutubeAudioPlaylist.playableAudioLst[0].audioFileName,
      );

      expect(
          loadedYoutubeAudioPlaylist
              .downloadedAudioLst[loadedDownloadedAudioLastItemIndex]
              .audioFileName,
          loadedExpectedAudioPlaylist
              .downloadedAudioLst[loadedDownloadedAudioLastItemIndex]
              .audioFileName);
      expect(loadedYoutubeAudioPlaylist.playableAudioLst[0].audioFileName,
          loadedExpectedAudioPlaylist.playableAudioLst[0].audioFileName);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
  });
  group('Delete existing playlist test', () {
    testWidgets('Delete selected Youtube playlist', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}2_youtube_2_local_playlists_integr_test_data",
        destinationRootPath: kDownloadAppTestDirWindows,
      );

      const String youtubePlaylistToDeleteTitle =
          'audio_learn_test_download_2_small_videos';

      SettingsDataService settingsDataService =
          SettingsDataService(isTest: true);

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      settingsDataService.loadSettingsFromFile(
          jsonPathFileName:
              "$kDownloadAppTestDirWindows${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list of playlist's.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the playlist to delete ListTile

      // First, find the Playlist ListTile Text widget
      final Finder youtubePlaylistToDeleteListTileTextWidgetFinder =
          find.text(youtubePlaylistToDeleteTitle);

      // Then obtain the Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      final Finder youtubePlaylistToDeleteListTileWidgetFinder = find.ancestor(
        of: youtubePlaylistToDeleteListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      final Finder youtubePlaylistToDeleteListTileCheckboxWidgetFinder =
          find.descendant(
        of: youtubePlaylistToDeleteListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(youtubePlaylistToDeleteListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Now test deleting the playlist

      // Open the delete playlist dialog by clicking on the 'Delete
      // playlist ...' playlist menu item

      // Now find the leading menu icon button of the Playlist to
      // delete ListTile and tap on it
      final Finder firstPlaylistListTileLeadingMenuIconButton = find.descendant(
        of: youtubePlaylistToDeleteListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(firstPlaylistListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the delete playlist popup menu item and tap on it
      final Finder popupDeletePlaylistMenuItem =
          find.byKey(const Key("popup_menu_delete_playlist"));

      await tester.tap(popupDeletePlaylistMenuItem);
      await tester.pumpAndSettle(); // Wait for tap action to complete

      // Now verifying the confirm dialog message

      final Text deletePlaylistDialogTitleWidget = tester.widget<Text>(
          find.byKey(const Key('playlistDeleteConfirmDialogTitleKey')));

      expect(deletePlaylistDialogTitleWidget.data,
          'Supprimer la playlist Youtube "$youtubePlaylistToDeleteTitle"');

      // Now find the delete button of the delete playlist confirm
      // dialog and tap on it
      await tester.tap(
          find.byKey(const Key('deletePlaylistConfirmDialogDeleteButton')));
      await tester.pumpAndSettle();

      // Reload the settings from the json file.
      settingsDataService.loadSettingsFromFile(
          jsonPathFileName:
              "$kDownloadAppTestDirWindows${path.separator}$kSettingsFileName");

      // Check that the deleted playlist title is no longer in the
      // playlist titles list of the settings data service
      expect(
          settingsDataService.get(
            settingType: SettingType.playlists,
            settingSubType: Playlists.orderedTitleLst,
          ),
          [
            'audio_player_view_2_shorts_test',
            'local_audio_playlist_2',
            'local_3'
          ]);

      final String youtubePlaylistToDeletePath = path.join(
        kDownloadAppTestDirWindows,
        youtubePlaylistToDeleteTitle,
      );

      // Check that the deleted playlist directory no longer exist
      expect(Directory(youtubePlaylistToDeletePath).existsSync(), false);

      // Since the deleted playlist was selected, there is no longer
      // a selected playlist. So, the selected playlist widgets
      // are disabled. Checking this now:

      verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'move_up_playlist_button',
      );

      verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'move_down_playlist_button',
      );

      verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'download_sel_playlists_button',
      );

      verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'audio_popup_menu_button',
      );

      // Verifying that the selected playlist text field is empty
      expect(
          reason: 'Selected playlist text field is not empty',
          tester
              .widget<TextField>(
                  find.byKey(const Key('selectedPlaylistTextField')))
              .controller!
              .text,
          '');

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
    testWidgets('Delete selected local playlist', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}2_youtube_2_local_playlists_integr_test_data",
        destinationRootPath: kDownloadAppTestDirWindows,
      );

      const String localPlaylistToDeleteTitle = 'local_audio_playlist_2';

      SettingsDataService settingsDataService =
          SettingsDataService(isTest: true);

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      settingsDataService.loadSettingsFromFile(
          jsonPathFileName:
              "$kDownloadAppTestDirWindows${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list of playlist's.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the playlist to delete ListTile

      // First, find the Playlist ListTile Text widget
      final Finder localPlaylistToDeleteListTileTextWidgetFinder =
          find.text(localPlaylistToDeleteTitle);

      // Then obtain the Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      final Finder localPlaylistToDeleteListTileWidgetFinder = find.ancestor(
        of: localPlaylistToDeleteListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      final Finder localPlaylistToDeleteListTileCheckboxWidgetFinder =
          find.descendant(
        of: localPlaylistToDeleteListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(localPlaylistToDeleteListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Now test deleting the playlist

      // Open the delete playlist dialog by clicking on the 'Delete
      // playlist ...' playlist menu item

      // Now find the leading menu icon button of the Playlist to
      // delete ListTile and tap on it
      final Finder firstPlaylistListTileLeadingMenuIconButton = find.descendant(
        of: localPlaylistToDeleteListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(firstPlaylistListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the delete playlist popup menu item and tap on it
      final Finder popupDeletePlaylistMenuItem =
          find.byKey(const Key("popup_menu_delete_playlist"));

      await tester.tap(popupDeletePlaylistMenuItem);
      await tester.pumpAndSettle(); // Wait for tap action to complete

      // Now verifying the confirm dialog message

      final Text deletePlaylistDialogTitleWidget = tester.widget<Text>(
          find.byKey(const Key('playlistDeleteConfirmDialogTitleKey')));

      expect(deletePlaylistDialogTitleWidget.data,
          'Supprimer la playlist locale "$localPlaylistToDeleteTitle"');

      // Now find the delete button of the delete playlist confirm
      // dialog and tap on it
      await tester.tap(
          find.byKey(const Key('deletePlaylistConfirmDialogDeleteButton')));
      await tester.pumpAndSettle();

      // Reload the settings from the json file.
      settingsDataService.loadSettingsFromFile(
          jsonPathFileName:
              "$kDownloadAppTestDirWindows${path.separator}$kSettingsFileName");

      // Check that the deleted playlist title is no longer in the
      // playlist titles list of the settings data service
      expect(
          settingsDataService.get(
            settingType: SettingType.playlists,
            settingSubType: Playlists.orderedTitleLst,
          ),
          [
            'audio_player_view_2_shorts_test',
            'audio_learn_test_download_2_small_videos',
            'local_3'
          ]);

      final String localPlaylistToDeletePath = path.join(
        kDownloadAppTestDirWindows,
        localPlaylistToDeleteTitle,
      );

      // Check that the deleted playlist directory no longer exist
      expect(Directory(localPlaylistToDeletePath).existsSync(), false);

      // Since the deleted playlist was selected, there is no longer
      // a selected playlist. So, the selected playlist widgets
      // are disabled. Checking this now:

      verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'move_up_playlist_button',
      );

      verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'move_down_playlist_button',
      );

      verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'download_sel_playlists_button',
      );

      verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'audio_popup_menu_button',
      );

      // Verifying that the selected playlist text field is empty
      expect(
          reason: 'Selected playlist text field is not empty',
          tester
              .widget<TextField>(
                  find.byKey(const Key('selectedPlaylistTextField')))
              .controller!
              .text,
          '');

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
    testWidgets(
        'Delete non selected Youtube playlist while another Youtube playlist is selected',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}2_youtube_2_local_playlists_integr_test_data",
        destinationRootPath: kDownloadAppTestDirWindows,
      );

      const String youtubePlaylistToDeleteTitle =
          'audio_learn_test_download_2_small_videos';

      const String youtubePlaylistToSelectTitle =
          'audio_player_view_2_shorts_test';

      SettingsDataService settingsDataService =
          SettingsDataService(isTest: true);

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      settingsDataService.loadSettingsFromFile(
          jsonPathFileName:
              "$kDownloadAppTestDirWindows${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list of playlist's.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the playlist to select ListTile

      // First, find the Playlist ListTile Text widget
      final Finder youtubePlaylistToSelectListTileTextWidgetFinder =
          find.text(youtubePlaylistToSelectTitle);

      // Then obtain the Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      final Finder youtubePlaylistToSelectListTileWidgetFinder = find.ancestor(
        of: youtubePlaylistToSelectListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      final Finder youtubePlaylistToSelectListTileCheckboxWidgetFinder =
          find.descendant(
        of: youtubePlaylistToSelectListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(youtubePlaylistToSelectListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Find the playlist to delete ListTile

      // First, find the Playlist ListTile Text widget
      final Finder playlistToDeleteListTileTextWidgetFinder =
          find.text(youtubePlaylistToDeleteTitle);

      // Then obtain the Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      final Finder playlistToDeleteListTileWidgetFinder = find.ancestor(
        of: playlistToDeleteListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now test deleting the playlist

      // Open the delete playlist dialog by clicking on the 'Delete
      // playlist ...' playlist menu item

      // Now find the leading menu icon button of the Playlist to
      // delete ListTile and tap on it
      final Finder firstPlaylistListTileLeadingMenuIconButton = find.descendant(
        of: playlistToDeleteListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(firstPlaylistListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the delete playlist popup menu item and tap on it
      final Finder popupDeletePlaylistMenuItem =
          find.byKey(const Key("popup_menu_delete_playlist"));

      await tester.tap(popupDeletePlaylistMenuItem);
      await tester.pumpAndSettle(); // Wait for tap action to complete

      // Now verifying the confirm dialog message

      final Text deletePlaylistDialogTitleWidget = tester.widget<Text>(
          find.byKey(const Key('playlistDeleteConfirmDialogTitleKey')));

      expect(deletePlaylistDialogTitleWidget.data,
          'Supprimer la playlist Youtube "$youtubePlaylistToDeleteTitle"');

      // Now find the delete button of the delete playlist confirm
      // dialog and tap on it
      await tester.tap(
          find.byKey(const Key('deletePlaylistConfirmDialogDeleteButton')));
      await tester.pumpAndSettle();

      // Reload the settings from the json file.
      settingsDataService.loadSettingsFromFile(
          jsonPathFileName:
              "$kDownloadAppTestDirWindows${path.separator}$kSettingsFileName");

      // Check that the deleted playlist title is no longer in the
      // playlist titles list of the settings data service
      expect(
          settingsDataService.get(
            settingType: SettingType.playlists,
            settingSubType: Playlists.orderedTitleLst,
          ),
          [
            'audio_player_view_2_shorts_test',
            'local_audio_playlist_2',
            'local_3'
          ]);

      final String newPlaylistPath = path.join(
        kDownloadAppTestDirWindows,
        youtubeNewPlaylistTitle,
      );

      // Check that the deleted playlist directory no longer exist
      expect(Directory(newPlaylistPath).existsSync(), false);

      // Since the deleted playlist was not selected and that another
      // Youtube playlist was selected, the selected playlist widgets
      // remain enabled. Checking this now:

      verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'move_up_playlist_button',
      );

      verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'move_down_playlist_button',
      );

      verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'download_sel_playlists_button',
      );

      verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'audio_popup_menu_button',
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
    testWidgets(
        'Delete non selected Youtube playlist while a local playlist is selected',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}2_youtube_2_local_playlists_integr_test_data",
        destinationRootPath: kDownloadAppTestDirWindows,
      );

      const String youtubePlaylistToDeleteTitle =
          'audio_learn_test_download_2_small_videos';

      const String localPlaylistToSelectTitle = 'local_audio_playlist_2';

      SettingsDataService settingsDataService =
          SettingsDataService(isTest: true);

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      settingsDataService.loadSettingsFromFile(
          jsonPathFileName:
              "$kDownloadAppTestDirWindows${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list of playlist's.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the playlist to select ListTile

      // First, find the Playlist ListTile Text widget
      final Finder localPlaylistToSelectListTileTextWidgetFinder =
          find.text(localPlaylistToSelectTitle);

      // Then obtain the Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      final Finder localPlaylistToSelectListTileWidgetFinder = find.ancestor(
        of: localPlaylistToSelectListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      final Finder localPlaylistToSelectListTileCheckboxWidgetFinder =
          find.descendant(
        of: localPlaylistToSelectListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(localPlaylistToSelectListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Find the playlist to delete ListTile

      // First, find the Playlist ListTile Text widget
      final Finder playlistToDeleteListTileTextWidgetFinder =
          find.text(youtubePlaylistToDeleteTitle);

      // Then obtain the Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      final Finder playlistToDeleteListTileWidgetFinder = find.ancestor(
        of: playlistToDeleteListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now test deleting the playlist

      // Open the delete playlist dialog by clicking on the 'Delete
      // playlist ...' playlist menu item

      // Now find the leading menu icon button of the Playlist to
      // delete ListTile and tap on it
      final Finder firstPlaylistListTileLeadingMenuIconButton = find.descendant(
        of: playlistToDeleteListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(firstPlaylistListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the delete playlist popup menu item and tap on it
      final Finder popupDeletePlaylistMenuItem =
          find.byKey(const Key("popup_menu_delete_playlist"));

      await tester.tap(popupDeletePlaylistMenuItem);
      await tester.pumpAndSettle(); // Wait for tap action to complete

      // Now verifying the confirm dialog message

      final Text deletePlaylistDialogTitleWidget = tester.widget<Text>(
          find.byKey(const Key('playlistDeleteConfirmDialogTitleKey')));

      expect(deletePlaylistDialogTitleWidget.data,
          'Supprimer la playlist Youtube "$youtubePlaylistToDeleteTitle"');

      // Now find the delete button of the delete playlist confirm
      // dialog and tap on it
      await tester.tap(
          find.byKey(const Key('deletePlaylistConfirmDialogDeleteButton')));
      await tester.pumpAndSettle();

      // Reload the settings from the json file.
      settingsDataService.loadSettingsFromFile(
          jsonPathFileName:
              "$kDownloadAppTestDirWindows${path.separator}$kSettingsFileName");

      // Check that the deleted playlist title is no longer in the
      // playlist titles list of the settings data service
      expect(
          settingsDataService.get(
            settingType: SettingType.playlists,
            settingSubType: Playlists.orderedTitleLst,
          ),
          [
            'audio_player_view_2_shorts_test',
            'local_audio_playlist_2',
            'local_3'
          ]);

      final String newPlaylistPath = path.join(
        kDownloadAppTestDirWindows,
        youtubeNewPlaylistTitle,
      );

      // Check that the deleted playlist directory no longer exist
      expect(Directory(newPlaylistPath).existsSync(), false);

      // Since the deleted playlist was not selected and that a local
      // playlist was selected, the selected playlist widgets remain
      // enabled, except the download selected playlist button.
      // Checking this now:

      verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'move_up_playlist_button',
      );

      verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'move_down_playlist_button',
      );

      verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'download_sel_playlists_button',
      );

      verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'audio_popup_menu_button',
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
  });
}

void verifyWidgetIsDisabled({
  required WidgetTester tester,
  required String widgetKeyStr,
}) {
  // Find the widget by its key
  final Finder widgetFinder = find.byKey(Key(widgetKeyStr));

  // Retrieve the widget as a generic Widget
  final Widget widget = tester.widget(widgetFinder);

  // Check if the widget is disabled based on its type
  if (widget is IconButton) {
    expect(widget.onPressed, isNull, reason: 'IconButton should be disabled');
  } else if (widget is ElevatedButton) {
    expect(widget.onPressed, isNull,
        reason: 'ElevatedButton should be disabled');
  } else if (widget is Checkbox) {
    // For Checkbox, you can check if onChanged is null
    expect(widget.onChanged, isNull, reason: 'Checkbox should be disabled');
  } else if (widget is PopupMenuButton) {
    // For PopupMenuButton, check the enabled property
    expect(widget.enabled, isFalse,
        reason: 'PopupMenuButton should be disabled');
  } else {
    fail(
        'The widget with key $widgetKeyStr is not a recognized type for this test');
  }
}

void verifyWidgetIsEnabled({
  required WidgetTester tester,
  required String widgetKeyStr,
}) {
  // Find the widget by its key
  final Finder widgetFinder = find.byKey(Key(widgetKeyStr));

  // Retrieve the widget as a generic Widget
  final Widget widget = tester.widget(widgetFinder);

  // Check if the widget is disabled based on its type
  if (widget is IconButton) {
    expect(widget.onPressed, isNotNull,
        reason: 'IconButton should be disabled');
  } else if (widget is ElevatedButton) {
    expect(widget.onPressed, isNotNull,
        reason: 'ElevatedButton should be disabled');
  } else if (widget is Checkbox) {
    // For Checkbox, you can check if onChanged is null
    expect(widget.onChanged, isNotNull, reason: 'Checkbox should be disabled');
  } else if (widget is PopupMenuButton) {
    // For PopupMenuButton, check the enabled property
    expect(widget.enabled, isTrue,
        reason: 'PopupMenuButton should be disabled');
  } else {
    fail(
        'The widget with key $widgetKeyStr is not a recognized type for this test');
  }
}

Future<void> _launchExpandablePlaylistListView({
  required tester,
  required AudioDownloadVM audioDownloadVM,
  required SettingsDataService settingsDataService,
  required PlaylistListVM expandablePlaylistListVM,
  required WarningMessageVM warningMessageVM,
  required AudioPlayerVM audioPlayerVM,
}) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => audioDownloadVM),
        ChangeNotifierProvider(
            create: (_) => ThemeProviderVM(
                  appSettings: settingsDataService,
                )),
        ChangeNotifierProvider(
            create: (_) => LanguageProviderVM(
                  appSettings: settingsDataService,
                )),
        ChangeNotifierProvider(create: (_) => expandablePlaylistListVM),
        ChangeNotifierProvider(create: (_) => warningMessageVM),
        ChangeNotifierProvider(create: (_) => audioPlayerVM),
      ],
      child: MaterialApp(
        // forcing dark theme
        theme: ScreenMixin.themeDataDark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const Scaffold(
          body: PlaylistDownloadView(
            onPageChangedFunction: changePage,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> findThenSelectAndTestListTileCheckbox({
  required WidgetTester tester,
  required String itemTextStr,
}) async {
  Finder listItemTileFinder = find.widgetWithText(ListTile, itemTextStr);

  // Find the Checkbox widget inside the ListTile
  Finder checkboxFinder = find.descendant(
    of: listItemTileFinder,
    matching: find.byType(Checkbox),
  );

  // Assert that the checkbox is not selected
  expect(tester.widget<Checkbox>(checkboxFinder).value, false);

  // now tap the item checkbox
  await tester.tap(find.descendant(
    of: listItemTileFinder,
    matching: find.byWidgetPredicate((widget) => widget is Checkbox),
  ));
  await tester.pump();

  // Find the Checkbox widget inside the ListTile

  listItemTileFinder = find.widgetWithText(ListTile, itemTextStr);

  checkboxFinder = find.descendant(
    of: listItemTileFinder,
    matching: find.byType(Checkbox),
  );

  expect(tester.widget<Checkbox>(checkboxFinder).value, true);
}

void changePage(int index) {
  onPageChanged(index);
  // _pageController.animateToPage(
  //   index,
  //   duration: pageTransitionDuration, // Use constant
  //   curve: pageTransitionCurve, // Use constant
  // );
}

void onPageChanged(int index) {
  // setState(() {
  //   _currentIndex = index;
  // });
}
