import '../models/audio.dart';
import '../utils/date_time_parser.dart';
import 'sort_filter_parameters.dart';

class AudioSortFilterService {
  static Map<SortingOption, SortCriteria<Audio>>
      sortCriteriaForSortingOptionMap = {
    SortingOption.audioDownloadDateTime: SortCriteria<Audio>(
      selectorFunction: (Audio audio) {
        return DateTimeParser.truncateDateTimeToDay(
            audio.audioDownloadDateTime);
      },
      sortOrder: sortDescending,
    ),
    SortingOption.videoUploadDate: SortCriteria<Audio>(
      selectorFunction: (Audio audio) {
        return DateTimeParser.truncateDateTimeToDay(audio.videoUploadDate);
      },
      sortOrder: sortDescending,
    ),
    SortingOption.validAudioTitle: SortCriteria<Audio>(
      selectorFunction: (Audio audio) {
        return audio.validVideoTitle.toLowerCase();
      },
      sortOrder: sortAscending,
    ),
    SortingOption.audioEnclosingPlaylistTitle: SortCriteria<Audio>(
      selectorFunction: (Audio audio) {
        return audio.enclosingPlaylist!.title;
      },
      sortOrder: sortAscending,
    ),
    SortingOption.audioDuration: SortCriteria<Audio>(
      selectorFunction: (Audio audio) {
        return audio.audioDuration!.inMilliseconds;
      },
      sortOrder: sortAscending,
    ),
    SortingOption.audioFileSize: SortCriteria<Audio>(
      selectorFunction: (Audio audio) {
        return audio.audioFileSize;
      },
      sortOrder: sortDescending,
    ),
    SortingOption.audioMusicQuality: SortCriteria<Audio>(
      selectorFunction: (Audio audio) {
        return audio.isMusicQuality ? 1 : 0;
      },
      sortOrder: sortAscending,
    ),
    SortingOption.audioDownloadSpeed: SortCriteria<Audio>(
      selectorFunction: (Audio audio) {
        return audio.audioDownloadSpeed;
      },
      sortOrder: sortDescending,
    ),
    SortingOption.audioDownloadDuration: SortCriteria<Audio>(
      selectorFunction: (Audio audio) {
        return audio.audioDownloadDuration!.inMilliseconds;
      },
      sortOrder: sortDescending,
    ),
    SortingOption.videoUrl: SortCriteria<Audio>(
      selectorFunction: (Audio audio) {
        return audio.videoUrl;
      },
      sortOrder: sortAscending,
    ),
  };

  /// Method called by filterAndSortAudioLst(). This method is used
  /// to sort the audio list by the given sorting option.
  ///
  /// Not private in order to be tested.
  List<Audio> sortAudioLstBySortingOptions({
    required List<Audio> audioLst,
    required List<SortingItem> selectedSortOptionsLst,
  }) {
    // Create a list of SortCriteria corresponding to the list of
    // selected sorting options coming from the UI.
    List<SortCriteria<Audio>> sortCriteriaLst =
        selectedSortOptionsLst.map((sortingItem) {
      SortCriteria<Audio> sortCriteria =
          sortCriteriaForSortingOptionMap[sortingItem.sortingOption]!;
      sortCriteria.sortOrder =
          sortingItem.isAscending ? sortAscending : sortDescending;

      return sortCriteria;
    }).toList();

    // Sorting the audio list by applying the SortCriteria of the
    // sortCriteriaLst
    audioLst.sort((a, b) {
      for (SortCriteria<Audio> sortCriteria in sortCriteriaLst) {
        int comparison = sortCriteria
                .selectorFunction(a)
                .compareTo(sortCriteria.selectorFunction(b)) *
            sortCriteria.sortOrder;
        if (comparison != 0) return comparison;
      }
      return 0;
    });

    return audioLst;
  }

  List<Audio> _sortAudioLstByVideoUploadDate({
    required List<Audio> audioLst,
    bool asc = true,
  }) {
    if (asc) {
      audioLst.sort((a, b) {
        if (a.videoUploadDate.isBefore(b.videoUploadDate)) {
          return -1;
        } else if (a.videoUploadDate.isAfter(b.videoUploadDate)) {
          return 1;
        } else {
          return 0;
        }
      });
    } else {
      audioLst.sort((a, b) {
        if (a.videoUploadDate.isBefore(b.videoUploadDate)) {
          return 1;
        } else if (a.videoUploadDate.isAfter(b.videoUploadDate)) {
          return -1;
        } else {
          return 0;
        }
      });
    }

    return audioLst;
  }

