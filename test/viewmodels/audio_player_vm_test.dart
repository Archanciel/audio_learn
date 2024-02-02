import 'dart:io';

import 'package:audio_learn/constants.dart';
import 'package:audio_learn/models/audio.dart';
import 'package:audio_learn/services/settings_data_service.dart';
import 'package:audio_learn/utils/dir_util.dart';
import 'package:audio_learn/viewmodels/audio_player_vm.dart';
import 'package:audio_learn/viewmodels/playlist_list_vm.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:audio_learn/viewmodels/audio_download_vm.dart';
import 'package:audio_learn/viewmodels/warning_message_vm.dart';

void main() {
  setUp(() {
    // This is necessary to avoid the following error:
    // FlutterError (Binding has not yet been initialized.
    // The "instance" getter on the ServicesBinding binding
    // mixin is only available once that binding has been
    // initialized. Typically, this is done by calling
    // "WidgetsFlutterBinding.ensureInitialized()"
    //
    // See https://stackoverflow.com/questions/57743173/flutter-unhandled-exception-servicesbinding-defaultbinarymessenger-was-accesse
    TestWidgetsFlutterBinding.ensureInitialized();
  });
  group('AudioPlayerVM << >> undo/redo', () {
    test('Test single undo/redo', () async {
      final SettingsDataService settingsDataService =
          await initializeTestDataAndLoadSettingsDataService(
        savedTestDataDirName: 'audio_player_vm_play_position_undo_redo_test',
      );
      WarningMessageVM warningMessageVM = WarningMessageVM();
      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        isTest: true,
      );
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

      // the globalAudioPlayerVM ScreenMixin variable is created
      // here since it needs expandablePlaylistListVM which is
      // created above
      AudioPlayerVM audioPlayerVM = AudioPlayerVM(
        playlistListVM: expandablePlaylistListVM,
      );

      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosOrderedByDownloadDate();

      await audioPlayerVM.setCurrentAudio(selectedPlaylistAudioList[0]);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
  });
}

Future<SettingsDataService> initializeTestDataAndLoadSettingsDataService({
  String? savedTestDataDirName,
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
          "$kDownloadAppTestSavedDataDir${Platform.pathSeparator}$savedTestDataDirName",
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
          "$kDownloadAppTestDirWindows${Platform.pathSeparator}$kSettingsFileName");

  return settingsDataService;
}
