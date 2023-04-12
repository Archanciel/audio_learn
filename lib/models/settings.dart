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
}
