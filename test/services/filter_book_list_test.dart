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
    // TODO: implement toString
    return validVideoTitle;
  }
}

void main() {
  Audio bookOne = Audio('Sur quelle tendance crypto investir en 2024 ?', '');
  Audio bookTwo = Audio('Tendance crypto en progression en 2024', '');
  Audio bookThree = Audio(
      'Intelligence Artificielle: quelle menace ou opportunité en 2024 ?', '');
  Audio bookFour =
      Audio('Intelligence humaine ou artificielle, quelles différences ?', '');
  List<Audio> books = [
    bookOne,
    bookTwo,
    bookThree,
    bookFour,
  ];

  group('ignoring case, filter book list on title test', () {
    test('filter by <tendance crypto> AND <en 2024>', () {
      List<Audio> expectedFilteredBooks = [
        bookOne,
        bookTwo,
      ];

      List<Audio> filteredBooks = filter(
          booksLst: books,
          filterSentences: [
            'tendance crypto',
            'en 2024',
          ],
          filterType: FilterType.AND,
          ignoreCase: true);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <tendance crypto> OR <en 2024>', () {
      List<Audio> expectedFilteredBooks = [
        bookOne,
        bookTwo,
        bookThree,
      ];

      List<Audio> filteredBooks = filter(
          booksLst: books,
          filterSentences: [
            'tendance crypto',
            'en 2024',
          ],
          filterType: FilterType.OR,
          ignoreCase: true);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <en 2024> AND <tendance crypto>', () {
      List<Audio> expectedFilteredBooks = [
        bookOne,
        bookTwo,
      ];

      List<Audio> filteredBooks = filter(
          booksLst: books,
          filterSentences: [
            'en 2024',
            'tendance crypto',
          ],
          filterType: FilterType.AND,
          ignoreCase: true);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <en 2024> OR <tendance crypto>', () {
      List<Audio> expectedFilteredBooks = [
        bookOne,
        bookTwo,
        bookThree,
      ];

      List<Audio> filteredBooks = filter(
          booksLst: books,
          filterSentences: [
            'en 2024',
            'tendance crypto',
          ],
          filterType: FilterType.OR,
          ignoreCase: true);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <quelle> AND <2024>', () {
      List<Audio> expectedFilteredBooks = [
        bookOne,
        bookThree,
      ];

      List<Audio> filteredBooks = filter(
          booksLst: books,
          filterSentences: [
            'quelle',
            '2024',
          ],
          filterType: FilterType.AND,
          ignoreCase: true);

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
          booksLst: books,
          filterSentences: [
            'quelle',
            '2024',
          ],
          filterType: FilterType.OR,
          ignoreCase: true);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <2024> AND <quelle>', () {
      List<Audio> expectedFilteredBooks = [
        bookOne,
        bookThree,
      ];

      List<Audio> filteredBooks = filter(
          booksLst: books,
          filterSentences: [
            '2024',
            'quelle',
          ],
          filterType: FilterType.AND,
          ignoreCase: true);

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
          booksLst: books,
          filterSentences: [
            '2024',
            'quelle',
          ],
          filterType: FilterType.OR,
          ignoreCase: true);

      expect(filteredBooks, expectedFilteredBooks);
    });
      test('filter by <intelligence> OR <artificielle>', () {
      List<Audio> expectedFilteredBooks = [
        bookThree,
        bookFour,
      ];

      List<Audio> filteredBooks = filter(
          booksLst: books,
          filterSentences: [
            'intelligence',
            'artificielle',
          ],
          filterType: FilterType.OR,
          ignoreCase: true);

      expect(filteredBooks, expectedFilteredBooks);
    });
  });
  group('not ignoring case, filter book list on title test', () {
    test('filter by <tendance crypto> AND <en 2024>', () {
      List<Audio> expectedFilteredBooks = [
        bookOne,
      ];

      List<Audio> filteredBooks = filter(
          booksLst: books,
          filterSentences: [
            'tendance crypto',
            'en 2024',
          ],
          filterType: FilterType.AND,
          ignoreCase: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <tendance crypto> OR <en 2024>', () {
      List<Audio> expectedFilteredBooks = [
        bookOne,
        bookTwo,
        bookThree,
      ];

      List<Audio> filteredBooks = filter(
          booksLst: books,
          filterSentences: [
            'tendance crypto',
            'en 2024',
          ],
          filterType: FilterType.OR,
          ignoreCase: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <en 2024> AND <tendance crypto>', () {
      List<Audio> expectedFilteredBooks = [
        bookOne,
      ];

      List<Audio> filteredBooks = filter(
          booksLst: books,
          filterSentences: [
            'en 2024',
            'tendance crypto',
          ],
          filterType: FilterType.AND,
          ignoreCase: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <en 2024> OR <tendance crypto>', () {
      List<Audio> expectedFilteredBooks = [
        bookOne,
        bookTwo,
        bookThree,
      ];

      List<Audio> filteredBooks = filter(
          booksLst: books,
          filterSentences: [
            'en 2024',
            'tendance crypto',
          ],
          filterType: FilterType.OR,
          ignoreCase: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <quelle> AND <2024>', () {
      List<Audio> expectedFilteredBooks = [
        bookOne,
        bookThree,
      ];

      List<Audio> filteredBooks = filter(
          booksLst: books,
          filterSentences: [
            'quelle',
            '2024',
          ],
          filterType: FilterType.AND,
          ignoreCase: false);

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
          booksLst: books,
          filterSentences: [
            'quelle',
            '2024',
          ],
          filterType: FilterType.OR,
          ignoreCase: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <2024> AND <quelle>', () {
      List<Audio> expectedFilteredBooks = [
        bookOne,
        bookThree,
      ];

      List<Audio> filteredBooks = filter(
          booksLst: books,
          filterSentences: [
            '2024',
            'quelle',
          ],
          filterType: FilterType.AND,
          ignoreCase: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <intelligence> OR <artificielle>', () {
      List<Audio> expectedFilteredBooks = [
        bookFour,
      ];

      List<Audio> filteredBooks = filter(
          booksLst: books,
          filterSentences: [
            'intelligence',
            'artificielle',
          ],
          filterType: FilterType.OR,
          ignoreCase: false);

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
          booksLst: books,
          filterSentences: [
            '2024',
            'quelle',
          ],
          filterType: FilterType.OR,
          ignoreCase: false);

      expect(filteredBooks, expectedFilteredBooks);
    });
  });
}

List<Audio> filter({
  required List<Audio> booksLst,
  required List<String> filterSentences,
  required FilterType filterType,
  required bool ignoreCase,
}) {
  List<Audio> filteredBooks = [];
  for (Audio book in booksLst) {
    bool isBookFiltered = false;
    for (String filterSentence in filterSentences) {
      if (ignoreCase
          ? book.validVideoTitle.toLowerCase().contains(filterSentence.toLowerCase())
          : book.validVideoTitle.contains(filterSentence)) {
        isBookFiltered = true;
        if (filterType == FilterType.OR) {
          break;
        }
      } else {
        if (filterType == FilterType.AND) {
          isBookFiltered = false;
          break;
        }
      }
    }
    if (isBookFiltered) {
      filteredBooks.add(book);
    }
  }

  return filteredBooks;
}