  List<Audio> _sortAudioLstByAudioDownloadDateTime({
    required List<Audio> audioLst,
    bool asc = true,
  }) {
    if (asc) {
      audioLst.sort((a, b) {
        if (a.audioDownloadDateTime.isBefore(b.audioDownloadDateTime)) {
          return -1;
        } else if (a.audioDownloadDateTime.isAfter(b.audioDownloadDateTime)) {
          return 1;
        } else {
          return 0;
        }
      });
    } else {
      audioLst.sort((a, b) {
        if (a.audioDownloadDateTime.isBefore(b.audioDownloadDateTime)) {
          return 1;
        } else if (a.audioDownloadDateTime.isAfter(b.audioDownloadDateTime)) {
          return -1;
        } else {
          return 0;
        }
      });
    }

    return audioLst;
  }

  /// Does not sort 'Échapper title' and 'ÉPICURE
  /// title' correctly !
  List<Audio> _sortAudioLstByTitle({
    required List<Audio> audioLst,
    bool asc = true,
  }) {
    if (asc) {
      audioLst.sort((a, b) {
        String cleanA = a.validVideoTitle
            .replaceAll(RegExp(r'[^A-Za-z0-9éèêëîïôœùûüÿç]'), '');
        String cleanB = b.validVideoTitle
            .replaceAll(RegExp(r'[^A-Za-z0-9éèêëîïôœùûüÿç]'), '');
        return cleanA.compareTo(cleanB);
      });
    } else {
      audioLst.sort((a, b) {
        String cleanA = a.validVideoTitle
            .replaceAll(RegExp(r'[^A-Za-z0-9éèêëîïôœùûüÿç]'), '');
        String cleanB = b.validVideoTitle
            .replaceAll(RegExp(r'[^A-Za-z0-9éèêëîïôœùûüÿç]'), '');
        return cleanB.compareTo(cleanA);
      });
    }

    return audioLst;
  }

  List<Audio> _sortAudioLstByDuration({
    required List<Audio> audioLst,
    bool asc = true,
  }) {
    if (asc) {
      audioLst.sort((a, b) {
        if (a.audioDuration!.inMilliseconds < b.audioDuration!.inMilliseconds) {
          return -1;
        } else if (a.audioDuration!.inMilliseconds >
            b.audioDuration!.inMilliseconds) {
          return 1;
        } else {
          return 0;
        }
      });
    } else {
      audioLst.sort((a, b) {
        if (a.audioDuration!.inMilliseconds > b.audioDuration!.inMilliseconds) {
          return -1;
        } else if (a.audioDuration!.inMilliseconds <
            b.audioDuration!.inMilliseconds) {
          return 1;
        } else {
          return 0;
        }
      });
    }

    return audioLst;
  }

  List<Audio> _sortAudioLstByDownloadDuration({
    required List<Audio> audioLst,
    bool asc = true,
  }) {
    if (asc) {
      audioLst.sort((a, b) {
        if (a.audioDownloadDuration!.inMilliseconds <
            b.audioDownloadDuration!.inMilliseconds) {
          return -1;
        } else if (a.audioDownloadDuration!.inMilliseconds >
            b.audioDownloadDuration!.inMilliseconds) {
          return 1;
        } else {
          return 0;
        }
      });
    } else {
      audioLst.sort((a, b) {
        if (a.audioDownloadDuration!.inMilliseconds >
            b.audioDownloadDuration!.inMilliseconds) {
          return -1;
        } else if (a.audioDownloadDuration!.inMilliseconds <
            b.audioDownloadDuration!.inMilliseconds) {
          return 1;
        } else {
          return 0;
        }
      });
    }

    return audioLst;
  }

  List<Audio> _sortAudioLstByDownloadSpeed({
    required List<Audio> audioLst,
    required bool asc,
  }) {
    if (asc) {
      audioLst.sort((a, b) {
        if (a.audioDownloadSpeed < b.audioDownloadSpeed) {
          return -1;
        } else if (a.audioDownloadSpeed > b.audioDownloadSpeed) {
          return 1;
        } else {
          return 0;
        }
      });
    } else {
      audioLst.sort((a, b) {
        if (a.audioDownloadSpeed < b.audioDownloadSpeed) {
          return 1;
        } else if (a.audioDownloadSpeed > b.audioDownloadSpeed) {
          return -1;
        } else {
          return 0;
        }
      });
    }

    return audioLst;
  }

