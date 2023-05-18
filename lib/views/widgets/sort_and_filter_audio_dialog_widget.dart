import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../constants.dart';
import '../../models/audio.dart';
import '../../services/audio_sort_filter_service.dart';

class SortAndFilterAudioDialogWidget extends StatefulWidget {
  final List<Audio> selectedPlaylistAudioLst;
  final FocusNode focusNode;

  const SortAndFilterAudioDialogWidget({
    super.key,
    required this.selectedPlaylistAudioLst,
    required this.focusNode,
  });

  @override
  _SortAndFilterAudioDialogWidgetState createState() =>
      _SortAndFilterAudioDialogWidgetState();
}

class _SortAndFilterAudioDialogWidgetState
    extends State<SortAndFilterAudioDialogWidget> {
  // must be initialized with a value included in the list of
  // sorting options, otherwise the dropdown button will not
  // display any value and he app will crash
  SortingOption _selectedSortingOption = SortingOption.audioDownloadDateTime;

  bool _sortAscending = false;
  bool _filterMusicQuality = false;
  bool _ignoreCase = false;
  bool _searchInVideoCompactDescription = false;

  final TextEditingController _startFileSizeController =
      TextEditingController();
  final TextEditingController _endFileSizeController = TextEditingController();
  final TextEditingController _audioTitleSubStringController =
      TextEditingController();
  final TextEditingController _startDownloadDateTimeController =
      TextEditingController();
  final TextEditingController _endDownloadDateTimeController =
      TextEditingController();
  final TextEditingController _startUploadDateTimeController =
      TextEditingController();
  final TextEditingController _endUploadDateTimeController =
      TextEditingController();
  final TextEditingController _startAudioDurationController =
      TextEditingController();
  final TextEditingController _endAudioDurationController =
      TextEditingController();
  String? _audioTitleSubString;
  DateTime? _startDownloadDateTime;
  DateTime? _endDownloadDateTime;
  DateTime? _startUploadDateTime;
  DateTime? _endUploadDateTime;

  @override
  void dispose() {
    _startFileSizeController.dispose();
    _endFileSizeController.dispose();
    _audioTitleSubStringController.dispose();
    _startDownloadDateTimeController.dispose();
    _endDownloadDateTimeController.dispose();
    _startUploadDateTimeController.dispose();
    _endUploadDateTimeController.dispose();
    _startAudioDurationController.dispose();
    _endAudioDurationController.dispose();
    super.dispose();
  }
  
  String _sortingOptionToString(
    SortingOption option,
    BuildContext context,
  ) {
    switch (option) {
      case SortingOption.audioDownloadDateTime:
        return AppLocalizations.of(context)!.audioDownloadDateTime;
      case SortingOption.videoUploadDate:
        return AppLocalizations.of(context)!.videoUploadDate;
      case SortingOption.validAudioTitle:
        return AppLocalizations.of(context)!.validVideoTitleLabel;
      case SortingOption.audioEnclosingPlaylistTitle:
        return AppLocalizations.of(context)!.audioEnclosingPlaylistTitle;
      case SortingOption.audioDuration:
        return AppLocalizations.of(context)!.audioDuration;
      case SortingOption.audioFileSize:
        return AppLocalizations.of(context)!.audioFileSize;
      case SortingOption.audioMusicQuality:
        return AppLocalizations.of(context)!.audioMusicQuality;
      case SortingOption.audioDownloadSpeed:
        return AppLocalizations.of(context)!.audioDownloadSpeed;
      case SortingOption.audioDownloadDuration:
        return AppLocalizations.of(context)!.audioDownloadDuration;
      case SortingOption.videoUrl:
        return AppLocalizations.of(context)!.videoUrlLabel;
      default:
        throw ArgumentError('Invalid sorting option');
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();

    return Center(
      child: RawKeyboardListener(
        focusNode: widget.focusNode,
        onKey: (event) {
          if (event.isKeyPressed(LogicalKeyboardKey.enter) ||
              event.isKeyPressed(LogicalKeyboardKey.numpadEnter)) {
            List<Audio> sortedAudioLstBySortingOption = _filterAndSortAudioLst();
            Navigator.of(context).pop(sortedAudioLstBySortingOption);
          }
        },
        child: AlertDialog(
          title: Text(AppLocalizations.of(context)!.sortFilterDialogTitle),
          content: SizedBox(
            width: double.maxFinite,
            height: 800,
            child: DraggableScrollableSheet(
              initialChildSize: 1,
              minChildSize: 1,
              maxChildSize: 1,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.sortBy,
                        style: kDialogTitlesStyle,
                      ),
                      DropdownButton<SortingOption>(
                        value: _selectedSortingOption,
                        onChanged: (SortingOption? newValue) {
                          setState(() {
                            _selectedSortingOption = newValue!;
                            _sortAscending = AudioSortFilterService
                                .sortingOptionToAscendingMap[newValue]!;
                          });
                        },
                        items: SortingOption.values
                            .map<DropdownMenuItem<SortingOption>>(
                                (SortingOption value) {
                          return DropdownMenuItem<SortingOption>(
                            value: value,
                            child: Text(_sortingOptionToString(value, context)),
                          );
                        }).toList(),
                      ),
                      Row(
                        children: [
                          ChoiceChip(
                            key: const Key('sortAscending'),
                            label: Text(
                                AppLocalizations.of(context)!.sortAscending),
                            selected: _sortAscending,
                            onSelected: (bool selected) {
                              setState(() {
                                _sortAscending = selected;
                              });
                            },
                          ),
                          ChoiceChip(
                            key: const Key('sortDescending'),
                            label: Text(
                                AppLocalizations.of(context)!.sortDescending),
                            selected: !_sortAscending,
                            onSelected: (bool selected) {
                              setState(() {
                                _sortAscending = !selected;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        AppLocalizations.of(context)!.filterOptions,
                        style: kDialogTitlesStyle,
                      ),
                      const SizedBox(
                        height: 14,
                      ),
                      Text(
                        AppLocalizations.of(context)!.videoTitleOrDescription,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      SizedBox(
                        height: kDialogTextFieldHeight,
                        child: TextField(
                          key: const Key('audioTitleSubStringTextField'),
                          style: kDialogTextFieldStyle,
                          decoration: kDialogTextFieldDecoration,
                          controller: _audioTitleSubStringController,
                          keyboardType: TextInputType.text,
                          onChanged: (value) {
                            _audioTitleSubString = value;
                          },
                        ),
                      ),
                      Row(
                        children: [
                          Text(AppLocalizations.of(context)!.ignoreCase),
                          Checkbox(
                            value: _ignoreCase,
                            onChanged: (bool? newValue) {
                              setState(() {
                                _ignoreCase = newValue!;
                              });
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(AppLocalizations.of(context)!
                              .searchInVideoCompactDescription),
                          Checkbox(
                            value: _searchInVideoCompactDescription,
                            onChanged: (bool? newValue) {
                              setState(() {
                                _searchInVideoCompactDescription = newValue!;
                              });
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(AppLocalizations.of(context)!.audioMusicQuality),
                          Checkbox(
                            value: _filterMusicQuality,
                            onChanged: (bool? newValue) {
                              setState(() {
                                _filterMusicQuality = newValue!;
                              });
                            },
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(AppLocalizations.of(context)!
                                .startDownloadDate),
                          ),
                          IconButton(
                            icon: const Icon(Icons.calendar_month_rounded),
                            onPressed: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: now,
                                firstDate: DateTime(2000),
                                lastDate: now,
                              );

                              if (pickedDate != null) {
                                // Add this check
                                _startDownloadDateTime = pickedDate;
                                _startDownloadDateTimeController.text =
                                    DateFormat('dd-MM-yyyy')
                                        .format(_startDownloadDateTime!);
                              }
                            },
                          ),
                          SizedBox(
                            width: 90,
                            height: kDialogTextFieldHeight,
                            child: TextField(
                              style: kDialogTextFieldStyle,
                              decoration: kDialogTextFieldDecoration,
                              controller: _startDownloadDateTimeController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(
                                AppLocalizations.of(context)!.endDownloadDate),
                          ),
                          IconButton(
                            icon: const Icon(Icons.calendar_month_rounded),
                            onPressed: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: now,
                                firstDate: DateTime(2000),
                                lastDate: now,
                              );

                              if (pickedDate != null) {
                                // Add this check
                                _endDownloadDateTime = pickedDate;
                                _endDownloadDateTimeController.text =
                                    DateFormat('dd-MM-yyyy')
                                        .format(_endDownloadDateTime!);
                              }
                            },
                          ),
                          SizedBox(
                            width: 90,
                            height: kDialogTextFieldHeight,
                            child: TextField(
                              style: kDialogTextFieldStyle,
                              decoration: kDialogTextFieldDecoration,
                              controller: _endDownloadDateTimeController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(
                                AppLocalizations.of(context)!.startUploadDate),
                          ),
                          IconButton(
                            icon: const Icon(Icons.calendar_month_rounded),
                            onPressed: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: now,
                                firstDate: DateTime(2000),
                                lastDate: now,
                              );

                              if (pickedDate != null) {
                                // Add this check
                                _startUploadDateTime = pickedDate;
                                _startUploadDateTimeController.text =
                                    DateFormat('dd-MM-yyyy')
                                        .format(_startUploadDateTime!);
                              }
                            },
                          ),
                          SizedBox(
                            width: 90,
                            height: kDialogTextFieldHeight,
                            child: TextField(
                              style: kDialogTextFieldStyle,
                              decoration: kDialogTextFieldDecoration,
                              controller: _startUploadDateTimeController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(
                                AppLocalizations.of(context)!.endUploadDate),
                          ),
                          IconButton(
                            icon: const Icon(Icons.calendar_month_rounded),
                            onPressed: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: now,
                                firstDate: DateTime(2000),
                                lastDate: now,
                              );

                              if (pickedDate != null) {
                                // Add this check
                                _endUploadDateTime = pickedDate;
                                _endUploadDateTimeController.text =
                                    DateFormat('dd-MM-yyyy')
                                        .format(_endUploadDateTime!);
                              }
                            },
                          ),
                          SizedBox(
                            width: 90,
                            height: kDialogTextFieldHeight,
                            child: TextField(
                              style: kDialogTextFieldStyle,
                              decoration: kDialogTextFieldDecoration,
                              controller: _endUploadDateTimeController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(AppLocalizations.of(context)!.fileSizeRange),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(AppLocalizations.of(context)!.start),
                          SizedBox(
                            width: 85,
                            height: kDialogTextFieldHeight,
                            child: TextField(
                              style: kDialogTextFieldStyle,
                              decoration: kDialogTextFieldDecoration,
                              controller: _startFileSizeController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(AppLocalizations.of(context)!.end),
                          SizedBox(
                            width: 85,
                            height: kDialogTextFieldHeight,
                            child: TextField(
                              style: kDialogTextFieldStyle,
                              decoration: kDialogTextFieldDecoration,
                              controller: _endFileSizeController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(AppLocalizations.of(context)!.audioDurationRange),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(AppLocalizations.of(context)!.start),
                          SizedBox(
                            width: 85,
                            height: kDialogTextFieldHeight,
                            child: TextField(
                              style: kDialogTextFieldStyle,
                              decoration: kDialogTextFieldDecoration,
                              controller: _startAudioDurationController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(AppLocalizations.of(context)!.end),
                          SizedBox(
                            width: 85,
                            height: kDialogTextFieldHeight,
                            child: TextField(
                              style: kDialogTextFieldStyle,
                              decoration: kDialogTextFieldDecoration,
                              controller: _endAudioDurationController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Apply sorting and filtering options
                print('Sorting option: $_selectedSortingOption');
                print('Sort ascending: $_sortAscending');
                print('Filter by music quality: $_filterMusicQuality');
                print('Audio title substring: $_audioTitleSubString');
                print(
                    'Start download date: ${(_startDownloadDateTime != null) ? _startDownloadDateTime!.toIso8601String() : ''}');
                print(
                    'End download date: ${(_endDownloadDateTime != null) ? _endDownloadDateTime!.toIso8601String() : ''}');
                print(
                    'Start upload date: ${(_startUploadDateTime != null) ? _startUploadDateTime!.toIso8601String() : ''}');
                print(
                    'End upload date: ${(_endUploadDateTime != null) ? _endUploadDateTime!.toIso8601String() : ''}');
                print(
                    'File size range: ${_startFileSizeController.text} - ${_endFileSizeController.text}');
                print(
                    'Audio duration range: ${_startAudioDurationController.text} - ${_endAudioDurationController.text}');
            List<Audio> sortedAudioLstBySortingOption = _filterAndSortAudioLst();
            Navigator.of(context).pop(sortedAudioLstBySortingOption);
                Navigator.of(context).pop(sortedAudioLstBySortingOption);
              },
              child: Text(AppLocalizations.of(context)!.apply),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
          ],
        ),
      ),
    );
  }

  List<Audio> _filterAndSortAudioLst() {
    List<Audio> sortedAudioLstBySortingOption =
        AudioSortFilterService().filterAndSortAudioLst(
      audioLst: widget.selectedPlaylistAudioLst,
      sortingOption: _selectedSortingOption,
      searchWords: _audioTitleSubString,
      ignoreCase: _ignoreCase,
      searchInVideoCompactDescription: _searchInVideoCompactDescription,
      asc: _sortAscending,
    );
    
    return sortedAudioLstBySortingOption;
  }
}
