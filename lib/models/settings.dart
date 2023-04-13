// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import '../constants.dart';

enum SettingType {
  theme,
  language,
  playlists,
}

enum Theme {
  clear,
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

class SettingTypeException implements Exception {
  SettingType _settingType;
  StackTrace _stackTrace;

  SettingTypeException({
    required SettingType settingType,
    StackTrace? stackTrace,
  })  : _settingType = settingType,
        _stackTrace = stackTrace ?? StackTrace.current;

  @override
  String toString() {
    return ('$_settingType not defined in enum ${_settingType.toString().split('.').first}.\nStack Trace:\n$_stackTrace');
  }
}

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
    return ('$_settingTypeName not defined in enum ${_settingTypeName.split('.').first}.\nStack Trace:\n$_stackTrace');
  }
}

class Settings {
  final Map<SettingType, Map<dynamic, dynamic>> _settings = {
    SettingType.theme: {SettingType.theme: Theme.dark},
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
            _parseEnumValue(_getAllSubKeys(), subKey),
            _parseJsonValue(subValue, _getEnumValues(settingType)),
          );
        });
        _settings[settingType] = subSettings;
      });
    }
  }

  List<dynamic> _getAllSubKeys() {
    return [
      ...SettingType.values,
      ...Theme.values,
      ...Language.values,
      ...Playlists.values,
      // ...AudioSortCriterion.values,
    ];
  }

  List<dynamic> _getEnumValues(SettingType settingType) {
    switch (settingType) {
      case SettingType.theme:
        return Theme.values;
      case SettingType.language:
        return Language.values;
      case SettingType.playlists:
        return [...Playlists.values, ...AudioSortCriterion.values];
      default:
        throw SettingTypeException(settingType: settingType);
    }
  }

  T _getSettingType<T>(List<T> enumValues, String settingTypeStr) {
    switch (settingTypeStr) {
      case 'SettingType.theme':
        return enumValues[0];
      case 'SettingType.language':
        return enumValues[1];
      case 'SettingType.playlists':
        return enumValues[2];
      default:
        throw SettingTypeNameException(settingTypeName: settingTypeStr);
    }
  }

  T _parseEnumValue<T>(List<T> enumValues, String stringValue) {
    // return enumValues.firstWhere((e) => e.toString() == stringValue, orElse: () => _getSettingType(enumValues, stringValue));
    return enumValues.firstWhere((e) => e.toString() == stringValue);
  }

  dynamic _parseJsonValue(String stringValue, List<dynamic> enumValues) {
    if (stringValue.startsWith('[') && stringValue.endsWith(']')) {
      List<String> stringList =
          stringValue.substring(1, stringValue.length - 1).split(', ');
      return stringList
          .map((element) => _parseJsonValue(element, enumValues))
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
  Settings initialSettings = Settings();

  // print initialSettings created with Settings initial values

  print(
      '${initialSettings.get(settingType: SettingType.theme, settingSubType: SettingType.theme)}');
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
      settingType: SettingType.theme,
      settingSubType: SettingType.theme,
      value: Theme.clear);

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
      '${initialSettings.get(settingType: SettingType.theme, settingSubType: SettingType.theme)}');
  print(
      '${initialSettings.get(settingType: SettingType.playlists, settingSubType: Playlists.rootPath)}');
  print(
      '${initialSettings.get(settingType: SettingType.playlists, settingSubType: Playlists.pathLst)}');
  print(
      '${initialSettings.get(settingType: SettingType.playlists, settingSubType: Playlists.isMusicQualityByDefault)}');
  print(
      '${initialSettings.get(settingType: SettingType.playlists, settingSubType: Playlists.defaultAudioSort)}');

  initialSettings.saveSettingsToFile('settings.json');

  Settings loadedSettings = Settings();
  loadedSettings.loadSettingsFromFile('settings.json');

  print(
      '${loadedSettings.get(settingType: SettingType.theme, settingSubType: SettingType.theme)}');
  print(
      '${loadedSettings.get(settingType: SettingType.playlists, settingSubType: Playlists.rootPath)}');
  print(
      '${loadedSettings.get(settingType: SettingType.playlists, settingSubType: Playlists.pathLst)}');
  print(
      '${loadedSettings.get(settingType: SettingType.playlists, settingSubType: Playlists.isMusicQualityByDefault)}');
  print(
      '${loadedSettings.get(settingType: SettingType.playlists, settingSubType: Playlists.defaultAudioSort)}');
}
