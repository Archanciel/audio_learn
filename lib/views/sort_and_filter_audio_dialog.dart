import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/audio.dart';
import '../utils/time_util.dart';

class SortAndFilterAudioDialog extends StatefulWidget {
  const SortAndFilterAudioDialog({super.key});

  @override
  _SortAndFilterAudioDialogState createState() =>
      _SortAndFilterAudioDialogState();
}

class _SortAndFilterAudioDialogState extends State<SortAndFilterAudioDialog> {
  // must be initialized with a value included in the list of
  // sorting options, otherwise the dropdown button will not
  // display any value and he app will crash
  late String _selectedSortingOption =
      AppLocalizations.of(context)!.audioDownloadDateTime;

  bool _sortAscending = true;
  bool _filterMusicQuality = false;
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
  String? _audioTitleSubString;
  DateTime _startDownloadDateTime = DateTime.now();
  DateTime _endDownloadDateTime = DateTime.now();
  DateTime _startUploadDateTime = DateTime.now();
  DateTime _endUploadDateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
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
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    DropdownButton<String>(
                      value: _selectedSortingOption,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedSortingOption = newValue!;
                        });
                      },
                      items: <String>[
                        AppLocalizations.of(context)!.audioDownloadDateTime,
                        AppLocalizations.of(context)!.videoUploadDate,
                        AppLocalizations.of(context)!.videoTitle,
                        AppLocalizations.of(context)!
                            .audioEnclosingPlaylistTitle,
                        AppLocalizations.of(context)!.audioDuration,
                        AppLocalizations.of(context)!.audioFileSize,
                        AppLocalizations.of(context)!.audioMusicQuality,
                        AppLocalizations.of(context)!.audioDownloadSpeed,
                        AppLocalizations.of(context)!.audioDownloadDuration,
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    Row(
                      children: [
                        const Text('Sort Ascending:'),
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
                    const Divider(),
                    const Text(
                      'Filter Options:',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('Audio Title Substring:'),
                    TextField(
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        hintText: '',
                        isDense:
                            true, // You can try adding isDense: true to better align the text vertically
                        contentPadding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                        border: InputBorder.none,
                      ),
                      controller: _audioTitleSubStringController,
                      keyboardType: TextInputType.text,
                      onChanged: (value) {
                        _audioTitleSubString = value;
                      },
                    ),
                    Row(
                      children: [
                        const Text('Music Quality:'),
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 120,
                          child: Text('Start downl date'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_month_rounded),
                          onPressed: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: _startDownloadDateTime,
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );

                            if (pickedDate != null) {
                              // Add this check
                              _startDownloadDateTime = pickedDate;
                              _startDownloadDateTimeController.text =
                                  DateFormat('dd-MM-yyyy')
                                      .format(_startDownloadDateTime);
                            }
                          },
                        ),
                        SizedBox(
                          width: 80,
                          child: TextField(
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: const InputDecoration(
                              hintText: '',
                              isDense:
                                  true, // You can try adding isDense: true to better align the text vertically
                              contentPadding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                              border: InputBorder.none,
                            ),
                            controller: _startDownloadDateTimeController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 120,
                          child: Text('End downl date'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_month_rounded),
                          onPressed: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: _endDownloadDateTime,
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );

                            if (pickedDate != null) {
                              // Add this check
                              _endDownloadDateTime = pickedDate;
                              _endDownloadDateTimeController.text =
                                  DateFormat('dd-MM-yyyy')
                                      .format(_endDownloadDateTime);
                            }
                          },
                        ),
                        SizedBox(
                          width: 80,
                          child: TextField(
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: const InputDecoration(
                              hintText: '',
                              isDense:
                                  true, // You can try adding isDense: true to better align the text vertically
                              contentPadding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                              border: InputBorder.none,
                            ),
                            controller: _endDownloadDateTimeController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 120,
                          child: Text('Start upl date'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_month_rounded),
                          onPressed: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: _startUploadDateTime,
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );

                            if (pickedDate != null) {
                              // Add this check
                              _startUploadDateTime = pickedDate;
                              _startUploadDateTimeController.text =
                                  DateFormat('dd-MM-yyyy')
                                      .format(_startUploadDateTime);
                            }
                          },
                        ),
                        SizedBox(
                          width: 80,
                          child: TextField(
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: const InputDecoration(
                              hintText: '',
                              isDense:
                                  true, // You can try adding isDense: true to better align the text vertically
                              contentPadding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                              border: InputBorder.none,
                            ),
                            controller: _startUploadDateTimeController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 120,
                          child: Text('End downl date'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_month_rounded),
                          onPressed: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: _endUploadDateTime,
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );

                            if (pickedDate != null) {
                              // Add this check
                              _endUploadDateTime = pickedDate;
                              _endUploadDateTimeController.text =
                                  DateFormat('dd-MM-yyyy')
                                      .format(_endUploadDateTime);
                            }
                          },
                        ),
                        SizedBox(
                          width: 80,
                          child: TextField(
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: const InputDecoration(
                              hintText: '',
                              isDense:
                                  true, // You can try adding isDense: true to better align the text vertically
                              contentPadding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                              border: InputBorder.none,
                            ),
                            controller: _endUploadDateTimeController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const Text('File Size Range (bytes):'),
                    Row(
                      children: [
                        const Text('Start:'),
                        SizedBox(
                          width: 50,
                          child: TextField(
                            controller: _startFileSizeController,
                            keyboardType: TextInputType.number,
                            maxLength: 9,
                          ),
                        ),
                        const SizedBox(width: 20),
                        const Text('End:'),
                        SizedBox(
                          width: 50,
                          child: TextField(
                            controller: _endFileSizeController,
                            keyboardType: TextInputType.number,
                            maxLength: 9,
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
                  'Start download date: ${_startDownloadDateTime.toIso8601String()}');
              print(
                  'End download date: ${_endDownloadDateTime.toIso8601String()}');
              print(
                  'Start upload date: ${_startUploadDateTime.toIso8601String()}');
              print('End upload date: ${_endUploadDateTime.toIso8601String()}');
              print(
                  'File size range: ${_startFileSizeController.text} - ${_endFileSizeController.text}');
              Navigator.of(context).pop();
            },
            child: const Text('Apply'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
