import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as path;
import 'package:audio_learn/constants.dart';
import 'package:audio_learn/services/settings_data_service.dart';
import 'package:audio_learn/utils/dir_util.dart';
import 'package:audio_learn/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('AudioPlayerView Integration Tests', () {
    testWidgets(
        'Opening AudioPlayerView by clicking on audio title. Then play and pause audio',
        (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle =
          'audio_player_view_2_shorts_test';
     // const String firstAudioTitle = 'Really short video';
      const String firstAudioTitle = 'morning _ cinematic video';

      await initializeApplication(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the lastly downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the currently paused audio

      // First, get the lastly downloaded Audio ListTile Text
      // widget finder and tap on it
      final Finder lastAudioListTileTextWidgetFinder =
          find.text(firstAudioTitle);

      await tester.tap(lastAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // Test play button
      final playButton = find.byIcon(Icons.play_arrow);
      await tester.tap(playButton);
      await tester.pumpAndSettle();

      // Verify if the play button changes to pause button
      expect(find.byIcon(Icons.pause), findsOneWidget);

      // Test pause button
      final pauseButton = find.byIcon(Icons.pause);
      await tester.tap(pauseButton);
      await tester.pumpAndSettle();

      // Verify if the pause button changes back to play button
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      // Add more tests as needed for slider movement, next/previous buttons, etc.

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
    testWidgets(
        'Opening AudioPlayerView by clicking on AudioPlayerView icon button. Then play and pause audio',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'audio_player_view_2_shorts_test';
     // const String firstAudioTitle = 'Really short video';
      const String firstAudioTitle = 'morning _ cinematic video';

      await initializeApplication(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we tap on the AudioPlayerView icon button to open
      // AudioPlayerView screen which displays the current
      // playable audio which is paused

      // Assuming you have a button to navigate to the AudioPlayerView
      final audioPlayerNavButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(audioPlayerNavButton);
      await tester.pumpAndSettle();

      // Test play button
      final playButton = find.byIcon(Icons.play_arrow);
      await tester.tap(playButton);
      await tester.pumpAndSettle();

      // Verify if the play button changes to pause button
      expect(find.byIcon(Icons.pause), findsOneWidget);

      // Test pause button
      final pauseButton = find.byIcon(Icons.pause);
      await tester.tap(pauseButton);
      await tester.pumpAndSettle();

      // Verify if the pause button changes back to play button
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      // Add more tests as needed for slider movement, next/previous buttons, etc.

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });

    // Additional tests can be added here
    testWidgets(
        'Opening AudioPlayerView by clicking on AudioPlayerView icon button with a playlist recently downloaded with no previously selected audio.',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'audio_player_view_no_sel_audio_test';

      await initializeApplication(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we tap on the AudioPlayerView icon button to open
      // AudioPlayerView screen which displays the current
      // playable audio which is paused

      // Assuming you have a button to navigate to the AudioPlayerView
      final audioPlayerNavButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(audioPlayerNavButton);
      await tester.pumpAndSettle();

      // Test play button
      final playButton = find.byIcon(Icons.play_arrow);
      await tester.tap(playButton);
      await tester.pumpAndSettle();

      // Verify the no selected audio title is displayed
      expect(find.text("Aucun audio sélectionné"), findsOneWidget);

      // Verify if the play button remained the same since
      // there is no audio to play
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
  });
}

Future<void> initializeApplication({
  required WidgetTester tester,
  required String savedTestDataDirName,
  required String selectedPlaylistTitle,
}) async {
  // Purge the test playlist directory if it exists so that the
  // playlist list is empty
  DirUtil.deleteFilesInDirAndSubDirs(
    rootPath: kDownloadAppTestDirWindows,
    deleteSubDirectoriesAsWell: true,
  );

  // Copy the test initial audio data to the app dir
  DirUtil.copyFilesFromDirAndSubDirsToDirectory(
    sourceRootPath:
        "$kDownloadAppTestSavedDataDir${path.separator}$savedTestDataDirName",
    destinationRootPath: kDownloadAppTestDirWindows,
  );

  SettingsDataService settingsDataService = SettingsDataService(isTest: true);

  // Load the settings from the json file. This is necessary
  // otherwise the ordered playlist titles will remain empty
  // and the playlist list will not be filled with the
  // playlists available in the download app test dir
  settingsDataService.loadSettingsFromFile(
      jsonPathFileName:
          "$kDownloadAppTestDirWindows${path.separator}$kSettingsFileName");

  await app.main(['test']);
  await tester.pumpAndSettle();

  // Tap the 'Toggle List' button to show the list. If the list
  // is not opened, checking that a ListTile with the title of
  // the playlist was added to the list will fail
  await tester.tap(find.byKey(const Key('playlist_toggle_button')));
  await tester.pumpAndSettle();

  // Find the ListTile Playlist containing the audio to copy to
  // the target local playlist

  // First, find the Playlist ListTile Text widget
  final Finder audioPlayerSelectedPlaylistFinder =
      find.text(selectedPlaylistTitle);

  // Then obtain the Playlist ListTile widget enclosing the Text widget
  // by finding its ancestor
  final Finder selectedPlaylistListTileWidgetFinder = find.ancestor(
    of: audioPlayerSelectedPlaylistFinder,
    matching: find.byType(ListTile),
  );

  // Now find the Checkbox widget located in the Playlist ListTile
  // and tap on it to select the playlist
  final Finder selectedPlaylistCheckboxWidgetFinder = find.descendant(
    of: selectedPlaylistListTileWidgetFinder,
    matching: find.byType(Checkbox),
  );

  // Retrieve the Checkbox widget
  final Checkbox checkbox =
      tester.widget<Checkbox>(selectedPlaylistCheckboxWidgetFinder);

  // Check if the checkbox is checked
  if (checkbox.value == null || !checkbox.value!) {
    // Tap the ListTile Playlist checkbox to select it
    // so that the playlist audios are listed
    await tester.tap(selectedPlaylistCheckboxWidgetFinder);
    await tester.pumpAndSettle();
  }
}
