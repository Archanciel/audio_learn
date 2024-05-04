import 'dart:convert';

void main() {
  // Simulated content of an ARB file as a JSON string
  var arbContent = '''
  {
    "defaultApplicationHelpTitle": "Default Application",
    "defaultApplicationHelpContent": "If no option is selected, the defined playback speed will only apply to newly created playlists.",
    "modifyingExistingPlaylistsHelpTitle": "Modifying Existing Playlists",
    "modifyingExistingPlaylistsHelpContent": "By selecting the first checkbox, all existing playlists will be set to use the new playback speed. However, this change will only affect audio files that are downloaded after this option is enabled.",
    "alreadyDownloadedAudiosHelpTitle": "Already Downloaded Audios",
    "alreadyDownloadedAudiosHelpContent": "Selecting the second checkbox allows you to change the playback speed for audio files already present on the device.",
    "excludingFutureDownloadsHelpTitle": "Excluding Future Downloads",
    "excludingFutureDownloadsHelpContent": "If only the second checkbox is checked, the playback speed will not be modified for audios that will be downloaded later in existing playlists. However, as mentioned previously, new playlists will use the newly defined playback speed for all downloaded audios."
  }
  ''';

  // Parsing the ARB content into a Map
  Map<String, dynamic> arbData = json.decode(arbContent);

  // Generating the Dart class
  String dartClass = generateLocalizationClass(arbData);

  // Printing the generated Dart class code
  print(dartClass);
}

String generateLocalizationClass(Map<String, dynamic> arbData) {
  StringBuffer sb = StringBuffer();

  // Begin class definition
  // sb.writeln('class MockAppLocalizations {');

  // Generate getters for each key in the JSON
  arbData.forEach((key, value) {
    String getterName = toCamelCase(key);  // Converting key to camelCase for the method name
    sb.writeln('  @override');
    sb.writeln('  String get $getterName => "$value";');
    sb.writeln();
  });

  // End class definition
  // sb.writeln('}');

  return sb.toString();
}

String toCamelCase(String text) {
  // Splitting text on underscores and capitalizing each part except the first one
  List<String> parts = text.split('_');
  for (int i = 1; i < parts.length; i++) {
    parts[i] = parts[i][0].toUpperCase() + parts[i].substring(1);
  }
  return parts.join();
}
