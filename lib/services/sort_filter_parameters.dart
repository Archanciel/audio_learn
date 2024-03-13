import 'dart:io';

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

  factory SortingItem.fromJson(Map<String, dynamic> json) {
    return SortingItem(
      sortingOption: SortingOption.values[json['sortingOption']],
      isAscending: json['isAscending'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sortingOption': sortingOption.index,
      'isAscending': isAscending,
    };
  }
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
  final int fileSizeStartRangeByte;
  final int fileSizeEndRangeByte;
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
    this.fileSizeStartRangeByte = 0,
    this.fileSizeEndRangeByte = 0,
    this.durationStartRangeSec = 0,
    this.durationEndRangeSec = 0,
  });

  factory AudioSortFilterParameters.fromJson(Map<String, dynamic> json) {
    return AudioSortFilterParameters(
      selectedSortItemLst: (json['selectedSortItemLst'] as List)
          .map((e) => SortingItem.fromJson(e))
          .toList(),
      filterSentenceLst: (json['filterSentenceLst'] as List).cast<String>(),
      sentencesCombination:
          SentencesCombination.values[json['sentencesCombination']],
      ignoreCase: json['ignoreCase'],
      searchAsWellInVideoCompactDescription:
          json['searchAsWellInVideoCompactDescription'],
      filterMusicQuality: json['filterMusicQuality'],
      filterFullyListened: json['filterFullyListened'],
      filterPartiallyListened: json['filterPartiallyListened'],
      filterNotListened: json['filterNotListened'],
      downloadDateStartRange: json['downloadDateStartRange'] == null
          ? null
          : DateTime.parse(json['downloadDateStartRange']),
      downloadDateEndRange: json['downloadDateEndRange'] == null
          ? null
          : DateTime.parse(json['downloadDateEndRange']),
      uploadDateStartRange: json['uploadDateStartRange'] == null
          ? null
          : DateTime.parse(json['uploadDateStartRange']),
      uploadDateEndRange: json['uploadDateEndRange'] == null
          ? null
          : DateTime.parse(json['uploadDateEndRange']),
      fileSizeStartRangeByte: json['fileSizeStartRangeByte'],
      fileSizeEndRangeByte: json['fileSizeEndRangeByte'],
      durationStartRangeSec: json['durationStartRangeSec'],
      durationEndRangeSec: json['durationEndRangeSec'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selectedSortItemLst': selectedSortItemLst,
      'filterSentenceLst': filterSentenceLst,
      'sentencesCombination': sentencesCombination.index,
      'ignoreCase': ignoreCase,
      'searchAsWellInVideoCompactDescription':
          searchAsWellInVideoCompactDescription,
      'filterMusicQuality': filterMusicQuality,
      'filterFullyListened': filterFullyListened,
      'filterPartiallyListened': filterPartiallyListened,
      'filterNotListened': filterNotListened,
      'downloadDateStartRange': downloadDateStartRange?.toIso8601String(),
      'downloadDateEndRange': downloadDateEndRange?.toIso8601String(),
      'uploadDateStartRange': uploadDateStartRange?.toIso8601String(),
      'uploadDateEndRange': uploadDateEndRange?.toIso8601String(),
      'fileSizeStartRangeByte': fileSizeStartRangeByte,
      'fileSizeEndRangeByte': fileSizeEndRangeByte,
      'durationStartRangeSec': durationStartRangeSec,
      'durationEndRangeSec': durationEndRangeSec,
    };
  }
}
