import 'dart:io';

import 'package:audio_learn/main.dart';
import 'package:audio_learn/services/settings_data_service.dart';
import 'package:audio_learn/utils/dir_util.dart';
import 'package:audio_learn/views/widgets/playlist_list_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:audio_learn/constants.dart';

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
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);

      final String youtubePlaylistUrl =
          'https://youtube.com/playlist?list=PLzwWSJNcZTMTSAE8iabVB6BCAfFGHHfah';
      final String youtubePlaylistTitle = 'audio_learn_new_youtube_playlist_test';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MainApp(
              key: const Key('mainAppKey'),
              settingsDataService: SettingsDataService(),
            ),
          ),
        ),
      );

      // Tap the 'Playlist' button to show the empty playlist list
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // The list should be visible now but empty
      expect(find.byKey(const Key('expandable_playlist_list')), findsOneWidget);
      expect(find.byType(PlaylistListItemWidget), findsNothing);
    });
  });
}
