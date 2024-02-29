import '../models/audio.dart';
import '../utils/date_time_parser.dart';
import 'sort_filter_parameters.dart';

enum SortingOption {
  audioDownloadDateTime,
  videoUploadDate,
  validAudioTitle,
  audioEnclosingPlaylistTitle,
  audioDuration,
  audioFileSize,
  audioMusicQuality,
  audioDownloadSpeed,
  audioDownloadDuration,
  videoUrl, // useful to detect audio duplicates
}

class AudioSortFilterService {
  static Map<SortingOption, SortCriteria<Audio>> sortingOptionToSortCriteriaMap = {
    SortingOption.audioDownloadDateTime: SortCriteria(
        selectorFunction: (Audio audio) {
          return DateTimeParser.truncateDateTimeToDay(audio.audioDownloadDateTime);
        },
      sortOrder: sortDescending,
    ),
    SortingOption.videoUploadDate: SortCriteria(
        selectorFunction: (Audio audio) {
          return DateTimeParser.truncateDateTimeToDay(audio.videoUploadDate);
        },
      sortOrder: sortDescending,
    ),
    SortingOption.validAudioTitle: SortCriteria(
        selectorFunction: (Audio audio) {
          return audio.validVideoTitle.toLowerCase();       
        },
      sortOrder: sortAscending,
    ),
    SortingOption.audioEnclosingPlaylistTitle: SortCriteria(
        selectorFunction: (Audio audio) {
          return audio.enclosingPlaylist!.title;       
        },
      sortOrder: sortAscending,
    ),
    SortingOption.audioDuration: SortCriteria(
        selectorFunction: (Audio audio) {
          return audio.audioDuration!.inMilliseconds;
        },
      sortOrder: sortAscending,
    ),
    SortingOption.audioFileSize: SortCriteria(
        selectorFunction: (Audio audio) {
          return audio.audioFileSize;
        },
      sortOrder: sortDescending,
    ),
    SortingOption.audioMusicQuality: SortCriteria(
        selectorFunction: (Audio audio) {
          return audio.isMusicQuality ? 1 : 0;
        },
      sortOrder: sortAscending,
    ),
    SortingOption.audioDownloadSpeed: SortCriteria(
        selectorFunction: (Audio audio) {
          return audio.audioDownloadSpeed;
        },
      sortOrder: sortDescending,
    ),
    SortingOption.audioDownloadDuration: SortCriteria(
        selectorFunction: (Audio audio) {
          return audio.audioDownloadDuration!.inMilliseconds;
        },
      sortOrder: sortDescending,
    ),
    SortingOption.videoUrl: SortCriteria(
        selectorFunction: (Audio audio) {
          return audio.videoUrl;
        },
      sortOrder: sortAscending,
    ),
  };

  /// This method is used to sort the audio list by the given sorting
  /// option. It is public only in order to be tested.
  List<Audio> sortAudioLstBySortingOption({
    required List<Audio> audioLst,
    required SortingOption sortingOption,
    bool asc = true,
  }) {
    switch (sortingOption) {
      case SortingOption.audioDownloadDateTime:
        return _sortAudioLstByAudioDownloadDateTime(
          audioLst: audioLst,
          asc: asc,
        );
      case SortingOption.videoUploadDate:
        return _sortAudioLstByVideoUploadDate(
          audioLst: audioLst,
          asc: asc,
        );
      case SortingOption.validAudioTitle:
        return _sortAudioLstByTitle(
          audioLst: audioLst,
          asc: asc,
        );
      case SortingOption.audioEnclosingPlaylistTitle:
        return _sortAudioLstByEnclosingPlaylistTitle(
          audioLst: audioLst,
          asc: asc,
        );
      case SortingOption.audioDuration:
        return _sortAudioLstByDuration(
          audioLst: audioLst,
          asc: asc,
        );
      case SortingOption.audioFileSize:
        return _sortAudioLstByFileSize(
          audioLst: audioLst,
          asc: asc,
        );
      case SortingOption.audioMusicQuality:
        return _sortAudioLstByMusicQuality(
          audioLst: audioLst,
          asc: asc,
        );
      case SortingOption.audioDownloadSpeed:
        return _sortAudioLstByDownloadSpeed(
          audioLst: audioLst,
          asc: asc,
        );
      case SortingOption.audioDownloadDuration:
        return _sortAudioLstByDownloadDuration(
          audioLst: audioLst,
          asc: asc,
        );
      case SortingOption.videoUrl:
        return _sortAudioLstByVideoUrl(
          audioLst: audioLst,
          asc: asc,
        );
      default:
        return audioLst;
    }
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

  List<Audio> filterAndSortAudioLst({
    required List<Audio> audioLst,
    required SortingOption sortingOption,
    String? searchWords,
    bool ignoreCase = false,
    bool searchInVideoCompactDescription = false,
    bool asc = true,
  }) {
    if (searchWords != null && searchWords.isNotEmpty) {
      if (!searchInVideoCompactDescription) {
        audioLst = _filterAudioLstByVideoTitleOnly(
          audioLst: audioLst,
          searchWords: searchWords,
          ignoreCase: ignoreCase,
        );
      } else {
        audioLst = _filterAudioLstByVideoTitleOrDescription(
          audioLst: audioLst,
          searchWords: searchWords,
          ignoreCase: ignoreCase,
        );
      }
    }

    return sortAudioLstBySortingOption(
      audioLst: audioLst,
      sortingOption: sortingOption,
      asc: asc,
    );
  }

  List<Audio> _filterAudioLstByVideoTitleOnly({
    required List<Audio> audioLst,
    required String searchWords,
    required bool ignoreCase,
  }) {
    RegExp searchWordsPattern = RegExp(searchWords, caseSensitive: !ignoreCase);

    return audioLst.where((audio) {
      return searchWordsPattern.hasMatch(audio.validVideoTitle);
    }).toList();
  }

  List<Audio> _filterAudioLstByVideoTitleOrDescription({
    required List<Audio> audioLst,
    required String searchWords,
    required bool ignoreCase,
  }) {
    RegExp searchWordsPattern = RegExp(searchWords, caseSensitive: !ignoreCase);

    return audioLst.where((audio) {
      return searchWordsPattern.hasMatch(
          '${audio.validVideoTitle} ${audio.compactVideoDescription}');
    }).toList();
  }

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