  List<Audio> _sortAudioLstByFileSize({
    required List<Audio> audioLst,
    bool asc = true,
  }) {
    if (asc) {
      audioLst.sort((a, b) {
        if (a.audioFileSize < b.audioFileSize) {
          return -1;
        } else if (a.audioFileSize > b.audioFileSize) {
          return 1;
        } else {
          return 0;
        }
      });
    } else {
      audioLst.sort((a, b) {
        if (a.audioFileSize < b.audioFileSize) {
          return 1;
        } else if (a.audioFileSize > b.audioFileSize) {
          return -1;
        } else {
          return 0;
        }
      });
    }

    return audioLst;
  }

  List<Audio> _sortAudioLstByMusicQuality({
    required List<Audio> audioLst,
    bool asc = true,
  }) {
    List<Audio> sortedAudioList = [];
    List<Audio> musicQualityList = [];
    List<Audio> speechQualityList = [];

    for (Audio audio in audioLst) {
      if (audio.isMusicQuality) {
        musicQualityList.add(audio);
      } else {
        speechQualityList.add(audio);
      }
    }

    if (asc) {
      sortedAudioList = musicQualityList + speechQualityList;
    } else {
      sortedAudioList = speechQualityList + musicQualityList;
    }

    return sortedAudioList;
  }

  List<Audio> _sortAudioLstByEnclosingPlaylistTitle({
    required List<Audio> audioLst,
    bool asc = true,
  }) {
    if (asc) {
      audioLst.sort((a, b) {
        return a.enclosingPlaylist!.title.compareTo(b.enclosingPlaylist!.title);
      });
    } else {
      audioLst.sort((a, b) {
        return b.enclosingPlaylist!.title.compareTo(a.enclosingPlaylist!.title);
      });
    }

    return audioLst;
  }

  List<Audio> _sortAudioLstByVideoUrl({
    required List<Audio> audioLst,
    bool asc = true,
  }) {
    if (asc) {
      audioLst.sort((a, b) {
        return a.videoUrl.compareTo(b.videoUrl);
      });
    } else {
      audioLst.sort((a, b) {
        return b.videoUrl.compareTo(a.videoUrl);
      });
    }

    return audioLst;
  }

  static bool getDefaultSortOptionOrder({
    required SortingOption sortingOption,
  }) {
    return sortCriteriaForSortingOptionMap[sortingOption]!.sortOrder ==
        sortAscending;
  }

  List<Audio> filterAndSortAudioLst({
    required List<Audio> audioLst,
    required List<SortingItem> selectedSortOptionLst,
    List<String> filterSentenceLst = const [],
    required SentencesCombination sentencesCombination,
    // bool searchSentencesAnd = true, // if false, searchSentencesOr !
    bool ignoreCase = false,
    bool searchAsWellInVideoCompactDescription = false,
  }) {
    List<Audio> audioLstCopy = List<Audio>.from(audioLst);

    if (filterSentenceLst.isNotEmpty) {
      audioLstCopy = filter(
        audioLst: audioLstCopy,
        filterSentenceLst: filterSentenceLst,
        sentencesCombination: sentencesCombination,
        ignoreCase: ignoreCase,
        searchAsWellInVideoCompactDescription:
            searchAsWellInVideoCompactDescription,
      );
    }

    // if (filterSentenceLst.isNotEmpty) {
    //   if (!searchAsWellInVideoCompactDescription) {
    //     // here, we filter by video title only
    //     if (sentencesCombination == SentencesCombination.AND) {
    //       // the audio valid video title must contain all the
    //       // search sentences
    //       for (String searchSentence in filterSentenceLst) {
    //         audioLstCopy = _filterAudioLstByVideoTitleOnly(
    //           audioLst: audioLstCopy,
    //           searchWords: searchSentence,
    //           ignoreCase: ignoreCase,
    //         );
    //       }
    //     } else {
    //       // the audio valid video title must contain
    //       // at least one of the search sentences
    //       List<List<Audio>> lstOfSentenceAudioLst = [];

    //       // NOT PERFORMANT !!!

    //       for (String searchSentence in filterSentenceLst) {
    //         lstOfSentenceAudioLst.add(
    //           _filterAudioLstByVideoTitleOnly(
    //             audioLst: audioLstCopy,
    //             searchWords: searchSentence,
    //             ignoreCase: ignoreCase,
    //           ),
    //         );
    //       }

    //       audioLstCopy = lstOfSentenceAudioLst
    //           .expand((element) => element)
    //           .toSet()
    //           .toList();
    //     }
    //   } else {
    //     // here, we filter by video title and by video description
    //     if (sentencesCombination == SentencesCombination.AND) {
    //       // the audio valid video title or the audio
    //       // compact video description must contain all
    //       // the search sentences
    //       for (String searchSentence in filterSentenceLst) {
    //         audioLstCopy = _filterAudioLstByVideoTitleOrDescription(
    //           audioLst: audioLstCopy,
    //           searchWords: searchSentence,
    //           ignoreCase: ignoreCase,
    //         );
    //       }
    //     } else {
    //       // the audio valid video title or the audio
    //       // compact video description must contain at
    //       // least one of the search sentences
    //       List<List<Audio>> lstOfSentenceAudioLst = [];

    //       // NOT PERFORMANT !!!

    //       for (String searchSentence in filterSentenceLst) {
    //         lstOfSentenceAudioLst.add(
    //           _filterAudioLstByVideoTitleOrDescription(
    //             audioLst: audioLstCopy,
    //             searchWords: searchSentence,
    //             ignoreCase: ignoreCase,
    //           ),
    //         );
    //       }

    //       audioLstCopy = lstOfSentenceAudioLst
    //           .expand((element) => element)
    //           .toSet()
    //           .toList();
    //     }
    //   }
    // }

    return sortAudioLstBySortingOptions(
      audioLst: audioLstCopy,
      selectedSortOptionsLst: selectedSortOptionLst,
    );
  }

