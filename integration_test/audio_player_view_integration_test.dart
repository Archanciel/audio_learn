import 'package:audio_learn/models/playlist.dart';
import 'package:audio_learn/services/json_data_service.dart';
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

  group('AudioPlayerView play/pause tests', () {
    testWidgets(
        'Opening AudioPlayerView by clicking on audio title. Then check play/pause button conversion only.',
        (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle =
          'audio_player_view_2_shorts_test';
      const String lastDownloadedAudioTitle = 'morning _ cinematic video';

      await initializeApplicationAndSelectPlaylist(
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

      await tester.tap(find.byIcon(Icons.play_arrow));
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

      await initializeApplicationAndSelectPlaylist(
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
      await tester.tap(find.byIcon(Icons.play_arrow));
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

      audioPositionText = tester
          .widget<Text>(find.byKey(const Key('audioPlayerViewAudioPosition')));
      Duration audioPositionDurationAfterPauseActual =
          DateTimeParser.parseMMSSDuration(audioPositionText.data ?? '')!;

      audioRemainingDurationText = tester.widget<Text>(
          find.byKey(const Key('audioPlayerViewAudioRemainingDuration')));
      Duration audioRemainingDurationAfterPauseActual =
          DateTimeParser.parseMMSSDuration(
              audioRemainingDurationText.data ?? '')!;

      Duration sumDurations = audioPositionDurationAfterPauseActual +
          audioRemainingDurationAfterPauseActual;

      // Check if the sum of the actual audio position duration
      // and the actual audio remaining duration is equal to 58 or
      // 59 seconds which is the total duration of the listened
      // audio minus 1 second. Checking the value of the audio
      // position and remaining duration is not safe.
      expect(sumDurations >= const Duration(seconds: 58), isTrue);
      expect(sumDurations <= const Duration(seconds: 59), isTrue);

      // Verify if the pause button changed back to play button
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
    testWidgets(
        'Opening AudioPlayerView by clicking on audio title. Then click on play button to finish playing the first downloaded audio and start playing the last downloaded audio, ignoring the 2 precendent audios already fully played.',
        (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'S8 audio';
      const String firstDownloadedAudioTitle =
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau';

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_first_to_last_audio_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // First, get the first downloaded Audio ListTile Text
      // widget finder and tap on it
      final Finder firstDownloadedAudioListTileTextWidgetFinder =
          find.text(firstDownloadedAudioTitle);

      await tester.tap(firstDownloadedAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // Now we tap on the play button in order to finish
      // playing the first downloaded audio and start playing
      // the last downloaded audio of the playlist. The 2
      // audios in between are ignored since they are already
      // fully played.

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Verify the last downloaded played audio title
      expect(
          find.text(
              '3 fois où Aurélien Barrau tire à balles réelles sur les riches\n8:50'),
          findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
  });
  group('AudioPlayerView no audio selected tests', () {
    testWidgets(
        'Opening AudioPlayerView by clicking on AudioPlayerView icon button with a playlist recently downloaded with no previously selected audio.',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'audio_player_view_no_sel_audio_test';

      await initializeApplicationAndSelectPlaylist(
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
    testWidgets(
        'Opening AudioPlayerView by clicking on AudioPlayerView icon button in situation where no playlist is selected.',
        (WidgetTester tester) async {
      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_no_playlist_selected_test',
        selectedPlaylistTitle: null, // no playlist selected
      );

      // Now we tap on the AudioPlayerView icon button to open
      // AudioPlayerView screen which displays the current
      // playable audio which is paused

      // Assuming you have a button to navigate to the AudioPlayerView
      final audioPlayerNavButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(audioPlayerNavButton);
      await tester.pumpAndSettle();

      // Verify the no selected audio title is displayed
      Finder noAudioTitleFinder = find.text("No audio selected");
      expect(noAudioTitleFinder, findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
  });
  group('AudioPlayerView set play speed tests', () {
    testWidgets(
        'Reduce play speed. Then go back to PlaylistDownloadView and click on another audio title.',
        (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'S8 audio';
      const String lastDownloadedAudioTitle =
          '3 fois où Aurélien Barrau tire à balles réelles sur les riches';
      const String firstDownloadedAudioTitle =
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau';

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_play_speed_bug_fix_test_data',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // First, get the first downloaded Audio ListTile Text
      // widget finder and tap on it
      final Finder firstDownloadedAudioListTileTextWidgetFinder =
          find.text(firstDownloadedAudioTitle);

      await tester.tap(firstDownloadedAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // Now open the audio play speed dialog
      await tester.tap(find.byKey(const Key('setAudioSpeedTextButton')));
      await tester.pumpAndSettle();

      // Now select the 0.7x play speed
      await tester.tap(find.text('0.7x'));
      await tester.pumpAndSettle();

      // And click on the Ok button
      await tester.tap(find.text('Ok'));
      await tester.pumpAndSettle();

      // Verify if the play speed is 0.70x
      expect(find.text('0.70x'), findsOneWidget);

      // Check the saved playlist first downloaded audio
      // play speed value in the json file

      int playableAudioLstAudioIndex = 1;
      double expectedAudioPlaySpeed = 0.7;

      verifyAudioPlaySpeedStoredInPlaylistJsonFile(
        audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex,
        expectedAudioPlaySpeed,
      );

      // Now we go back to the PlayListDownloadView in order
      // to tap on the last downloaded audio title

      final audioPlayerNavButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(audioPlayerNavButton);
      await tester.pumpAndSettle();

      // Now we want to tap on the last downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // First, get the last downloaded Audio ListTile Text
      // widget finder and tap on it
      final Finder lastDownloadedAudioListTileTextWidgetFinder =
          find.text(lastDownloadedAudioTitle);

      await tester.tap(lastDownloadedAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // Verify if the play speed of the last downloaded audio
      // which was not modified is 1.50x
      expect(find.text('1.50x'), findsOneWidget);

      // Check the saved playlist last downloaded audio
      // play speed value in the json file

      playableAudioLstAudioIndex = 0;
      expectedAudioPlaySpeed = 1.5;

      verifyAudioPlaySpeedStoredInPlaylistJsonFile(
        audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex,
        expectedAudioPlaySpeed,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
    testWidgets(
        'Reduce play speed. Then click twice on >| button to start playing the most recently downloaded audio.',
        (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'S8 audio';
      const String firstDownloadedAudioTitle =
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau';

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_play_speed_bug_fix_test_data',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // First, get the first downloaded Audio ListTile Text
      // widget finder and tap on it
      final Finder firstDownloadedAudioListTileTextWidgetFinder =
          find.text(firstDownloadedAudioTitle);

      await tester.tap(firstDownloadedAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // Now open the audio play speed dialog
      await tester.tap(find.byKey(const Key('setAudioSpeedTextButton')));
      await tester.pumpAndSettle();

      // Now select the 0.7x play speed
      await tester.tap(find.text('0.7x'));
      await tester.pumpAndSettle();

      // And click on the Ok button
      await tester.tap(find.text('Ok'));
      await tester.pumpAndSettle();

      // Verify if the play speed is 0.70x
      expect(find.text('0.70x'), findsOneWidget);

      // Check the saved playlist first downloaded audio
      // play speed value in the json file

      int playableAudioLstAudioIndex = 1;
      double expectedAudioPlaySpeed = 0.7;

      verifyAudioPlaySpeedStoredInPlaylistJsonFile(
        audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex,
        expectedAudioPlaySpeed,
      );

      // Now we tap twice on the >| button in order to start
      // playing the last downloaded audio of the playlist

      await tester.tap(find.byKey(const Key('audioPlayerViewSkipToEndButton')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('audioPlayerViewSkipToEndButton')));
      await tester.pumpAndSettle();

      // Verify if the play speed of the last downloaded audio
      // which was not modified is 1.50x
      expect(find.text('1.50x'), findsOneWidget);

      playableAudioLstAudioIndex = 0;
      expectedAudioPlaySpeed = 1.5;

      verifyAudioPlaySpeedStoredInPlaylistJsonFile(
        audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex,
        expectedAudioPlaySpeed,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
    testWidgets(
        'Reduce play speed. Then click on play button to finish playing the first downloaded audio and start playing the next downloaded audio.',
        (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'S8 audio';
      const String firstDownloadedAudioTitle =
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau';

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_play_speed_bug_fix_test_data',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // First, get the first downloaded Audio ListTile Text
      // widget finder and tap on it
      final Finder firstDownloadedAudioListTileTextWidgetFinder =
          find.text(firstDownloadedAudioTitle);

      await tester.tap(firstDownloadedAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // Now open the audio play speed dialog
      await tester.tap(find.byKey(const Key('setAudioSpeedTextButton')));
      await tester.pumpAndSettle();

      // Now select the 0.7x play speed
      await tester.tap(find.text('0.7x'));
      await tester.pumpAndSettle();

      // And click on the Ok button
      await tester.tap(find.text('Ok'));
      await tester.pumpAndSettle();

      // Verify if the play speed is 0.70x
      expect(find.text('0.70x'), findsOneWidget);

      // Check the saved playlist first downloaded audio
      // play speed value in the json file

      int playableAudioLstAudioIndex = 1;
      double expectedAudioPlaySpeed = 0.7;

      verifyAudioPlaySpeedStoredInPlaylistJsonFile(
        audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex,
        expectedAudioPlaySpeed,
      );

      // Now we tap on the play button in order to finish
      // playing the first downloaded audio and start playing
      // the last downloaded audio of the playlist

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Verify if the play speed of the last downloaded audio
      // which was not modified is 1.50x
      expect(find.text('1.50x'), findsOneWidget);

      playableAudioLstAudioIndex = 0;
      expectedAudioPlaySpeed = 1.5;

      verifyAudioPlaySpeedStoredInPlaylistJsonFile(
        audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex,
        expectedAudioPlaySpeed,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
    testWidgets('Reduce play speed. Then click on Cancel.', (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'S8 audio';
      const String firstDownloadedAudioTitle =
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau';

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_play_speed_bug_fix_test_data',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // First, get the first downloaded Audio ListTile Text
      // widget finder and tap on it
      final Finder firstDownloadedAudioListTileTextWidgetFinder =
          find.text(firstDownloadedAudioTitle);

      await tester.tap(firstDownloadedAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // Now open the audio play speed dialog
      await tester.tap(find.byKey(const Key('setAudioSpeedTextButton')));
      await tester.pumpAndSettle();

      // Now select the 0.7x play speed
      await tester.tap(find.text('0.7x'));
      await tester.pumpAndSettle();

      // And click on the Cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify if the play speed is 1.25x
      expect(find.text('1.25x'), findsOneWidget);

      // Check the saved playlist first downloaded audio
      // play speed value in the json file

      int playableAudioLstAudioIndex = 1;
      double expectedAudioPlaySpeed = 1.25;

      verifyAudioPlaySpeedStoredInPlaylistJsonFile(
        audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex,
        expectedAudioPlaySpeed,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
    testWidgets(
        'Reduce play speed. Then click on play button to finish playing the first downloaded audio and start playing the last downloaded audio, ignoring the 2 precendent audios already fully played.',
        (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'S8 audio';
      const String firstDownloadedAudioTitle =
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau';

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_first_to_last_audio_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // First, get the first downloaded Audio ListTile Text
      // widget finder and tap on it
      final Finder firstDownloadedAudioListTileTextWidgetFinder =
          find.text(firstDownloadedAudioTitle);

      await tester.tap(firstDownloadedAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // Now open the audio play speed dialog
      await tester.tap(find.byKey(const Key('setAudioSpeedTextButton')));
      await tester.pumpAndSettle();

      // Now select the 0.7x play speed
      await tester.tap(find.text('0.7x'));
      await tester.pumpAndSettle();

      // And click on the Ok button
      await tester.tap(find.text('Ok'));
      await tester.pumpAndSettle();

      // Verify if the play speed is 0.70x
      expect(find.text('0.70x'), findsOneWidget);

      // Check the saved playlist first downloaded audio
      // play speed value in the json file

      int playableAudioLstAudioIndex = 1;
      double expectedAudioPlaySpeed = 0.7;

      verifyAudioPlaySpeedStoredInPlaylistJsonFile(
        audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex,
        expectedAudioPlaySpeed,
      );

      // Now we tap on the play button in order to finish
      // playing the first downloaded audio and start playing
      // the last downloaded audio of the playlist. The 2
      // audios in between are ignored since they are already
      // fully played.

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Verify if the play speed of the last downloaded audio
      // which was not modified is 1.50x
      expect(find.text('1.50x'), findsOneWidget);

      playableAudioLstAudioIndex = 0;
      expectedAudioPlaySpeed = 1.5;

      verifyAudioPlaySpeedStoredInPlaylistJsonFile(
        audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex,
        expectedAudioPlaySpeed,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
    testWidgets(
        'Reduce play speed. Then open the DisplaySelectableAudioListDialogWidget and select the most recently downloaded audio.',
        (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'S8 audio';
      const String nextUnreadAndLastDownloadedAudioTitle =
          '3 fois où Aurélien Barrau tire à balles réelles sur les riches';
      const String firstDownloadedAudioTitle =
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau';

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_play_speed_bug_fix_test_data',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // First, get the first downloaded Audio ListTile Text
      // widget finder and tap on it
      final Finder firstDownloadedAudioListTileTextWidgetFinder =
          find.text(firstDownloadedAudioTitle);

      await tester.tap(firstDownloadedAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // Now open the audio play speed dialog
      await tester.tap(find.byKey(const Key('setAudioSpeedTextButton')));
      await tester.pumpAndSettle();

      // Now select the 0.7x play speed
      await tester.tap(find.text('0.7x'));
      await tester.pumpAndSettle();

      // And click on the Ok button
      await tester.tap(find.text('Ok'));
      await tester.pumpAndSettle();

      // Verify if the play speed is 0.70x
      expect(find.text('0.70x'), findsOneWidget);

      // Check the saved playlist first downloaded audio
      // play speed value in the json file

      int playableAudioLstAudioIndex = 1;
      double expectedAudioPlaySpeed = 0.7;

      verifyAudioPlaySpeedStoredInPlaylistJsonFile(
        audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex,
        expectedAudioPlaySpeed,
      );

      // Now we open the DisplaySelectableAudioListDialogWidget
      // and select the last downloaded audio of the playlist

      await tester.tap(find.text(
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau\n6:29'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(nextUnreadAndLastDownloadedAudioTitle));
      await tester.pumpAndSettle();

      // Verify if the play speed of the last downloaded audio
      // which was not modified is 1.50x
      expect(find.text('1.50x'), findsOneWidget);

      playableAudioLstAudioIndex = 0;
      expectedAudioPlaySpeed = 1.5;

      verifyAudioPlaySpeedStoredInPlaylistJsonFile(
        audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex,
        expectedAudioPlaySpeed,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
  });
  group(
      'AudioPlayerView skip to next audio ignoring already listened audios tests.',
      () {
    testWidgets(
        'The next unread audio is also the last downloaded audio of the playlist.',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String firstDownloadedAudioTitle =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";
      const String lastDownloadedAudioTitle =
          "La résilience insulaire par Fiona Roche\n13:35";

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName:
            'audio_play_skip_to_next_and_last_unread_audio_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // Tap the 'Toggle List' button to avoid displaying the list
      // of playlists which may hide the audio title we want to
      // tap on
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // First, get the first downloaded Audio ListTile Text
      // widget finder and tap on it
      final Finder firstDownloadedAudioListTileTextWidgetFinder =
          find.text(firstDownloadedAudioTitle);

      await tester.tap(firstDownloadedAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // Now play the audio and wait 5 seconds
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Verify if the last downloaded audio title is displayed
      expect(find.text(lastDownloadedAudioTitle), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
  });
  group('AudioPlayerView display audio list.', () {
    const Color fullyPlayedAudioTitleColor = kSliderThumbColorInDarkMode;
    const Color currentlyPlayingAudioTitleTextColor = Colors.white;
    const Color currentlyPlayingAudioTitleTextBackgroundColor = Colors.blue;
    const Color? unplayedAudioTitleTextColor = null;
    const Color partiallyPlayedAudioTitleTextdColor = Colors.blue;

    testWidgets('All audio displayed', (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String currentPartiallyPlayedAudioTitle =
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau";

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_display_audio_list_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // Tap the 'Toggle List' button to avoid displaying the list
      // of playlists which may hide the audio title we want to
      // tap on
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // First, get the current parially played Audio ListTile Text
      // widget finder and tap on it
      final Finder currentPartiallyPlayedAudioListTileTextWidgetFinder =
          find.text(currentPartiallyPlayedAudioTitle);

      await tester.tap(currentPartiallyPlayedAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // Now we open the DisplaySelectableAudioListDialogWidget
      // and verify the color of the displayed audio titles

      await tester.tap(find.text(
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau\n6:29'));
      await tester.pumpAndSettle();

      await checkAudioTextColor(
        tester: tester,
        audioTitle:
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
        expectedTitleTextColor: fullyPlayedAudioTitleColor,
        expectedTitleTextBackgroundColor: null,
      );

      await checkAudioTextColor(
        tester: tester,
        audioTitle:
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        expectedTitleTextColor: currentlyPlayingAudioTitleTextColor,
        expectedTitleTextBackgroundColor:
            currentlyPlayingAudioTitleTextBackgroundColor,
      );

      await checkAudioTextColor(
        tester: tester,
        audioTitle: "Les besoins artificiels par R.Keucheyan",
        expectedTitleTextColor: fullyPlayedAudioTitleColor,
        expectedTitleTextBackgroundColor: null,
      );

      await checkAudioTextColor(
        tester: tester,
        audioTitle: "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
        expectedTitleTextColor: unplayedAudioTitleTextColor,
        expectedTitleTextBackgroundColor: null,
      );

      await checkAudioTextColor(
        tester: tester,
        audioTitle: "La résilience insulaire par Fiona Roche",
        expectedTitleTextColor: partiallyPlayedAudioTitleTextdColor,
        expectedTitleTextBackgroundColor: null,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
    testWidgets('Only no played or partially played audio displayed',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String currentPartiallyPlayedAudioTitle =
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau";

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_display_audio_list_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // Tap the 'Toggle List' button to avoid displaying the list
      // of playlists which may hide the audio title we want to
      // tap on
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // First, get the current parially played Audio ListTile Text
      // widget finder and tap on it
      final Finder currentPartiallyPlayedAudioListTileTextWidgetFinder =
          find.text(currentPartiallyPlayedAudioTitle);

      await tester.tap(currentPartiallyPlayedAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // Now we open the DisplaySelectableAudioListDialogWidget
      // and verify the color of the displayed audio titles

      await tester.tap(find.text(
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau\n6:29'));
      await tester.pumpAndSettle();

      // Tap the Exclude fully played audio checkbox
      await tester
          .tap(find.byKey(const Key('excludeFullyPlayedAudiosCheckbox')));
      await tester.pumpAndSettle();

      expect(
          find.text(
              "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)"),
          findsNothing);
      expect(
          find.text("Les besoins artificiels par R.Keucheyan"), findsNothing);

      await checkAudioTextColor(
        tester: tester,
        audioTitle:
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        expectedTitleTextColor: currentlyPlayingAudioTitleTextColor,
        expectedTitleTextBackgroundColor:
            currentlyPlayingAudioTitleTextBackgroundColor,
      );

      await checkAudioTextColor(
        tester: tester,
        audioTitle: "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
        expectedTitleTextColor: unplayedAudioTitleTextColor,
        expectedTitleTextBackgroundColor: null,
      );

      await checkAudioTextColor(
        tester: tester,
        audioTitle: "La résilience insulaire par Fiona Roche",
        expectedTitleTextColor: partiallyPlayedAudioTitleTextdColor,
        expectedTitleTextBackgroundColor: null,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
  });
  group('AudioPlayerView single undo/redo tests', () {
    testWidgets('forward 1 minute position change',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String toSelectAudioTitle =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_vm_play_position_undo_redo_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // Tap the 'Toggle List' button to avoid displaying the list
      // of playlists which may hide the audio title we want to
      // tap on
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // First, get the ListTile Text widget finder of the audio
      // to be selected and tap on it
      final Finder toSelectAudioListTileTextWidgetFinder =
          find.text(toSelectAudioTitle);

      await tester.tap(toSelectAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('10:00'), findsOneWidget);

      // change the current audio's play position

      await tester.tap(find.byKey(const Key('audioPlayerViewForward1mButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('11:00'), findsOneWidget);

      // undo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewUndoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position after the undo
      expect(find.text('10:00'), findsOneWidget);

      // redo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewRedoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('11:00'), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
    testWidgets('forward 10 seconds position change',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String toSelectAudioTitle =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_vm_play_position_undo_redo_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // Tap the 'Toggle List' button to avoid displaying the list
      // of playlists which may hide the audio title we want to
      // tap on
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // First, get the ListTile Text widget finder of the audio
      // to be selected and tap on it
      final Finder toSelectAudioListTileTextWidgetFinder =
          find.text(toSelectAudioTitle);

      await tester.tap(toSelectAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('10:00'), findsOneWidget);

      // change the current audio's play position

      await tester
          .tap(find.byKey(const Key('audioPlayerViewForward10sButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('10:10'), findsOneWidget);

      // undo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewUndoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position after the undo
      expect(find.text('10:00'), findsOneWidget);

      // redo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewRedoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('10:10'), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
    testWidgets('backward 1 minute position change',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String toSelectAudioTitle =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_vm_play_position_undo_redo_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // Tap the 'Toggle List' button to avoid displaying the list
      // of playlists which may hide the audio title we want to
      // tap on
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // First, get the ListTile Text widget finder of the audio
      // to be selected and tap on it
      final Finder toSelectAudioListTileTextWidgetFinder =
          find.text(toSelectAudioTitle);

      await tester.tap(toSelectAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('10:00'), findsOneWidget);

      // change the current audio's play position

      await tester.tap(find.byKey(const Key('audioPlayerViewRewind1mButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('9:00'), findsOneWidget);

      // undo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewUndoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position after the undo
      expect(find.text('10:00'), findsOneWidget);

      // redo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewRedoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('9:00'), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
    testWidgets('backward 10 seconds position change',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String toSelectAudioTitle =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_vm_play_position_undo_redo_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // Tap the 'Toggle List' button to avoid displaying the list
      // of playlists which may hide the audio title we want to
      // tap on
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // First, get the ListTile Text widget finder of the audio
      // to be selected and tap on it
      final Finder toSelectAudioListTileTextWidgetFinder =
          find.text(toSelectAudioTitle);

      await tester.tap(toSelectAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('10:00'), findsOneWidget);

      // change the current audio's play position

      await tester.tap(find.byKey(const Key('audioPlayerViewRewind10sButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('9:50'), findsOneWidget);

      // undo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewUndoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position after the undo
      expect(find.text('10:00'), findsOneWidget);

      // redo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewRedoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('9:50'), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
    testWidgets('skip to start position change',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String toSelectAudioTitle =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_vm_play_position_undo_redo_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // Tap the 'Toggle List' button to avoid displaying the list
      // of playlists which may hide the audio title we want to
      // tap on
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // First, get the ListTile Text widget finder of the audio
      // to be selected and tap on it
      final Finder toSelectAudioListTileTextWidgetFinder =
          find.text(toSelectAudioTitle);

      await tester.tap(toSelectAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('10:00'), findsOneWidget);

      // change the current audio's play position to audio start

      await tester.tap(find.byKey(const Key('audioPlayerViewSkipToStartButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('0:00'), findsOneWidget);

      // undo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewUndoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position after the undo
      expect(find.text('10:00'), findsOneWidget);

      // redo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewRedoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('0:00'), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
    testWidgets('skip to end position change',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String toSelectAudioTitle =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_vm_play_position_undo_redo_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // Tap the 'Toggle List' button to avoid displaying the list
      // of playlists which may hide the audio title we want to
      // tap on
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // First, get the ListTile Text widget finder of the audio
      // to be selected and tap on it
      final Finder toSelectAudioListTileTextWidgetFinder =
          find.text(toSelectAudioTitle);

      await tester.tap(toSelectAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('10:00'), findsOneWidget);

      // change the current audio's play position to audio end

      await tester.tap(find.byKey(const Key('audioPlayerViewSkipToEndButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('20:32'), findsOneWidget);

      // undo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewUndoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position after the undo
      expect(find.text('10:00'), findsOneWidget);

      // redo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewRedoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('20:32'), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
  });
  group('AudioPlayerView undo/redo with new command between tests', () {
    testWidgets('forward 1 minute position change',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String toSelectAudioTitle =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_vm_play_position_undo_redo_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // Tap the 'Toggle List' button to avoid displaying the list
      // of playlists which may hide the audio title we want to
      // tap on
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // First, get the ListTile Text widget finder of the audio
      // to be selected and tap on it
      final Finder toSelectAudioListTileTextWidgetFinder =
          find.text(toSelectAudioTitle);

      await tester.tap(toSelectAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // check the current audio's play position
      expect(find.text('10:00'), findsOneWidget);

      // change the current audio's play position

      await tester.tap(find.byKey(const Key('audioPlayerViewForward1mButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('11:00'), findsOneWidget);

      // undo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewUndoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position after the undo
      expect(find.text('10:00'), findsOneWidget);

      // new command: change the current audio's play position to audio start

      await tester.tap(find.byKey(const Key('audioPlayerViewSkipToStartButton')));
      await tester.pumpAndSettle();

      expect(find.text('0:00'), findsOneWidget);

      // redo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewRedoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('11:00'), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
    testWidgets('forward 10 seconds position change',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String toSelectAudioTitle =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_vm_play_position_undo_redo_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // Tap the 'Toggle List' button to avoid displaying the list
      // of playlists which may hide the audio title we want to
      // tap on
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // First, get the ListTile Text widget finder of the audio
      // to be selected and tap on it
      final Finder toSelectAudioListTileTextWidgetFinder =
          find.text(toSelectAudioTitle);

      await tester.tap(toSelectAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // check the current audio's initial position
      expect(find.text('10:00'), findsOneWidget);

      // change the current audio's play position

      await tester
          .tap(find.byKey(const Key('audioPlayerViewForward10sButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('10:10'), findsOneWidget);

      // undo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewUndoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position after the undo
      expect(find.text('10:00'), findsOneWidget);

      // new command: change the current audio's play position to audio start

      await tester.tap(find.byKey(const Key('audioPlayerViewSkipToStartButton')));
      await tester.pumpAndSettle();

      expect(find.text('0:00'), findsOneWidget);

      // redo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewRedoButton')));
      await tester.pumpAndSettle();

      // check the current audio's redoned change position
      expect(find.text('10:10'), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
    testWidgets('backward 1 minute position change',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String toSelectAudioTitle =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_vm_play_position_undo_redo_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // Tap the 'Toggle List' button to avoid displaying the list
      // of playlists which may hide the audio title we want to
      // tap on
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // First, get the ListTile Text widget finder of the audio
      // to be selected and tap on it
      final Finder toSelectAudioListTileTextWidgetFinder =
          find.text(toSelectAudioTitle);

      await tester.tap(toSelectAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // check the current audio's play position
      expect(find.text('10:00'), findsOneWidget);

      // change the current audio's play position

      await tester.tap(find.byKey(const Key('audioPlayerViewRewind1mButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('9:00'), findsOneWidget);

      // undo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewUndoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position after the undo
      expect(find.text('10:00'), findsOneWidget);

      // new command: change the current audio's play position to audio end

      await tester.tap(find.byKey(const Key('audioPlayerViewSkipToEndButton')));
      await tester.pumpAndSettle();

      expect(find.text('20:32'), findsOneWidget);

      // redo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewRedoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('9:00'), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
    testWidgets('backward 10 seconds position change',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String toSelectAudioTitle =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_vm_play_position_undo_redo_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // Tap the 'Toggle List' button to avoid displaying the list
      // of playlists which may hide the audio title we want to
      // tap on
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // First, get the ListTile Text widget finder of the audio
      // to be selected and tap on it
      final Finder toSelectAudioListTileTextWidgetFinder =
          find.text(toSelectAudioTitle);

      await tester.tap(toSelectAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // check the current audio's play position
      expect(find.text('10:00'), findsOneWidget);

      // change the current audio's play position

      await tester.tap(find.byKey(const Key('audioPlayerViewRewind10sButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('9:50'), findsOneWidget);

      // undo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewUndoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position after the undo
      expect(find.text('10:00'), findsOneWidget);

      // new command: change the current audio's play position to audio end

      await tester.tap(find.byKey(const Key('audioPlayerViewSkipToEndButton')));
      await tester.pumpAndSettle();

      expect(find.text('20:32'), findsOneWidget);

      // redo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewRedoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('9:50'), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
    testWidgets('skip to start position change',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String toSelectAudioTitle =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_vm_play_position_undo_redo_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // Tap the 'Toggle List' button to avoid displaying the list
      // of playlists which may hide the audio title we want to
      // tap on
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // First, get the ListTile Text widget finder of the audio
      // to be selected and tap on it
      final Finder toSelectAudioListTileTextWidgetFinder =
          find.text(toSelectAudioTitle);

      await tester.tap(toSelectAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('10:00'), findsOneWidget);

      // change the current audio's play position to audio start

      await tester.tap(find.byKey(const Key('audioPlayerViewSkipToStartButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('0:00'), findsOneWidget);

      // undo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewUndoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position after the undo
      expect(find.text('10:00'), findsOneWidget);

      // new command: go forward 1 minute

      await tester.tap(find.byKey(const Key('audioPlayerViewForward1mButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('11:00'), findsOneWidget);

      // redo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewRedoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('0:00'), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
    testWidgets('skip to end position change',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String toSelectAudioTitle =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_vm_play_position_undo_redo_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // Tap the 'Toggle List' button to avoid displaying the list
      // of playlists which may hide the audio title we want to
      // tap on
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // First, get the ListTile Text widget finder of the audio
      // to be selected and tap on it
      final Finder toSelectAudioListTileTextWidgetFinder =
          find.text(toSelectAudioTitle);

      await tester.tap(toSelectAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('10:00'), findsOneWidget);

      // change the current audio's play position to audio end

      await tester.tap(find.byKey(const Key('audioPlayerViewSkipToEndButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('20:32'), findsOneWidget);

      // undo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewUndoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position after the undo
      expect(find.text('10:00'), findsOneWidget);

      // new command: go back 1 minute

      await tester.tap(find.byKey(const Key('audioPlayerViewRewind1mButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('9:00'), findsOneWidget);

      // redo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewRedoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('20:32'), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
  });
}

Future<void> checkAudioTextColor({
  required WidgetTester tester,
  required String audioTitle,
  required Color? expectedTitleTextColor,
  required Color? expectedTitleTextBackgroundColor,
}) async {
  // Find the Text widget by its text content
  final Finder textFinder = find.text(audioTitle);

  // Retrieve the Text widget
  final Text textWidget = tester.widget(textFinder) as Text;

  // Check if the color of the Text widget is as expected
  expect(textWidget.style?.color, equals(expectedTitleTextColor));
  expect(textWidget.style?.backgroundColor,
      equals(expectedTitleTextBackgroundColor));
}

void verifyAudioPlaySpeedStoredInPlaylistJsonFile(
    String audioPlayerSelectedPlaylistTitle,
    int playableAudioLstAudioIndex,
    double expectedAudioPlaySpeed) {
  final String selectedPlaylistPath = path.join(
    kDownloadAppTestDirWindows,
    audioPlayerSelectedPlaylistTitle,
  );

  final selectedPlaylistFilePathName = path.join(
    selectedPlaylistPath,
    '$audioPlayerSelectedPlaylistTitle.json',
  );

  // Load playlist from the json file
  Playlist loadedSelectedPlaylist = JsonDataService.loadFromFile(
    jsonPathFileName: selectedPlaylistFilePathName,
    type: Playlist,
  );

  expect(
      loadedSelectedPlaylist
          .playableAudioLst[playableAudioLstAudioIndex].audioPlaySpeed,
      expectedAudioPlaySpeed);
}

/// Initializes the application and selects the playlist if
/// [selectedPlaylistTitle] is not null.
Future<void> initializeApplicationAndSelectPlaylist({
  required WidgetTester tester,
  String? savedTestDataDirName,
  String? selectedPlaylistTitle,
}) async {
  // Purge the test playlist directory if it exists so that the
  // playlist list is empty
  DirUtil.deleteFilesInDirAndSubDirs(
    rootPath: kDownloadAppTestDirWindows,
    deleteSubDirectoriesAsWell: true,
  );

  if (savedTestDataDirName != null) {
    // Copy the test initial audio data to the app dir
    DirUtil.copyFilesFromDirAndSubDirsToDirectory(
      sourceRootPath:
          "$kDownloadAppTestSavedDataDir${path.separator}$savedTestDataDirName",
      destinationRootPath: kDownloadAppTestDirWindows,
    );
  }

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

  if (selectedPlaylistTitle != null) {
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

    // Tap on the playlist checkbox to select it if it is not
    // already selected
    if (checkbox.value == null || !checkbox.value!) {
      // Tap the ListTile Playlist checkbox to select it
      // so that the playlist audios are listed
      await tester.tap(selectedPlaylistCheckboxWidgetFinder);
      await tester.pumpAndSettle();
    }
  }
}

Duration parseDuration(String hhmmString) {
  List<String> parts = hhmmString.split(':');
  if (parts.length != 2) {
    throw const FormatException("Invalid duration format");
  }

  int hours = int.parse(parts[0]);
  int minutes = int.parse(parts[1]);

  return Duration(hours: hours, minutes: minutes);
}
