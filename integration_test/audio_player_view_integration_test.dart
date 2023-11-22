import 'dart:async';

import 'package:audio_learn/utils/date_time_parser.dart';
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
        'Opening AudioPlayerView by clicking on audio title. Then check play/pause button conversion only.',
        (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle =
          'audio_player_view_2_shorts_test';
      const String lastDownloadedAudioTitle = 'morning _ cinematic video';

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
      final Finder lastDownloadedAudioListTileTextWidgetFinder =
          find.text(lastDownloadedAudioTitle);

      await tester.tap(lastDownloadedAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      await tester
          .tap(find.byIcon(Icons.play_arrow)); // Replace with your interaction
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify if the play button changes to pause button
      expect(find.byIcon(Icons.pause), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
    testWidgets(
        'Opening AudioPlayerView by clicking on AudioPlayerView icon button. Then check play/pause button conversion only.',
        (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle =
          'audio_player_view_2_shorts_test';

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

      await tester
          .tap(find.byIcon(Icons.play_arrow)); // Replace with your interaction
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify if the play button changes to pause button
      expect(find.byIcon(Icons.pause), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
    testWidgets(
        'Opening AudioPlayerView by clicking on audio title. Then play audio during 5 seconds and the pause it',
        (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle =
          'audio_player_view_2_shorts_test';
      const String lastDownloadedAudioTitle = 'morning _ cinematic video';

      await initializeApplication(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the lastly downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the currently not played audio

      // First, get the lastly downloaded Audio ListTile Text
      // widget finder and tap on it
      final Finder lastDownloadedAudioListTileTextWidgetFinder =
          find.text(lastDownloadedAudioTitle);

      await tester.tap(lastDownloadedAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // Now verify if the displayed audio position and remaining
      // duration are correct

      Text audioPositionText = tester
          .widget<Text>(find.byKey(const Key('audioPlayerViewAudioPosition')));
      expect(audioPositionText.data, '0:00');

      Text audioRemainingDurationText = tester.widget<Text>(
          find.byKey(const Key('audioPlayerViewAudioRemainingDuration')));
      expect(audioRemainingDurationText.data, '0:59');

      // Now play the audio and wait 5 seconds
      await tester
          .tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Verify if the play button changed to pause button
      Finder pauseIconFinder = find.byIcon(Icons.pause);
      expect(pauseIconFinder, findsOneWidget);

      // Now pause the audio and wait 1 second
      await tester.tap(pauseIconFinder);
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 1));

      Duration audioPositionDurationAfterPauseExpected = const Duration(seconds: 5);

      audioPositionText = tester
          .widget<Text>(find.byKey(const Key('audioPlayerViewAudioPosition')));
      Duration audioPositionDurationAfterPauseActual = DateTimeParser.parseMMSSDuration(audioPositionText.data ?? '')!;

      // Check if the actual audio position Duration is correct
      expect(audioPositionDurationAfterPauseActual, audioPositionDurationAfterPauseExpected);

      Duration audioRemainingDurationAfterPauseExpected = const Duration(seconds: 54);

      audioRemainingDurationText = tester.widget<Text>(
          find.byKey(const Key('audioPlayerViewAudioRemainingDuration')));
      Duration audioRemainingDurationAfterPauseActual = DateTimeParser.parseMMSSDuration(audioRemainingDurationText.data ?? '')!;

      // Check if the actual audio remaining Duration is correct
      expect(audioRemainingDurationAfterPauseActual, audioRemainingDurationAfterPauseExpected);

      // Check if the sum of the actual audio position duration
      // and the actual audio remaining duration is equal to 59
      // seconds which is the total duration of the listened
      // audio minus 1 second
      expect((audioPositionDurationAfterPauseActual + audioRemainingDurationAfterPauseActual), const Duration(seconds: 59));

      // Verify if the pause button changed back to play button
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
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

  // Find the ListTile Playlist containing the playlist which
  // contains the audio to play

  // First, find the Playlist ListTile Text widget
  final Finder audioPlayerSelectedPlaylistFinder =
      find.text(selectedPlaylistTitle);

  // Then obtain the Playlist ListTile widget enclosing the Text
  // widget by finding its ancestor
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

Duration parseDuration(String hhmmString) {
  List<String> parts = hhmmString.split(':');
  if (parts.length != 2) {
    throw FormatException("Invalid duration format");
  }

  int hours = int.parse(parts[0]);
  int minutes = int.parse(parts[1]);

  return Duration(hours: hours, minutes: minutes);
}
