import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:audio_learn/models/audio.dart';
import 'package:audio_learn/models/playlist.dart';
import 'package:audio_learn/services/json_data_service.dart';

class UnsupportedClass {}

class MyUnsupportedTestClass {
  final String name;
  final int value;

  MyUnsupportedTestClass({required this.name, required this.value});

  factory MyUnsupportedTestClass.fromJson(Map<String, dynamic> json) {
    return MyUnsupportedTestClass(
      name: json['name'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
    };
  }
}

void main() {
  const jsonPath = 'test.json';

  group('JsonDataService individual', () {
    test('saveToFile and loadFromFile for one Audio instance', () async {
      // Create a temporary directory to store the serialized Audio object
      Directory tempDir = await Directory.systemTemp.createTemp('AudioTest');
      String filePath = path.join(tempDir.path, 'audio.json');

      // Create an Audio instance
      Audio originalAudio = Audio.fullConstructor(
        enclosingPlaylist: null,
        originalVideoTitle: 'Test Video Title',
        compactVideoDescription: '',
        validVideoTitle: 'Test Video Title',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isMusicQuality: false,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );

      // Save the Audio instance to a file
      JsonDataService.saveToFile(model: originalAudio, path: filePath);

      // Load the Audio instance from the file
      Audio deserializedAudio =
          JsonDataService.loadFromFile(jsonPathFileName: filePath, type: Audio);

      // Compare the deserialized Audio instance with the original Audio instance
      compareDeserializedWithOriginalAudio(
        deserializedAudio: deserializedAudio,
        originalAudio: originalAudio,
      );

      // Cleanup the temporary directory
      await tempDir.delete(recursive: true);
    });

    test('loadFromFile one Audio instance file not exist', () async {
      // Create a temporary directory to store the serialized Audio object
      Directory tempDir = await Directory.systemTemp.createTemp('AudioTest');
      String filePath = path.join(tempDir.path, 'audio.json');
      // Load the Audio instance from the file
      dynamic deserializedAudio =
          JsonDataService.loadFromFile(jsonPathFileName: filePath, type: Audio);

      // Compare the deserialized Audio instance with the original Audio instance
      expect(deserializedAudio, null);

      // Cleanup the temporary directory
      await tempDir.delete(recursive: true);
    });
    test(
        'saveToFile and loadFromFile for one Audio instance with null audioDuration',
        () async {
      // Create a temporary directory to store the serialized Audio object
      Directory tempDir = await Directory.systemTemp.createTemp('AudioTest');
      String filePath = path.join(tempDir.path, 'audio.json');

      // Create an Audio instance
      Audio originalAudio = Audio.fullConstructor(
        enclosingPlaylist: null,
        originalVideoTitle: 'Test Video Title',
        compactVideoDescription: '',
        validVideoTitle: 'Test Video Title',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 1, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: null,
        isMusicQuality: false,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );

      // Save the Audio instance to a file
      JsonDataService.saveToFile(model: originalAudio, path: filePath);

      // Load the Audio instance from the file
      Audio deserializedAudio =
          JsonDataService.loadFromFile(jsonPathFileName: filePath, type: Audio);

      // Compare the deserialized Audio instance with the original Audio instance
      compareDeserializedWithOriginalAudio(
        deserializedAudio: deserializedAudio,
        originalAudio: originalAudio,
      );

      // Cleanup the temporary directory
      await tempDir.delete(recursive: true);
    });
    test('saveToFile and loadFromFile for one Playlist instance', () async {
      // Create a temporary directory to store the serialized Audio object
      Directory tempDir = await Directory.systemTemp.createTemp('AudioTest');
      String filePath = path.join(tempDir.path, 'audio.json');
      // Create a Playlist with 2 Audio instances
      Playlist testPlaylist = Playlist(
        id: 'testPlaylist1ID',
        title: 'Test Playlist',
        url: 'https://www.example.com/playlist-url',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
        isSelected: true,
      );

      testPlaylist.downloadPath = 'path/to/downloads';

      Audio audio1 = Audio.fullConstructor(
        enclosingPlaylist: testPlaylist,
        originalVideoTitle: 'Test Video 1',
        compactVideoDescription: 'Test Video 1 Description',
        validVideoTitle: 'Test Video Title',
        videoUrl: 'https://www.example.com/video-url-1',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime.now().subtract(const Duration(days: 10)),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isMusicQuality: false,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );

      Audio audio2 = Audio.fullConstructor(
        enclosingPlaylist: testPlaylist,
        originalVideoTitle: 'Test Video 2',
        compactVideoDescription: 'Test Video 2 Description',
        validVideoTitle: 'Test Video Title',
        videoUrl: 'https://www.example.com/video-url-2',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 38),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime.now().subtract(const Duration(days: 5)),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isMusicQuality: false,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );

      testPlaylist.downloadedAudioLst = [audio1, audio2];
      testPlaylist.playableAudioLst = [audio2];

      // Save Playlist to a file
      JsonDataService.saveToFile(model: testPlaylist, path: filePath);

      // Load Playlist from the file
      Playlist loadedPlaylist = JsonDataService.loadFromFile(
          jsonPathFileName: filePath, type: Playlist);

      // Compare original and loaded Playlist
      compareDeserializedWithOriginalPlaylist(
        deserializedPlaylist: loadedPlaylist,
        originalPlaylist: testPlaylist,
      );

      // Cleanup the temporary directory
      await tempDir.delete(recursive: true);
    });
    test('loadFromFile one Playlist instance file not exist', () async {
      // Create a temporary directory to store the serialized Audio object
      Directory tempDir = await Directory.systemTemp.createTemp('AudioTest');
      String filePath = path.join(tempDir.path, 'audio.json');
      // Load the Audio instance from the file
      dynamic deserializedPlaylist = JsonDataService.loadFromFile(
          jsonPathFileName: filePath, type: Playlist);

      // Compare the deserialized Audio instance with the original Audio instance
      expect(deserializedPlaylist, null);

      // Cleanup the temporary directory
      await tempDir.delete(recursive: true);
    });
    test('ClassNotContainedInJsonFileException', () {
      // Prepare a temporary file
      File tempFile = File('temp.json');
      tempFile.writeAsStringSync(jsonEncode({'test': 'data'}));

      try {
        // Try to load a MyClass instance from the temporary file, which
        // should throw an exception
        JsonDataService.loadFromFile(
            jsonPathFileName: 'temp.json', type: Audio);
      } catch (e) {
        expect(e, isA<ClassNotContainedInJsonFileException>());
      } finally {
        tempFile.deleteSync(); // Clean up the temporary file
      }
    });
    test('ClassNotSupportedByToJsonDataServiceException', () {
      // Create a class not supported by JsonDataService

      try {
        // Try to encode an instance of UnsupportedClass, which should throw an exception
        JsonDataService.encodeJson(UnsupportedClass());
      } catch (e) {
        expect(e, isA<ClassNotSupportedByToJsonDataServiceException>());
      }
    });
  });
  group('JsonDataService list', () {
    test('saveListToFile() ClassNotSupportedByToJsonDataServiceException', () {
      // Prepare test data
      List<MyUnsupportedTestClass> testList = [
        MyUnsupportedTestClass(name: 'Test1', value: 1),
        MyUnsupportedTestClass(name: 'Test2', value: 2),
      ];

      // Save the list to a file
      try {
        // Try to decode the JSON string into an instance of UnsupportedClass, which should throw an exception
        JsonDataService.saveListToFile(
            jsonPathFileName: jsonPath, data: testList);
      } catch (e) {
        expect(e, isA<ClassNotSupportedByToJsonDataServiceException>());
      }
    });
    test('saveListToFile() ClassNotSupportedByFromJsonDataServiceException',
        () {
      // Create an Audio instance
      Audio originalAudio = Audio.fullConstructor(
        enclosingPlaylist: null,
        originalVideoTitle: 'Test Video Title',
        compactVideoDescription: '',
        validVideoTitle: 'Test Video Title',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isMusicQuality: false,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );

      // Save the Audio instance to a file
      JsonDataService.saveToFile(model: originalAudio, path: jsonPath);

      // Load the list from the file
      try {
        JsonDataService.loadListFromFile(
            jsonPathFileName: jsonPath, type: MyUnsupportedTestClass);
      } catch (e) {
        expect(e, isA<ClassNotSupportedByFromJsonDataServiceException>());
      }

      // Clean up the test file
      File(jsonPath).deleteSync();
    });
    test('saveListToFile() and loadListFromFile() for Audio list', () async {
      // Create an Audio instance
      Audio audioOne = Audio.fullConstructor(
        enclosingPlaylist: null,
        originalVideoTitle: 'Test Video One Title',
        compactVideoDescription: '',
        validVideoTitle: 'Test Video Title',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isMusicQuality: false,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );

      Audio audioTwo = Audio.fullConstructor(
        enclosingPlaylist: null,
        originalVideoTitle: 'Test Video Two Title',
        compactVideoDescription: '',
        validVideoTitle: 'Test Video Title',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isMusicQuality: false,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );

      // Prepare test data
      List<Audio> testList = [audioOne, audioTwo];

      // Save the list to a file
      JsonDataService.saveListToFile(
          data: testList, jsonPathFileName: jsonPath);

      // Load the list from the file
      List<Audio> loadedList = JsonDataService.loadListFromFile(
          jsonPathFileName: jsonPath, type: Audio);

      // Check if the loaded list matches the original list
      expect(loadedList.length, testList.length);

      for (int i = 0; i < loadedList.length; i++) {
        compareDeserializedWithOriginalAudio(
          deserializedAudio: loadedList[i],
          originalAudio: testList[i],
        );
      }

      // Clean up the test file
      File(jsonPath).deleteSync();
    });
    test('loadListFromFile() for Audio list file not exist', () {
      // Create an Audio instance
      // Load the list from the file
      List<Audio> loadedList = JsonDataService.loadListFromFile(
          jsonPathFileName: jsonPath, type: Audio);

      // Check if the loaded list matches the original list
      expect(loadedList.length, 0);
    });
    test('saveListToFile() and loadListFromFile() for Playlist list', () {
      // Create an Audio instance
      Playlist testPlaylistOne = Playlist(
        id: 'testPlaylistID1',
        title: 'Test Playlist One',
        url: 'https://www.example.com/playlist-url',
        playlistType: PlaylistType.local,
        playlistQuality: PlaylistQuality.music,
        isSelected: true,
      );

      testPlaylistOne.downloadPath = 'path/to/downloads';

      Audio audio1 = Audio.fullConstructor(
        enclosingPlaylist: testPlaylistOne,
        originalVideoTitle: 'Test Video 1',
        compactVideoDescription: 'Test Video 1 compact description',
        validVideoTitle: 'Test Video Title',
        videoUrl: 'https://www.example.com/video-url-1',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime.now().subtract(const Duration(days: 10)),
        audioDuration: null,
        isMusicQuality: false,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );

      Audio audio2 = Audio.fullConstructor(
        enclosingPlaylist: testPlaylistOne,
        originalVideoTitle: 'Test Video 2',
        compactVideoDescription: 'Test Video 2 compact description',
        validVideoTitle: 'Test Video Title',
        videoUrl: 'https://www.example.com/video-url-2',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime.now().subtract(const Duration(days: 5)),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isMusicQuality: false,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );

      testPlaylistOne.addDownloadedAudio(audio1);
      testPlaylistOne.addDownloadedAudio(audio2);

      Playlist testPlaylistTwo = Playlist(
        id: 'testPlaylistID2',
        title: 'Test Playlist Two',
        url: 'https://www.example.com/playlist-url',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
        isSelected: false,
      );

      testPlaylistTwo.downloadPath = 'path/to/downloads';

      Audio audio3 = Audio.fullConstructor(
        enclosingPlaylist: testPlaylistTwo,
        originalVideoTitle: 'Test Video 1',
        compactVideoDescription: 'Test Video 1 compact description',
        validVideoTitle: 'Test Video Title',
        videoUrl: 'https://www.example.com/video-url-1',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime.now().subtract(const Duration(days: 10)),
        audioDuration: null,
        isMusicQuality: false,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );

      Audio audio4 = Audio.fullConstructor(
        enclosingPlaylist: testPlaylistTwo,
        originalVideoTitle: 'Test Video 2',
        compactVideoDescription: 'Test Video 2 compact description',
        validVideoTitle: 'Test Video Title',
        videoUrl: 'https://www.example.com/video-url-2',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime.now().subtract(const Duration(days: 5)),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isMusicQuality: false,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );

      testPlaylistTwo.addDownloadedAudio(audio3);
      testPlaylistTwo.addDownloadedAudio(audio4);

      // Prepare test data
      List<Playlist> testList = [testPlaylistOne, testPlaylistTwo];

      // Save the list to a file
      JsonDataService.saveListToFile(
          data: testList, jsonPathFileName: jsonPath);

      // Load the list from the file
      List<Playlist> loadedList = JsonDataService.loadListFromFile(
          jsonPathFileName: jsonPath, type: Playlist);

      // Check if the loaded list matches the original list
      expect(loadedList.length, testList.length);

      for (int i = 0; i < loadedList.length; i++) {
        compareDeserializedWithOriginalPlaylist(
          deserializedPlaylist: loadedList[i],
          originalPlaylist: testList[i],
        );
      }

      // Clean up the test file
      File(jsonPath).deleteSync();
    });
    test('loadListFromFile() for Playlist list file not exist', () {
      // Create an Audio instance
      // Load the list from the file
      List<Audio> loadedList = JsonDataService.loadListFromFile(
          jsonPathFileName: jsonPath, type: Playlist);

      // Check if the loaded list matches the original list
      expect(loadedList.length, 0);
    });
  });
}

