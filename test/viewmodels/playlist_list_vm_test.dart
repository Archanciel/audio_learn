import 'package:path/path.dart' as path;
import 'package:flutter_test/flutter_test.dart';

import 'package:audio_learn/models/playlist.dart';
import 'package:audio_learn/services/json_data_service.dart';
import 'package:audio_learn/utils/dir_util.dart';
import 'package:audio_learn/viewmodels/audio_download_vm.dart';
import 'package:audio_learn/viewmodels/warning_message_vm.dart';
import 'package:audio_learn/constants.dart';
import 'package:audio_learn/models/audio.dart';
import 'package:audio_learn/services/settings_data_service.dart';
import 'package:audio_learn/viewmodels/playlist_list_vm.dart';

void main() {
  group('Copy/move audio to target playlist', () {
    late PlaylistListVM playlistListVM;

    setUp(() {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}playlist_list_vm_copy_move_audio_test_data",
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
        sourcePlaylist,
        0,
        targetPlaylist,
      );

      // Testing copy Le Secret de la RESILIENCE révélé par Boris Cyrulnik
      // with play position at end of audio
      testCopyAudioToPlaylist(
        playlistListVM,
        sourcePlaylist,
        1,
        targetPlaylist,
      );

      // Testing copy Ce qui va vraiment sauver notre espèce par Jancovici
      // et Barrau with play position 2 seconds before end of audio
      testCopyAudioToPlaylist(
        playlistListVM,
        sourcePlaylist,
        4,
        targetPlaylist,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
    test('moveAudioToPlaylist moves audio to playlist', () {
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

      // Testing move La résilience insulaire par Fiona Roche with
      // play position at start of audio
      testMoveAudioToPlaylist(
        playlistListVM,
        sourcePlaylist,
        0,
        targetPlaylist,
      );

      // Testing move Le Secret de la RESILIENCE révélé par Boris Cyrulnik
      // with play position at end of audio
      testMoveAudioToPlaylist(
        playlistListVM,
        sourcePlaylist,
        0,
        targetPlaylist,
      );

      // Testing move Ce qui va vraiment sauver notre espèce par Jancovici
      // et Barrau with play position 2 seconds before end of audio
      testMoveAudioToPlaylist(
        playlistListVM,
        sourcePlaylist,
        2,
        targetPlaylist,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
  });
  group('Obtain next playable audio', () {
    late PlaylistListVM playlistListVM;

    test('Next playable audio is not last downloaded', () {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_play_skip_to_next_not_last_unread_audio_test",
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

      // Obtaining the audio from which to obtain the next playable
      // audio
      Playlist sourcePlaylist = playlistListVM.getSelectedPlaylists()[0];
      Audio currentAudio = sourcePlaylist.playableAudioLst[7];

      // Obtaining the next playable audio
      Audio? nextAudio =
          playlistListVM.getSubsequentlyDownloadedNotFullyPlayedAudio(
        currentAudio: currentAudio,
      );

      expect(nextAudio!.validVideoTitle,
          'Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik');

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
    test(
        'Next playable audio when current audio is last downloaded audio which is not fully played',
        () {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_play_skip_to_next_not_last_unread_audio_test",
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
      List<Playlist> selectablePlaylistLst =
          playlistListVM.getUpToDateSelectablePlaylists();

      // Obtaining the audio from which to obtain the next playable
      // audio
      Playlist sourcePlaylist = selectablePlaylistLst[3]; // local
      Audio lastDownloadedAudio = sourcePlaylist.playableAudioLst[0];

      // Obtaining the next playable audio
      Audio? nextAudio =
          playlistListVM.getSubsequentlyDownloadedNotFullyPlayedAudio(
        currentAudio: lastDownloadedAudio,
      );

      // Since the last downloaded audio is not fully played, it
      // is the next playable audio and so there is no next playable
      // audio
      expect(nextAudio, null);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
    test(
        'Next playable audio when current audio is last downloaded audio which is fully played',
        () {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_play_skip_to_next_not_last_unread_audio_test",
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
      List<Playlist> selectablePlaylistLst =
          playlistListVM.getUpToDateSelectablePlaylists();

      // Obtaining the audio from which to obtain the next playable
      // audio
      Playlist sourcePlaylist = selectablePlaylistLst[5]; // local_3
      Audio lastDownloadedAudio = sourcePlaylist.playableAudioLst[0];

      // Obtaining the next playable audio
      Audio? nextAudio =
          playlistListVM.getSubsequentlyDownloadedNotFullyPlayedAudio(
        currentAudio: lastDownloadedAudio,
      );

      // Since the last downloaded audio is fully played, there is no
      // next playable audio
      expect(nextAudio, null);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
    test('Next playable audio is last downloaded audio', () {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_play_skip_to_next_not_last_unread_audio_test",
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
      List<Playlist> selectablePlaylistLst =
          playlistListVM.getUpToDateSelectablePlaylists();

      // Obtaining the audio from which to obtain the next playable
      // audio
      Playlist sourcePlaylist = selectablePlaylistLst[4]; // local_2
      Audio firstDownloadedAudio = sourcePlaylist.playableAudioLst[1];

      // Obtaining the next playable audio
      Audio? nextaudioIslastdownloaded =
          playlistListVM.getSubsequentlyDownloadedNotFullyPlayedAudio(
        currentAudio: firstDownloadedAudio,
      );

      // Since the first downloaded audio is not fully played, it
      // is the next playable audio and so there is no next playableaudio
      expect(nextaudioIslastdownloaded!.validVideoTitle, 'Really short video');

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
  });
  group('Obtain list of playable audios', () {
    late PlaylistListVM playlistListVM;

    test(
        'Playlist has several not fully played audios. Last downloaded audio is not played.',
        () {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_play_skip_to_next_not_last_unread_audio_test",
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
      List<Playlist> selectablePlaylistLst =
          playlistListVM.getUpToDateSelectablePlaylists();

      // Obtaining the audio from which to obtain the next playable
      // audio
      List<Audio> playableAudioLst = playlistListVM
          .getSelectedPlaylistNotFullyPlayedAudiosApplyingSortFilterParameters();

      expect(playableAudioLst.length, 2);
      expect(playableAudioLst[0].validVideoTitle,
          'La résilience insulaire par Fiona Roche');
      expect(playableAudioLst[1].validVideoTitle,
          'Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik');

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
    test(
        'Playlist has several not fully played audios. Last downloaded audio is fully played.',
        () {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_play_skip_to_next_not_last_unread_audio_test",
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

      // Obtaining the audio from which to obtain the next playable
      // audio
      playlistListVM.getUpToDateSelectablePlaylists();
      playlistListVM.setPlaylistSelection(
        playlistIndex: 1,
        isUniquePlaylistSelected: true,
      );

      List<Audio> playableAudioLst = playlistListVM
          .getSelectedPlaylistNotFullyPlayedAudiosApplyingSortFilterParameters();

      expect(playableAudioLst.length, 3);
      expect(playableAudioLst[0].validVideoTitle,
          "Les besoins artificiels par R.Keucheyan");
      expect(playableAudioLst[1].validVideoTitle,
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau");
      expect(playableAudioLst[2].validVideoTitle,
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)");

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
    test('Playlist has no not fully played audios', () {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_play_skip_to_next_not_last_unread_audio_test",
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
      playlistListVM.setPlaylistSelection(
        playlistIndex: 2,
        isUniquePlaylistSelected: true,
      );

      // Obtaining the audio from which to obtain the next playable
      // audio
      List<Audio> playableAudioLst = playlistListVM
          .getSelectedPlaylistNotFullyPlayedAudiosApplyingSortFilterParameters();

      expect(playableAudioLst.length, 0);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
  });
}

void testCopyAudioToPlaylist(
  PlaylistListVM playlistListVM,
  Playlist sourcePlaylist,
  int sourceAudioIndex,
  Playlist targetPlaylist,
) {
  Audio sourceAudio = sourcePlaylist.playableAudioLst[sourceAudioIndex];

  playlistListVM.copyAudioToPlaylist(
    audio: sourceAudio,
    targetPlaylist: targetPlaylist,
  );

  Audio modifiedSourceAudio = sourcePlaylist.playableAudioLst[sourceAudioIndex];
  Audio copiedAudio = targetPlaylist.playableAudioLst[0];

  expect(
      ensureAudioAreEquals(
        modifiedSourceAudio,
        copiedAudio,
      ),
      isTrue);

  expect(modifiedSourceAudio.copiedFromPlaylistTitle == null, isTrue);

  expect(modifiedSourceAudio.copiedToPlaylistTitle == targetPlaylist.title,
      isTrue);

  expect(modifiedSourceAudio.movedFromPlaylistTitle == null, isTrue);

  expect(modifiedSourceAudio.movedToPlaylistTitle == null, isTrue);

  expect(
      copiedAudio.copiedFromPlaylistTitle ==
          sourceAudio.enclosingPlaylist!.title,
      isTrue);

  expect(copiedAudio.copiedToPlaylistTitle == null, isTrue);

  expect(copiedAudio.movedFromPlaylistTitle == null, isTrue);

  expect(copiedAudio.movedToPlaylistTitle == null, isTrue);
}

void testMoveAudioToPlaylist(
  PlaylistListVM playlistListVM,
  Playlist sourcePlaylist,
  int sourceAudioIndex,
  Playlist targetPlaylist,
) {
  Audio sourceAudio = sourcePlaylist.playableAudioLst[sourceAudioIndex];

  playlistListVM.moveAudioToPlaylist(
    audio: sourceAudio,
    targetPlaylist: targetPlaylist,
    keepAudioInSourcePlaylistDownloadedAudioLst: true,
  );

  List<Audio> sourcePlaylistDownloadedAudioLst =
      sourcePlaylist.downloadedAudioLst;

  int modifiedSourceAudioIndex = sourcePlaylistDownloadedAudioLst.indexWhere(
    (audio) => audio == sourceAudio,
  );

  Audio modifiedSourceAudio =
      sourcePlaylistDownloadedAudioLst[modifiedSourceAudioIndex];
  Audio movedAudio = targetPlaylist.playableAudioLst[0];

  expect(
      ensureAudioAreEquals(
        sourceAudio,
        movedAudio,
      ),
      isTrue);

  expect(modifiedSourceAudio.movedFromPlaylistTitle == null, isTrue);

  expect(
      modifiedSourceAudio.movedToPlaylistTitle == targetPlaylist.title, isTrue);

  expect(modifiedSourceAudio.copiedFromPlaylistTitle == null, isTrue);

  expect(modifiedSourceAudio.copiedToPlaylistTitle == null, isTrue);

  expect(
      movedAudio.movedFromPlaylistTitle == sourceAudio.enclosingPlaylist!.title,
      isTrue);

  expect(movedAudio.movedToPlaylistTitle == null, isTrue);

  expect(movedAudio.copiedFromPlaylistTitle == null, isTrue);

  expect(movedAudio.copiedToPlaylistTitle == null, isTrue);
}

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
