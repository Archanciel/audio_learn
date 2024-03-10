import '../models/audio.dart';

/// This enum is used to specify how to sort the audio list.
/// It is used in the sort and filter audio dialog.
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

/// This enum is used to specify how to combine the filter sentences
/// specified by the user in the sort and filter audio dialog.
enum SentencesCombination {
  AND, // all sentences must be found
  OR, // at least one sentence must be found
}

const int sortAscending = 1;
const int sortDescending = -1;

/// This class represent a 'Sort by:' list item added by the user in
/// the sort and filter audio dialog. It associates a SortingOption
/// with a boolean indicating if the sorting is ascending or descending.
class SortingItem {
  final SortingOption sortingOption;
  bool isAscending;

  SortingItem({
    required this.sortingOption,
    required this.isAscending,
  });
}

class SortCriteria<T> {
  final Comparable Function(T) selectorFunction;
  int sortOrder;

  SortCriteria({
    required this.selectorFunction,
    required this.sortOrder,
  });
}

class AudioSortFilterParametersFull {
  final List<SortCriteria<Audio>> sortCriteriaLst;
  final String videoTitleAndDescription;
  final bool ignoreCase;
  final bool includeDescription;
  final bool audioMusicQuality;
  final DateTime? downloadDateStartRange;
  final DateTime? downloadDateEndRange;
  final DateTime? uploadDateStartRange;
  final DateTime? uploadDateEndRange;
  final int fileSizeStartRange;
  final int? fileSizeEndRange;
  final int? durationStartRange;
  final int? durationEndRange;

  AudioSortFilterParametersFull({
    required this.sortCriteriaLst,
    this.videoTitleAndDescription = '',
    this.ignoreCase = true,
    this.includeDescription = true,
    this.audioMusicQuality = false,
    this.downloadDateStartRange,
    this.downloadDateEndRange,
    this.uploadDateStartRange,
    this.uploadDateEndRange,
    this.fileSizeStartRange = 0,
    this.fileSizeEndRange = 0, // 1 GB
    this.durationStartRange = 0,
    this.durationEndRange = 0,
  });
}

class AudioSortFilterParameters {
  final List<SortingItem> selectedSortItemLst;
  final List<String> filterSentenceLst;
  final SentencesCombination sentencesCombination;
  final bool ignoreCase;
  final bool searchAsWellInVideoCompactDescription;
  final bool filterMusicQuality;

  AudioSortFilterParameters({
    required this.selectedSortItemLst,
    this.filterSentenceLst = const [],
    required this.sentencesCombination,
    this.ignoreCase = true, // when opening the sort and filter dialog,
    //                         the corresponding checkbox is checked
    this.searchAsWellInVideoCompactDescription = true, // when opening
    //                         the sort and filter dialog, the
    //                         corresponding checkbox is checked
    this.filterMusicQuality = false, // when opening the sort and
    //                         filter dialog, the corresponding
    //                         checkbox is not checked
  });
}