void compareDeserializedWithOriginalPlaylist({
  required Playlist deserializedPlaylist,
  required Playlist originalPlaylist,
}) {
  expect(deserializedPlaylist.id, originalPlaylist.id);
  expect(deserializedPlaylist.title, originalPlaylist.title);
  expect(deserializedPlaylist.url, originalPlaylist.url);
  expect(deserializedPlaylist.playlistType, originalPlaylist.playlistType);
  expect(
      deserializedPlaylist.playlistQuality, originalPlaylist.playlistQuality);
  expect(deserializedPlaylist.downloadPath, originalPlaylist.downloadPath);
  expect(deserializedPlaylist.isSelected, originalPlaylist.isSelected);

  // Compare Audio instances in original and loaded Playlist
  expect(deserializedPlaylist.downloadedAudioLst.length,
      originalPlaylist.downloadedAudioLst.length);
  expect(deserializedPlaylist.playableAudioLst.length,
      originalPlaylist.playableAudioLst.length);

  for (int i = 0; i < deserializedPlaylist.downloadedAudioLst.length; i++) {
    Audio originalAudio = originalPlaylist.downloadedAudioLst[i];
    Audio loadedAudio = deserializedPlaylist.downloadedAudioLst[i];

    compareDeserializedWithOriginalAudio(
      deserializedAudio: loadedAudio,
      originalAudio: originalAudio,
    );
  }

  for (int i = 0; i < deserializedPlaylist.playableAudioLst.length; i++) {
    Audio originalAudio = originalPlaylist.playableAudioLst[i];
    Audio loadedAudio = deserializedPlaylist.playableAudioLst[i];

    compareDeserializedWithOriginalAudio(
      deserializedAudio: loadedAudio,
      originalAudio: originalAudio,
    );
  }
}

