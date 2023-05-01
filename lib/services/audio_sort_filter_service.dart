import '../models/audio.dart';

class AudioSortFilterService {
  static List<Audio> sortAudioLstByVideoUploadDate({
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

  static List<Audio> sortAudioLstByAudioDownloadDateTime({
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

  static List<Audio> sortAudioLstByTitle({
    required List<Audio> audioLst,
    bool asc = true,
  }) {
    if (asc) {
      audioLst.sort((a, b) {
        return a.validVideoTitle.compareTo(b.validVideoTitle);
      });
    } else {
      audioLst.sort((a, b) {
        return b.validVideoTitle.compareTo(a.validVideoTitle);
      });
    }

    return audioLst;
  }

  static List<Audio> sortAudioLstByDuration({
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

  static List<Audio> sortAudioLstByDownloadDuration({
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

  static List<Audio> sortAudioLstByDownloadSpeed({
    required List<Audio> audioLst,
    bool asc = true,
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
          return -1;
        } else if (a.audioDownloadSpeed > b.audioDownloadSpeed) {
          return 1;
        } else {
          return 0;
        }
      });
    }

    return audioLst;
  }

  static List<Audio> sortAudioLstByFileSize({
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

  static List<Audio> sortAudioLstByMusicQuality({
    required List<Audio> audioLst,
    bool asc = true,
  }) {
    if (asc) {
      audioLst.sort((a, b) {
        if (a.isMusicQuality && !b.isMusicQuality) {
          return -1;
        } else if (!a.isMusicQuality && b.isMusicQuality) {
          return 1;
        } else {
          return 0;
        }
      });
    } else {
      audioLst.sort((a, b) {
        if (a.isMusicQuality && !b.isMusicQuality) {
          return 1;
        } else if (!a.isMusicQuality && b.isMusicQuality) {
          return -1;
        } else {
          return 0;
        }
      });
    }

    return audioLst;
  }

// Method not useful
// static List<Audio> sortAudioLstByVideoUrl({
//   required List<Audio> audioLst,
//   bool asc = true,
// }) {
//   if (asc) {
//     audioLst.sort((a, b) {
//       return a.videoUrl.compareTo(b.videoUrl);
//     });
//   } else {
//     audioLst.sort((a, b) {
//       return b.videoUrl.compareTo(a.videoUrl);
//     });
//   }

//   return audioLst;
// }

  static List<Audio> sortAudioLstByEnclosingPlaylistTitle({
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

  /// Currently not searching video description since
  /// video description is not available in audio object
  static List<Audio> filterAudioLstByVideoTitleOrDescription({
    required List<Audio> audioLst,
    required String searchWords,
  }) {
    return audioLst.where((audio) {
      return audio.originalVideoTitle.contains(searchWords);
    }).toList();
  }

  static List<Audio> filterAudioLstByAudioDownloadDateTime({
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

  static List<Audio> filterAudioLstByAudioVideoUploadDateTime({
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

  static List<Audio> filterAudioLstByAudioFileSize({
    required List<Audio> audioLst,
    required int startFileSize,
    required int endFileSize,
  }) {
    return audioLst.where((audio) {
      return (audio.audioFileSize >= startFileSize ||
              audio.audioFileSize == startFileSize) &&
          (audio.audioFileSize <= endFileSize ||
              audio.audioFileSize == endFileSize);
    }).toList();
  }

  static List<Audio> filterAudioLstByMusicQuality({
    required List<Audio> audioLst,
    required bool isMusicQuality,
  }) {
    return audioLst.where((audio) {
      return audio.isMusicQuality == isMusicQuality;
    }).toList();
  }
}
