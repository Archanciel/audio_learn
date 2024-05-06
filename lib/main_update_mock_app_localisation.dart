import 'dart:convert';
import 'dart:io';

void main() async {
  // Simulated content of an ARB file as a JSON string, including a parameterized string
  var arbContent = '''
  {
    "audioNotCopiedFromYoutubePlaylistToLocalPlaylist": "Audio \\"{audioTitle}\\" NOT copied from Youtube playlist \\"{fromPlaylistTitle}\\" to local playlist \\"{toPlaylistTitle}\\" since it is already present in the destination playlist."
  }
  ''';

  // Parsing the ARB content into a Map
  Map<String, dynamic> arbData = json.decode(arbContent);

  // Generating the Dart class
  String dartClass = generateLocalizationClass(arbData);

  // Define the path to the file in the test directory
  String filePath = 'test/mock_app_localizations.dart';

  // Insert the generated class into the file
  await insertIntoFile(filePath, dartClass);

  print('Localization class has been inserted into $filePath');
}

String generateLocalizationClass(Map<String, dynamic> arbData) {
  StringBuffer sb = StringBuffer();

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

  return sb.toString();
}

Future<void> insertIntoFile(String filePath, String contentToInsert) async {
  var file = File(filePath);
  if (await file.exists()) {
    String originalContent = await file.readAsString();
    int insertPosition = originalContent.lastIndexOf('}');

    if (insertPosition != -1) {
      String newContent = originalContent.substring(0, insertPosition) +
          contentToInsert +
          originalContent.substring(insertPosition);
      await file.writeAsString(newContent);
    }
  }
}

String toCamelCase(String text) {
  List<String> parts = text.split('_');
  for (int i = 1; i < parts.length; i++) {
    parts[i] = parts[i][0].toUpperCase() + parts[i].substring(1);
  }
  return parts.join();
}