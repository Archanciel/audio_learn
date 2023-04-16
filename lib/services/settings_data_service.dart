// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import '../constants.dart';

enum SettingType {
  appTheme,
  language,
  playlists,
}

enum AppTheme {
  light,
  dark,
}

enum Language {
  english,
  french,
}

enum Playlists {
  rootPath,
  pathLst,
  isMusicQualityByDefault,
  defaultAudioSort,
}

enum AudioSortCriterion { audioDownloadDateTime, validVideoTitle }

class SettingTypeNameException implements Exception {
  String _settingTypeName;
  StackTrace _stackTrace;

  SettingTypeNameException({
    required String settingTypeName,
    StackTrace? stackTrace,
  })  : _settingTypeName = settingTypeName,
        _stackTrace = stackTrace ?? StackTrace.current;

  @override
  String toString() {
    return ('$_settingTypeName not defined in Settings._allSettingsKeyLst.\nStack Trace:\n$_stackTrace');
  }
}

/// ChatGPT recommanded: Use JSON serialization libraries like
/// json_serializable to simplify the JSON encoding and decoding
/// process. This will also help you avoid writing manual string
/// parsing code.
class SettingsDataService {
  final Map<SettingType, Map<dynamic, dynamic>> _settings = {
    SettingType.appTheme: {SettingType.appTheme: AppTheme.light},
    SettingType.language: {SettingType.language: Language.english},
    SettingType.playlists: {
      Playlists.rootPath: kDownloadAppDir,
      Playlists.pathLst: ["/EMPTY", "/BOOKS", "/MUSIC"],
      Playlists.isMusicQualityByDefault: false,
      Playlists.defaultAudioSort: AudioSortCriterion.audioDownloadDateTime,
    },
  };

  Map<SettingType, Map<dynamic, dynamic>> get settings => _settings;

  dynamic get({
    required SettingType settingType,
    required dynamic settingSubType,
  }) {
    return _settings[settingType]![settingSubType];
  }

  final List<dynamic> _allSettingsKeyLst = [
    ...SettingType.values,
    ...AppTheme.values,
    ...Language.values,
    ...Playlists.values,
    ...AudioSortCriterion.values,
  ];

  void set({
    required SettingType settingType,
    required dynamic settingSubType,
    required dynamic value,
  }) {
    _settings[settingType]![settingSubType] = value;
  }

  // Save settings to a JSON file
  Future<void> saveSettingsToFile(String filePathName) async {
    final File file = File(filePathName);
    final Map<String, dynamic> convertedSettings = _settings.map((key, value) {
      return MapEntry(
        key.toString(),
        value.map((subKey, subValue) =>
            MapEntry(subKey.toString(), subValue.toString())),
      );
    });
    final String jsonString = jsonEncode(convertedSettings);
    await file.writeAsString(jsonString);
  }

  /// Load settings from a JSON file
  Future<void> loadSettingsFromFile(String filePathName) async {
    final File file = File(filePathName);
    if (await file.exists()) {
      // if settings json file not exist, then the default Settings values
      // set in the Settings constructor are used ...
      final String jsonString = await file.readAsString();
      final Map<String, dynamic> decodedSettings = jsonDecode(jsonString);
      decodedSettings.forEach((key, value) {
        final settingType = _parseEnumValue(SettingType.values, key);
        final subSettings =
            (value as Map<String, dynamic>).map((subKey, subValue) {
          return MapEntry(
            _parseEnumValue(_allSettingsKeyLst, subKey),
            _parseJsonValue(_allSettingsKeyLst, subValue),
          );
        });
        _settings[settingType] = subSettings;
      });
    }
  }

  T _parseEnumValue<T>(List<T> enumValues, String stringValue) {
    T setting = enumValues[0];

    try {
      setting = enumValues.firstWhere((e) => e.toString() == stringValue);
    } catch (e) {
      throw SettingTypeNameException(settingTypeName: stringValue);
    }

    return setting;
  }