void compareDeserializedWithOriginalAudio({
  required Audio deserializedAudio,
  required Audio originalAudio,
}) {
  (deserializedAudio.enclosingPlaylist != null)
      ? expect(deserializedAudio.enclosingPlaylist!.title,
          originalAudio.enclosingPlaylist!.title)
      : expect(
          deserializedAudio.enclosingPlaylist, originalAudio.enclosingPlaylist);
  expect(
      deserializedAudio.originalVideoTitle, originalAudio.originalVideoTitle);
  expect(deserializedAudio.validVideoTitle, originalAudio.validVideoTitle);
  expect(deserializedAudio.compactVideoDescription,
      originalAudio.compactVideoDescription);
  expect(deserializedAudio.videoUrl, originalAudio.videoUrl);
  expect(deserializedAudio.audioDownloadDateTime.toIso8601String(),
      originalAudio.audioDownloadDateTime.toIso8601String());
  expect(deserializedAudio.audioDownloadDuration,
      originalAudio.audioDownloadDuration ?? const Duration(milliseconds: 0));
  expect(
      deserializedAudio.audioDownloadSpeed, originalAudio.audioDownloadSpeed);
  expect(deserializedAudio.videoUploadDate.toIso8601String(),
      originalAudio.videoUploadDate.toIso8601String());

  // inMilliseconds is used because the duration is not exactly the same
  // when it is serialized and deserialized since it is stored in the json
  // file as a number of milliseconds
  expect(deserializedAudio.audioDownloadDuration!.inMilliseconds,
      originalAudio.audioDownloadDuration!.inMilliseconds);
      
  expect(deserializedAudio.isMusicQuality, originalAudio.isMusicQuality);
  expect(deserializedAudio.audioFileName, originalAudio.audioFileName);
  expect(deserializedAudio.audioFileSize, originalAudio.audioFileSize);
}
