import 'dart:io';
import 'package:audio_learn/models/playlist.dart';
import 'package:audio_learn/services/json_data_service.dart';
import 'package:audio_learn/utils/dir_util.dart';
import 'package:audio_learn/viewmodels/audio_download_vm.dart';
import 'package:audio_learn/viewmodels/warning_message_vm.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_test/flutter_test.dart';

import 'package:audio_learn/constants.dart';
import 'package:audio_learn/models/audio.dart';
import 'package:audio_learn/services/settings_data_service.dart';
import 'package:audio_learn/viewmodels/playlist_list_vm.dart';

void main() {
  group('PlaylistListVM', () {
    late PlaylistListVM playlistListVM;

    setUp(() {
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

      // audioDownloadVM.youtubeExplode = mockYoutubeExplode;

      playlistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // expandablePlaylistListVM to know which playlists are
      // selected and which are not
      playlistListVM.getUpToDateSelectablePlaylists();
    });

    test('copyAudioToPlaylist copies audio to playlist', () {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}playlist_list_vm_test_data",
        destinationRootPath: kDownloadAppTestDirWindows,
      );

      const String sourcePlaylistTitle = 'S8 audio';

      final sourcePlaylistPath = path.join(
        kDownloadAppTestDirWindows,
        sourcePlaylistTitle,
      );

      final sourcePlaylistFilePathName = path.join(
        sourcePlaylistPath,
        '$sourcePlaylistTitle.json',
      );

      // Load playlist from the json file
      Playlist sourcePlaylist = JsonDataService.loadFromFile(
        jsonPathFileName: sourcePlaylistFilePathName,
        type: Playlist,
      );

      const String targetPlaylistTitle = 'local_target';

      final targetPlaylistPath = path.join(
        kDownloadAppTestDirWindows,
        targetPlaylistTitle,
      );

      final targetPlaylistFilePathName = path.join(
        targetPlaylistPath,
        '$targetPlaylistTitle.json',
      );

      // Load playlist from the json file
      Playlist targetPlaylist = JsonDataService.loadFromFile(
        jsonPathFileName: targetPlaylistFilePathName,
        type: Playlist,
      );

      // Testing copy La résilience insulaire par Fiona Roche with
      // play position at start of audio
      testCopyAudioToPlaylist(
        playlistListVM,
        sourcePlaylist.playableAudioLst[0],
        targetPlaylist,
      );

      // Testing copy Le Secret de la RESILIENCE révélé par Boris Cyrulnik
      // with play position at end of audio
      testCopyAudioToPlaylist(
        playlistListVM,
        sourcePlaylist.playableAudioLst[1],
        targetPlaylist,
      );

      // Testing copy Ce qui va vraiment sauver notre espèce par Jancovici
      // et Barrau with play position 2 seconds before end of audio
      testCopyAudioToPlaylist(
        playlistListVM,
        sourcePlaylist.playableAudioLst[4],
        targetPlaylist,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
    // Add more tests as needed
  });
}

void testCopyAudioToPlaylist(
  PlaylistListVM playlistListVM,
  Audio audio,
  Playlist targetPlaylist,
) {
  playlistListVM.copyAudioToPlaylist(
    audio: audio,
    targetPlaylist: targetPlaylist,
  );

  Audio copiedAudio = targetPlaylist.playableAudioLst[0];

  expect(
      ensureAudioAreEquals(
        audio,
        copiedAudio,
      ),
      isTrue);

  expect(
      copiedAudio.copiedFromPlaylistTitle ==
          audio.enclosingPlaylist!.title,
      isTrue);

  expect(
      copiedAudio.copiedToPlaylistTitle ==
          null,
      isTrue);

  expect(
      copiedAudio.movedFromPlaylistTitle ==
          null,
      isTrue);

  expect(
      copiedAudio.movedToPlaylistTitle ==
          null,
      isTrue);
}

      // audio1.enclosingPlaylist == audio2.enclosingPlaylist &&
      // audio1.movedFromPlaylistTitle == audio2.movedFromPlaylistTitle &&
      // audio1.movedToPlaylistTitle == audio2.movedToPlaylistTitle &&
      // audio1.copiedFromPlaylistTitle == audio2.copiedFromPlaylistTitle &&
      // audio1.copiedToPlaylistTitle == audio2.copiedToPlaylistTitle &&
      
bool ensureAudioAreEquals(Audio audio1, Audio audio2) {
  return audio1.originalVideoTitle == audio2.originalVideoTitle &&
      audio1.validVideoTitle == audio2.validVideoTitle &&
      audio1.compactVideoDescription == audio2.compactVideoDescription &&
      audio1.videoUrl == audio2.videoUrl &&
      audio1.audioDownloadDateTime == audio2.audioDownloadDateTime &&
      audio1.audioDownloadDuration == audio2.audioDownloadDuration &&
      audio1.videoUploadDate == audio2.videoUploadDate &&
      audio1.audioFileName == audio2.audioFileName &&
      audio1.audioDuration == audio2.audioDuration &&
      audio1.audioFileSize == audio2.audioFileSize &&
      audio1.audioDownloadSpeed == audio2.audioDownloadSpeed &&
      audio1.isPlayingOrPausedWithPositionBetweenAudioStartAndEnd ==
          audio2.isPlayingOrPausedWithPositionBetweenAudioStartAndEnd &&
      audio1.audioPositionSeconds == audio2.audioPositionSeconds &&
      audio1.isPaused == audio2.isPaused &&
      audio1.audioPausedDateTime == audio2.audioPausedDateTime &&
      audio1.audioPlaySpeed == audio2.audioPlaySpeed &&
      audio1.isAudioMusicQuality == audio2.isAudioMusicQuality;
}
