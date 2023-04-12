// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import '../constants.dart';

enum SettingType {
  theme,
  language,
  audio,
  audioTwo,
}

enum Theme {
  clear,
  dark,
}

enum Language {
  english,
  french,
}

enum Audio {
  rootPath,
  pathLst,
  defaultQuality,
}

enum AudioTwo {
  rootPath,
  pathLst,
  defaultQuality,
}

class Settings {
  final Map<SettingType, Map<dynamic, dynamic>> _settings = {
    SettingType.theme: {SettingType.theme: Theme.dark},
    SettingType.language: {SettingType.language: Language.english},
    SettingType.audio: {
      Audio.rootPath: kDownloadAppDir,
      Audio.pathLst: ["empty", "books", "music"]
    },
    SettingType.audioTwo: {
      AudioTwo.rootPath: kDownloadAppDir,
      AudioTwo.pathLst: ["EMPTY", "BOOKS", "MUSIC"]
    },
  };

  Map<SettingType, Map<dynamic, dynamic>> get settings => _settings;

  dynamic get({
    required SettingType settingType,
    required dynamic settingSubType,
  }) {
    return _settings[settingType]![settingSubType];
  }

  void set({
    required SettingType settingType,
    required dynamic settingSubType,
    required dynamic value,
  }) {
    _settings[settingType]![settingSubType] = value;
  }

// Save settings to a JSON file
  Future<void> saveSettingsToFile(String filePath) async {
    final File file = File(filePath);
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

// Load settings from a JSON file
  Future<void> loadSettingsFromFile(String filePath) async {
    final File file = File(filePath);
    if (await file.exists()) {
      final String jsonString = await file.readAsString();
      final Map<String, dynamic> decodedSettings = jsonDecode(jsonString);
      decodedSettings.forEach((key, value) {
        final settingType = _parseEnumValue(SettingType.values, key);
        final subSettings =
            (value as Map<String, dynamic>).map((subKey, subValue) {
          return MapEntry(
            _parseEnumValue(_getEnumValues(settingType), subKey),
            _parseEnumValue(_getEnumValues(settingType), subValue),
          );
        });
        _settings[settingType] = subSettings;
      });
    }
  }

  List<dynamic> _getEnumValues(SettingType settingType) {
    switch (settingType) {
      case SettingType.theme:
        return Theme.values;
      case SettingType.language:
        return Language.values;
      case SettingType.audio:
        return Audio.values;
      case SettingType.audioTwo:
      default:
        return AudioTwo.values;
    }
  }

  T _parseEnumValue<T>(List<T> enumValues, String stringValue) {
    return enumValues.firstWhere((e) => e.toString() == stringValue);
  }
}

Future<void> main(List<String> args) async {
  Settings initialSettings = Settings();

  print(
      '${initialSettings.get(settingType: SettingType.theme, settingSubType: SettingType.theme)}');
  print(
      '${initialSettings.get(settingType: SettingType.audio, settingSubType: Audio.rootPath)}');
  print(
      '${initialSettings.get(settingType: SettingType.audio, settingSubType: Audio.pathLst)}');
  print(
      '${initialSettings.get(settingType: SettingType.audioTwo, settingSubType: AudioTwo.pathLst)}');

  initialSettings.set(
      settingType: SettingType.theme,
      settingSubType: SettingType.theme,
      value: Theme.clear);

  initialSettings.set(
      settingType: SettingType.audio,
      settingSubType: Audio.rootPath,
      value: kDownloadAppTestDirWindows);

  initialSettings.set(
      settingType: SettingType.audio,
      settingSubType: Audio.pathLst,
      value: ['one', 'two']);

  initialSettings.set(
      settingType: SettingType.audioTwo,
      settingSubType: AudioTwo.pathLst,
      value: ['ONE', 'TWO']);

  print(
      '${initialSettings.get(settingType: SettingType.theme, settingSubType: SettingType.theme)}');
  print(
      '${initialSettings.get(settingType: SettingType.audio, settingSubType: Audio.rootPath)}');
  print(
      '${initialSettings.get(settingType: SettingType.audio, settingSubType: Audio.pathLst)}');
  print(
      '${initialSettings.get(settingType: SettingType.audioTwo, settingSubType: AudioTwo.pathLst)}');

  initialSettings.saveSettingsToFile('settings.json');

  Settings loadedSettings = Settings();
  loadedSettings.loadSettingsFromFile('settings.json');

  print(
      '${loadedSettings.get(settingType: SettingType.theme, settingSubType: SettingType.theme)}');
  print(
      '${loadedSettings.get(settingType: SettingType.audio, settingSubType: Audio.rootPath)}');
  print(
      '${loadedSettings.get(settingType: SettingType.audio, settingSubType: Audio.pathLst)}');
  print(
      '${loadedSettings.get(settingType: SettingType.audioTwo, settingSubType: AudioTwo.pathLst)}');
}
