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

      List<Audio> expectedResultForTitleDesc = [
        zebra,
        bananna,
        apple,
      ];

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

      print('expectedResultForTitleAsc: $expectedResultForTitleAsc\n');

      print('sortedByTitleDesc: $sortedByTitleDesc\n');
      print('expectedResultForTitleDesc: $expectedResultForTitleDesc\n');

      int i = 0;
      for (i = 0; i < sortedByTitleAsc.length;i++) {
        expect(
            sortedByTitleAsc[i].validVideoTitle ==
                expectedResultForTitleAsc[i].validVideoTitle,
            true);
      }

      i = 0;
      for (Audio audio in sortedByTitleDesc) {
        expect(
            audio.validVideoTitle ==
                expectedResultForTitleDesc[i].validVideoTitle,
            true);
        i++;
      }

      // expect(sortedByTitleAsc, equals(expectedResultForTitleAsc));
      // expect(sortedByTitleDesc, equals(expectedResultForTitleDesc));
    });
  });
}
