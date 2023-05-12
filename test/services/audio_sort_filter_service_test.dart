import 'package:flutter_test/flutter_test.dart';
import 'package:audio_learn/models/audio.dart';
import 'package:audio_learn/services/audio_sort_filter_service.dart';

void main() {
  group('AudioSortFilterService', () {
    late AudioSortFilterService audioSortFilterService;

    setUp(() {
      audioSortFilterService = AudioSortFilterService();
    });

    test('sortAudioLstBySortingOption should sort by title', () {
      final Audio zebra = Audio.fullConstructor(
        enclosingPlaylist: null,
        originalVideoTitle: 'Zebra ?',
        validVideoTitle: 'Zebra',
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
      final Audio apple = Audio.fullConstructor(
        enclosingPlaylist: null,
        originalVideoTitle: 'Apple ?',
        validVideoTitle: 'Apple',
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
      final Audio bananna = Audio.fullConstructor(
        enclosingPlaylist: null,
        originalVideoTitle: 'Bananna ?',
        validVideoTitle: 'Bananna',
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

      List<Audio> audioList = [
        zebra,
        apple,
        bananna,
      ];

      print('audioList: $audioList\n');

      List<Audio> expectedResultForTitleAsc = [
        apple,
        bananna,
        zebra,
      ];

      print('expectedResultForTitleAsc: $expectedResultForTitleAsc\n');

      List<Audio> expectedResultForTitleDesc = [
        zebra,
        bananna,
        apple,
      ];

      print('expectedResultForTitleDesc: $expectedResultForTitleDesc\n');

      List<Audio> sortedByTitleAsc =
          audioSortFilterService.sortAudioLstBySortingOption(
        audioLst: audioList,
        sortingOption: SortingOption.validAudioTitle,
        asc: true,
      );
   
      print('sortedByTitleAsc: $sortedByTitleAsc\n');

      List<Audio> sortedByTitleDesc =
          audioSortFilterService.sortAudioLstBySortingOption(
        audioLst: audioList,
        sortingOption: SortingOption.validAudioTitle,
        asc: false,
      );
   
      print('sortedByTitleDesc: $sortedByTitleDesc\n');

      print('sortedByTitleAsc.map: ${sortedByTitleAsc.map((audio) => audio.validVideoTitle).toList()}\n');
      print('expectedResultForTitleAsc.map: ${expectedResultForTitleAsc.map((audio) => audio.validVideoTitle).toList()}\n');

      print('sortedByTitleDesc.map: ${sortedByTitleDesc.map((audio) => audio.validVideoTitle).toList()}\n');
      print('expectedResultForTitleDesc.map: ${expectedResultForTitleDesc.map((audio) => audio.validVideoTitle).toList()}\n');

      int i = 1;
      expect(
          sortedByTitleAsc.map((audio) => audio.validVideoTitle).toList(),
          equals(expectedResultForTitleAsc
              .map((audio) => audio.validVideoTitle)
              .toList()));
      expect(
          sortedByTitleDesc.map((audio) => audio.validVideoTitle).toList(),
          equals(expectedResultForTitleDesc
              .map((audio) => audio.validVideoTitle)
              .toList()));
    });
  });
}
