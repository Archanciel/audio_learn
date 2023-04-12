// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import '../constants.dart';

enum SettingType {
  theme,
  language,
  audio,
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

class Settings {
  final Map<SettingType, dynamic> _settings = {
    SettingType.theme: Theme.dark,
    SettingType.language: Language.english,
    SettingType.audio: {
      Audio.rootPath: kDownloadAppDir,
      Audio.pathLst: ["", "books", "music"],
    },
  };

  Map<SettingType, dynamic> get settings => _settings;

  T get<T>(SettingType settingType, [dynamic subKey]) {
    if (subKey != null) {
      return _settings[settingType][subKey] as T;
    } else {
      return _settings[settingType] as T;
    }
  }

  void set<T>(SettingType settingType, T value, [dynamic subKey]) {
    if (subKey != null) {
      _settings[settingType][subKey] = value;
    } else {
      _settings[settingType] = value;
    }
  }

  Future<void> saveSettingsToFile(String filePath) async {
    final File file = File(filePath);
    final Map<String, dynamic> convertedSettings = _settings.map((key, value) {
      return MapEntry(
          key.index.toString(), value is Map ? _convertSubMap(value) : value);
    });
    final String jsonString = jsonEncode(convertedSettings);
    await file.writeAsString(jsonString);
  }

  Map<String, dynamic> _convertSubMap(Map<dynamic, dynamic> subMap) {
    return subMap.map((key, value) {
      return MapEntry(key.index.toString(), value);
    });
  }

  Future<void> loadSettingsFromFile(String filePath) async {
    final File file = File(filePath);
    if (await file.exists()) {
      final String jsonString = await file.readAsString();
      final Map<String, dynamic> decodedSettings = jsonDecode(jsonString);
      decodedSettings.forEach((key, value) {
        final settingType = SettingType.values[int.parse(key)];
        if (value is Map) {
          _settings[settingType] = _decodeSubMap(value);
        } else {
          _settings[settingType] = value;
        }
      });
    }
  }

  Map<dynamic, dynamic> _decodeSubMap(Map<dynamic, dynamic> subMap) {
    return subMap.map((key, value) {
      return MapEntry(Audio.values[int.parse(key as String)], value);
    });
  }
}

void main(List<String> args) async {
  Settings settings = Settings();

  // Get settings
  print('${settings.get<Theme>(SettingType.theme)}');
  print('${settings.get<Language>(SettingType.language)}');
  print('${settings.get<String>(SettingType.audio, Audio.rootPath)}');
  print('${settings.get<List<String>>(SettingType.audio, Audio.pathLst)}');

  // Set new values
  settings.set(SettingType.theme, Theme.clear);
  settings.set(SettingType.language, Language.french);
  settings.set<String>(SettingType.audio, 'new_root_path', Audio.rootPath);
  settings.set<List<String>>(
      SettingType.audio,
      [
        'default',
        'conferences',
        'interviews',
        'books',
        'music',
      ],
      Audio.pathLst);

  // Save settings to a JSON file
  await settings.saveSettingsToFile('settings.json');

  // Load settings from a JSON file
  await settings.loadSettingsFromFile('settings.json');

  print('${settings.get<Theme>(SettingType.theme)}');
  print('${settings.get<Language>(SettingType.language)}');
  print('${settings.get<String>(SettingType.audio, Audio.rootPath)}');
  print('${settings.get<List<String>>(SettingType.audio, Audio.pathLst)}');
}
