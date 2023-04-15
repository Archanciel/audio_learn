import 'dart:convert';
import 'dart:io';

import 'package:audio_learn/utils/dir_util.dart';

import '../viewmodels/theme_provider.dart';

class ThemeService {
  final String _settingsFile = 'settings.json';

  Future<File> _getLocalFile() async {
    String path = DirUtil.getPlaylistDownloadHomePath();

    return File('$path${Platform.pathSeparator}$_settingsFile');
  }

  Future<void> saveTheme(AppTheme theme) async {
    File file = await _getLocalFile();
    Map<String, dynamic> settings = {'theme': theme.toString()};
    await file.writeAsString(jsonEncode(settings));
  }

  Future<AppTheme> loadTheme() async {
    try {
      File file = await _getLocalFile();
      String jsonString = await file.readAsString();
      Map<String, dynamic> settings = jsonDecode(jsonString);
      return AppTheme.values.firstWhere(
          (element) => element.toString() == settings['theme']);
    } catch (e) {
      return AppTheme.light; // Default theme if no settings found
    }
  }
}
