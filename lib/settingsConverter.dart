import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

/// Commando generate the apk:
/// 
/// flutter build apk --release --target=lib/settingsConverter.dart
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Modify JSON App',
      home: JsonModifier(),
    );
  }
}

class JsonModifier extends StatefulWidget {
  @override
  _JsonModifierState createState() => _JsonModifierState();
}

class _JsonModifierState extends State<JsonModifier> {
  final TextEditingController _controller = TextEditingController();
  String _status = '';

  @override
  Widget build(BuildContext context) {
    _controller.text = "/storage/emulated/0/Download/audiolearn/settings.json";
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modify JSON'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter application root path',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _modifyJsonFile,
            child: const Text('Update settings.json'),
          ),
          const SizedBox(height: 20),
          Text(_status),
        ],
      ),
    );
  }

  Future<void> _modifyJsonFile() async {
    String filePath = _controller.text;
    try {
      await removePlaylistSettingsFromJsonFile(filePath: filePath);
      setState(() {
        _status = 'settings.json modified successfully ! Now, install the new version of audioLearn.apk.';
      });
    } catch (e) {
      setState(() {
        _status = 'Error modifying settings.json: $e. Do not install the new version of audioLearn.apk';
      });
    }
  }
}

Future<void> removePlaylistSettingsFromJsonFile({required String filePath}) async {
  File file = File(filePath);
  String content = await file.readAsString();
  Map<String, dynamic> jsonData = jsonDecode(content);

  (jsonData['SettingType.playlists'] as Map<String, dynamic>).remove('Playlists.defaultAudioSort');
  (jsonData['SettingType.playlists'] as Map<String, dynamic>).remove('Playlists.pathLst');

  String modifiedContent = jsonEncode(jsonData);
  await file.writeAsString(modifiedContent);
}
