import 'package:path/path.dart' as path;
import 'package:flutter_test/flutter_test.dart';

import 'package:audio_learn/services/settings_data_service.dart';
import 'package:audio_learn/utils/dir_util.dart';
import 'package:audio_learn/viewmodels/audio_download_vm.dart';
import 'package:audio_learn/viewmodels/playlist_list_vm.dart';
import 'package:audio_learn/viewmodels/warning_message_vm.dart';
import 'package:audio_learn/constants.dart';
import 'package:audio_learn/models/audio.dart';
import 'package:audio_learn/services/audio_sort_filter_service.dart';

void main() {
  final Audio audioOne = Audio.fullConstructor(
    enclosingPlaylist: null,
    movedFromPlaylistTitle: null,
    movedToPlaylistTitle: null,
    copiedFromPlaylistTitle: null,
    copiedToPlaylistTitle: null,
    originalVideoTitle: 'Zebra ?',
    compactVideoDescription:
        'On vous propose de découvrir les tendances crypto en progression en 2024. Découvrez lesquelles sont les plus prometteuses et lesquelles sont à éviter.',
    validVideoTitle: 'Sur quelle tendance crypto investir en 2024 ?',
    videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
    audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
    audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
    audioDownloadSpeed: 1000000,
    videoUploadDate: DateTime(2023, 3, 1),
    audioDuration: const Duration(minutes: 5, seconds: 30),
    isAudioMusicQuality: false,
    audioPlaySpeed: kAudioDefaultPlaySpeed,
    audioPlayVolume: kAudioDefaultPlayVolume,
    isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
    isPaused: true,
    audioPausedDateTime: null,
    audioPositionSeconds: 0,
    audioFileName: 'Test Video Title.mp3',
    audioFileSize: 330000000,
  );

  final Audio audioTwo = Audio.fullConstructor(
    enclosingPlaylist: null,
    movedFromPlaylistTitle: null,
    movedToPlaylistTitle: null,
    copiedFromPlaylistTitle: null,
    copiedToPlaylistTitle: null,
    originalVideoTitle: 'Zebra ?',
    compactVideoDescription:
        'Éthique et tac vous propose de découvrir les tendances crypto en progression en 2024. Découvrez lesquelles sont les plus prometteuses et lesquelles sont à éviter.',
    validVideoTitle: 'Tendance crypto en accélération en 2024',
    videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
    audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
    audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
    audioDownloadSpeed: 1000000,
    videoUploadDate: DateTime(2023, 3, 1),
    audioDuration: const Duration(minutes: 5, seconds: 30),
    isAudioMusicQuality: false,
    audioPlaySpeed: kAudioDefaultPlaySpeed,
    audioPlayVolume: kAudioDefaultPlayVolume,
    isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
    isPaused: true,
    audioPausedDateTime: null,
    audioPositionSeconds: 0,
    audioFileName: 'Test Video Title.mp3',
    audioFileSize: 330000000,
  );
  final Audio audioThree = Audio.fullConstructor(
    enclosingPlaylist: null,
    movedFromPlaylistTitle: null,
    movedToPlaylistTitle: null,
    copiedFromPlaylistTitle: null,
    copiedToPlaylistTitle: null,
    originalVideoTitle: 'Zebra ?',
    compactVideoDescription:
        "Se dirige-t-on vers une intelligence artificielle qui pourrait menacer l’humanité ou au contraire, vers une opportunité pour l’humanité ? Découvrez les réponses à ces questions dans ce podcast.",
    validVideoTitle:
        'Intelligence Artificielle: quelle menace ou opportunité en 2024 ?',
    videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
    audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
    audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
    audioDownloadSpeed: 1000000,
    videoUploadDate: DateTime(2023, 3, 1),
    audioDuration: const Duration(minutes: 5, seconds: 30),
    isAudioMusicQuality: false,
    audioPlaySpeed: kAudioDefaultPlaySpeed,
    audioPlayVolume: kAudioDefaultPlayVolume,
    isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
    isPaused: true,
    audioPausedDateTime: null,
    audioPositionSeconds: 0,
    audioFileName: 'Test Video Title.mp3',
    audioFileSize: 330000000,
  );
  final Audio audioFour = Audio.fullConstructor(
    enclosingPlaylist: null,
    movedFromPlaylistTitle: null,
    movedToPlaylistTitle: null,
    copiedFromPlaylistTitle: null,
    copiedToPlaylistTitle: null,
    originalVideoTitle: 'Zebra ?',
    compactVideoDescription:
        "Sur le plan philosophique, quelles différences entre l’intelligence humaine et l’intelligence artificielle ? Découvrez les réponses à ces questions dans ce podcast.",
    validVideoTitle:
        'Intelligence humaine ou artificielle, quelles différences ?',
    videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
    audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
    audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
    audioDownloadSpeed: 1000000,
    videoUploadDate: DateTime(2023, 3, 1),
    audioDuration: const Duration(minutes: 5, seconds: 30),
    isAudioMusicQuality: false,
    audioPlaySpeed: kAudioDefaultPlaySpeed,
    audioPlayVolume: kAudioDefaultPlayVolume,
    isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
    isPaused: true,
    audioPausedDateTime: null,
    audioPositionSeconds: 0,
    audioFileName: 'Test Video Title.mp3',
    audioFileSize: 330000000,
  );

  List<Audio> audioLst = [
    audioOne,
    audioTwo,
    audioThree,
    audioFour,
  ];

  group(
      'filter test: ignoring case, filter audio list on validVideoTitle only test',
      () {
    late AudioSortFilterService audioSortFilterService;

    setUp(() {
      audioSortFilterService = AudioSortFilterService();
    });
    test('filter by <tendance crypto> AND <en 2024>', () {
      List<Audio> expectedFilteredBooks = [
        audioOne,
        audioTwo,
      ];

      List<Audio> filteredBooks = audioSortFilterService.filter(
          audioLst: audioLst,
          filterSentenceLst: [
            'tendance crypto',
            'en 2024',
          ],
          sentencesCombination: SentencesCombination.AND,
          ignoreCase: true,
          searchAsWellInVideoCompactDescription: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <tendance crypto> OR <en 2024>', () {
      List<Audio> expectedFilteredBooks = [
        audioOne,
        audioTwo,
        audioThree,
      ];

      List<Audio> filteredBooks = audioSortFilterService.filter(
          audioLst: audioLst,
          filterSentenceLst: [
            'tendance crypto',
            'en 2024',
          ],
          sentencesCombination: SentencesCombination.OR,
          ignoreCase: true,
          searchAsWellInVideoCompactDescription: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <en 2024> AND <tendance crypto>', () {
      List<Audio> expectedFilteredBooks = [
        audioOne,
        audioTwo,
      ];

      List<Audio> filteredBooks = audioSortFilterService.filter(
          audioLst: audioLst,
          filterSentenceLst: [
            'en 2024',
            'tendance crypto',
          ],
          sentencesCombination: SentencesCombination.AND,
          ignoreCase: true,
          searchAsWellInVideoCompactDescription: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <en 2024> OR <tendance crypto>', () {
      List<Audio> expectedFilteredBooks = [
        audioOne,
        audioTwo,
        audioThree,
      ];

      List<Audio> filteredBooks = audioSortFilterService.filter(
          audioLst: audioLst,
          filterSentenceLst: [
            'en 2024',
            'tendance crypto',
          ],
          sentencesCombination: SentencesCombination.OR,
          ignoreCase: true,
          searchAsWellInVideoCompactDescription: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <quelle> AND <2024>', () {
      List<Audio> expectedFilteredBooks = [
        audioOne,
        audioThree,
      ];

      List<Audio> filteredBooks = audioSortFilterService.filter(
          audioLst: audioLst,
          filterSentenceLst: [
            'quelle',
            '2024',
          ],
          sentencesCombination: SentencesCombination.AND,
          ignoreCase: true,
          searchAsWellInVideoCompactDescription: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <quelle> OR <2024>', () {
      List<Audio> expectedFilteredBooks = [
        audioOne,
        audioTwo,
        audioThree,
        audioFour,
      ];

      List<Audio> filteredBooks = audioSortFilterService.filter(
          audioLst: audioLst,
          filterSentenceLst: [
            'quelle',
            '2024',
          ],
          sentencesCombination: SentencesCombination.OR,
          ignoreCase: true,
          searchAsWellInVideoCompactDescription: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <2024> AND <quelle>', () {
      List<Audio> expectedFilteredBooks = [
        audioOne,
        audioThree,
      ];

      List<Audio> filteredBooks = audioSortFilterService.filter(
          audioLst: audioLst,
          filterSentenceLst: [
            '2024',
            'quelle',
          ],
          sentencesCombination: SentencesCombination.AND,
          ignoreCase: true,
          searchAsWellInVideoCompactDescription: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <2024> OR <quelle>', () {
      List<Audio> expectedFilteredBooks = [
        audioOne,
        audioTwo,
        audioThree,
        audioFour,
      ];

      List<Audio> filteredBooks = audioSortFilterService.filter(
          audioLst: audioLst,
          filterSentenceLst: [
            '2024',
            'quelle',
          ],
          sentencesCombination: SentencesCombination.OR,
          ignoreCase: true,
          searchAsWellInVideoCompactDescription: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <intelligence> OR <artificielle>', () {
      List<Audio> expectedFilteredBooks = [
        audioThree,
        audioFour,
      ];

      List<Audio> filteredBooks = audioSortFilterService.filter(
          audioLst: audioLst,
          filterSentenceLst: [
            'intelligence',
            'artificielle',
          ],
          sentencesCombination: SentencesCombination.OR,
          ignoreCase: true,
          searchAsWellInVideoCompactDescription: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
  });
  group(
      'filter test: not ignoring case, filter audio list on validVideoTitle only test',
      () {
    late AudioSortFilterService audioSortFilterService;

    setUp(() {
      audioSortFilterService = AudioSortFilterService();
    });
    test('filter by <tendance crypto> AND <en 2024>', () {
      List<Audio> expectedFilteredBooks = [
        audioOne,
      ];

      List<Audio> filteredBooks = audioSortFilterService.filter(
          audioLst: audioLst,
          filterSentenceLst: [
            'tendance crypto',
            'en 2024',
          ],
          sentencesCombination: SentencesCombination.AND,
          ignoreCase: false,
          searchAsWellInVideoCompactDescription: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <tendance crypto> OR <en 2024>', () {
      List<Audio> expectedFilteredBooks = [
        audioOne,
        audioTwo,
        audioThree,
      ];

      List<Audio> filteredBooks = audioSortFilterService.filter(
          audioLst: audioLst,
          filterSentenceLst: [
            'tendance crypto',
            'en 2024',
          ],
          sentencesCombination: SentencesCombination.OR,
          ignoreCase: false,
          searchAsWellInVideoCompactDescription: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <en 2024> AND <tendance crypto>', () {
      List<Audio> expectedFilteredBooks = [
        audioOne,
      ];

      List<Audio> filteredBooks = audioSortFilterService.filter(
          audioLst: audioLst,
          filterSentenceLst: [
            'en 2024',
            'tendance crypto',
          ],
          sentencesCombination: SentencesCombination.AND,
          ignoreCase: false,
          searchAsWellInVideoCompactDescription: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <en 2024> OR <tendance crypto>', () {
      List<Audio> expectedFilteredBooks = [
        audioOne,
        audioTwo,
        audioThree,
      ];

      List<Audio> filteredBooks = audioSortFilterService.filter(
          audioLst: audioLst,
          filterSentenceLst: [
            'en 2024',
            'tendance crypto',
          ],
          sentencesCombination: SentencesCombination.OR,
          ignoreCase: false,
          searchAsWellInVideoCompactDescription: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <quelle> AND <2024>', () {
      List<Audio> expectedFilteredBooks = [
        audioOne,
        audioThree,
      ];

      List<Audio> filteredBooks = audioSortFilterService.filter(
          audioLst: audioLst,
          filterSentenceLst: [
            'quelle',
            '2024',
          ],
          sentencesCombination: SentencesCombination.AND,
          ignoreCase: false,
          searchAsWellInVideoCompactDescription: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <quelle> OR <2024>', () {
      List<Audio> expectedFilteredBooks = [
        audioOne,
        audioTwo,
        audioThree,
        audioFour,
      ];

      List<Audio> filteredBooks = audioSortFilterService.filter(
          audioLst: audioLst,
          filterSentenceLst: [
            'quelle',
            '2024',
          ],
          sentencesCombination: SentencesCombination.OR,
          ignoreCase: false,
          searchAsWellInVideoCompactDescription: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <2024> AND <quelle>', () {
      List<Audio> expectedFilteredBooks = [
        audioOne,
        audioThree,
      ];

      List<Audio> filteredBooks = audioSortFilterService.filter(
          audioLst: audioLst,
          filterSentenceLst: [
            '2024',
            'quelle',
          ],
          sentencesCombination: SentencesCombination.AND,
          ignoreCase: false,
          searchAsWellInVideoCompactDescription: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <intelligence> OR <artificielle>', () {
      List<Audio> expectedFilteredBooks = [
        audioFour,
      ];

      List<Audio> filteredBooks = audioSortFilterService.filter(
          audioLst: audioLst,
          filterSentenceLst: [
            'intelligence',
            'artificielle',
          ],
          sentencesCombination: SentencesCombination.OR,
          ignoreCase: false,
          searchAsWellInVideoCompactDescription: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <2024> OR <quelle>', () {
      List<Audio> expectedFilteredBooks = [
        audioOne,
        audioTwo,
        audioThree,
        audioFour,
      ];

      List<Audio> filteredBooks = audioSortFilterService.filter(
          audioLst: audioLst,
          filterSentenceLst: [
            '2024',
            'quelle',
          ],
          sentencesCombination: SentencesCombination.OR,
          ignoreCase: false,
          searchAsWellInVideoCompactDescription: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
  });
  group(
      'filter test: ignoring case, filter audio list on validVideoTitle or compactVideoDescription test',
      () {
    late AudioSortFilterService audioSortFilterService;

    setUp(() {
      audioSortFilterService = AudioSortFilterService();
    });
    test('filter by <investir en 2024> AND <éthique et tac>', () {
      List<Audio> expectedFilteredBooks = [];

      List<Audio> filteredBooks = audioSortFilterService.filter(
          audioLst: audioLst,
          filterSentenceLst: [
            'investir en 2024',
            'éthique et tac',
          ],
          sentencesCombination: SentencesCombination.AND,
          ignoreCase: true,
          searchAsWellInVideoCompactDescription: true);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <accélération> AND <éthique et tac>', () {
      List<Audio> expectedFilteredBooks = [
        audioTwo,
      ];

      List<Audio> filteredBooks = audioSortFilterService.filter(
          audioLst: audioLst,
          filterSentenceLst: [
            'accélération',
            'éthique et tac',
          ],
          sentencesCombination: SentencesCombination.AND,
          ignoreCase: true,
          searchAsWellInVideoCompactDescription: true);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <investir en 2024> OR <éthique et tac>', () {
      List<Audio> expectedFilteredBooks = [
        audioOne,
        audioTwo,
      ];

      List<Audio> filteredBooks = audioSortFilterService.filter(
          audioLst: audioLst,
          filterSentenceLst: [
            'investir en 2024',
            'éthique et tac',
          ],
          sentencesCombination: SentencesCombination.OR,
          ignoreCase: true,
          searchAsWellInVideoCompactDescription: true);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <on vous propose> OR <en accélération>', () {
      List<Audio> expectedFilteredBooks = [
        audioOne,
        audioTwo,
      ];

      List<Audio> filteredBooks = audioSortFilterService.filter(
          audioLst: audioLst,
          filterSentenceLst: [
            'on vous propose',
            'en accélération',
          ],
          sentencesCombination: SentencesCombination.OR,
          ignoreCase: true,
          searchAsWellInVideoCompactDescription: true);

      expect(filteredBooks, expectedFilteredBooks);
    });
  });
  group(
      'filter test: not ignoring case, filter audio list on validVideoTitle or compactVideoDescription test',
      () {
    late AudioSortFilterService audioSortFilterService;

    setUp(() {
      audioSortFilterService = AudioSortFilterService();
    });
    test('filter by <investir en 2024> AND <éthique et tac>', () {
      List<Audio> expectedFilteredBooks = [];

      List<Audio> filteredBooks = audioSortFilterService.filter(
          audioLst: audioLst,
          filterSentenceLst: [
            'investir en 2024',
            'éthique et tac',
          ],
          sentencesCombination: SentencesCombination.AND,
          ignoreCase: false,
          searchAsWellInVideoCompactDescription: true);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <accélération> AND <Éthique et tac>', () {
      List<Audio> expectedFilteredBooks = [
        audioTwo,
      ];

      List<Audio> filteredBooks = audioSortFilterService.filter(
          audioLst: audioLst,
          filterSentenceLst: [
            'accélération',
            'Éthique et tac',
          ],
          sentencesCombination: SentencesCombination.AND,
          ignoreCase: false,
          searchAsWellInVideoCompactDescription: true);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <investir en 2024> OR <Éthique et tac>', () {
      List<Audio> expectedFilteredBooks = [audioOne, audioTwo];

      List<Audio> filteredBooks = audioSortFilterService.filter(
          audioLst: audioLst,
          filterSentenceLst: [
            'investir en 2024',
            'Éthique et tac',
          ],
          sentencesCombination: SentencesCombination.OR,
          ignoreCase: false,
          searchAsWellInVideoCompactDescription: true);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <investir en 2024> OR <éthique et tac>', () {
      List<Audio> expectedFilteredBooks = [
        audioOne,
      ];

      List<Audio> filteredBooks = audioSortFilterService.filter(
          audioLst: audioLst,
          filterSentenceLst: [
            'investir en 2024',
            'éthique et tac',
          ],
          sentencesCombination: SentencesCombination.OR,
          ignoreCase: false,
          searchAsWellInVideoCompactDescription: true);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <on vous propose> OR <en accélération>', () {
      List<Audio> expectedFilteredBooks = [
        audioTwo,
      ];

      List<Audio> filteredBooks = audioSortFilterService.filter(
          audioLst: audioLst,
          filterSentenceLst: [
            'on vous propose',
            'en accélération',
          ],
          sentencesCombination: SentencesCombination.OR,
          ignoreCase: false,
          searchAsWellInVideoCompactDescription: true);

      expect(filteredBooks, expectedFilteredBooks);
    });
  });
  group('sort audio lst by one SortingOption', () {
    late AudioSortFilterService audioSortFilterService;

    setUp(() {
      audioSortFilterService = AudioSortFilterService();
    });
    test('sort by title', () {
      final Audio zebra = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Zebra ?',
        compactVideoDescription: '',
        validVideoTitle: 'Zebra',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );
      final Audio apple = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Apple ?',
        compactVideoDescription: '',
        validVideoTitle: 'Apple',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );
      final Audio bananna = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Bananna ?',
        compactVideoDescription: '',
        validVideoTitle: 'Bananna',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
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

      final List<SortingItem> selectedSortOptionsLstAsc = [
        SortingItem(
          sortingOption: SortingOption.validAudioTitle,
          isAscending: true,
        ),
      ];

      List<Audio> sortedByTitleAsc =
          audioSortFilterService.sortAudioLstBySortingOptions(
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortOptionsLst: selectedSortOptionsLstAsc,
      );

      expect(
          sortedByTitleAsc.map((audio) => audio.validVideoTitle).toList(),
          equals(expectedResultForTitleAsc
              .map((audio) => audio.validVideoTitle)
              .toList()));

      final List<SortingItem> selectedSortOptionsLstDesc = [
        SortingItem(
          sortingOption: SortingOption.validAudioTitle,
          isAscending: false,
        ),
      ];

      List<Audio> sortedByTitleDesc =
          audioSortFilterService.sortAudioLstBySortingOptions(
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortOptionsLst: selectedSortOptionsLstDesc,
      );

      expect(
          sortedByTitleDesc.map((audio) => audio.validVideoTitle).toList(),
          equals(expectedResultForTitleDesc
              .map((audio) => audio.validVideoTitle)
              .toList()));
    });

    test('sort by title starting with non language chars', () {
      Audio title = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: "'title",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "'title",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(seconds: 1),
        audioDownloadSpeed: 1,
        videoUploadDate: DateTime.now(),
        audioDuration: const Duration(seconds: 1),
        isAudioMusicQuality: true,
        audioPlaySpeed: 1.0,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'audioFileName',
        audioFileSize: 1,
      );

      Audio avecPercentTitle = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: "%avec percent title",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "%avec percent title",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(seconds: 1),
        audioDownloadSpeed: 1,
        videoUploadDate: DateTime.now(),
        audioDuration: const Duration(seconds: 1),
        isAudioMusicQuality: true,
        audioPlaySpeed: 1.0,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'audioFileName',
        audioFileSize: 1,
      );

      Audio percentTitle = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: "%percent title",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "%percent title",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(seconds: 1),
        audioDownloadSpeed: 1,
        videoUploadDate: DateTime.now(),
        audioDuration: const Duration(seconds: 1),
        isAudioMusicQuality: true,
        audioPlaySpeed: 1.0,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'audioFileName',
        audioFileSize: 1,
      );

      Audio powerTitle = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: "power title",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "power title",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(seconds: 1),
        audioDownloadSpeed: 1,
        videoUploadDate: DateTime.now(),
        audioDuration: const Duration(seconds: 1),
        isAudioMusicQuality: true,
        audioPlaySpeed: 1.0,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'audioFileName',
        audioFileSize: 1,
      );

      Audio amenTitle = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: "#'amen title",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "#'amen title",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(seconds: 1),
        audioDownloadSpeed: 1,
        videoUploadDate: DateTime.now(),
        audioDuration: const Duration(seconds: 1),
        isAudioMusicQuality: true,
        audioPlaySpeed: 1.0,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'audioFileName',
        audioFileSize: 1,
      );

      Audio epicure = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: "ÉPICURE - La mort n'est rien 📏",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "ÉPICURE - La mort n'est rien",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(seconds: 1),
        audioDownloadSpeed: 1,
        videoUploadDate: DateTime.now(),
        audioDuration: const Duration(seconds: 1),
        isAudioMusicQuality: true,
        audioPlaySpeed: 1.0,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'audioFileName',
        audioFileSize: 1,
      );

      Audio ninetyFiveTitle = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: "%95 title",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "%95 title",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(seconds: 1),
        audioDownloadSpeed: 1,
        videoUploadDate: DateTime.now(),
        audioDuration: const Duration(seconds: 1),
        isAudioMusicQuality: true,
        audioPlaySpeed: 1.0,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'audioFileName',
        audioFileSize: 1,
      );

      Audio ninetyThreeTitle = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: "93 title",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "93 title",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(seconds: 1),
        audioDownloadSpeed: 1,
        videoUploadDate: DateTime.now(),
        audioDuration: const Duration(seconds: 1),
        isAudioMusicQuality: true,
        audioPlaySpeed: 1.0,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'audioFileName',
        audioFileSize: 1,
      );

      Audio ninetyFourTitle = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: "#94 title",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "#94 title",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(seconds: 1),
        audioDownloadSpeed: 1,
        videoUploadDate: DateTime.now(),
        audioDuration: const Duration(seconds: 1),
        isAudioMusicQuality: true,
        audioPlaySpeed: 1.0,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'audioFileName',
        audioFileSize: 1,
      );

      Audio echapper = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: "Échapper à l'illusion de l'esprit",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "Échapper à l'illusion de l'esprit",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(seconds: 1),
        audioDownloadSpeed: 1,
        videoUploadDate: DateTime.now(),
        audioDuration: const Duration(seconds: 1),
        isAudioMusicQuality: true,
        audioPlaySpeed: 1.0,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'audioFileName',
        audioFileSize: 1,
      );

      Audio evidentTitle = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: "évident title",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "évident title",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(seconds: 1),
        audioDownloadSpeed: 1,
        videoUploadDate: DateTime.now(),
        audioDuration: const Duration(seconds: 1),
        isAudioMusicQuality: true,
        audioPlaySpeed: 1.0,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'audioFileName',
        audioFileSize: 1,
      );

      Audio aLireTitle = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: "à lire title",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "à lire title",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(seconds: 1),
        audioDownloadSpeed: 1,
        videoUploadDate: DateTime.now(),
        audioDuration: const Duration(seconds: 1),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'audioFileName',
        audioFileSize: 1,
      );

      Audio nineTitle = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: "9 title",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "9 title",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(seconds: 1),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: true,
        isPaused: true,
        audioPausedDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioPositionSeconds: 500,
        audioDownloadSpeed: 1,
        videoUploadDate: DateTime.now(),
        audioDuration: const Duration(seconds: 10000),
        audioFileName: 'audioFileName',
        audioFileSize: 1,
      );

      Audio eightTitle = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: "8 title",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "8 title",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(seconds: 1),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: true,
        isPaused: true,
        audioPausedDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioPositionSeconds: 500,
        audioDownloadSpeed: 1,
        videoUploadDate: DateTime.now(),
        audioDuration: const Duration(seconds: 10000),
        audioFileName: 'audioFileName',
        audioFileSize: 1,
      );

      Audio eventuelTitle = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: "éventuel title",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "éventuel title",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
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
        amenTitle,
        ninetyFourTitle,
        ninetyFiveTitle,
        avecPercentTitle,
        percentTitle,
        title,
        eightTitle,
        nineTitle,
        ninetyThreeTitle,
        powerTitle,
        aLireTitle,
        echapper,
        epicure,
        eventuelTitle,
        evidentTitle,
      ];

      List<Audio?> expectedResultForTitleDesc = [
        evidentTitle,
        eventuelTitle,
        epicure,
        echapper,
        aLireTitle,
        powerTitle,
        ninetyThreeTitle,
        nineTitle,
        eightTitle,
        title,
        percentTitle,
        avecPercentTitle,
        ninetyFiveTitle,
        ninetyFourTitle,
        amenTitle,
      ];

      final List<SortingItem> selectedSortOptionsLstAsc = [
        SortingItem(
          sortingOption: SortingOption.validAudioTitle,
          isAscending: true,
        ),
      ];

      List<Audio> sortedByTitleAsc =
          audioSortFilterService.sortAudioLstBySortingOptions(
        audioLst: List<Audio>.from(audioLst), // copy list
        selectedSortOptionsLst: selectedSortOptionsLstAsc,
      );

      expect(
          sortedByTitleAsc.map((audio) => audio.validVideoTitle).toList(),
          equals(expectedResultForTitleAsc
              .map((audio) => audio!.validVideoTitle)
              .toList()));

      final List<SortingItem> selectedSortOptionsLstDesc = [
        SortingItem(
          sortingOption: SortingOption.validAudioTitle,
          isAscending: false,
        ),
      ];

      List<Audio> sortedByTitleDesc =
          audioSortFilterService.sortAudioLstBySortingOptions(
        audioLst: List<Audio>.from(audioLst), // copy list
        selectedSortOptionsLst: selectedSortOptionsLstDesc,
      );

      expect(
          sortedByTitleDesc.map((audio) => audio.validVideoTitle).toList(),
          equals(expectedResultForTitleDesc
              .map((audio) => audio!.validVideoTitle)
              .toList()));
    });
  });
  group("sort audio lst by multiple SortingOption's", () {
    late AudioSortFilterService audioSortFilterService;

    setUp(() {
      audioSortFilterService = AudioSortFilterService();
    });
    test('sort by duration and title', () {
      final Audio zebra = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Zebra ?',
        compactVideoDescription: '',
        validVideoTitle: 'Zebra',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );
      final Audio apple = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Apple ?',
        compactVideoDescription: '',
        validVideoTitle: 'Apple',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );
      final Audio bananna = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Bananna ?',
        compactVideoDescription: '',
        validVideoTitle: 'Bananna',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 15, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );
      final Audio banannaLonger = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Bananna ?',
        compactVideoDescription: '',
        validVideoTitle: 'Bananna Longer',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 25, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );

      List<Audio> audioList = [
        zebra,
        banannaLonger,
        apple,
        bananna,
      ];

      List<Audio> expectedResultForDurationAscAndTitleAsc = [
        apple,
        zebra,
        bananna,
        banannaLonger,
      ];

      List<Audio> expectedResultForDurationDescAndTitleDesc = [
        banannaLonger,
        bananna,
        zebra,
        apple,
      ];

      final List<SortingItem> selectedSortOptionsLstDurationAscAndTitleAsc = [
        SortingItem(
          sortingOption: SortingOption.audioDuration,
          isAscending: true,
        ),
        SortingItem(
          sortingOption: SortingOption.validAudioTitle,
          isAscending: true,
        ),
      ];

      List<Audio> sortedByTitleAsc =
          audioSortFilterService.sortAudioLstBySortingOptions(
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortOptionsLst: selectedSortOptionsLstDurationAscAndTitleAsc,
      );

      expect(
          sortedByTitleAsc.map((audio) => audio.validVideoTitle).toList(),
          equals(expectedResultForDurationAscAndTitleAsc
              .map((audio) => audio.validVideoTitle)
              .toList()));

      final List<SortingItem> selectedSortOptionsLstDurationDescAndTitleDesc = [
        SortingItem(
          sortingOption: SortingOption.audioDuration,
          isAscending: false,
        ),
        SortingItem(
          sortingOption: SortingOption.validAudioTitle,
          isAscending: false,
        ),
      ];

      List<Audio> sortedByTitleDesc =
          audioSortFilterService.sortAudioLstBySortingOptions(
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortOptionsLst: selectedSortOptionsLstDurationDescAndTitleDesc,
      );

      expect(
          sortedByTitleDesc.map((audio) => audio.validVideoTitle).toList(),
          equals(expectedResultForDurationDescAndTitleDesc
              .map((audio) => audio.validVideoTitle)
              .toList()));
    });
  });
  group('filterAndSortAudioLst by title and description', () {
    late AudioSortFilterService audioSortFilterService;

    setUp(() {
      audioSortFilterService = AudioSortFilterService();
    });

    test('with search word present in in title only', () {
      final Audio zebra1 = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Zebra ?',
        compactVideoDescription: '',
        validVideoTitle: 'Zebra 1',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );
      final Audio apple = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Apple ?',
        compactVideoDescription: '',
        validVideoTitle: 'Apple',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );
      final Audio zebra3 = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Zebra ?',
        compactVideoDescription: '',
        validVideoTitle: 'Zebra 3',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );
      final Audio bananna = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Bananna ?',
        compactVideoDescription: '',
        validVideoTitle: 'Bananna',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );
      final Audio zebra2 = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Zebra ?',
        compactVideoDescription: '',
        validVideoTitle: 'Zebra 2',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );

      List<Audio> audioList = [
        zebra1,
        apple,
        zebra3,
        bananna,
        zebra2,
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

      final List<SortingItem> selectedSortOptionsLstAsc = [
        SortingItem(
          sortingOption: SortingOption.validAudioTitle,
          isAscending: true,
        ),
      ];

      List<Audio> sortedByTitleAsc =
          audioSortFilterService.sortAudioLstBySortingOptions(
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortOptionsLst: selectedSortOptionsLstAsc,
      );

      expect(
          sortedByTitleAsc.map((audio) => audio.validVideoTitle).toList(),
          equals(expectedResultForTitleAsc
              .map((audio) => audio.validVideoTitle)
              .toList()));

      final List<SortingItem> selectedSortOptionsLstDesc = [
        SortingItem(
          sortingOption: SortingOption.validAudioTitle,
          isAscending: false,
        ),
      ];

      List<Audio> sortedByTitleDesc =
          audioSortFilterService.sortAudioLstBySortingOptions(
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortOptionsLst: selectedSortOptionsLstDesc,
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
        selectedSortOptionLst: selectedSortOptionsLstAsc,
        filterSentenceLst: ['Zeb'],
        sentencesCombination: SentencesCombination.AND,
        searchAsWellInVideoCompactDescription: true,
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
        selectedSortOptionLst: selectedSortOptionsLstDesc,
        filterSentenceLst: ['Zeb'],
        sentencesCombination: SentencesCombination.AND,
        searchAsWellInVideoCompactDescription: true,
      );

      expect(
          filteredAndSortedByTitleDesc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          equals(expectedResultForFilterSortTitleDesc
              .map((audio) => audio.validVideoTitle)
              .toList()));
    });
    test('with search word present in compact description only', () {
      final Audio zebra1 = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Zebra ?',
        compactVideoDescription: 'Julien Bam',
        validVideoTitle: 'Zebra 1',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );
      final Audio apple = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Apple ?',
        compactVideoDescription: 'description',
        validVideoTitle: 'Apple',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );
      final Audio zebra3 = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Zebra ?',
        compactVideoDescription: 'Julien Bam',
        validVideoTitle: 'Zebra 3',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );
      final Audio bananna = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Bananna ?',
        compactVideoDescription: '',
        validVideoTitle: 'Bananna',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );
      final Audio zebra2 = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Zebra ?',
        compactVideoDescription: 'Julien Goal',
        validVideoTitle: 'Zebra 2',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );

      List<Audio> audioList = [
        zebra1,
        apple,
        zebra3,
        bananna,
        zebra2,
      ];

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

      final List<SortingItem> selectedSortOptionsLstAsc = [
        SortingItem(
          sortingOption: SortingOption.validAudioTitle,
          isAscending: true,
        ),
      ];

      List<Audio> filteredAndSortedByTitleAsc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortOptionLst: selectedSortOptionsLstAsc,
        filterSentenceLst: ['Julien'],
        sentencesCombination: SentencesCombination.AND,
        searchAsWellInVideoCompactDescription: true,
      );

      expect(
          filteredAndSortedByTitleAsc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          equals(expectedResultForFilterSortTitleAsc
              .map((audio) => audio.validVideoTitle)
              .toList()));

      final List<SortingItem> selectedSortOptionsLstDesc = [
        SortingItem(
          sortingOption: SortingOption.validAudioTitle,
          isAscending: false,
        ),
      ];

      List<Audio> filteredAndSortedByTitleDesc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortOptionLst: selectedSortOptionsLstDesc,
        sentencesCombination: SentencesCombination.AND,
        filterSentenceLst: ['Julien'],
        searchAsWellInVideoCompactDescription: true,
      );

      expect(
          filteredAndSortedByTitleDesc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          equals(expectedResultForFilterSortTitleDesc
              .map((audio) => audio.validVideoTitle)
              .toList()));
    });
    test('with search word in title and in compact description', () {
      final Audio zebra1 = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Zebra ?',
        compactVideoDescription: 'Julien Bam',
        validVideoTitle: 'Zebra 1',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );
      final Audio apple = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Apple ?',
        compactVideoDescription: 'description',
        validVideoTitle: 'Apple Julien',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );
      final Audio zebra3 = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Zebra ?',
        compactVideoDescription: 'Julien Bam',
        validVideoTitle: 'Zebra 3',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );
      final Audio bananna = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Bananna ?',
        compactVideoDescription: '',
        validVideoTitle: 'Bananna',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );
      final Audio zebra2 = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Zebra ?',
        compactVideoDescription: 'Julien Goal',
        validVideoTitle: 'Zebra 2',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );

      List<Audio> audioList = [
        zebra1,
        apple,
        zebra3,
        bananna,
        zebra2,
      ];

      List<Audio> expectedResultForFilterSortTitleAsc = [
        apple,
        zebra1,
        zebra2,
        zebra3,
      ];

      List<Audio> expectedResultForFilterSortTitleDesc = [
        zebra3,
        zebra2,
        zebra1,
        apple,
      ];

      final List<SortingItem> selectedSortOptionsLstAsc = [
        SortingItem(
          sortingOption: SortingOption.validAudioTitle,
          isAscending: true,
        ),
      ];

      List<Audio> filteredAndSortedByTitleAsc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortOptionLst: selectedSortOptionsLstAsc,
        filterSentenceLst: ['Julien'],
        sentencesCombination: SentencesCombination.AND,
        searchAsWellInVideoCompactDescription: true,
      );

      expect(
          filteredAndSortedByTitleAsc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          equals(expectedResultForFilterSortTitleAsc
              .map((audio) => audio.validVideoTitle)
              .toList()));

      final List<SortingItem> selectedSortOptionsLstDesc = [
        SortingItem(
          sortingOption: SortingOption.validAudioTitle,
          isAscending: false,
        ),
      ];

      List<Audio> filteredAndSortedByTitleDesc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortOptionLst: selectedSortOptionsLstDesc,
        filterSentenceLst: ['Julien'],
        sentencesCombination: SentencesCombination.AND,
        searchAsWellInVideoCompactDescription: true,
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
  group('filterAndSortAudioLst by title only', () {
    late AudioSortFilterService audioSortFilterService;

    setUp(() {
      audioSortFilterService = AudioSortFilterService();
    });

    test('with search word in title and in compact description', () {
      final Audio zebra1 = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Zebra ?',
        compactVideoDescription: 'Julien Bam',
        validVideoTitle: 'Zebra 1 Julien',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );
      final Audio apple = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Apple ?',
        compactVideoDescription: 'description',
        validVideoTitle: 'Apple Julien',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );
      final Audio zebra3 = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Zebra ?',
        compactVideoDescription: 'Julien Bam',
        validVideoTitle: 'Zebra 3',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );
      final Audio bananna = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Bananna ?',
        compactVideoDescription: '',
        validVideoTitle: 'Bananna',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );
      final Audio zebra2 = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Zebra ?',
        compactVideoDescription: 'Julien Goal',
        validVideoTitle: 'Zebra 2',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );

      List<Audio> audioList = [
        zebra1,
        apple,
        zebra3,
        bananna,
        zebra2,
      ];

      List<Audio> expectedResultForFilterSortTitleAsc = [
        apple,
        zebra1,
      ];

      List<Audio> expectedResultForFilterSortTitleDesc = [
        zebra1,
        apple,
      ];

      final List<SortingItem> selectedSortOptionsLstAsc = [
        SortingItem(
          sortingOption: SortingOption.validAudioTitle,
          isAscending: true,
        ),
      ];

      List<Audio> filteredAndSortedByTitleAsc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortOptionLst: selectedSortOptionsLstAsc,
        filterSentenceLst: ['Julien'],
        sentencesCombination: SentencesCombination.AND,
        searchAsWellInVideoCompactDescription: false,
      );

      expect(
          filteredAndSortedByTitleAsc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          equals(expectedResultForFilterSortTitleAsc
              .map((audio) => audio.validVideoTitle)
              .toList()));

      final List<SortingItem> selectedSortOptionsLstDesc = [
        SortingItem(
          sortingOption: SortingOption.validAudioTitle,
          isAscending: false,
        ),
      ];

      List<Audio> filteredAndSortedByTitleDesc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortOptionLst: selectedSortOptionsLstDesc,
        filterSentenceLst: ['Julien'],
        sentencesCombination: SentencesCombination.AND,
        searchAsWellInVideoCompactDescription: false,
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
  group("filter sort audio by multiple filter and multiple SortingOption's",
      () {
    late AudioSortFilterService audioSortFilterService;
    late PlaylistListVM playlistListVM;

    setUp(() {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_sort_filter_service_test_data",
        destinationRootPath: kDownloadAppTestDirWindows,
      );

      SettingsDataService settingsDataService =
          SettingsDataService(isTest: true);

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      settingsDataService.loadSettingsFromFile(
          jsonPathFileName:
              "$kDownloadAppTestDirWindows${path.separator}$kSettingsFileName");

      // Since we have to use a mock AudioDownloadVM to add the
      // youtube playlist, we can not use app.main() to start the
      // app because app.main() uses the real AudioDownloadVM
      // and we don't want to make the main.dart file dependent
      // of a mock class. So we have to start the app by hand.

      WarningMessageVM warningMessageVM = WarningMessageVM();
      // MockAudioDownloadVM mockAudioDownloadVM = MockAudioDownloadVM(
      //   warningMessageVM: warningMessageVM,
      //   isTest: true,
      // );
      // mockAudioDownloadVM.youtubePlaylistTitle = youtubeNewPlaylistTitle;

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        isTest: true,
      );

      // audioDownloadVM.youtubeExplode = mockYoutubeExplode;

      playlistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // expandablePlaylistListVM to know which playlists are
      // selected and which are not
      playlistListVM.getUpToDateSelectablePlaylists();

      audioSortFilterService = AudioSortFilterService();
    });
    test(
        'filter by one word in audio title and sort by download date descending and duration ascending',
        () {
      List<Audio> audioList =
          playlistListVM.getSelectedPlaylistPlayableAudios();

      List<String>
          expectedResultForFilterByWordAndSortByDownloadDateDescAndDurationAsc =
          [
        "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
        "La surpopulation mondiale par Jancovici et Barrau",
        "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
      ];

      final List<SortingItem>
          selectedSortOptionsLstDownloadDateDescAndDurationAsc = [
        SortingItem(
          sortingOption: SortingOption.audioDownloadDateTime,
          isAscending: false,
        ),
        SortingItem(
          sortingOption: SortingOption.audioDuration,
          isAscending: true,
        ),
      ];

      List<Audio> filteredByWordAndSortedByDownloadDateDescAndDurationAsc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortOptionLst:
            selectedSortOptionsLstDownloadDateDescAndDurationAsc,
        filterSentenceLst: ['Jancovici'],
        sentencesCombination: SentencesCombination.AND,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
      );

      expect(
          filteredByWordAndSortedByDownloadDateDescAndDurationAsc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          expectedResultForFilterByWordAndSortByDownloadDateDescAndDurationAsc);

      final List<SortingItem>
          selectedSortOptionsLstDownloadDateAscAndDurationDesc = [
        SortingItem(
          sortingOption: SortingOption.audioDownloadDateTime,
          isAscending: true,
        ),
        SortingItem(
          sortingOption: SortingOption.audioDuration,
          isAscending: false,
        ),
      ];

      List<Audio> filteredByWordAndSortedByDownloadDateAscAndDurationDesc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortOptionLst:
            selectedSortOptionsLstDownloadDateAscAndDurationDesc,
        filterSentenceLst: ['Janco'],
        sentencesCombination: SentencesCombination.AND,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
      );

      List<String>
          expectedResultForFilterByWordAndSortByDownloadDateAscAndDurationDesc =
          [
        "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        "La surpopulation mondiale par Jancovici et Barrau",
        "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
      ];

      expect(
          filteredByWordAndSortedByDownloadDateAscAndDurationDesc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          expectedResultForFilterByWordAndSortByDownloadDateAscAndDurationDesc);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );
    });
    test(
        'filter by multiple words in audio title or in audio compact description and sort by download date descending and duration ascending',
        () {
      List<Audio> audioList =
          playlistListVM.getSelectedPlaylistPlayableAudios();

      List<String>
          expectedResultForFilterByWordAndSortByDownloadDateDescAndDurationAsc =
          [
        "La surpopulation mondiale par Jancovici et Barrau",
        "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
      ];

      final List<SortingItem>
          selectedSortOptionsLstDownloadDateDescAndDurationAsc = [
        SortingItem(
          sortingOption: SortingOption.audioDownloadDateTime,
          isAscending: false,
        ),
        SortingItem(
          sortingOption: SortingOption.audioDuration,
          isAscending: true,
        ),
      ];

      List<Audio> filteredByWordAndSortedByDownloadDateDescAndDurationAsc =
          audioSortFilterService.filterAndSortAudioLst(
              audioLst: List<Audio>.from(audioList), // copy list
              selectedSortOptionLst:
                  selectedSortOptionsLstDownloadDateDescAndDurationAsc,
              filterSentenceLst: ['Éthique et tac', 'Jancovici'],
              sentencesCombination: SentencesCombination.AND,
              ignoreCase: true,
              searchAsWellInVideoCompactDescription: true);

      expect(
          filteredByWordAndSortedByDownloadDateDescAndDurationAsc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          expectedResultForFilterByWordAndSortByDownloadDateDescAndDurationAsc);

      final List<SortingItem>
          selectedSortOptionsLstDownloadDateAscAndDurationDesc = [
        SortingItem(
          sortingOption: SortingOption.audioDownloadDateTime,
          isAscending: true,
        ),
        SortingItem(
          sortingOption: SortingOption.audioDuration,
          isAscending: false,
        ),
      ];

      List<Audio> filteredByWordAndSortedByDownloadDateAscAndDurationDesc =
          audioSortFilterService.filterAndSortAudioLst(
              audioLst: List<Audio>.from(audioList), // copy list
              selectedSortOptionLst:
                  selectedSortOptionsLstDownloadDateAscAndDurationDesc,
              filterSentenceLst: ['Éthique et tac', 'Jancovici'],
              sentencesCombination: SentencesCombination.AND,
              ignoreCase: true,
              searchAsWellInVideoCompactDescription: true);

      List<String>
          expectedResultForFilterByWordAndSortByDownloadDateAscAndDurationDesc =
          [
        "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        "La surpopulation mondiale par Jancovici et Barrau",
      ];

      expect(
          filteredByWordAndSortedByDownloadDateAscAndDurationDesc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          expectedResultForFilterByWordAndSortByDownloadDateAscAndDurationDesc);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );
    });
    test(
        'filter by one sentence present in audio compact description only with searchInVideoCompactDescription = false and sort by download date descending and duration ascending. Result list will be empty',
        () {
      List<Audio> audioList =
          playlistListVM.getSelectedPlaylistPlayableAudios();

      final List<SortingItem>
          selectedSortOptionsLstDownloadDateDescAndDurationAsc = [
        SortingItem(
          sortingOption: SortingOption.audioDownloadDateTime,
          isAscending: false,
        ),
        SortingItem(
          sortingOption: SortingOption.audioDuration,
          isAscending: true,
        ),
      ];

      List<Audio> filteredByWordAndSortedByDownloadDateDescAndDurationAsc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortOptionLst:
            selectedSortOptionsLstDownloadDateDescAndDurationAsc,
        filterSentenceLst: ['Éthique et tac'],
        ignoreCase: true,
        sentencesCombination: SentencesCombination.OR,
      );

      expect(
          filteredByWordAndSortedByDownloadDateDescAndDurationAsc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          []);

      final List<SortingItem>
          selectedSortOptionsLstDownloadDateAscAndDurationDesc = [
        SortingItem(
          sortingOption: SortingOption.audioDownloadDateTime,
          isAscending: true,
        ),
        SortingItem(
          sortingOption: SortingOption.audioDuration,
          isAscending: false,
        ),
      ];

      List<Audio> filteredByWordAndSortedByDownloadDateAscAndDurationDesc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortOptionLst:
            selectedSortOptionsLstDownloadDateAscAndDurationDesc,
        filterSentenceLst: ['Éthique et tac'],
        ignoreCase: true,
        sentencesCombination: SentencesCombination.OR,
      );

      expect(
          filteredByWordAndSortedByDownloadDateAscAndDurationDesc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          []);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );
    });
    test(
        "filter in 'and' mode by multiple sentences present in audio title and compact description only with searchInVideoCompactDescription = false and sort by download date descending and duration ascending",
        () {
      List<Audio> audioList =
          playlistListVM.getSelectedPlaylistPlayableAudios();

      final List<SortingItem>
          selectedSortOptionsLstDownloadDateDescAndDurationAsc = [
        SortingItem(
          sortingOption: SortingOption.audioDownloadDateTime,
          isAscending: false,
        ),
        SortingItem(
          sortingOption: SortingOption.audioDuration,
          isAscending: true,
        ),
      ];

      List<Audio> filteredByWordAndSortedByDownloadDateDescAndDurationAsc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortOptionLst:
            selectedSortOptionsLstDownloadDateDescAndDurationAsc,
        filterSentenceLst: [
          'Janco',
          'Éthique et tac',
        ],
        sentencesCombination: SentencesCombination.AND,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: false,
      );

      expect(
          filteredByWordAndSortedByDownloadDateDescAndDurationAsc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          []);

      final List<SortingItem>
          selectedSortOptionsLstDownloadDateAscAndDurationDesc = [
        SortingItem(
          sortingOption: SortingOption.audioDownloadDateTime,
          isAscending: true,
        ),
        SortingItem(
          sortingOption: SortingOption.audioDuration,
          isAscending: false,
        ),
      ];

      List<Audio> filteredByWordAndSortedByDownloadDateAscAndDurationDesc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortOptionLst:
            selectedSortOptionsLstDownloadDateAscAndDurationDesc,
        filterSentenceLst: ['Éthique et tac'],
        sentencesCombination: SentencesCombination.AND,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: false,
      );

      expect(
          filteredByWordAndSortedByDownloadDateAscAndDurationDesc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          []);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );
    });
    test(
        "filter in 'and' mode by multiple sentences present in audio title and compact description only with searchInVideoCompactDescription = true and sort by download date descending and duration ascending",
        () {
      List<Audio> audioList =
          playlistListVM.getSelectedPlaylistPlayableAudios();

      final List<SortingItem>
          selectedSortOptionsLstDownloadDateDescAndDurationAsc = [
        SortingItem(
          sortingOption: SortingOption.audioDownloadDateTime,
          isAscending: false,
        ),
        SortingItem(
          sortingOption: SortingOption.audioDuration,
          isAscending: true,
        ),
      ];

      List<Audio> filteredByWordAndSortedByDownloadDateDescAndDurationAsc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortOptionLst:
            selectedSortOptionsLstDownloadDateDescAndDurationAsc,
        filterSentenceLst: [
          'Janco',
          'Éthique et tac',
        ],
        sentencesCombination: SentencesCombination.AND,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
      );

      expect(
          filteredByWordAndSortedByDownloadDateDescAndDurationAsc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          [
            'La surpopulation mondiale par Jancovici et Barrau',
            'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau'
          ]);

      final List<SortingItem>
          selectedSortOptionsLstDownloadDateAscAndDurationDesc = [
        SortingItem(
          sortingOption: SortingOption.audioDownloadDateTime,
          isAscending: true,
        ),
        SortingItem(
          sortingOption: SortingOption.audioDuration,
          isAscending: false,
        ),
      ];

      List<Audio> filteredByWordAndSortedByDownloadDateAscAndDurationDesc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortOptionLst:
            selectedSortOptionsLstDownloadDateAscAndDurationDesc,
        filterSentenceLst: ['Éthique et tac', 'Janco'],
        sentencesCombination: SentencesCombination.AND,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
      );

      expect(
          filteredByWordAndSortedByDownloadDateAscAndDurationDesc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          [
            'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau',
            'La surpopulation mondiale par Jancovici et Barrau'
          ]);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );
    });
    test(
        "filter in 'or' mode by multiple sentences present in audio title and compact description only with searchInVideoCompactDescription = false and sort by download date descending and duration ascending",
        () {
      List<Audio> audioList =
          playlistListVM.getSelectedPlaylistPlayableAudios();

      final List<SortingItem>
          selectedSortOptionsLstDownloadDateDescAndDurationAsc = [
        SortingItem(
          sortingOption: SortingOption.audioDownloadDateTime,
          isAscending: false,
        ),
        SortingItem(
          sortingOption: SortingOption.audioDuration,
          isAscending: true,
        ),
      ];

      List<Audio> filteredByWordAndSortedByDownloadDateDescAndDurationAsc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortOptionLst:
            selectedSortOptionsLstDownloadDateDescAndDurationAsc,
        filterSentenceLst: [
          'Janco',
          'Roche',
        ],
        sentencesCombination: SentencesCombination.OR,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: false,
      );

      expect(
          filteredByWordAndSortedByDownloadDateDescAndDurationAsc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          [
            "Jancovici m\'explique l’importance des ordres de grandeur face au changement climatique",
            'La surpopulation mondiale par Jancovici et Barrau',
            'La résilience insulaire par Fiona Roche',
            'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau'
          ]);

      final List<SortingItem>
          selectedSortOptionsLstDownloadDateAscAndDurationDesc = [
        SortingItem(
          sortingOption: SortingOption.audioDownloadDateTime,
          isAscending: true,
        ),
        SortingItem(
          sortingOption: SortingOption.audioDuration,
          isAscending: false,
        ),
      ];

      List<Audio> filteredByWordAndSortedByDownloadDateAscAndDurationDesc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortOptionLst:
            selectedSortOptionsLstDownloadDateAscAndDurationDesc,
        filterSentenceLst: [
          'Janco',
          'Roche',
        ],
        sentencesCombination: SentencesCombination.OR,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: false,
      );

      expect(
          filteredByWordAndSortedByDownloadDateAscAndDurationDesc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          [
            'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau',
            'La résilience insulaire par Fiona Roche',
            'La surpopulation mondiale par Jancovici et Barrau',
            "Jancovici m\'explique l’importance des ordres de grandeur face au changement climatique",
          ]);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );
    });
    test(
        "filter in 'or' mode by multiple sentences present in audio title and compact description only with searchInVideoCompactDescription = true and sort by download date descending and duration ascending",
        () {
      List<Audio> audioList =
          playlistListVM.getSelectedPlaylistPlayableAudios();

      final List<SortingItem>
          selectedSortOptionsLstDownloadDateDescAndDurationAsc = [
        SortingItem(
          sortingOption: SortingOption.audioDownloadDateTime,
          isAscending: false,
        ),
        SortingItem(
          sortingOption: SortingOption.audioDuration,
          isAscending: true,
        ),
      ];

      List<Audio> filteredByWordAndSortedByDownloadDateDescAndDurationAsc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortOptionLst:
            selectedSortOptionsLstDownloadDateDescAndDurationAsc,
        filterSentenceLst: [
          'Janco',
          'Éthique et tac',
        ],
        sentencesCombination: SentencesCombination.OR,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
      );

      expect(
          filteredByWordAndSortedByDownloadDateDescAndDurationAsc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          [
            "Jancovici m\'explique l’importance des ordres de grandeur face au changement climatique",
            'La surpopulation mondiale par Jancovici et Barrau',
            'La résilience insulaire par Fiona Roche',
            'Les besoins artificiels par R.Keucheyan',
            'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau',
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)"
          ]);

      final List<SortingItem>
          selectedSortOptionsLstDownloadDateAscAndDurationDesc = [
        SortingItem(
          sortingOption: SortingOption.audioDownloadDateTime,
          isAscending: true,
        ),
        SortingItem(
          sortingOption: SortingOption.audioDuration,
          isAscending: false,
        ),
      ];

      List<Audio> filteredByWordAndSortedByDownloadDateAscAndDurationDesc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortOptionLst:
            selectedSortOptionsLstDownloadDateAscAndDurationDesc,
        filterSentenceLst: ['Éthique et tac', 'Janco'],
        sentencesCombination: SentencesCombination.OR,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
      );

      expect(
          filteredByWordAndSortedByDownloadDateAscAndDurationDesc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          [
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
            'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau',
            'Les besoins artificiels par R.Keucheyan',
            'La résilience insulaire par Fiona Roche',
            'La surpopulation mondiale par Jancovici et Barrau',
            "Jancovici m\'explique l’importance des ordres de grandeur face au changement climatique",
          ]);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );
    });
  });
  group('bug fix', () {
    late AudioSortFilterService audioSortFilterService;
    late PlaylistListVM playlistListVM;

    setUp(() {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_sort_filter_service_test_data",
        destinationRootPath: kDownloadAppTestDirWindows,
      );

      SettingsDataService settingsDataService =
          SettingsDataService(isTest: true);

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      settingsDataService.loadSettingsFromFile(
          jsonPathFileName:
              "$kDownloadAppTestDirWindows${path.separator}$kSettingsFileName");

      // Since we have to use a mock AudioDownloadVM to add the
      // youtube playlist, we can not use app.main() to start the
      // app because app.main() uses the real AudioDownloadVM
      // and we don't want to make the main.dart file dependent
      // of a mock class. So we have to start the app by hand.

      WarningMessageVM warningMessageVM = WarningMessageVM();
      // MockAudioDownloadVM mockAudioDownloadVM = MockAudioDownloadVM(
      //   warningMessageVM: warningMessageVM,
      //   isTest: true,
      // );
      // mockAudioDownloadVM.youtubePlaylistTitle = youtubeNewPlaylistTitle;

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        isTest: true,
      );

      // audioDownloadVM.youtubeExplode = mockYoutubeExplode;

      playlistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // expandablePlaylistListVM to know which playlists are
      // selected and which are not
      playlistListVM.getUpToDateSelectablePlaylists();

      audioSortFilterService = AudioSortFilterService();
    });
    test(
        'filter by no word in audio title or video compact description and sort by download date descending',
        () {
      List<Audio> audioList =
          playlistListVM.getSelectedPlaylistPlayableAudios();

      List<String>
          expectedResultForFilterByWordAndSortByDownloadDateDescAndDurationAsc =
          [
        "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
        'La surpopulation mondiale par Jancovici et Barrau',
        'La résilience insulaire par Fiona Roche',
        'Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik',
        'Les besoins artificiels par R.Keucheyan',
        'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau',
        '3 fois où un économiste m\'a ouvert les yeux (Giraud, Lefournier, Porcher)',
      ];

      final List<SortingItem>
          selectedSortOptionsLstDownloadDateDescAndDurationAsc = [
        SortingItem(
          sortingOption: SortingOption.audioDownloadDateTime,
          isAscending: false,
        ),
      ];

      List<Audio> filteredByWordAndSortedByDownloadDateDescAndDurationAsc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortOptionLst:
            selectedSortOptionsLstDownloadDateDescAndDurationAsc,
        filterSentenceLst: [],
        sentencesCombination: SentencesCombination.AND,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
      );

      expect(
          filteredByWordAndSortedByDownloadDateDescAndDurationAsc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          expectedResultForFilterByWordAndSortByDownloadDateDescAndDurationAsc);

      final List<SortingItem>
          selectedSortOptionsLstDownloadDateAscAndDurationDesc = [
        SortingItem(
          sortingOption: SortingOption.audioDownloadDateTime,
          isAscending: true,
        ),
        SortingItem(
          sortingOption: SortingOption.audioDuration,
          isAscending: false,
        ),
      ];

      List<Audio> filteredByWordAndSortedByDownloadDateAscAndDurationDesc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortOptionLst:
            selectedSortOptionsLstDownloadDateAscAndDurationDesc,
        filterSentenceLst: ['Janco'],
        sentencesCombination: SentencesCombination.AND,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
      );

      List<String>
          expectedResultForFilterByWordAndSortByDownloadDateAscAndDurationDesc =
          [
        "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        "La surpopulation mondiale par Jancovici et Barrau",
        "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
      ];

      expect(
          filteredByWordAndSortedByDownloadDateAscAndDurationDesc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          expectedResultForFilterByWordAndSortByDownloadDateAscAndDurationDesc);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );
    });
  });
}
