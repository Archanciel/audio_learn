import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../models/audio.dart';
import '../../models/playlist.dart';
import '../../services/audio_sort_filter_service.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/theme_provider_vm.dart';

class SortAndFilterAudioDialogWidget extends StatefulWidget {
  final Playlist selectedPlaylist;
  final List<Audio> selectedPlaylistAudioLst;
  final FocusNode focusNode;

  const SortAndFilterAudioDialogWidget({
    super.key,
    required this.selectedPlaylist,
    required this.selectedPlaylistAudioLst,
    required this.focusNode,
  });

  @override
  _SortAndFilterAudioDialogWidgetState createState() =>
      _SortAndFilterAudioDialogWidgetState();
}

class _SortAndFilterAudioDialogWidgetState
    extends State<SortAndFilterAudioDialogWidget> {
  final InputDecoration _dialogTextFieldDecoration = const InputDecoration(
    isDense: true, //  better aligns the text vertically
    contentPadding: EdgeInsets.all(8),
    border: OutlineInputBorder(),
  );

  // must be initialized with a value included in the list of
  // sorting options, otherwise the dropdown button will not
  // display any value and he app will crash
  late SortingOption _selectedSortingOption;

  late bool _sortAscending;
  late bool _filterMusicQuality;
  late bool _ignoreCase;
  late bool _searchInVideoCompactDescription;

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

  final _audioTitleSubStringFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Add this line to request focus on the TextField after the build
    // method has been called
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(
        _audioTitleSubStringFocusNode,
      );
    });

    _setPlaylistSortFilterOptions();
  }

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
    _audioTitleSubStringFocusNode.dispose();

    super.dispose();
  }

  void _resetSortFilterOptions() {
    _selectedSortingOption = SortingOption.audioDownloadDateTime;
    _sortAscending = false;
    _filterMusicQuality = false;
    _ignoreCase = true;
    _searchInVideoCompactDescription = true;
    _startFileSizeController.clear();
    _endFileSizeController.clear();
    _audioTitleSubStringController.clear();
    _startDownloadDateTimeController.clear();
    _endDownloadDateTimeController.clear();
    _startUploadDateTimeController.clear();
    _endUploadDateTimeController.clear();
    _startAudioDurationController.clear();
    _endAudioDurationController.clear();
    _audioTitleSubString = null;
    _startDownloadDateTime = null;
    _endDownloadDateTime = null;
    _startUploadDateTime = null;
    _endUploadDateTime = null;
  }

  void _setPlaylistSortFilterOptions() {
    _selectedSortingOption = SortingOption.audioDownloadDateTime;
    _sortAscending = false;
    _filterMusicQuality = false;
    _ignoreCase = true;
    _searchInVideoCompactDescription = true;
    _startFileSizeController.clear();
    _endFileSizeController.clear();
    _audioTitleSubStringController.clear();
    _startDownloadDateTimeController.clear();
    _endDownloadDateTimeController.clear();
    _startUploadDateTimeController.clear();
    _endUploadDateTimeController.clear();
    _startAudioDurationController.clear();
    _endAudioDurationController.clear();
    _audioTitleSubString = null;
    _startDownloadDateTime = null;
    _endDownloadDateTime = null;
    _startUploadDateTime = null;
    _endUploadDateTime = null;
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
    ThemeProviderVM themeProviderVM = Provider.of<ThemeProviderVM>(
      context,
      listen: false,
    );
    return Center(
      child: RawKeyboardListener(
        focusNode: widget.focusNode,
        onKey: (event) {
          if (event.isKeyPressed(LogicalKeyboardKey.enter) ||
              event.isKeyPressed(LogicalKeyboardKey.numpadEnter)) {
            // executing the same code as in the 'Apply'
            // TextButton onPressed callback
            List<Audio> sortedAudioLstBySortingOption =
                _filterAndSortAudioLst();
            Navigator.of(context).pop(sortedAudioLstBySortingOption);
          }
        },
        child: AlertDialog(
          title: Text(AppLocalizations.of(context)!.sortFilterDialogTitle),
          actionsPadding:
              // reduces the top vertical space between the buttons
              // and the content
              const EdgeInsets.fromLTRB(
                  10, 0, 10, 10), // Adjust the value as needed
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
                        key: const Key('sortingOptionDropdownButton'),
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
                            // The Flutter ChoiceChip widget is designed
                            // to represent a single choice from a set of
                            // options.
                            key: const Key('sortAscending'),
                            label: Text(
                                AppLocalizations.of(context)!.sortAscending),
                            selected: _sortAscending,
                            onSelected: (bool selected) {
                              setState(() {
                                _sortAscending = selected;
                              });

                              // now clicking on Enter works since the
                              // Checkbox is not focused anymore
                              _audioTitleSubStringFocusNode.requestFocus();
                            },
                          ),
                          ChoiceChip(
                            // The Flutter ChoiceChip widget is designed
                            // to represent a single choice from a set of
                            // options.
                            key: const Key('sortDescending'),
                            label: Text(
                                AppLocalizations.of(context)!.sortDescending),
                            selected: !_sortAscending,
                            onSelected: (bool selected) {
                              setState(() {
                                _sortAscending = !selected;
                              });

                              // now clicking on Enter works since the
                              // Checkbox is not focused anymore
                              _audioTitleSubStringFocusNode.requestFocus();
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
                          focusNode: _audioTitleSubStringFocusNode,
                          style: kDialogTextFieldStyle,
                          decoration: _dialogTextFieldDecoration,
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
                            key: const Key('ignoreCaseCheckbox'),
                            value: _ignoreCase,
                            onChanged: (bool? newValue) {
                              setState(() {
                                _ignoreCase = newValue!;
                              });

                              // now clicking on Enter works since the
                              // Checkbox is not focused anymore
                              _audioTitleSubStringFocusNode.requestFocus();
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(AppLocalizations.of(context)!
                              .searchInVideoCompactDescription),
                          Checkbox(
                            key: const Key('searchInVideoCompactDescription'),
                            value: _searchInVideoCompactDescription,
                            onChanged: (bool? newValue) {
                              setState(() {
                                _searchInVideoCompactDescription = newValue!;
                              });

                              // now clicking on Enter works since the
                              // Checkbox is not focused anymore
                              _audioTitleSubStringFocusNode.requestFocus();
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(AppLocalizations.of(context)!.audioMusicQuality),
                          Checkbox(
                            key: const Key('filterMusicQualityCheckbox'),
                            value: _filterMusicQuality,
                            onChanged: (bool? newValue) {
                              setState(() {
                                _filterMusicQuality = newValue!;
                              });

                              // now clicking on Enter works since the
                              // Checkbox is not focused anymore
                              _audioTitleSubStringFocusNode.requestFocus();
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
                            key: const Key('startDownloadDateIconButton'),
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

                              // now clicking on Enter works since the
                              // Checkbox is not focused anymore
                              _audioTitleSubStringFocusNode.requestFocus();
                            },
                          ),
                          SizedBox(
                            width: 90,
                            height: kDialogTextFieldHeight,
                            child: TextField(
                              key: const Key('startDownloadDateTextField'),
                              style: kDialogTextFieldStyle,
                              decoration: _dialogTextFieldDecoration,
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
                            key: const Key('endDownloadDateIconButton'),
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

                              // now clicking on Enter works since the
                              // Checkbox is not focused anymore
                              _audioTitleSubStringFocusNode.requestFocus();
                            },
                          ),
                          SizedBox(
                            width: 90,
                            height: kDialogTextFieldHeight,
                            child: TextField(
                              key: const Key('endDownloadDateTextField'),
                              style: kDialogTextFieldStyle,
                              decoration: _dialogTextFieldDecoration,
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
                            key: const Key('startUploadDateIconButton'),
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

                              // now clicking on Enter works since the
                              // Checkbox is not focused anymore
                              _audioTitleSubStringFocusNode.requestFocus();
                            },
                          ),
                          SizedBox(
                            width: 90,
                            height: kDialogTextFieldHeight,
                            child: TextField(
                              key: const Key('startUploadDateTextField'),
                              style: kDialogTextFieldStyle,
                              decoration: _dialogTextFieldDecoration,
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
                            key: const Key('endUploadDateIconButton'),
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

                              // now clicking on Enter works since the
                              // Checkbox is not focused anymore
                              _audioTitleSubStringFocusNode.requestFocus();
                            },
                          ),
                          SizedBox(
                            key: const Key('endUploadDateTextField'),
                            width: 90,
                            height: kDialogTextFieldHeight,
                            child: TextField(
                              style: kDialogTextFieldStyle,
                              decoration: _dialogTextFieldDecoration,
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
                              key: const Key('startFileSizeTextField'),
                              style: kDialogTextFieldStyle,
                              decoration: _dialogTextFieldDecoration,
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
                              key: const Key('endFileSizeTextField'),
                              style: kDialogTextFieldStyle,
                              decoration: _dialogTextFieldDecoration,
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
                              key:
                                  const Key('audioDurationRangeStartTextField'),
                              style: kDialogTextFieldStyle,
                              decoration: _dialogTextFieldDecoration,
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
                              key: const Key('audioDurationRangeEndTextField'),
                              style: kDialogTextFieldStyle,
                              decoration: _dialogTextFieldDecoration,
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
            IconButton(
              key: const Key('resetSortFilterOptionsIconButton'),
              icon: const Icon(Icons.clear),
              onPressed: () async {
                _resetSortFilterOptions();

                // now clicking on Enter works since the
                // Checkbox is not focused anymore
                _audioTitleSubStringFocusNode.requestFocus();
              },
            ),
            IconButton(
              key: const Key('setPlaylistSortFilterOptionsIconButton'),
              icon: const Icon(Icons.perm_data_setting),
              onPressed: () async {
                _setPlaylistSortFilterOptions();

                // now clicking on Enter works since the
                // Checkbox is not focused anymore
                _audioTitleSubStringFocusNode.requestFocus();
              },
            ),
            TextButton(
              key: const Key('applySortFilterButton'),
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
                List<Audio> sortedAudioLstBySortingOption =
                    _filterAndSortAudioLst();
                Navigator.of(context).pop(sortedAudioLstBySortingOption);
              },
              child: Text(
                AppLocalizations.of(context)!.apply,
                style: (themeProviderVM.currentTheme == AppTheme.dark)
                    ? kTextButtonStyleDarkMode
                    : kTextButtonStyleLightMode,
              ),
            ),
            TextButton(
              key: const Key('cancelSortFilterButton'),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: (themeProviderVM.currentTheme == AppTheme.dark)
                    ? kTextButtonStyleDarkMode
                    : kTextButtonStyleLightMode,
              ),
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