  /// Method called by filterAndSortAudioLst().
  ///
  /// Not private in order to be tested
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

  // List<Audio> _filterAudioLstByVideoTitleOnly({
  //   required List<Audio> audioLst,
  //   required String searchWords,
  //   required bool ignoreCase,
  // }) {
  //   RegExp searchWordsPattern = RegExp(searchWords, caseSensitive: !ignoreCase);

  //   return audioLst.where((audio) {
  //     return searchWordsPattern.hasMatch(audio.validVideoTitle);
  //   }).toList();
  // }

  // List<Audio> _filterAudioLstByVideoTitleOrDescription({
  //   required List<Audio> audioLst,
  //   required String searchWords,
  //   required bool ignoreCase,
  // }) {
  //   RegExp searchWordsPattern = RegExp(searchWords, caseSensitive: !ignoreCase);

  //   return audioLst.where((audio) {
  //     return searchWordsPattern.hasMatch(
  //         '${audio.validVideoTitle} ${audio.compactVideoDescription}');
  //   }).toList();
  // }

  List<Audio> _filterAudioLstByAudioDownloadDateTime({
    required List<Audio> audioLst,
    required DateTime startDateTime,
    required DateTime endDateTime,
  }) {
    return audioLst.where((audio) {
      return (audio.audioDownloadDateTime.isAfter(startDateTime) ||
              audio.audioDownloadDateTime.isAtSameMomentAs(startDateTime)) &&
          (audio.audioDownloadDateTime.isBefore(endDateTime) ||
              audio.audioDownloadDateTime.isAtSameMomentAs(endDateTime));
    }).toList();
  }

  List<Audio> _filterAudioLstByAudioVideoUploadDateTime({
    required List<Audio> audioLst,
    required DateTime startDateTime,
    required DateTime endDateTime,
  }) {
    return audioLst.where((audio) {
      return (audio.videoUploadDate.isAfter(startDateTime) ||
              audio.videoUploadDate.isAtSameMomentAs(startDateTime)) &&
          (audio.videoUploadDate.isBefore(endDateTime) ||
              audio.videoUploadDate.isAtSameMomentAs(endDateTime));
    }).toList();
  }

  List<Audio> _filterAudioLstByAudioFileSize({
    required List<Audio> audioLst,
    required int startFileSize,
    required int endFileSize,
  }) {
    return audioLst.where((audio) {
      return (audio.audioFileSize >= startFileSize) &&
          (audio.audioFileSize <= endFileSize);
    }).toList();
  }

  List<Audio> _filterAudioLstByMusicQuality({
    required List<Audio> audioLst,
    required bool isMusicQuality,
  }) {
    return audioLst.where((audio) {
      return audio.isMusicQuality == isMusicQuality;
    }).toList();
  }

  List<Audio> _filterAudioByAudioDuration({
    required List<Audio> audioLst,
    required Duration startDuration,
    required Duration endDuration,
  }) {
    return audioLst.where((audio) {
      return (audio.audioDownloadDuration!.inMilliseconds >=
              startDuration.inMilliseconds) &&
          (audio.audioDownloadDuration!.inMilliseconds <=
              endDuration.inMilliseconds);
    }).toList();
  }
}
