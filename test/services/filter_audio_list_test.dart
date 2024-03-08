import 'package:audio_learn/constants.dart';
import 'package:audio_learn/models/audio.dart';
import 'package:flutter_test/flutter_test.dart';

enum SentencesCombination { AND, OR }

// class Audio {
//   String validVideoTitle;
//   String compactVideoDescription;

//   Audio(
//     this.validVideoTitle,
//     this.compactVideoDescription,
//   );

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;

//     return other is Audio && other.validVideoTitle == validVideoTitle;
//   }

//   @override
//   String toString() {
//     return validVideoTitle;
//   }
// }

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
    validVideoTitle: 'Intelligence Artificielle: quelle menace ou opportunité en 2024 ?',
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
    validVideoTitle: 'Intelligence humaine ou artificielle, quelles différences ?',
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

  group('ignoring case, filter audio list on validVideoTitle only test', () {
    test('filter by <tendance crypto> AND <en 2024>', () {
      List<Audio> expectedFilteredBooks = [
        audioOne,
        audioTwo,
      ];

      List<Audio> filteredBooks = filter(
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

      List<Audio> filteredBooks = filter(
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

      List<Audio> filteredBooks = filter(
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

      List<Audio> filteredBooks = filter(
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

      List<Audio> filteredBooks = filter(
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

      List<Audio> filteredBooks = filter(
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

      List<Audio> filteredBooks = filter(
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

      List<Audio> filteredBooks = filter(
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

      List<Audio> filteredBooks = filter(
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
  group('not ignoring case, filter audio list on validVideoTitle only test',
      () {
    test('filter by <tendance crypto> AND <en 2024>', () {
      List<Audio> expectedFilteredBooks = [
        audioOne,
      ];

      List<Audio> filteredBooks = filter(
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

      List<Audio> filteredBooks = filter(
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

      List<Audio> filteredBooks = filter(
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

      List<Audio> filteredBooks = filter(
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

      List<Audio> filteredBooks = filter(
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

      List<Audio> filteredBooks = filter(
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

      List<Audio> filteredBooks = filter(
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

      List<Audio> filteredBooks = filter(
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

      List<Audio> filteredBooks = filter(
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
      'ignoring case, filter audio list on validVideoTitle or compactVideoDescription test',
      () {
    test('filter by <investir en 2024> AND <éthique et tac>', () {
      List<Audio> expectedFilteredBooks = [];

      List<Audio> filteredBooks = filter(
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

      List<Audio> filteredBooks = filter(
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

      List<Audio> filteredBooks = filter(
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

      List<Audio> filteredBooks = filter(
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
      'not ignoring case, filter audio list on validVideoTitle or compactVideoDescription test',
      () {
    test('filter by <investir en 2024> AND <éthique et tac>', () {
      List<Audio> expectedFilteredBooks = [];

      List<Audio> filteredBooks = filter(
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

      List<Audio> filteredBooks = filter(
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

      List<Audio> filteredBooks = filter(
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

      List<Audio> filteredBooks = filter(
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

      List<Audio> filteredBooks = filter(
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
}

List<Audio> filter({
  required List<Audio> audioLst,
  required List<String> filterSentenceLst,
  required SentencesCombination sentencesCombination,
  required bool ignoreCase,
  required bool searchAsWellInVideoCompactDescription,
}) {
  List<Audio> filteredAudios = [];
  for (Audio audio in audioLst) {
    bool isAudioFiltered = false;
    for (String filterSentence in filterSentenceLst) {
      if (searchAsWellInVideoCompactDescription) {
        // we need to search in the valid video title as well as in the
        // compact video description
        String? filterSentenceInLowerCase;
        if (ignoreCase) {
          // computing the filter sentence in lower case makes
          // sense when we are analysing the two fields in order
          // to avoid computing twice the same thing
          filterSentenceInLowerCase = filterSentence.toLowerCase();
        }
        if (ignoreCase
            ? audio.validVideoTitle
                    .toLowerCase()
                    .contains(filterSentenceInLowerCase!) ||
                audio.compactVideoDescription
                    .toLowerCase()
                    .contains(filterSentenceInLowerCase)
            : audio.validVideoTitle.contains(filterSentence) ||
                audio.compactVideoDescription.contains(filterSentence)) {
          isAudioFiltered = true;
          if (sentencesCombination == SentencesCombination.OR) {
            break;
          }
        } else {
          if (sentencesCombination == SentencesCombination.AND) {
            isAudioFiltered = false;
            break;
          }
        }
      } else {
        // we need to search in the valid video title only
        if (ignoreCase
            ? audio.validVideoTitle
                .toLowerCase()
                .contains(filterSentence.toLowerCase())
            : audio.validVideoTitle.contains(filterSentence)) {
          isAudioFiltered = true;
          if (sentencesCombination == SentencesCombination.OR) {
            break;
          }
        } else {
          if (sentencesCombination == SentencesCombination.AND) {
            isAudioFiltered = false;
            break;
          }
        }
      }
    }
    if (isAudioFiltered) {
      filteredAudios.add(audio);
    }
  }

  return filteredAudios;
}
