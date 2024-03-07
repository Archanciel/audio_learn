import 'package:flutter_test/flutter_test.dart';

enum FilterType { AND, OR }

class Audio {
  String validVideoTitle;
  String compactVideoDescription;

  Audio(
    this.validVideoTitle,
    this.compactVideoDescription,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Audio && other.validVideoTitle == validVideoTitle;
  }

  @override
  String toString() {
    return validVideoTitle;
  }
}

void main() {
  Audio bookOne = Audio(
    'Sur quelle tendance crypto investir en 2024 ?',
    'On vous propose de découvrir les tendances crypto en progression en 2024. Découvrez lesquelles sont les plus prometteuses et lesquelles sont à éviter.',
  );
  Audio bookTwo = Audio(
    'Tendance crypto en accélération en 2024',
    'Éthique et tac vous propose de découvrir les tendances crypto en progression en 2024. Découvrez lesquelles sont les plus prometteuses et lesquelles sont à éviter.',
  );
  Audio bookThree = Audio(
    'Intelligence Artificielle: quelle menace ou opportunité en 2024 ?',
    "Se dirige-t-on vers une intelligence artificielle qui pourrait menacer l’humanité ou au contraire, vers une opportunité pour l’humanité ? Découvrez les réponses à ces questions dans ce podcast.",
  );
  Audio bookFour = Audio(
    'Intelligence humaine ou artificielle, quelles différences ?',
    "Sur le plan philosophique, quelles différences entre l’intelligence humaine et l’intelligence artificielle ? Découvrez les réponses à ces questions dans ce podcast.",
  );
  List<Audio> books = [
    bookOne,
    bookTwo,
    bookThree,
    bookFour,
  ];

  group('ignoring case, filter audio list on validVideoTitle only test', () {
    test('filter by <tendance crypto> AND <en 2024>', () {
      List<Audio> expectedFilteredBooks = [
        bookOne,
        bookTwo,
      ];

      List<Audio> filteredBooks = filter(
          audiosLst: books,
          filterSentences: [
            'tendance crypto',
            'en 2024',
          ],
          filterType: FilterType.AND,
          ignoreCase: true,
          searchInVideoCompactDescription: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <tendance crypto> OR <en 2024>', () {
      List<Audio> expectedFilteredBooks = [
        bookOne,
        bookTwo,
        bookThree,
      ];

      List<Audio> filteredBooks = filter(
          audiosLst: books,
          filterSentences: [
            'tendance crypto',
            'en 2024',
          ],
          filterType: FilterType.OR,
          ignoreCase: true,
          searchInVideoCompactDescription: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <en 2024> AND <tendance crypto>', () {
      List<Audio> expectedFilteredBooks = [
        bookOne,
        bookTwo,
      ];

      List<Audio> filteredBooks = filter(
          audiosLst: books,
          filterSentences: [
            'en 2024',
            'tendance crypto',
          ],
          filterType: FilterType.AND,
          ignoreCase: true,
          searchInVideoCompactDescription: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <en 2024> OR <tendance crypto>', () {
      List<Audio> expectedFilteredBooks = [
        bookOne,
        bookTwo,
        bookThree,
      ];

      List<Audio> filteredBooks = filter(
          audiosLst: books,
          filterSentences: [
            'en 2024',
            'tendance crypto',
          ],
          filterType: FilterType.OR,
          ignoreCase: true,
          searchInVideoCompactDescription: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <quelle> AND <2024>', () {
      List<Audio> expectedFilteredBooks = [
        bookOne,
        bookThree,
      ];

      List<Audio> filteredBooks = filter(
          audiosLst: books,
          filterSentences: [
            'quelle',
            '2024',
          ],
          filterType: FilterType.AND,
          ignoreCase: true,
          searchInVideoCompactDescription: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <quelle> OR <2024>', () {
      List<Audio> expectedFilteredBooks = [
        bookOne,
        bookTwo,
        bookThree,
        bookFour,
      ];

      List<Audio> filteredBooks = filter(
          audiosLst: books,
          filterSentences: [
            'quelle',
            '2024',
          ],
          filterType: FilterType.OR,
          ignoreCase: true,
          searchInVideoCompactDescription: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <2024> AND <quelle>', () {
      List<Audio> expectedFilteredBooks = [
        bookOne,
        bookThree,
      ];

      List<Audio> filteredBooks = filter(
          audiosLst: books,
          filterSentences: [
            '2024',
            'quelle',
          ],
          filterType: FilterType.AND,
          ignoreCase: true,
          searchInVideoCompactDescription: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <2024> OR <quelle>', () {
      List<Audio> expectedFilteredBooks = [
        bookOne,
        bookTwo,
        bookThree,
        bookFour,
      ];

      List<Audio> filteredBooks = filter(
          audiosLst: books,
          filterSentences: [
            '2024',
            'quelle',
          ],
          filterType: FilterType.OR,
          ignoreCase: true,
          searchInVideoCompactDescription: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <intelligence> OR <artificielle>', () {
      List<Audio> expectedFilteredBooks = [
        bookThree,
        bookFour,
      ];

      List<Audio> filteredBooks = filter(
          audiosLst: books,
          filterSentences: [
            'intelligence',
            'artificielle',
          ],
          filterType: FilterType.OR,
          ignoreCase: true,
          searchInVideoCompactDescription: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
  });
  group('not ignoring case, filter audio list on validVideoTitle only test',
      () {
    test('filter by <tendance crypto> AND <en 2024>', () {
      List<Audio> expectedFilteredBooks = [
        bookOne,
      ];

      List<Audio> filteredBooks = filter(
          audiosLst: books,
          filterSentences: [
            'tendance crypto',
            'en 2024',
          ],
          filterType: FilterType.AND,
          ignoreCase: false,
          searchInVideoCompactDescription: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <tendance crypto> OR <en 2024>', () {
      List<Audio> expectedFilteredBooks = [
        bookOne,
        bookTwo,
        bookThree,
      ];

      List<Audio> filteredBooks = filter(
          audiosLst: books,
          filterSentences: [
            'tendance crypto',
            'en 2024',
          ],
          filterType: FilterType.OR,
          ignoreCase: false,
          searchInVideoCompactDescription: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <en 2024> AND <tendance crypto>', () {
      List<Audio> expectedFilteredBooks = [
        bookOne,
      ];

      List<Audio> filteredBooks = filter(
          audiosLst: books,
          filterSentences: [
            'en 2024',
            'tendance crypto',
          ],
          filterType: FilterType.AND,
          ignoreCase: false,
          searchInVideoCompactDescription: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <en 2024> OR <tendance crypto>', () {
      List<Audio> expectedFilteredBooks = [
        bookOne,
        bookTwo,
        bookThree,
      ];

      List<Audio> filteredBooks = filter(
          audiosLst: books,
          filterSentences: [
            'en 2024',
            'tendance crypto',
          ],
          filterType: FilterType.OR,
          ignoreCase: false,
          searchInVideoCompactDescription: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <quelle> AND <2024>', () {
      List<Audio> expectedFilteredBooks = [
        bookOne,
        bookThree,
      ];

      List<Audio> filteredBooks = filter(
          audiosLst: books,
          filterSentences: [
            'quelle',
            '2024',
          ],
          filterType: FilterType.AND,
          ignoreCase: false,
          searchInVideoCompactDescription: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <quelle> OR <2024>', () {
      List<Audio> expectedFilteredBooks = [
        bookOne,
        bookTwo,
        bookThree,
        bookFour,
      ];

      List<Audio> filteredBooks = filter(
          audiosLst: books,
          filterSentences: [
            'quelle',
            '2024',
          ],
          filterType: FilterType.OR,
          ignoreCase: false,
          searchInVideoCompactDescription: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <2024> AND <quelle>', () {
      List<Audio> expectedFilteredBooks = [
        bookOne,
        bookThree,
      ];

      List<Audio> filteredBooks = filter(
          audiosLst: books,
          filterSentences: [
            '2024',
            'quelle',
          ],
          filterType: FilterType.AND,
          ignoreCase: false,
          searchInVideoCompactDescription: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <intelligence> OR <artificielle>', () {
      List<Audio> expectedFilteredBooks = [
        bookFour,
      ];

      List<Audio> filteredBooks = filter(
          audiosLst: books,
          filterSentences: [
            'intelligence',
            'artificielle',
          ],
          filterType: FilterType.OR,
          ignoreCase: false,
          searchInVideoCompactDescription: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <2024> OR <quelle>', () {
      List<Audio> expectedFilteredBooks = [
        bookOne,
        bookTwo,
        bookThree,
        bookFour,
      ];

      List<Audio> filteredBooks = filter(
          audiosLst: books,
          filterSentences: [
            '2024',
            'quelle',
          ],
          filterType: FilterType.OR,
          ignoreCase: false,
          searchInVideoCompactDescription: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
  });
  group(
      'ignoring case, filter audio list on validVideoTitle or compactVideoDescription test',
      () {
    test('filter by <investir en 2024> AND <éthique et tac>', () {
      List<Audio> expectedFilteredBooks = [];

      List<Audio> filteredBooks = filter(
          audiosLst: books,
          filterSentences: [
            'investir en 2024',
            'éthique et tac',
          ],
          filterType: FilterType.AND,
          ignoreCase: true,
          searchInVideoCompactDescription: true);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <accélération> AND <éthique et tac>', () {
      List<Audio> expectedFilteredBooks = [
        bookTwo,
      ];

      List<Audio> filteredBooks = filter(
          audiosLst: books,
          filterSentences: [
            'accélération',
            'éthique et tac',
          ],
          filterType: FilterType.AND,
          ignoreCase: true,
          searchInVideoCompactDescription: true);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <investir en 2024> OR <éthique et tac>', () {
      List<Audio> expectedFilteredBooks = [
        bookOne,
        bookTwo,
      ];

      List<Audio> filteredBooks = filter(
          audiosLst: books,
          filterSentences: [
            'investir en 2024',
            'éthique et tac',
          ],
          filterType: FilterType.OR,
          ignoreCase: true,
          searchInVideoCompactDescription: true);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <tendance crypto> OR <en 2024>', () {
      List<Audio> expectedFilteredBooks = [
        bookOne,
        bookTwo,
        bookThree,
      ];

      List<Audio> filteredBooks = filter(
          audiosLst: books,
          filterSentences: [
            'tendance crypto',
            'en 2024',
          ],
          filterType: FilterType.OR,
          ignoreCase: true,
          searchInVideoCompactDescription: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <en 2024> AND <tendance crypto>', () {
      List<Audio> expectedFilteredBooks = [
        bookOne,
        bookTwo,
      ];

      List<Audio> filteredBooks = filter(
          audiosLst: books,
          filterSentences: [
            'en 2024',
            'tendance crypto',
          ],
          filterType: FilterType.AND,
          ignoreCase: true,
          searchInVideoCompactDescription: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <en 2024> OR <tendance crypto>', () {
      List<Audio> expectedFilteredBooks = [
        bookOne,
        bookTwo,
        bookThree,
      ];

      List<Audio> filteredBooks = filter(
          audiosLst: books,
          filterSentences: [
            'en 2024',
            'tendance crypto',
          ],
          filterType: FilterType.OR,
          ignoreCase: true,
          searchInVideoCompactDescription: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <quelle> AND <2024>', () {
      List<Audio> expectedFilteredBooks = [
        bookOne,
        bookThree,
      ];

      List<Audio> filteredBooks = filter(
          audiosLst: books,
          filterSentences: [
            'quelle',
            '2024',
          ],
          filterType: FilterType.AND,
          ignoreCase: true,
          searchInVideoCompactDescription: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <quelle> OR <2024>', () {
      List<Audio> expectedFilteredBooks = [
        bookOne,
        bookTwo,
        bookThree,
        bookFour,
      ];

      List<Audio> filteredBooks = filter(
          audiosLst: books,
          filterSentences: [
            'quelle',
            '2024',
          ],
          filterType: FilterType.OR,
          ignoreCase: true,
          searchInVideoCompactDescription: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <2024> AND <quelle>', () {
      List<Audio> expectedFilteredBooks = [
        bookOne,
        bookThree,
      ];

      List<Audio> filteredBooks = filter(
          audiosLst: books,
          filterSentences: [
            '2024',
            'quelle',
          ],
          filterType: FilterType.AND,
          ignoreCase: true,
          searchInVideoCompactDescription: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <2024> OR <quelle>', () {
      List<Audio> expectedFilteredBooks = [
        bookOne,
        bookTwo,
        bookThree,
        bookFour,
      ];

      List<Audio> filteredBooks = filter(
          audiosLst: books,
          filterSentences: [
            '2024',
            'quelle',
          ],
          filterType: FilterType.OR,
          ignoreCase: true,
          searchInVideoCompactDescription: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <intelligence> OR <artificielle>', () {
      List<Audio> expectedFilteredBooks = [
        bookThree,
        bookFour,
      ];

      List<Audio> filteredBooks = filter(
          audiosLst: books,
          filterSentences: [
            'intelligence',
            'artificielle',
          ],
          filterType: FilterType.OR,
          ignoreCase: true,
          searchInVideoCompactDescription: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
  });
}

List<Audio> filter({
  required List<Audio> audiosLst,
  required List<String> filterSentences,
  required FilterType filterType,
  required bool ignoreCase,
  required bool searchInVideoCompactDescription,
}) {
  List<Audio> filteredAudios = [];
  for (Audio audio in audiosLst) {
    bool isAudioFiltered = false;
    for (String filterSentence in filterSentences) {
      if (searchInVideoCompactDescription) {
        String lowerCase = filterSentence.toLowerCase();
        if (ignoreCase
            ? audio.validVideoTitle.toLowerCase().contains(lowerCase) ||
                audio.compactVideoDescription.toLowerCase().contains(lowerCase)
            : audio.validVideoTitle.contains(filterSentence) ||
                audio.compactVideoDescription.contains(filterSentence)) {
          isAudioFiltered = true;
          if (filterType == FilterType.OR) {
            break;
          }
        } else {
          if (filterType == FilterType.AND) {
            isAudioFiltered = false;
            break;
          }
        }
      } else {
        if (ignoreCase
            ? audio.validVideoTitle
                .toLowerCase()
                .contains(filterSentence.toLowerCase())
            : audio.validVideoTitle.contains(filterSentence)) {
          isAudioFiltered = true;
          if (filterType == FilterType.OR) {
            break;
          }
        } else {
          if (filterType == FilterType.AND) {
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
