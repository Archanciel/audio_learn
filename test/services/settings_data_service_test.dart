import 'dart:io';
import 'package:audio_learn/services/sort_filter_parameters.dart';
import 'package:audio_learn/utils/dir_util.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_test/flutter_test.dart';

import 'package:audio_learn/constants.dart';
import 'package:audio_learn/services/settings_data_service.dart';

enum UnsupportedSettingsEnum { unsupported }

void main() {
  const String testSettingsDir =
      '$kDownloadAppTestDirWindows\\audio_learn_test_settings';

  group('Settings', () {
    late SettingsDataService settings;

    setUp(() {
      settings = SettingsDataService(isTest: true);
      settings.addOrReplaceAudioSortFilterSettings(
        audioSortFilterParametersName: 'Default',
        audioSortFilterParameters:
            AudioSortFilterParameters.createDefaultAudioSortFilterParameters(),
      );
    });

    test('Test initial, modified, saved and loaded values', () async {
      final Directory directory = Directory(testSettingsDir);

      if (directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }

      // Initial values
      expect(
          settings.get(
              settingType: SettingType.appTheme,
              settingSubType: SettingType.appTheme),
          AppTheme.dark);
      expect(
          settings.get(
              settingType: SettingType.language,
              settingSubType: SettingType.language),
          Language.english);
      expect(
          settings.get(
              settingType: SettingType.playlists,
              settingSubType: Playlists.rootPath),
          kDownloadAppDir);
      expect(
          settings.get(
              settingType: SettingType.playlists,
              settingSubType: Playlists.pathLst),
          ["/EMPTY", "/BOOKS", "/MUSIC"]);
      expect(
          settings.get(
              settingType: SettingType.playlists,
              settingSubType: Playlists.isMusicQualityByDefault),
          false);
      expect(
          settings.get(
              settingType: SettingType.playlists,
              settingSubType: Playlists.defaultAudioSort),
          AudioSortCriterion.audioDownloadDateTime);

      AudioSortFilterParameters defaultAudioSortFilterParameters =
          settings.audioSortFilterParametersMap['Default']!;

      expect(
          defaultAudioSortFilterParameters ==
              AudioSortFilterParameters
                  .createDefaultAudioSortFilterParameters(),
          true);

      // Modify values
      settings.set(
          settingType: SettingType.appTheme,
          settingSubType: SettingType.appTheme,
          value: AppTheme.light);
      settings.set(
          settingType: SettingType.playlists,
          settingSubType: Playlists.rootPath,
          value: kDownloadAppTestDirWindows);
      settings.set(
          settingType: SettingType.playlists,
          settingSubType: Playlists.pathLst,
          value: ['\\one', '\\two']);
      settings.set(
          settingType: SettingType.playlists,
          settingSubType: Playlists.isMusicQualityByDefault,
          value: true);
      settings.set(
          settingType: SettingType.playlists,
          settingSubType: Playlists.defaultAudioSort,
          value: AudioSortCriterion.validVideoTitle);

      // Save to file
      await DirUtil.createDirIfNotExist(pathStr: testSettingsDir);

      final String testSettingsPathFileName =
          path.join(testSettingsDir, 'settings.json');
      settings.saveSettingsToFile(
        jsonPathFileName: testSettingsPathFileName,
      );

      // Load from file
      final SettingsDataService loadedSettings = SettingsDataService();
      loadedSettings.loadSettingsFromFile(
        jsonPathFileName: testSettingsPathFileName,
      );

      // Check loaded values
      expect(
          loadedSettings.get(
              settingType: SettingType.appTheme,
              settingSubType: SettingType.appTheme),
          AppTheme.light);
      expect(
          loadedSettings.get(
              settingType: SettingType.playlists,
              settingSubType: Playlists.rootPath),
          kDownloadAppTestDirWindows);
      expect(
          loadedSettings.get(
              settingType: SettingType.playlists,
              settingSubType: Playlists.pathLst),
          ['\\one', '\\two']);
      expect(
          loadedSettings.get(
              settingType: SettingType.playlists,
              settingSubType: Playlists.isMusicQualityByDefault),
          true);
      expect(
          loadedSettings.get(
              settingType: SettingType.playlists,
              settingSubType: Playlists.defaultAudioSort),
          AudioSortCriterion.validVideoTitle);

      AudioSortFilterParameters loadedDefaultAudioSortFilterParameters =
          loadedSettings.audioSortFilterParametersMap['Default']!;
      expect(
          loadedDefaultAudioSortFilterParameters ==
              AudioSortFilterParameters
                  .createDefaultAudioSortFilterParameters(),
          true);

      // Cleanup the test data directory
      if (directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }
    });
  });
}
