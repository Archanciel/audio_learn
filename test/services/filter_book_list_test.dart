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
      'Intelligence artificielle: quelle menace ou opportunité en 2024 ?', '');
  Book bookFour =
      Book('Intelligence humaine ou artificielle, quelles différences ?', '');
  List<Book> books = [
    bookOne,
    bookTwo,
    bookThree,
    bookFour,
  ];

  group('filter book list on title test', () {
    test('filter by <tendance crypto> AND <en 2024>', () {
      List<Book> expectedFilteredBooks = [
        bookOne,
        bookTwo,
      ];

      List<Book> filteredBooks = filter(
          books,
          [
            'tendance crypto',
            'en 2024',
          ],
          FilterType.AND);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <tendance crypto> OR <en 2024>', () {
      List<Book> expectedFilteredBooks = [
        bookOne,
        bookTwo,
        bookThree,
      ];

      List<Book> filteredBooks = filter(
          books,
          [
            'tendance crypto',
            'en 2024',
          ],
          FilterType.OR);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <en 2024> AND <tendance crypto>', () {
      List<Book> expectedFilteredBooks = [
        bookOne,
        bookTwo,
      ];

      List<Book> filteredBooks = filter(
          books,
          [
            'en 2024',
            'tendance crypto',
          ],
          FilterType.AND);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <en 2024> OR <tendance crypto>', () {
      List<Book> expectedFilteredBooks = [
        bookOne,
        bookTwo,
        bookThree,
      ];

      List<Book> filteredBooks = filter(
          books,
          [
            'en 2024',
            'tendance crypto',
          ],
          FilterType.OR);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <quelle> AND <2024>', () {
      List<Book> expectedFilteredBooks = [
        bookOne,
        bookThree,
      ];

      List<Book> filteredBooks = filter(
          books,
          [
            'quelle',
            '2024',
          ],
          FilterType.AND);

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
          books,
          [
            'quelle',
            '2024',
          ],
          FilterType.OR);

      expect(filteredBooks, expectedFilteredBooks);
    });
    test('filter by <2024> AND <quelle>', () {
      List<Book> expectedFilteredBooks = [
        bookOne,
        bookThree,
      ];

      List<Book> filteredBooks = filter(
          books,
          [
            '2024',
            'quelle',
          ],
          FilterType.AND);

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
          books,
          [
            '2024',
            'quelle',
          ],
          FilterType.OR);

      expect(filteredBooks, expectedFilteredBooks);
    });
  });

  List<String> filterSentences = [
    'tendance crypto',
    'en 2024',
  ];

  print(
      '\nbooks list after AND filter sentences <tendance crypto> and <en 2024>');
  printBooks(filter(books, filterSentences, FilterType.AND));

  print(
      '\nbooks list after OR filter sentences <tendance crypto> and <en 2024>');
  printBooks(filter(books, filterSentences, FilterType.OR));

  filterSentences = [
    'en 2024',
    'tendance crypto',
  ];

  print(
      '\nbooks list after AND filter sentences <en 2024> and <tendance crypto>');
  printBooks(filter(books, filterSentences, FilterType.AND));

  print(
      '\nbooks list after OR filter sentences <en 2024> and <tendance crypto>');
  printBooks(filter(books, filterSentences, FilterType.OR));

  filterSentences = [
    'quelle',
    '2024',
  ];

  print('\nbooks list after AND filter sentences <quelle> and <2024>');
  printBooks(filter(books, filterSentences, FilterType.AND));

  print('\nbooks list after OR filter sentences <quelle> and <2024>');
  printBooks(filter(books, filterSentences, FilterType.OR));

  filterSentences = [
    '2024',
    'quelle',
  ];

  print('\nbooks list after AND filter sentences <2024> and <quelle>');
  printBooks(filter(books, filterSentences, FilterType.AND));

  print('\nbooks list after OR filter sentences <2024> and <quelle>');
  printBooks(filter(books, filterSentences, FilterType.OR));
}

void printBooks(List<Book> books) {
  for (Book book in books) {
    print('title: ${book.title}');
  }
}

List<Book> filter(
  List<Book> booksLst,
  List<String> filterSentences,
  FilterType filterType,
) {
  List<Book> filteredBooks = [];
  for (Book book in booksLst) {
    bool isBookFiltered = false;
    for (String filterSentence in filterSentences) {
      if (book.title.toLowerCase().contains(filterSentence.toLowerCase())) {
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