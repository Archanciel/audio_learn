import 'dart:convert';

/// Executing in vs code Terminal:
///
/// dart run ./lib/main_create_mock_app_localisation.dart
void main() {
  // Simulated content of an ARB file as a JSON string,
  // including a parameterized string
  var arbContent = '''
  {
  "alreadyDownloadedAudiosPlaylistHelpTitle": "Already Downloaded Audios",
  "alreadyDownloadedAudiosPlaylistHelpContent": "Selecting the checkbox allows you to change the playback speed for playlist audio files already present on the device."
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

  // Generate getters or methods for each key in the JSON
  arbData.forEach((key, value) {
    // Check if the value contains parameters
    RegExp exp = RegExp(r'\{([^}]+)\}');
    var matches = exp.allMatches(value);

    if (matches.isEmpty) {
      // Generate a simple getter if there are no parameters
      String getterName = toCamelCase(key);
      sb.writeln('  @override');
      sb.writeln('  String get $getterName => "$value";');
      sb.writeln();
    } else {
      // Generate a method if there are parameters
      String methodName = toCamelCase(key);
      String methodParameters =
          matches.map((m) => 'Object ${m.group(1)}').join(', ');
      String formattedString =
          value.replaceAllMapped(exp, (m) => '\${${m.group(1)}}');

      sb.writeln('  @override');
      sb.writeln('  String $methodName($methodParameters,) =>');
      sb.writeln('      "$formattedString";');
      sb.writeln();
    }
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
