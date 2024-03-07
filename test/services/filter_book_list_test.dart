import 'package:flutter_test/flutter_test.dart';

enum FilterType { AND, OR }

class Book {
  String title;
  String summary;

  Book(
    this.title,
    this.summary,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Book && other.title == title;
  }

  @override
  String toString() {
    // TODO: implement toString
    return title;
  }
}

void main() {
  Book bookOne = Book('Sur quelle tendance crypto investir en 2024 ?', '');
  Book bookTwo = Book('Tendance crypto en progression en 2024', '');
  Book bookThree = Book(
      'Intelligence Artificielle: quelle menace ou opportunité en 2024 ?', '');
  Book bookFour =
      Book('Intelligence humaine ou artificielle, quelles différences ?', '');
  List<Book> books = [
    bookOne,
    bookTwo,
    bookThree,
    bookFour,
  ];

  group('ignoring case, filter book list on title test', () {
    test('filter by <tendance crypto> AND <en 2024>', () {
      List<Book> expectedFilteredBooks = [
        bookOne,
        bookTwo,
      ];

      List<Book> filteredBooks = filter(
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
      List<Book> expectedFilteredBooks = [
        bookOne,
        bookTwo,
        bookThree,
      ];

      List<Book> filteredBooks = filter(
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
      List<Book> expectedFilteredBooks = [
        bookOne,
        bookTwo,
      ];

      List<Book> filteredBooks = filter(
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
      List<Book> expectedFilteredBooks = [
        bookOne,
        bookTwo,
        bookThree,
      ];

      List<Book> filteredBooks = filter(
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
      List<Book> expectedFilteredBooks = [
        bookOne,
        bookThree,
      ];

      List<Book> filteredBooks = filter(
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
      List<Book> expectedFilteredBooks = [
        bookOne,
        bookTwo,
        bookThree,
        bookFour,
      ];

      List<Book> filteredBooks = filter(
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
      List<Book> expectedFilteredBooks = [
        bookOne,
        bookThree,
      ];

      List<Book> filteredBooks = filter(
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
      List<Book> expectedFilteredBooks = [
        bookOne,
        bookTwo,
        bookThree,
        bookFour,
      ];

      List<Book> filteredBooks = filter(
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
      List<Book> expectedFilteredBooks = [
        bookThree,
        bookFour,
      ];

      List<Book> filteredBooks = filter(
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
      List<Book> expectedFilteredBooks = [
        bookOne,
      ];

      List<Book> filteredBooks = filter(
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
      List<Book> expectedFilteredBooks = [
        bookOne,
        bookTwo,
        bookThree,
      ];

      List<Book> filteredBooks = filter(
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
      List<Book> expectedFilteredBooks = [
        bookOne,
      ];

      List<Book> filteredBooks = filter(
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
      List<Book> expectedFilteredBooks = [
        bookOne,
        bookTwo,
        bookThree,
      ];

      List<Book> filteredBooks = filter(
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
      List<Book> expectedFilteredBooks = [
        bookOne,
        bookThree,
      ];

      List<Book> filteredBooks = filter(
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
      List<Book> expectedFilteredBooks = [
        bookOne,
        bookTwo,
        bookThree,
        bookFour,
      ];

      List<Book> filteredBooks = filter(
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
      List<Book> expectedFilteredBooks = [
        bookOne,
        bookThree,
      ];

      List<Book> filteredBooks = filter(
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
      List<Book> expectedFilteredBooks = [
        bookFour,
      ];

      List<Book> filteredBooks = filter(
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
      List<Book> expectedFilteredBooks = [
        bookOne,
        bookTwo,
        bookThree,
        bookFour,
      ];

      List<Book> filteredBooks = filter(
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

List<Book> filter({
  required List<Book> booksLst,
  required List<String> filterSentences,
  required FilterType filterType,
  required bool ignoreCase,
}) {
  List<Book> filteredBooks = [];
  for (Book book in booksLst) {
    bool isBookFiltered = false;
    for (String filterSentence in filterSentences) {
      if (ignoreCase
          ? book.title.toLowerCase().contains(filterSentence.toLowerCase())
          : book.title.contains(filterSentence)) {
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
