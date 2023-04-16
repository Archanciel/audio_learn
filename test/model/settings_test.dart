import 'dart:io';
import 'package:audio_learn/utils/dir_util.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_test/flutter_test.dart';

import 'package:audio_learn/constants.dart';
import 'package:audio_learn/models/settings.dart';

enum UnsupportedSettingsEnum { unsupported }

void main() {
  const String testSettingsDir =
      '$kDownloadAppTestDir\\audio_learn_test_settings';

  group('Settings', () {
    late Settings settings;

    setUp(() {
      settings = Settings();
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
          AppTheme.light);
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
      await settings.saveSettingsToFile(testSettingsPathFileName);

      // Load from file
      final Settings loadedSettings = Settings();
      await loadedSettings.loadSettingsFromFile(testSettingsPathFileName);

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

      // Cleanup the test data directory
      if (directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }
    });
    test(
        'throws exception when loading Settings json file containing invalid enum',
        () async {
      final Directory directory = Directory(testSettingsDir);

      if (directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }

      settings.set(
          settingType: SettingType.playlists,
          settingSubType: Playlists.defaultAudioSort,
          value: UnsupportedSettingsEnum.unsupported);

      // Save to file
      await DirUtil.createDirIfNotExist(pathStr: testSettingsDir);

      final String testSettingsPathFileName =
          path.join(testSettingsDir, 'settings.json');
      await settings.saveSettingsToFile(testSettingsPathFileName);

      // Load from file
      final Settings loadedSettings = Settings();

      // without await, deleting the test data dir causes
      // loadSettingsFromFile to throw another exception
      // since the json file is not found
      await expectLater(
          loadedSettings.loadSettingsFromFile(testSettingsPathFileName),
          throwsA(isA<SettingTypeNameException>()));

      // Cleanup the test data directory
      if (directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }
    });
  });
}
