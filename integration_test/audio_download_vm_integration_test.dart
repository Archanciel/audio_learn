import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;

import 'package:audio_learn/constants.dart';
import 'package:audio_learn/models/audio.dart';
import 'package:audio_learn/models/playlist.dart';
import 'package:audio_learn/utils/dir_util.dart';
import 'package:audio_learn/viewmodels/audio_download_vm.dart';
import 'package:audio_learn/viewmodels/warning_message_vm.dart';

const int secondsDelay = 8; // 7 works, but 8 is safer
final String todayDownloadFileNamePrefix = (kAudioFileNamePrefixIncludeTime)
    ? Audio.downloadDateTimePrefixFormatter.format(DateTime.now())
    : Audio.downloadDatePrefixFormatter
        .format(DateTime.now().add(const Duration(seconds: secondsDelay)));

void main() {
  const String testPlaylistId = 'PLzwWSJNcZTMRB9ILve6fEIS_OHGrV5R2o';
  const String testPlaylistUrl =
      'https://youtube.com/playlist?list=PLzwWSJNcZTMRB9ILve6fEIS_OHGrV5R2o';
  const String testPlaylistTitle = 'audio_learn_test_download_2_small_videos';
  const String testPlaylistDir =
      '$kDownloadAppTestDir\\audio_learn_test_download_2_small_videos';

  // Necessary to avoid FatalFailureException (FatalFailureException: Failed
  // to perform an HTTP request to YouTube due to a fatal failure. In most
  // cases, this error indicates that YouTube most likely changed something,
  // which broke the library.
  // If this issue persists, please report it on the project's GitHub page.
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Download 1 playlist with short audios', () {
    test('Check initial values', () {
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      final WarningMessageVM warningMessageVM = WarningMessageVM();
      final AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        isTest: true,
      );

      expect(audioDownloadVM.listOfPlaylist, []);
      expect(audioDownloadVM.isDownloading, false);
      expect(audioDownloadVM.downloadProgress, 0.0);
      expect(audioDownloadVM.lastSecondDownloadSpeed, 0);
      expect(audioDownloadVM.isHighQuality, false);
    });

    testWidgets('Playlist 2 short audios: playlist dir not exist',
        (WidgetTester tester) async {
      late AudioDownloadVM audioDownloadVM;
      final Directory directory = Directory(testPlaylistDir);

      deletePlaylistDownloadDir(directory);

      expect(directory.existsSync(), false);

      // await tester.pumpWidget(MyApp());
      await tester.pumpWidget(ChangeNotifierProvider(
        create: (BuildContext context) {
          final WarningMessageVM warningMessageVM = WarningMessageVM();
          audioDownloadVM = AudioDownloadVM(
            warningMessageVM: warningMessageVM,
            isTest: true,
          );
          return audioDownloadVM;
        },
        child: const MaterialApp(
          home: DownloadPlaylistPage(
            playlistUrl: testPlaylistUrl,
          ),
        ),
      ));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Add a delay to allow the download to finish. 5 seconds is ok
      // when running the audio_download_vm_test only.
      // Waiting 5 seconds only causes MissingPluginException
      // 'No implementation found for method $method on channel $name'
      // when all tsts are run. 7 seconds solve the problem.
      await Future.delayed(const Duration(seconds: 10));
      await tester.pump();

      expect(directory.existsSync(), true);

      Playlist downloadedPlaylist = audioDownloadVM.listOfPlaylist[0];

      checkDownloadedPlaylist(
        downloadedPlaylist: downloadedPlaylist,
        playlistId: testPlaylistId,
        playlistTitle: testPlaylistTitle,
        playlistUrl: testPlaylistUrl,
        playlistDir: testPlaylistDir,
      );

      expect(audioDownloadVM.isDownloading, false);
      expect(audioDownloadVM.downloadProgress, 1.0);
      expect(audioDownloadVM.lastSecondDownloadSpeed, 0);
      expect(audioDownloadVM.isHighQuality, false);

      // downloadedAudioLst contains added Audio^s
      checkDownloadedAudios(
        downloadedAudioOne: downloadedPlaylist.downloadedAudioLst[0],
        downloadedAudioTwo: downloadedPlaylist.downloadedAudioLst[1],
        downloadFileNamePrefix: todayDownloadFileNamePrefix,
      );

      // playableAudioLst contains inserted at list start Audio^s
      checkDownloadedAudios(
        downloadedAudioOne: downloadedPlaylist.playableAudioLst[1],
        downloadedAudioTwo: downloadedPlaylist.playableAudioLst[0],
        downloadFileNamePrefix: todayDownloadFileNamePrefix,
      );

      // Checking if there are 3 files in the directory (2 mp3 and 1 json)
      final List<FileSystemEntity> files =
          directory.listSync(recursive: false, followLinks: false);

      expect(files.length, 3);

      deletePlaylistDownloadDir(directory);
    });
    testWidgets(
        'Playlist 2 short audios: playlist 1st audio was already downloaded and was deleted',
        (WidgetTester tester) async {
      late AudioDownloadVM audioDownloadVM;
      final Directory directory = Directory(testPlaylistDir);

      deletePlaylistDownloadDir(directory);

      expect(directory.existsSync(), false);

      await DirUtil.createDirIfNotExist(pathStr: testPlaylistDir);
      await DirUtil.copyFileToDirectory(
        sourceFilePathName:
            "$kDownloadAppTestSavedDataDir${path.separator}$testPlaylistTitle${path.separator}${testPlaylistTitle}_1_audio.json",
        targetDirectoryPath: testPlaylistDir,
        targetFileName: '$testPlaylistTitle.json',
      );

      final WarningMessageVM warningMessageVM = WarningMessageVM();
      final AudioDownloadVM audioDownloadVMbeforeDownload = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        isTest: true,
      );
      Playlist downloadedPlaylistBeforeDownload =
          audioDownloadVMbeforeDownload.listOfPlaylist[0];

      checkDownloadedPlaylist(
        downloadedPlaylist: downloadedPlaylistBeforeDownload,
        playlistId: testPlaylistId,
        playlistTitle: testPlaylistTitle,
        playlistUrl: testPlaylistUrl,
        playlistDir: testPlaylistDir,
      );

      List<Audio> downloadedAudioLstBeforeDownload =
          downloadedPlaylistBeforeDownload.downloadedAudioLst;
      List<Audio> playableAudioLstBeforeDownload =
          downloadedPlaylistBeforeDownload.playableAudioLst;

      expect(downloadedAudioLstBeforeDownload.length, 1);
      expect(playableAudioLstBeforeDownload.length, 1);

      checkAudioTwo(
        downloadedAudioTwo: downloadedAudioLstBeforeDownload[0],
        downloadFileNamePrefix: '230406',
      );
      checkAudioTwo(
        downloadedAudioTwo: playableAudioLstBeforeDownload[0],
        downloadFileNamePrefix: '230406',
      );

      // await tester.pumpWidget(MyApp());
      await tester.pumpWidget(ChangeNotifierProvider(
        create: (BuildContext context) {
          final WarningMessageVM warningMessageVM = WarningMessageVM();
          audioDownloadVM = AudioDownloadVM(
            warningMessageVM: warningMessageVM,
            isTest: true,
          );
          return audioDownloadVM;
        },
        child: const MaterialApp(
          home: DownloadPlaylistPage(
            playlistUrl: testPlaylistUrl,
          ),
        ),
      ));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Add a delay to allow the download to finish. 5 seconds is ok
      // when running the audio_download_vm_test only.
      // Waiting 5 seconds only causes MissingPluginException
      // 'No implementation found for method $method on channel $name'
      // when all tsts are run. 7 seconds solve the problem.
      await Future.delayed(const Duration(seconds: secondsDelay));
      await tester.pump();

      expect(directory.existsSync(), true);

      Playlist downloadedPlaylist = audioDownloadVM.listOfPlaylist[0];

      checkDownloadedPlaylist(
        downloadedPlaylist: downloadedPlaylist,
        playlistId: testPlaylistId,
        playlistTitle: testPlaylistTitle,
        playlistUrl: testPlaylistUrl,
        playlistDir: testPlaylistDir,
      );

      expect(audioDownloadVM.isDownloading, false);
      expect(audioDownloadVM.downloadProgress, 1.0);
      expect(audioDownloadVM.lastSecondDownloadSpeed, 0);
      expect(audioDownloadVM.isHighQuality, false);

      // downloadedAudioLst contains added Audio^s
      checkDownloadedAudios(
        downloadedAudioOne: downloadedPlaylist.downloadedAudioLst[1],
        downloadedAudioTwo: downloadedPlaylist.downloadedAudioLst[0],
        downloadFileNamePrefix: '230406',
        todayFileNamePrefix: todayDownloadFileNamePrefix,
      );

      // playableAudioLst contains inserted at list start Audio^s
      checkDownloadedAudios(
        downloadedAudioOne: downloadedPlaylist.playableAudioLst[0],
        downloadedAudioTwo: downloadedPlaylist.playableAudioLst[1],
        downloadFileNamePrefix: '230406',
        todayFileNamePrefix: todayDownloadFileNamePrefix,
      );

      // Checking if there are 3 files in the directory (1 mp3 and 1 json)
      final List<FileSystemEntity> files =
          directory.listSync(recursive: false, followLinks: false);

      expect(files.length, 2);

      deletePlaylistDownloadDir(directory);
    });
  });
  group('Download recreated playlist with short audios', () {
    /// This test is used to test recreating the playlist with the
    /// same name. Recreating a playlist with an identical name avoids
    /// to loose time removing from the original playlist the referenced
    /// videos. The recreated playlist audios are downloaded in the same
    /// dir than the original playlist, The original playlist json file is
    /// updated with the recreated playlist id and url as well with the
    /// newly downloaded audios.
    testWidgets(
        'Recreated playlist 2 new short audios: initial playlist 1st and 2nd audio were already downloaded and were deleted',
        (WidgetTester tester) async {
      late AudioDownloadVM audioDownloadVM;
      final Directory directory = Directory(testPlaylistDir);

      deletePlaylistDownloadDir(directory);

      expect(directory.existsSync(), false);

      await DirUtil.createDirIfNotExist(pathStr: testPlaylistDir);
      await DirUtil.copyFileToDirectory(
        sourceFilePathName:
            "$kDownloadAppTestSavedDataDir${path.separator}$testPlaylistTitle${path.separator}$testPlaylistTitle.json",
        targetDirectoryPath: testPlaylistDir,
        targetFileName: '$testPlaylistTitle.json',
      );

      final WarningMessageVM warningMessageVM = WarningMessageVM();
      final AudioDownloadVM audioDownloadVMbeforeDownload = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        isTest: true,
      );
      Playlist downloadedPlaylistBeforeDownload =
          audioDownloadVMbeforeDownload.listOfPlaylist[0];

      checkDownloadedPlaylist(
        downloadedPlaylist: downloadedPlaylistBeforeDownload,
        playlistId: testPlaylistId,
        playlistTitle: testPlaylistTitle,
        playlistUrl: testPlaylistUrl,
        playlistDir: testPlaylistDir,
      );

      List<Audio> downloadedAudioLstBeforeDownload =
          downloadedPlaylistBeforeDownload.downloadedAudioLst;
      List<Audio> playableAudioLstBeforeDownload =
          downloadedPlaylistBeforeDownload.playableAudioLst;

      checkDownloadedAudios(
        downloadedAudioOne: downloadedAudioLstBeforeDownload[0],
        downloadedAudioTwo: downloadedAudioLstBeforeDownload[1],
        downloadFileNamePrefix: '230406',
      );

      // playableAudioLst contains inserted at list start Audio^s
      checkDownloadedAudios(
        downloadedAudioOne: playableAudioLstBeforeDownload[1],
        downloadedAudioTwo: playableAudioLstBeforeDownload[0],
        downloadFileNamePrefix: '230406',
      );

      // await tester.pumpWidget(MyApp());
      await tester.pumpWidget(ChangeNotifierProvider(
        create: (BuildContext context) {
          final WarningMessageVM warningMessageVM = WarningMessageVM();
          audioDownloadVM = AudioDownloadVM(
            warningMessageVM: warningMessageVM,
            isTest: true,
          );
          return audioDownloadVM;
        },
        child: const MaterialApp(
          home: DownloadPlaylistPage(
            playlistUrl: testPlaylistUrl,
          ),
        ),
      ));

      const String recreatedPlaylistId = 'PLzwWSJNcZTMSwrDOAZEPf0u6YvrKGNnvC';
      const String recreatedPlaylistWithSameTitleUrl =
          'https://youtube.com/playlist?list=PLzwWSJNcZTMSwrDOAZEPf0u6YvrKGNnvC';

      await tester.enterText(
        find.byKey(const Key('playlistUrlTextField')),
        recreatedPlaylistWithSameTitleUrl,
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Add a delay to allow the download to finish. 5 seconds is ok
      // when running the audio_download_vm_test only.
      // Waiting 5 seconds only causes MissingPluginException
      // 'No implementation found for method $method on channel $name'
      // when all tsts are run. 7 seconds solve the problem.
      await Future.delayed(const Duration(seconds: secondsDelay));
      await tester.pump();

      expect(directory.existsSync(), true);

      Playlist downloadedPlaylist = audioDownloadVM.listOfPlaylist[0];

      checkDownloadedPlaylist(
        downloadedPlaylist: downloadedPlaylist,
        playlistId: recreatedPlaylistId,
        playlistTitle: testPlaylistTitle,
        playlistUrl: recreatedPlaylistWithSameTitleUrl,
        playlistDir: testPlaylistDir,
      );

      expect(audioDownloadVM.isDownloading, false);
      expect(audioDownloadVM.downloadProgress, 1.0);
      expect(audioDownloadVM.lastSecondDownloadSpeed, 0);
      expect(audioDownloadVM.isHighQuality, false);

      // downloadedAudioLst contains added Audio^s
      checkDownloadedAudios(
        downloadedAudioOne: downloadedPlaylist.downloadedAudioLst[0],
        downloadedAudioTwo: downloadedPlaylist.downloadedAudioLst[1],
        downloadFileNamePrefix: '230406',
      );

      if (!kAudioFileNamePrefixIncludeTime) {
        // if kAudioFileNamePrefixIncludeTime is true,
        // it is not possible to check the audio file
        // name because it contains the time when the
        // audio was downloaded.
        expect(downloadedPlaylist.downloadedAudioLst[2].audioFileName,
            '$todayDownloadFileNamePrefix-Really short video 16-05-12.mp3');
        expect(downloadedPlaylist.downloadedAudioLst[3].audioFileName,
            '$todayDownloadFileNamePrefix-morning _ cinematic video 19-03-06.mp3');
      }

      // playableAudioLst contains inserted at list start Audio^s
      checkDownloadedAudios(
        downloadedAudioOne: downloadedPlaylist.playableAudioLst[3],
        downloadedAudioTwo: downloadedPlaylist.playableAudioLst[2],
        downloadFileNamePrefix: '230406',
      );

      if (!kAudioFileNamePrefixIncludeTime) {
        // if kAudioFileNamePrefixIncludeTime is true,
        // it is not possible to check the audio file
        // name because it contains the time when the
        // audio was downloaded.
        expect(downloadedPlaylist.playableAudioLst[1].audioFileName,
            '$todayDownloadFileNamePrefix-Really short video 16-05-12.mp3');
        expect(downloadedPlaylist.playableAudioLst[0].audioFileName,
            '$todayDownloadFileNamePrefix-morning _ cinematic video 19-03-06.mp3');
      }

      // Checking if there are 3 files in the directory (1 mp3 and 1 json)
      final List<FileSystemEntity> files =
          directory.listSync(recursive: false, followLinks: false);

      expect(files.length, 3);

      deletePlaylistDownloadDir(directory);
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

class DownloadPlaylistPage extends StatefulWidget {
  final String playlistUrl;

  const DownloadPlaylistPage({
    super.key,
    required this.playlistUrl,
  });

  @override
  State<DownloadPlaylistPage> createState() => _DownloadPlaylistPageState();
}

class _DownloadPlaylistPageState extends State<DownloadPlaylistPage> {
  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    _urlController.text = widget.playlistUrl;
    super.initState();
  }

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