  dynamic _parseJsonValue(List<dynamic> enumValues, String stringValue) {
    if (stringValue.startsWith('[') && stringValue.endsWith(']')) {
      List<String> stringList =
          stringValue.substring(1, stringValue.length - 1).split(', ');
      return stringList
          .map((element) => _parseJsonValue(enumValues, element))
          .toList();
    } else if (stringValue == 'true') {
      return true;
    } else if (stringValue == 'false') {
      return false;
    } else if (_isFilePath(stringValue)) {
      return stringValue;
    } else {
      return _parseEnumValue(enumValues, stringValue);
    }
  }

  bool _isFilePath(String value) {
    // A simple check to determine if the value is a file path.
    // You can adjust the condition as needed.
    return value.contains('\\') || value.contains('/');
  }
}

Future<void> main(List<String> args) async {
  SettingsDataService initialSettings = SettingsDataService();

  // print initialSettings created with Settings initial values

  print(
      '${initialSettings.get(settingType: SettingType.appTheme, settingSubType: SettingType.appTheme)}');
  print(
      '${initialSettings.get(settingType: SettingType.playlists, settingSubType: Playlists.rootPath)}');
  print(
      '${initialSettings.get(settingType: SettingType.playlists, settingSubType: Playlists.pathLst)}');
  print(
      '${initialSettings.get(settingType: SettingType.playlists, settingSubType: Playlists.isMusicQualityByDefault)}');
  print(
      '${initialSettings.get(settingType: SettingType.playlists, settingSubType: Playlists.defaultAudioSort)}');

  // modify initialSettings values

  initialSettings.set(
      settingType: SettingType.appTheme,
      settingSubType: SettingType.appTheme,
      value: AppTheme.light);

  initialSettings.set(
      settingType: SettingType.playlists,
      settingSubType: Playlists.rootPath,
      value: kDownloadAppTestDirWindows);

  initialSettings.set(
      settingType: SettingType.playlists,
      settingSubType: Playlists.pathLst,
      value: ['\\one', '\\two']);

  initialSettings.set(
      settingType: SettingType.playlists,
      settingSubType: Playlists.isMusicQualityByDefault,
      value: true);

  initialSettings.set(
      settingType: SettingType.playlists,
      settingSubType: Playlists.defaultAudioSort,
      value: AudioSortCriterion.validVideoTitle);

  // print initialSettings after modifying its values

  print(
      '${initialSettings.get(settingType: SettingType.appTheme, settingSubType: SettingType.appTheme)}');
  print(
      '${initialSettings.get(settingType: SettingType.playlists, settingSubType: Playlists.rootPath)}');
  print(
      '${initialSettings.get(settingType: SettingType.playlists, settingSubType: Playlists.pathLst)}');
  print(
      '${initialSettings.get(settingType: SettingType.playlists, settingSubType: Playlists.isMusicQualityByDefault)}');
  print(
      '${initialSettings.get(settingType: SettingType.playlists, settingSubType: Playlists.defaultAudioSort)}');

  await initialSettings.saveSettingsToFile('settings.json');

  SettingsDataService loadedSettings = SettingsDataService();
  await loadedSettings.loadSettingsFromFile('settings.json');

  print(
      '${loadedSettings.get(settingType: SettingType.appTheme, settingSubType: SettingType.appTheme)}');
  print(
      '${loadedSettings.get(settingType: SettingType.playlists, settingSubType: Playlists.rootPath)}');
  print(
      '${loadedSettings.get(settingType: SettingType.playlists, settingSubType: Playlists.pathLst)}');
  print(
      '${loadedSettings.get(settingType: SettingType.playlists, settingSubType: Playlists.isMusicQualityByDefault)}');
  print(
      '${loadedSettings.get(settingType: SettingType.playlists, settingSubType: Playlists.defaultAudioSort)}');
}
