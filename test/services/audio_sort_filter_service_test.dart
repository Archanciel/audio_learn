import 'package:flutter_test/flutter_test.dart';
import 'package:audio_learn/models/audio.dart';
import 'package:audio_learn/services/audio_sort_filter_service.dart';

void main() {
  group('sortAudioLstBySortingOption', () {
    late AudioSortFilterService audioSortFilterService;

    setUp(() {
      audioSortFilterService = AudioSortFilterService();
    });

    test('sort by title', () {
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
        audioLst: List<Audio>.from(audioList), // copy list
        sortingOption: SortingOption.validAudioTitle,
        asc: true,
      );

      expect(
          sortedByTitleAsc.map((audio) => audio.validVideoTitle).toList(),
          equals(expectedResultForTitleAsc
              .map((audio) => audio.validVideoTitle)
              .toList()));

      List<Audio> sortedByTitleDesc =
          audioSortFilterService.sortAudioLstBySortingOption(
        audioLst: List<Audio>.from(audioList), // copy list
        sortingOption: SortingOption.validAudioTitle,
        asc: false,
      );

      expect(
          sortedByTitleDesc.map((audio) => audio.validVideoTitle).toList(),
          equals(expectedResultForTitleDesc
              .map((audio) => audio.validVideoTitle)
              .toList()));
    });
  });
  group('filterAndSortAudioLst', () {
    late AudioSortFilterService audioSortFilterService;

    setUp(() {
      audioSortFilterService = AudioSortFilterService();
    });

    test('filter and sort by title', () {
      final Audio zebra1 = Audio.fullConstructor(
        enclosingPlaylist: null,
        originalVideoTitle: 'Zebra ?',
        validVideoTitle: 'Zebra 1',
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
      final Audio zebra3 = Audio.fullConstructor(
        enclosingPlaylist: null,
        originalVideoTitle: 'Zebra ?',
        validVideoTitle: 'Zebra 3',
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
      final Audio zebra2 = Audio.fullConstructor(
        enclosingPlaylist: null,
        originalVideoTitle: 'Zebra ?',
        validVideoTitle: 'Zebra 2',
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
        zebra1,
        apple,
        zebra3,
        bananna,
        zebra2
      ];

      List<Audio> expectedResultForTitleAsc = [
        apple,
        bananna,
        zebra1,
        zebra2,
        zebra3,
      ];

      List<Audio> expectedResultForTitleDesc = [
        zebra3,
        zebra2,
        zebra1,
        bananna,
        apple,
      ];

      List<Audio> sortedByTitleAsc =
          audioSortFilterService.sortAudioLstBySortingOption(
        audioLst: List<Audio>.from(audioList), // copy list
        sortingOption: SortingOption.validAudioTitle,
        asc: true,
      );

      expect(
          sortedByTitleAsc.map((audio) => audio.validVideoTitle).toList(),
          equals(expectedResultForTitleAsc
              .map((audio) => audio.validVideoTitle)
              .toList()));

      List<Audio> sortedByTitleDesc =
          audioSortFilterService.sortAudioLstBySortingOption(
        audioLst: List<Audio>.from(audioList), // copy list
        sortingOption: SortingOption.validAudioTitle,
        asc: false,
      );

      expect(
          sortedByTitleDesc.map((audio) => audio.validVideoTitle).toList(),
          equals(expectedResultForTitleDesc
              .map((audio) => audio.validVideoTitle)
              .toList()));


      List<Audio> expectedResultForFilterSortTitleAsc = [
        zebra1,
        zebra2,
        zebra3,
      ];

      List<Audio> expectedResultForFilterSortTitleDesc = [
        zebra3,
        zebra2,
        zebra1,
      ];

      List<Audio> filteredAndSortedByTitleAsc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
        sortingOption: SortingOption.validAudioTitle,
        searchWords: 'Zeb',
        asc: true,
      );

      expect(
          filteredAndSortedByTitleAsc.map((audio) => audio.validVideoTitle).toList(),
          equals(expectedResultForFilterSortTitleAsc
              .map((audio) => audio.validVideoTitle)
              .toList()));

      List<Audio> filteredAndSortedByTitleDesc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
        sortingOption: SortingOption.validAudioTitle,
        searchWords: 'Zeb',
        asc: false,
      );

      expect(
          filteredAndSortedByTitleDesc.map((audio) => audio.validVideoTitle).toList(),
          equals(expectedResultForFilterSortTitleDesc
              .map((audio) => audio.validVideoTitle)
              .toList()));
    });
  });
}
