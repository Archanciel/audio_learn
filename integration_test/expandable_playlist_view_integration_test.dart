import 'package:audio_learn/main.dart';
import 'package:audio_learn/services/settings_data_service.dart';
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
    /// This test is used to test recreating the playlist with the
    /// same name. Recreating a playlist with an identical name avoids
    /// to loose time removing from the original playlist the referenced
    /// videos. The recreated playlist audios are downloaded in the same
    /// dir than the original playlist, The original playlist json file is
    /// updated with the recreated playlist id and url as well with the
    /// newly downloaded audios.
    testWidgets('Add Youtube playlist', (tester) async {
      String youtubePlaylistUrl =
          'https://youtube.com/playlist?list=PLzwWSJNcZTMTSAE8iabVB6BCAfFGHHfah';
      String youtubePlaylistTitle = 'audio_learn_new_youtube_playlist_test';

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

      // see chatgpt_audio_learn main_expandable_integration_test.dart
      // for integr testing usage ...
    });
  });
}
