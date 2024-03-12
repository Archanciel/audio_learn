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

class AudioSortFilterParameters {
  final List<SortingItem> selectedSortItemLst;
  final List<String> filterSentenceLst;
  final SentencesCombination sentencesCombination;
  final bool ignoreCase;
  final bool searchAsWellInVideoCompactDescription;
  final bool filterMusicQuality;
final bool filterFullyListened;
    final bool filterPartiallyListened;
    final bool filterNotListened;

  final DateTime? downloadDateStartRange;
  final DateTime? downloadDateEndRange;
  final DateTime? uploadDateStartRange;
  final DateTime? uploadDateEndRange;
  final int fileSizeStartRangeSec;
  final int fileSizeEndRangeSec;
  final int durationStartRangeSec;
  final int durationEndRangeSec;

  AudioSortFilterParameters({
    required this.selectedSortItemLst,
    this.filterSentenceLst = const [],
    required this.sentencesCombination,
    this.ignoreCase = true, //                  when opening the sort and filter
    this.searchAsWellInVideoCompactDescription = true, // dialog, corresponding
    this.filterMusicQuality = false, //         checkbox's are not checked
    this.filterFullyListened = true,
    this.filterPartiallyListened = true,
    this.filterNotListened = true,
    this.downloadDateStartRange,
    this.downloadDateEndRange,
    this.uploadDateStartRange,
    this.uploadDateEndRange,
    this.fileSizeStartRangeSec = 0,
    this.fileSizeEndRangeSec = 0,
    this.durationStartRangeSec = 0,
    this.durationEndRangeSec = 0,
  });
}
