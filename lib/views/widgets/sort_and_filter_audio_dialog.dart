import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../constants.dart';
import '../../models/audio.dart';
import '../../services/audio_sort_filter_service.dart';

class SortAndFilterAudioDialog extends StatefulWidget {
  final List<Audio> selectedPlaylistAudioLst;

  const SortAndFilterAudioDialog({
    super.key,
    required this.selectedPlaylistAudioLst,
  });

  @override
  _SortAndFilterAudioDialogState createState() =>
      _SortAndFilterAudioDialogState();
}

class _SortAndFilterAudioDialogState extends State<SortAndFilterAudioDialog> {
  // must be initialized with a value included in the list of
  // sorting options, otherwise the dropdown button will not
  // display any value and he app will crash
  SortingOption _selectedSortingOption = SortingOption.audioDownloadDateTime;

  bool _sortAscending = false;
  bool _filterMusicQuality = false;
  final TextEditingController _startFileSizeController =
      TextEditingController();
  final TextEditingController _endFileSizeController = TextEditingController();
  final TextEditingController _videoTitleOrDescriptionController =
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
        return AppLocalizations.of(context)!.validAudioTitle;
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
      default:
        throw ArgumentError('Invalid sorting option');
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();

    return Center(
      child: AlertDialog(
        title: Text(AppLocalizations.of(context)!.sortFilterDialogTitle),
        content: SizedBox(
          width: double.maxFinite,
          height: 800,
          child: DraggableScrollableSheet(
            initialChildSize: 1,
            minChildSize: 1,
            maxChildSize: 1,
            builder: (BuildContext context, ScrollController scrollController) {
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
                        Text(AppLocalizations.of(context)!.sortAscending),
                        Checkbox(
                          value: _sortAscending,
                          onChanged: (bool? newValue) {
                            setState(() {
                              _sortAscending = newValue!;
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
                        style: kDialogTextFieldStyle,
                        decoration: kDialogTextFieldDecoration,
                        controller: _videoTitleOrDescriptionController,
                        keyboardType: TextInputType.text,
                        onChanged: (value) {
                          _audioTitleSubString = value;
                        },
                      ),
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
                          child: Text(
                              AppLocalizations.of(context)!.startDownloadDate),
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
                          child:
                              Text(AppLocalizations.of(context)!.endUploadDate),
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
              AudioSortFilterService audioSortFilterService =
                  AudioSortFilterService();
              List<Audio> sortedAudioLstBySortingOption =
                  audioSortFilterService.sortAudioLstBySortingOption(
                audioLst: widget.selectedPlaylistAudioLst,
                sortingOption: _selectedSortingOption,
                asc: _sortAscending,
              );
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
    );
  }
}
