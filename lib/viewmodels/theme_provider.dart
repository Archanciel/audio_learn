import 'dart:io';

import 'package:flutter/material.dart';

import '../constants.dart';
import '../services/settings_data_service.dart';
import '../utils/dir_util.dart';

class ThemeProvider extends ChangeNotifier {
  final SettingsDataService _appSettings;

  late AppTheme _currentTheme;
  AppTheme get currentTheme => _currentTheme;

  ThemeProvider({
    required SettingsDataService appSettings,
  }) : _appSettings = appSettings {
    _currentTheme = appSettings.get(
      settingType: SettingType.appTheme,
      settingSubType: SettingType.appTheme,
    );
  }

  void toggleTheme() {
    if (_currentTheme == AppTheme.light) {
      _currentTheme = AppTheme.dark;
    } else {
      _currentTheme = AppTheme.light;
    }

    _appSettings.set(
        settingType: SettingType.appTheme,
        settingSubType: SettingType.appTheme,
        value: _currentTheme);

    _appSettings.saveSettingsToFile(
      jsonPathFileName:
          '${DirUtil.getPlaylistDownloadHomePath()}${Platform.pathSeparator}$kSettingsFileName',
    );

    notifyListeners();
  }
}
