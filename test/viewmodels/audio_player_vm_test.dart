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
  group('AudioPlayerVM changeAudioPlayPosition undo/redo', () {
    test('Test single undo/redo of forward position change', () async {
      AudioPlayerVM audioPlayerVM = await createAudioPlayerVM();

      // obtain the list of playable audios of the selected
      // playlist ordered by download date
      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosOrderedByDownloadDate();

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(selectedPlaylistAudioList[0]);

      // obtain the current audio's initial position
      Duration currentAudioInitialPosition = audioPlayerVM.currentAudioPosition;

      // change the current audio's play position

      int forwardChangePosition = 100;
      audioPlayerVM.changeAudioPlayPosition(
          positiveOrNegativeDuration: Duration(seconds: forwardChangePosition));

      // obtain the current audio's changed position
      Duration currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      expect(
          currentAudioChangedPosition.inSeconds -
              currentAudioInitialPosition.inSeconds,
          forwardChangePosition);

      // undo the change
      audioPlayerVM.undo();

      // obtain the current audio's position after the undo
      Duration currentAudioPositionAfterUndo = audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterUndo.inSeconds,
          currentAudioInitialPosition.inSeconds);

      // redo the change
      audioPlayerVM.redo();

      // obtain the current audio's position after the redo
      Duration currentAudioPositionAfterRedo = audioPlayerVM.currentAudioPosition;

      expect(
          currentAudioPositionAfterRedo.inSeconds -
              currentAudioInitialPosition.inSeconds,
          forwardChangePosition);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
    test('Test single undo/redo of backward position change', () async {
      AudioPlayerVM audioPlayerVM = await createAudioPlayerVM();

      // obtain the list of playable audios of the selected
      // playlist ordered by download date
      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosOrderedByDownloadDate();

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(selectedPlaylistAudioList[0]);

      // obtain the current audio's initial position
      Duration currentAudioInitialPosition = audioPlayerVM.currentAudioPosition;

      // change the current audio's play position

      int backwardChangePosition = -100;
      audioPlayerVM.changeAudioPlayPosition(
          positiveOrNegativeDuration: Duration(seconds: backwardChangePosition));

      // obtain the current audio's changed position
      Duration currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      expect(
          currentAudioChangedPosition.inSeconds -
              currentAudioInitialPosition.inSeconds,
          backwardChangePosition);

      // undo the change
      audioPlayerVM.undo();

      // obtain the current audio's position after the undo
      Duration currentAudioPositionAfterUndo = audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterUndo.inSeconds,
          currentAudioInitialPosition.inSeconds);

      // redo the change
      audioPlayerVM.redo();

      // obtain the current audio's position after the redo
      Duration currentAudioPositionAfterRedo = audioPlayerVM.currentAudioPosition;

      expect(
          currentAudioPositionAfterRedo.inSeconds -
              currentAudioInitialPosition.inSeconds,
          backwardChangePosition);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
  });
  group('AudioPlayerVM goToAudioPlayPosition undo/redo', () {
  });
  group('AudioPlayerVM skipToStart undo/redo', () {
  });
  group('AudioPlayerVM skipToEndNoPlay undo/redo', () {
  });
  group('AudioPlayerVM skipToEndAndPlay undo/redo', () {
  });
}

Future<AudioPlayerVM> createAudioPlayerVM() async {
  final SettingsDataService settingsDataService =
      await initializeTestDataAndLoadSettingsDataService(
    savedTestDataDirName: 'audio_player_vm_play_position_undo_redo_test',
  );
  final WarningMessageVM warningMessageVM = WarningMessageVM();
  final AudioDownloadVM audioDownloadVM = AudioDownloadVM(
    warningMessageVM: warningMessageVM,
    isTest: true,
  );
  final PlaylistListVM playlistListVM = PlaylistListVM(
    warningMessageVM: warningMessageVM,
    audioDownloadVM: audioDownloadVM,
    settingsDataService: settingsDataService,
  );
  
  // calling getUpToDateSelectablePlaylists() loads all the
  // playlist json files from the app dir and so enables
  // playlistListVM to know which playlists are
  // selected and which are not
  playlistListVM.getUpToDateSelectablePlaylists();
  
  AudioPlayerVM audioPlayerVM = AudioPlayerVM(
    playlistListVM: playlistListVM,
  );
  return audioPlayerVM;
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
