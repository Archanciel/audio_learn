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
        compactVideoDescription: '',
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
        compactVideoDescription: '',
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
        compactVideoDescription: '',
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

    test('sort by title starting with non language chars', () {
      List<String> videoTitleLst = [
        "'title",
        "%avec percent title",
        "%percent title",
        "power title",
        "#'amen title",
        "ÉPICURE - La mort n'est rien",
        "%95 title",
        "93 title",
        "#94 title",
        "Échapper à l'illusion de l'esprit",
        "évident title",
        "à lire title",
        "9 title",
        "8 title",
        "%éventuel title",
      ];

      Audio title = Audio.fullConstructor(
        enclosingPlaylist: null,
        originalVideoTitle: "'title",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "'title",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(seconds: 1),
        audioDownloadSpeed: 1,
        videoUploadDate: DateTime.now(),
        audioDuration: const Duration(seconds: 1),
        isMusicQuality: true,
        audioFileName: 'audioFileName',
        audioFileSize: 1,
      );

      Audio avecPercentTitle = Audio.fullConstructor(
        enclosingPlaylist: null,
        originalVideoTitle: "%avec percent title",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "%avec percent title",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(seconds: 1),
        audioDownloadSpeed: 1,
        videoUploadDate: DateTime.now(),
        audioDuration: const Duration(seconds: 1),
        isMusicQuality: true,
        audioFileName: 'audioFileName',
        audioFileSize: 1,
      );

      Audio percentTitle = Audio.fullConstructor(
        enclosingPlaylist: null,
        originalVideoTitle: "%percent title",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "%percent title",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(seconds: 1),
        audioDownloadSpeed: 1,
        videoUploadDate: DateTime.now(),
        audioDuration: const Duration(seconds: 1),
        isMusicQuality: true,
        audioFileName: 'audioFileName',
        audioFileSize: 1,
      );

      Audio powerTitle = Audio.fullConstructor(
        enclosingPlaylist: null,
        originalVideoTitle: "power title",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "power title",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(seconds: 1),
        audioDownloadSpeed: 1,
        videoUploadDate: DateTime.now(),
        audioDuration: const Duration(seconds: 1),
        isMusicQuality: true,
        audioFileName: 'audioFileName',
        audioFileSize: 1,
      );

      Audio amenTitle = Audio.fullConstructor(
        enclosingPlaylist: null,
        originalVideoTitle: "#'amen title",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "#'amen title",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(seconds: 1),
        audioDownloadSpeed: 1,
        videoUploadDate: DateTime.now(),
        audioDuration: const Duration(seconds: 1),
        isMusicQuality: true,
        audioFileName: 'audioFileName',
        audioFileSize: 1,
      );

      Audio epicure = Audio.fullConstructor(
        enclosingPlaylist: null,
        originalVideoTitle: "ÉPICURE - La mort n'est rien 📏",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "ÉPICURE - La mort n'est rien",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(seconds: 1),
        audioDownloadSpeed: 1,
        videoUploadDate: DateTime.now(),
        audioDuration: const Duration(seconds: 1),
        isMusicQuality: true,
        audioFileName: 'audioFileName',
        audioFileSize: 1,
      );

      Audio ninetyFiveTitle = Audio.fullConstructor(
        enclosingPlaylist: null,
        originalVideoTitle: "%95 title",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "%95 title",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(seconds: 1),
        audioDownloadSpeed: 1,
        videoUploadDate: DateTime.now(),
        audioDuration: const Duration(seconds: 1),
        isMusicQuality: true,
        audioFileName: 'audioFileName',
        audioFileSize: 1,
      );

      Audio ninetyThreeTitle = Audio.fullConstructor(
        enclosingPlaylist: null,
        originalVideoTitle: "93 title",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "93 title",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(seconds: 1),
        audioDownloadSpeed: 1,
        videoUploadDate: DateTime.now(),
        audioDuration: const Duration(seconds: 1),
        isMusicQuality: true,
        audioFileName: 'audioFileName',
        audioFileSize: 1,
      );

      Audio ninetyFourTitle = Audio.fullConstructor(
        enclosingPlaylist: null,
        originalVideoTitle: "#94 title",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "#94 title",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(seconds: 1),
        audioDownloadSpeed: 1,
        videoUploadDate: DateTime.now(),
        audioDuration: const Duration(seconds: 1),
        isMusicQuality: true,
        audioFileName: 'audioFileName',
        audioFileSize: 1,
      );

      Audio echapper = Audio.fullConstructor(
        enclosingPlaylist: null,
        originalVideoTitle: "Échapper à l'illusion de l'esprit",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "Échapper à l'illusion de l'esprit",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(seconds: 1),
        audioDownloadSpeed: 1,
        videoUploadDate: DateTime.now(),
        audioDuration: const Duration(seconds: 1),
        isMusicQuality: true,
        audioFileName: 'audioFileName',
        audioFileSize: 1,
      );

      Audio evidentTitle = Audio.fullConstructor(
        enclosingPlaylist: null,
        originalVideoTitle: "évident title",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "évident title",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(seconds: 1),
        audioDownloadSpeed: 1,
        videoUploadDate: DateTime.now(),
        audioDuration: const Duration(seconds: 1),
        isMusicQuality: true,
        audioFileName: 'audioFileName',
        audioFileSize: 1,
      );

      Audio aLireTitle = Audio.fullConstructor(
        enclosingPlaylist: null,
        originalVideoTitle: "à lire title",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "à lire title",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(seconds: 1),
        audioDownloadSpeed: 1,
        videoUploadDate: DateTime.now(),
        audioDuration: const Duration(seconds: 1),
        isMusicQuality: false,
        audioFileName: 'audioFileName',
        audioFileSize: 1,
      );

      Audio nineTitle = Audio.fullConstructor(
        enclosingPlaylist: null,
        originalVideoTitle: "9 title",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "9 title",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(seconds: 1),
        audioDownloadSpeed: 1,
        videoUploadDate: DateTime.now(),
        isMusicQuality: false,
        audioDuration: const Duration(seconds: 1),
        audioFileName: 'audioFileName',
        audioFileSize: 1,
      );

      Audio eightTitle = Audio.fullConstructor(
        enclosingPlaylist: null,
        originalVideoTitle: "8 title",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "8 title",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(seconds: 1),
        isMusicQuality: false,
        audioDownloadSpeed: 1,
        videoUploadDate: DateTime.now(),
        audioDuration: const Duration(seconds: 1),
        audioFileName: 'audioFileName',
        audioFileSize: 1,
      );

      Audio eventuelTitle = Audio.fullConstructor(
        enclosingPlaylist: null,
        originalVideoTitle: "éventuel title",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "éventuel title",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        isMusicQuality: false,
        audioDownloadDuration: const Duration(seconds: 1),
        audioDownloadSpeed: 1,
        videoUploadDate: DateTime.now(),
        audioDuration: const Duration(seconds: 1),
        audioFileName: 'audioFileName',
        audioFileSize: 1,
      );

      List<Audio?> audioLst = [
        title,
        avecPercentTitle,
        percentTitle,
        powerTitle,
        amenTitle,
        epicure,
        ninetyFiveTitle,
        ninetyThreeTitle,
        ninetyFourTitle,
        echapper,
        evidentTitle,
        aLireTitle,
        nineTitle,
        eightTitle,
        eventuelTitle,
      ];

      List<Audio?> expectedResultForTitleAsc = [
        eightTitle,
        ninetyThreeTitle,
        ninetyFourTitle,
        ninetyFiveTitle,
        nineTitle,
        epicure,
        amenTitle,
        avecPercentTitle,
        echapper,
        aLireTitle,
        percentTitle,
        powerTitle,
        title,
        eventuelTitle,
        evidentTitle,
      ];
/* Results if sorting was totally correct ! 
 [
            '8 title',
            '93 title',
            '#94 title',
            '%95 title',
            '9 title',
            'ÉPICURE - La mort n\'est rien',
            'Échapper à l\'illusion de l\'esprit',
            '#\'amen title',
            '%avec percent title',
            'à lire title',
            '%percent title',
            'power title',
            '\'title',
            'éventuel title',
            'évident title'
          ]     

      List<Audio?> expectedResultForTitleDesc = [
        evident_title,
        eventuel_title,
        title,
        power_title,
        percent_title,
        a_lire_title,
        avec_percent_title,
        amen_title,
        echapper,
        epicure,
        nine_title,
        ninety_five_title,
        ninety_four_title,
        ninety_three_title,
        eight_title,
      ];
*/

      List<Audio?> expectedResultForTitleDesc = [
        evidentTitle,
        eventuelTitle,
        title,
        powerTitle,
        percentTitle,
        aLireTitle,
        echapper,
        avecPercentTitle,
        amenTitle,
        epicure,
        nineTitle,
        ninetyFiveTitle,
        ninetyFourTitle,
        ninetyThreeTitle,
        eightTitle,
      ];

      List<Audio> sortedByTitleAsc =
          audioSortFilterService.sortAudioLstBySortingOption(
        audioLst: List<Audio>.from(audioLst), // copy list
        sortingOption: SortingOption.validAudioTitle,
        asc: true,
      );

      expect(
          sortedByTitleAsc.map((audio) => audio.validVideoTitle).toList(),
          equals(expectedResultForTitleAsc
              .map((audio) => audio!.validVideoTitle)
              .toList()));

      List<Audio> sortedByTitleDesc =
          audioSortFilterService.sortAudioLstBySortingOption(
        audioLst: List<Audio>.from(audioLst), // copy list
        sortingOption: SortingOption.validAudioTitle,
        asc: false,
      );

      expect(
          sortedByTitleDesc.map((audio) => audio.validVideoTitle).toList(),
          equals(expectedResultForTitleDesc
              .map((audio) => audio!.validVideoTitle)
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
        compactVideoDescription: '',
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
        compactVideoDescription: '',
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
        compactVideoDescription: '',
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
        compactVideoDescription: '',
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
        compactVideoDescription: '',
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

      List<Audio> audioList = [zebra1, apple, zebra3, bananna, zebra2];

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
          filteredAndSortedByTitleAsc
              .map((audio) => audio.validVideoTitle)
              .toList(),
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
          filteredAndSortedByTitleDesc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          equals(expectedResultForFilterSortTitleDesc
              .map((audio) => audio.validVideoTitle)
              .toList()));
    });
  });
}
