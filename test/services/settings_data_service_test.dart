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
    test('Test initial, modified, saved and loaded values', () async {
      final Directory directory = Directory(testSettingsDir);

      if (directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }

      SettingsDataService settings = SettingsDataService(isTest: true);

      // load settings from file which does not exist. This
      // will ensure that the default playlist root path is set
      settings.loadSettingsFromFile(jsonPathFileName: 'test/settings.json');

      settings.addOrReplaceNamedAudioSortFilterSettings(
        audioSortFilterParametersName: 'Default',
        audioSortFilterParameters:
            AudioSortFilterParameters.createDefaultAudioSortFilterParameters(),
      );
      AudioSortFilterParameters historicalAudioSortFilterParameters =
          AudioSortFilterParameters.createDefaultAudioSortFilterParameters();
      historicalAudioSortFilterParameters.filterSentenceLst.add("Jancovici");
      historicalAudioSortFilterParameters.selectedSortItemLst.add(SortingItem(
        sortingOption: SortingOption.audioDuration,
        isAscending: true,
      ));

      settings.addAudioSortFilterSettingsToSearchHistory(
        audioSortFilterParameters: historicalAudioSortFilterParameters,
      );

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
          kDownloadAppDirWindows);
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
              settingSubType: Playlists.playSpeed),
          kAudioDefaultPlaySpeed);
      expect(
          settings.get(
              settingType: SettingType.playlists,
              settingSubType: Playlists.defaultAudioSort),
          AudioSortCriterion.audioDownloadDateTime);

      AudioSortFilterParameters defaultAudioSortFilterParameters =
          settings.namedAudioSortFilterParametersMap['Default']!;

      expect(
          defaultAudioSortFilterParameters ==
              AudioSortFilterParameters
                  .createDefaultAudioSortFilterParameters(),
          true);

      AudioSortFilterParameters firstHistoricalAudioSortFilterParameters =
          settings.searchHistoryAudioSortFilterParametersLst[0];

      expect(
          firstHistoricalAudioSortFilterParameters.filterSentenceLst
                  .contains("Jancovici") &&
              firstHistoricalAudioSortFilterParameters.selectedSortItemLst
                  .contains(SortingItem(
                sortingOption: SortingOption.audioDuration,
                isAscending: true,
              )),
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
          settingSubType: Playlists.playSpeed,
          value: 1.1);
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
              settingSubType: Playlists.playSpeed),
          1.1);
      expect(
          loadedSettings.get(
              settingType: SettingType.playlists,
              settingSubType: Playlists.defaultAudioSort),
          AudioSortCriterion.validVideoTitle);

      AudioSortFilterParameters loadedDefaultAudioSortFilterParameters =
          loadedSettings.namedAudioSortFilterParametersMap['Default']!;
      expect(
          loadedDefaultAudioSortFilterParameters ==
              AudioSortFilterParameters
                  .createDefaultAudioSortFilterParameters(),
          true);

      AudioSortFilterParameters loadedFirstHistoricalAudioSortFilterParameters =
          loadedSettings.searchHistoryAudioSortFilterParametersLst[0];

      expect(loadedFirstHistoricalAudioSortFilterParameters,
          firstHistoricalAudioSortFilterParameters);

      expect(
          loadedFirstHistoricalAudioSortFilterParameters.filterSentenceLst
                  .contains("Jancovici") &&
              loadedFirstHistoricalAudioSortFilterParameters.selectedSortItemLst
                  .contains(SortingItem(
                sortingOption: SortingOption.audioDuration,
                isAscending: true,
              )),
          true);

      // Cleanup the test data directory
      if (directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }
    });
    test(
        'Test initial, modified, saved and loaded values with 2 AudioSortFilterParameters in collections',
        () async {
      final Directory directory = Directory(testSettingsDir);

      if (directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }

      SettingsDataService settings = SettingsDataService(isTest: true);

      // load settings from file which does not exist. This
      // will ensure that the default playlist root path is set
      settings.loadSettingsFromFile(jsonPathFileName: 'test/settings.json');

      settings.addOrReplaceNamedAudioSortFilterSettings(
        audioSortFilterParametersName: 'Default',
        audioSortFilterParameters:
            AudioSortFilterParameters.createDefaultAudioSortFilterParameters(),
      );
      AudioSortFilterParameters audioSortFilterParametersJancovici =
          AudioSortFilterParameters.createDefaultAudioSortFilterParameters();
      audioSortFilterParametersJancovici.filterSentenceLst.add("Jancovici");
      settings.addOrReplaceNamedAudioSortFilterSettings(
        audioSortFilterParametersName: 'Jancovici',
        audioSortFilterParameters: audioSortFilterParametersJancovici,
      );
      AudioSortFilterParameters historicalAudioSortFilterParameters =
          AudioSortFilterParameters.createDefaultAudioSortFilterParameters();
      historicalAudioSortFilterParameters.filterSentenceLst.add("Euthanasie");
      historicalAudioSortFilterParameters.selectedSortItemLst.add(SortingItem(
        sortingOption: SortingOption.audioDuration,
        isAscending: true,
      ));

      settings.addAudioSortFilterSettingsToSearchHistory(
        audioSortFilterParameters: historicalAudioSortFilterParameters,
      );
      settings.addAudioSortFilterSettingsToSearchHistory(
        audioSortFilterParameters: audioSortFilterParametersJancovici,
      );

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

      AudioSortFilterParameters loadedDefaultAudioSortFilterParameters =
          loadedSettings.namedAudioSortFilterParametersMap['Default']!;
      expect(
          loadedDefaultAudioSortFilterParameters ==
              AudioSortFilterParameters
                  .createDefaultAudioSortFilterParameters(),
          true);

      AudioSortFilterParameters loadedJancoAudioSortFilterParameters =
          loadedSettings.namedAudioSortFilterParametersMap['Jancovici']!;
      expect(loadedJancoAudioSortFilterParameters,
          audioSortFilterParametersJancovici);

      AudioSortFilterParameters loadedFirstHistoricalAudioSortFilterParameters =
          loadedSettings.searchHistoryAudioSortFilterParametersLst[0];

      expect(
          loadedFirstHistoricalAudioSortFilterParameters ==
              historicalAudioSortFilterParameters,
          true);

      expect(
          loadedFirstHistoricalAudioSortFilterParameters.filterSentenceLst
                  .contains("Euthanasie") &&
              loadedFirstHistoricalAudioSortFilterParameters.selectedSortItemLst
                  .contains(SortingItem(
                sortingOption: SortingOption.audioDuration,
                isAscending: true,
              )),
          true);

      AudioSortFilterParameters
          loadedSecondHistoricalAudioSortFilterParameters =
          loadedSettings.searchHistoryAudioSortFilterParametersLst[1];

      expect(loadedSecondHistoricalAudioSortFilterParameters,
          audioSortFilterParametersJancovici);

      expect(
          loadedSecondHistoricalAudioSortFilterParameters.filterSentenceLst
                  .contains("Jancovici") &&
              loadedSecondHistoricalAudioSortFilterParameters
                  .selectedSortItemLst
                  .contains(SortingItem(
                sortingOption: SortingOption.audioDownloadDate,
                isAscending: false,
              )),
          true);

      // Cleanup the test data directory
      if (directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }
    });
    test(
        'Test initial, modified, saved and loaded values with 3 AudioSortFilterParameters in collections',
        () async {
      final Directory directory = Directory(testSettingsDir);

      if (directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }

      SettingsDataService settings = SettingsDataService(isTest: true);

      // load settings from file which does not exist. This
      // will ensure that the default playlist root path is set
      settings.loadSettingsFromFile(jsonPathFileName: 'test/settings.json');

      settings.addOrReplaceNamedAudioSortFilterSettings(
        audioSortFilterParametersName: 'Default',
        audioSortFilterParameters:
            AudioSortFilterParameters.createDefaultAudioSortFilterParameters(),
      );
      AudioSortFilterParameters audioSortFilterParametersJancovici =
          AudioSortFilterParameters.createDefaultAudioSortFilterParameters();
      audioSortFilterParametersJancovici.filterSentenceLst.add("Jancovici");
      settings.addOrReplaceNamedAudioSortFilterSettings(
        audioSortFilterParametersName: 'Jancovici',
        audioSortFilterParameters: audioSortFilterParametersJancovici,
      );
      AudioSortFilterParameters audioSortFilterParametersBarrau =
          AudioSortFilterParameters.createDefaultAudioSortFilterParameters();
      audioSortFilterParametersBarrau.filterSentenceLst.add("Barrau");
      settings.addOrReplaceNamedAudioSortFilterSettings(
        audioSortFilterParametersName: 'Barrau',
        audioSortFilterParameters: audioSortFilterParametersBarrau,
      );
      AudioSortFilterParameters historicalAudioSortFilterParameters =
          AudioSortFilterParameters.createDefaultAudioSortFilterParameters();
      historicalAudioSortFilterParameters.filterSentenceLst.add("Euthanasie");
      historicalAudioSortFilterParameters.selectedSortItemLst.add(SortingItem(
        sortingOption: SortingOption.audioDuration,
        isAscending: true,
      ));

      settings.addAudioSortFilterSettingsToSearchHistory(
        audioSortFilterParameters: historicalAudioSortFilterParameters,
      );
      settings.addAudioSortFilterSettingsToSearchHistory(
        audioSortFilterParameters: audioSortFilterParametersJancovici,
      );
      settings.addAudioSortFilterSettingsToSearchHistory(
        audioSortFilterParameters: audioSortFilterParametersBarrau,
      );

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

      AudioSortFilterParameters loadedDefaultAudioSortFilterParameters =
          loadedSettings.namedAudioSortFilterParametersMap['Default']!;
      expect(
          loadedDefaultAudioSortFilterParameters ==
              AudioSortFilterParameters
                  .createDefaultAudioSortFilterParameters(),
          true);

      AudioSortFilterParameters loadedJancoAudioSortFilterParameters =
          loadedSettings.namedAudioSortFilterParametersMap['Jancovici']!;
      expect(loadedJancoAudioSortFilterParameters,
          audioSortFilterParametersJancovici);

      loadedJancoAudioSortFilterParameters =
          loadedSettings.namedAudioSortFilterParametersMap['Barrau']!;
      expect(loadedJancoAudioSortFilterParameters,
          audioSortFilterParametersBarrau);

      AudioSortFilterParameters loadedFirstHistoricalAudioSortFilterParameters =
          loadedSettings.searchHistoryAudioSortFilterParametersLst[0];

      expect(
          loadedFirstHistoricalAudioSortFilterParameters ==
              historicalAudioSortFilterParameters,
          true);

      expect(
          loadedFirstHistoricalAudioSortFilterParameters.filterSentenceLst
                  .contains("Euthanasie") &&
              loadedFirstHistoricalAudioSortFilterParameters.selectedSortItemLst
                  .contains(SortingItem(
                sortingOption: SortingOption.audioDuration,
                isAscending: true,
              )),
          true);

      AudioSortFilterParameters
          loadedSecondHistoricalAudioSortFilterParameters =
          loadedSettings.searchHistoryAudioSortFilterParametersLst[1];

      expect(loadedSecondHistoricalAudioSortFilterParameters,
          audioSortFilterParametersJancovici);

      expect(
          loadedSecondHistoricalAudioSortFilterParameters.filterSentenceLst
                  .contains("Jancovici") &&
              loadedSecondHistoricalAudioSortFilterParameters
                  .selectedSortItemLst
                  .contains(SortingItem(
                sortingOption: SortingOption.audioDownloadDate,
                isAscending: false,
              )),
          true);

      AudioSortFilterParameters loadedThirdHistoricalAudioSortFilterParameters =
          loadedSettings.searchHistoryAudioSortFilterParametersLst[2];

      expect(loadedThirdHistoricalAudioSortFilterParameters,
          audioSortFilterParametersBarrau);

      expect(
          loadedThirdHistoricalAudioSortFilterParameters.filterSentenceLst
                  .contains("Barrau") &&
              loadedThirdHistoricalAudioSortFilterParameters.selectedSortItemLst
                  .contains(SortingItem(
                sortingOption: SortingOption.audioDownloadDate,
                isAscending: false,
              )),
          true);

      // Cleanup the test data directory
      if (directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }
    });
    test(
        'Test initial, modified, saved and loaded values with empty AudioSortFilterParameters collections',
        () async {
      final Directory directory = Directory(testSettingsDir);

      if (directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }

      SettingsDataService settings = SettingsDataService(isTest: true);

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

      AudioSortFilterParameters? loadedDefaultAudioSortFilterParameters =
          loadedSettings.namedAudioSortFilterParametersMap['Default'];

      expect(loadedDefaultAudioSortFilterParameters, null);

      expect(loadedSettings.searchHistoryAudioSortFilterParametersLst.isEmpty,
          true);

      // Cleanup the test data directory
      if (directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }
    });
  });
}
