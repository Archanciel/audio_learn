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
  final Map<SettingType, Map<dynamic, dynamic>> _settings = {
    SettingType.theme: {SettingType.theme: Theme.dark},
    SettingType.language: {SettingType.language: Language.english},
    SettingType.audio: {
      Audio.rootPath: kDownloadAppDir,
      Audio.pathLst: ["", "books", "music"]
    },
  };

  Map<SettingType, Map<dynamic, dynamic>> get settings => _settings;

  dynamic get({
    required SettingType settingType,
    required dynamic settingSubType,
  }) {
    return _settings[settingType]![settingSubType];
  }
}

void main(List<String> args) {
  Settings settings = Settings();

  print('${settings.get(settingType: SettingType.theme, settingSubType: SettingType.theme)}');
  print('${settings.get(settingType: SettingType.audio, settingSubType: Audio.rootPath)}');
  print('${settings.get(settingType: SettingType.audio, settingSubType: Audio.pathLst)}');
}
