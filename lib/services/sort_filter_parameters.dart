import '../models/audio.dart';

const int sortAscending = 1;
const int sortDescending = -1;

class SortCriteria<T> {
  final Comparable Function(T) selectorFunction;
  final int sortOrder;

  SortCriteria({
    required this.selectorFunction,
    required this.sortOrder,
  });
}

class AudioSortFilterParameters {
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

  AudioSortFilterParameters({
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
