import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter_test/flutter_test.dart';

import 'package:audio_learn/constants.dart';
import 'package:audio_learn/models/settings.dart';

void main() {
  group('Settings', () {
    late Settings settings;

    setUp(() {
      settings = Settings();
    });

    test('Test initial, modified, and loaded values', () async {
      // Initial values
      expect(settings.get(settingType: SettingType.theme, settingSubType: SettingType.theme), Theme.dark);
      expect(settings.get(settingType: SettingType.language, settingSubType: SettingType.language), Language.english);
      expect(settings.get(settingType: SettingType.playlists, settingSubType: Playlists.rootPath), kDownloadAppDir);
      expect(settings.get(settingType: SettingType.playlists, settingSubType: Playlists.pathLst), ["/EMPTY", "/BOOKS", "/MUSIC"]);
      expect(settings.get(settingType: SettingType.playlists, settingSubType: Playlists.isMusicQualityByDefault), false);
      expect(settings.get(settingType: SettingType.playlists, settingSubType: Playlists.defaultAudioSort), AudioSortCriterion.audioDownloadDateTime);

      // Modify values
      settings.set(settingType: SettingType.theme, settingSubType: SettingType.theme, value: Theme.clear);
      settings.set(settingType: SettingType.playlists, settingSubType: Playlists.rootPath, value: kDownloadAppTestDirWindows);
      settings.set(settingType: SettingType.playlists, settingSubType: Playlists.pathLst, value: ['\\one', '\\two']);
      settings.set(settingType: SettingType.playlists, settingSubType: Playlists.isMusicQualityByDefault, value: true);
      settings.set(settingType: SettingType.playlists, settingSubType: Playlists.defaultAudioSort, value: AudioSortCriterion.validVideoTitle);

      // Save to file
      // Create a temporary directory to store the serialized Audio object
      final Directory tempDir = await Directory.systemTemp.createTemp('SettingsTest');
      final String testSettingsPath = path.join(tempDir.path, 'settings.json');
      await settings.saveSettingsToFile(testSettingsPath);

      // Load from file
      final Settings loadedSettings = Settings();
      await loadedSettings.loadSettingsFromFile(testSettingsPath);

      // Check loaded values
      expect(loadedSettings.get(settingType: SettingType.theme, settingSubType: SettingType.theme), Theme.clear);
      expect(loadedSettings.get(settingType: SettingType.playlists, settingSubType: Playlists.rootPath), kDownloadAppTestDirWindows);
      expect(loadedSettings.get(settingType: SettingType.playlists, settingSubType: Playlists.pathLst), ['\\one', '\\two']);
      expect(loadedSettings.get(settingType: SettingType.playlists, settingSubType: Playlists.isMusicQualityByDefault), true);
      expect(loadedSettings.get(settingType: SettingType.playlists, settingSubType: Playlists.defaultAudioSort), AudioSortCriterion.validVideoTitle);

      // Cleanup the temporary directory
      await tempDir.delete(recursive: true);
    });
  });
}
