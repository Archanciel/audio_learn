import 'dart:io';
import 'package:audio_learn/main.dart';
import 'package:audio_learn/services/settings_data_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'package:audio_learn/constants.dart';
import 'package:audio_learn/models/audio.dart';
import 'package:audio_learn/models/playlist.dart';
import 'package:audio_learn/viewmodels/audio_download_vm.dart';
import 'package:audio_learn/viewmodels/warning_message_vm.dart';

const int secondsDelay = 8; // 7 works, but 8 is safer
final String todayDownloadFileNamePrefix = (kAudioFileNamePrefixIncludeTime)
    ? Audio.downloadDateTimePrefixFormatter.format(DateTime.now())
    : Audio.downloadDatePrefixFormatter
        .format(DateTime.now().add(const Duration(seconds: secondsDelay)));

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

void checkDownloadedPlaylist({
  required Playlist downloadedPlaylist,
  required String playlistId,
  required String playlistTitle,
  required String playlistUrl,
  required String playlistDir,
}) {
  expect(downloadedPlaylist.id, playlistId);
  expect(downloadedPlaylist.title, playlistTitle);
  expect(downloadedPlaylist.url, playlistUrl);
  expect(downloadedPlaylist.downloadPath, playlistDir);
}

void checkDownloadedAudios({
  required Audio downloadedAudioOne,
  required Audio downloadedAudioTwo,
  required String downloadFileNamePrefix,
  String? todayFileNamePrefix,
}) {
  checkAudioOne(
    downloadedAudioOne: downloadedAudioOne,
    downloadFileNamePrefix: downloadFileNamePrefix,
  );

  checkAudioTwo(
    downloadedAudioTwo: downloadedAudioTwo,
    todayFileNamePrefix: todayFileNamePrefix,
    downloadFileNamePrefix: downloadFileNamePrefix,
  );
}

void checkAudioTwo({
  required Audio downloadedAudioTwo,
  String? todayFileNamePrefix,
  required String downloadFileNamePrefix,
}) {
  expect(downloadedAudioTwo.originalVideoTitle,
      "audio learn test short video two");
  expect(
      downloadedAudioTwo.validVideoTitle, "audio learn test short video two");
  expect(downloadedAudioTwo.compactVideoDescription,
      "Jean-Pierre Schnyder\n\nCette vidéo me sert à tester AudioLearn, l'app Android que je développe. ...");
  expect(downloadedAudioTwo.videoUrl,
      "https://www.youtube.com/watch?v=uv3VQoWSjBE");
  expect(downloadedAudioTwo.videoUploadDate,
      DateTime.parse("2023-06-10T00:00:00.000"));
  expect(downloadedAudioTwo.audioDuration, const Duration(milliseconds: 10000));
  expect(downloadedAudioTwo.isMusicQuality, false);

  if (!kAudioFileNamePrefixIncludeTime) {
    // if kAudioFileNamePrefixIncludeTime is true,
    // it is not possible to check the audio file
    // name because it contains the time when the
    // audio was downloaded.
    expect(downloadedAudioTwo.audioFileName,
        "${todayFileNamePrefix ?? downloadFileNamePrefix}-audio learn test short video two 23-06-10.mp3");
  }
  expect(downloadedAudioTwo.audioFileSize, 61425);
}

void checkAudioOne({
  required Audio downloadedAudioOne,
  required String downloadFileNamePrefix,
}) {
  expect(downloadedAudioOne.originalVideoTitle,
      "audio learn test short video one");
  expect(
      downloadedAudioOne.validVideoTitle, "audio learn test short video one");
  expect(downloadedAudioOne.videoUrl,
      "https://www.youtube.com/watch?v=v7PWb7f_P8M");
  expect(downloadedAudioOne.compactVideoDescription,
      "Jean-Pierre Schnyder\n\nCette vidéo me sert à tester AudioLearn, l'app Android que je développe et dont le code est disponible sur GitHub. ...");
  expect(downloadedAudioOne.videoUploadDate,
      DateTime.parse("2023-06-10T00:00:00.000"));
  expect(downloadedAudioOne.audioDuration, const Duration(milliseconds: 24000));
  expect(downloadedAudioOne.isMusicQuality, false);
  if (!kAudioFileNamePrefixIncludeTime) {
    // if kAudioFileNamePrefixIncludeTime is true,
    // it is not possible to check the audio file
    // name because it contains the time when the
    // audio was downloaded.
    expect(downloadedAudioOne.audioFileName,
        "$downloadFileNamePrefix-audio learn test short video one 23-06-10.mp3");
  }
  expect(downloadedAudioOne.audioFileSize, 143679);
}

void deletePlaylistDownloadDir(Directory directory) {
  if (directory.existsSync()) {
    directory.deleteSync(recursive: true);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final WarningMessageVM warningMessageVM = WarningMessageVM();
    final AudioDownloadVM audioDownloadVM = AudioDownloadVM(
      warningMessageVM: warningMessageVM,
    );
    return MaterialApp(
      home: ChangeNotifierProvider(
        create: (context) => audioDownloadVM,
        child: const DownloadPlaylistPage(),
      ),
    );
  }
}

class DownloadPlaylistPage extends StatefulWidget {
  const DownloadPlaylistPage({super.key});

  @override
  State<DownloadPlaylistPage> createState() => _DownloadPlaylistPageState();
}

class _DownloadPlaylistPageState extends State<DownloadPlaylistPage> {
  final TextEditingController _urlController = TextEditingController(
    text:
        'https://youtube.com/playlist?list=PLzwWSJNcZTMRB9ILve6fEIS_OHGrV5R2o',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Download Playlist Audios')),
      body: Center(
        child: Column(
          children: [
            TextField(
              key: const Key('playlistUrlTextField'),
              controller: _urlController,
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<AudioDownloadVM>(context, listen: false)
                    .downloadPlaylistAudios(
                  playlistUrl: _urlController.text,
                );
              },
              child: const Text('Download Playlist Audios'),
            ),
          ],
        ),
      ),
    );
  }
}
