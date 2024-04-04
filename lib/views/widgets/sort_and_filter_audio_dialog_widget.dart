import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../services/sort_filter_parameters.dart';
import '../screen_mixin.dart';
import '../../models/audio.dart';
import '../../services/audio_sort_filter_service.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/theme_provider_vm.dart';

class SortAndFilterAudioDialogWidget extends StatefulWidget {
  final List<Audio> selectedPlaylistAudioLst;
  AudioSortFilterParameters audioSortFilterParameters;
  AudioSortFilterParameters audioSortPlaylistFilterParameters;
  final AudioLearnAppViewType audioLearnAppViewType;
  final FocusNode focusNode;

  SortAndFilterAudioDialogWidget({
    super.key,
    required this.selectedPlaylistAudioLst,
    required this.audioSortFilterParameters,
    required this.audioSortPlaylistFilterParameters,
    required this.audioLearnAppViewType,
    required this.focusNode,
  });

  @override
  _SortAndFilterAudioDialogWidgetState createState() =>
      _SortAndFilterAudioDialogWidgetState();
}

class _SortAndFilterAudioDialogWidgetState
    extends State<SortAndFilterAudioDialogWidget> with ScreenMixin {
  final InputDecoration _dialogTextFieldDecoration = const InputDecoration(
    isDense: true, //  better aligns the text vertically
    contentPadding: EdgeInsets.all(5),
    border: OutlineInputBorder(),
  );

  late final List<String> _audioTitleFilterSentencesLst = [];

  late List<SortingItem> _selectedSortingItemLst;
  late bool _isAnd;
  late bool _isOr;
  late bool _ignoreCase;
  late bool _searchInVideoCompactDescription;
  late bool _filterMusicQuality;
  late bool _filterFullyListened;
  late bool _filterPartiallyListened;
  late bool _filterNotListened;

  final TextEditingController _startFileSizeController =
      TextEditingController();
  final TextEditingController _endFileSizeController = TextEditingController();
  final TextEditingController _audioTitleSearchSentenceController =
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
  String _audioTitleSearchSentence = '';
  DateTime? _startDownloadDateTime;
  DateTime? _endDownloadDateTime;
  DateTime? _startUploadDateTime;
  DateTime? _endUploadDateTime;

  final _audioTitleSearchSentenceFocusNode = FocusNode();

  Color _audioTitleSearchSentencePlusButtonIconColor =
      kDarkAndLightDisabledIconColorOnDialog;

  final AudioSortFilterService _audioSortFilterService =
      AudioSortFilterService();

  @override
  void initState() {
    super.initState();

    // Add this line to request focus on the TextField after the build
    // method has been called
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(
        _audioTitleSearchSentenceFocusNode,
      );
    });

    // Set the initial sort and filter fields
    AudioSortFilterParameters audioSortDefaultFilterParameters =
        widget.audioSortPlaylistFilterParameters;

    _selectedSortingItemLst = [];
    _selectedSortingItemLst
        .addAll(audioSortDefaultFilterParameters.selectedSortItemLst);
    _audioTitleFilterSentencesLst
        .addAll(audioSortDefaultFilterParameters.filterSentenceLst);
    _ignoreCase = audioSortDefaultFilterParameters.ignoreCase;
    _searchInVideoCompactDescription =
        widget.audioSortFilterParameters.searchAsWellInVideoCompactDescription;
    _isAnd = (audioSortDefaultFilterParameters.sentencesCombination ==
        SentencesCombination.AND);
    _isOr = !_isAnd;
    _filterMusicQuality = audioSortDefaultFilterParameters.filterMusicQuality;
    _filterFullyListened = audioSortDefaultFilterParameters.filterFullyListened;
    _filterPartiallyListened =
        audioSortDefaultFilterParameters.filterPartiallyListened;
    _filterNotListened = audioSortDefaultFilterParameters.filterNotListened;
  }

  @override
  void dispose() {
    _startFileSizeController.dispose();
    _endFileSizeController.dispose();
    _audioTitleSearchSentenceController.dispose();
    _startDownloadDateTimeController.dispose();
    _endDownloadDateTimeController.dispose();
    _startUploadDateTimeController.dispose();
    _endUploadDateTimeController.dispose();
    _startAudioDurationController.dispose();
    _endAudioDurationController.dispose();
    _audioTitleSearchSentenceFocusNode.dispose();

    super.dispose();
  }

  void _resetSortFilterOptions() {
    _selectedSortingItemLst.clear();
    _selectedSortingItemLst
        .addAll(widget.audioSortFilterParameters.selectedSortItemLst);
    _audioTitleSearchSentenceController.clear();
    _audioTitleFilterSentencesLst.clear();
    _ignoreCase = true;
    _searchInVideoCompactDescription = true;
    _isAnd = true;
    _isOr = false;
    _filterMusicQuality = false;
    _filterFullyListened = true;
    _filterPartiallyListened = true;
    _filterNotListened = true;
    _startDownloadDateTimeController.clear();
    _endDownloadDateTimeController.clear();
    _startUploadDateTimeController.clear();
    _endUploadDateTimeController.clear();
    _startAudioDurationController.clear();
    _endAudioDurationController.clear();
    _startFileSizeController.clear();
    _endFileSizeController.clear();
  }

  void _setPlaylistSortFilterOptions() {
    AudioSortFilterParameters audioSortPlaylistFilterParameters =
        widget.audioSortPlaylistFilterParameters;

    _selectedSortingItemLst.clear();
    _selectedSortingItemLst
        .addAll(audioSortPlaylistFilterParameters.selectedSortItemLst);
    _audioTitleSearchSentenceController.clear();
    _audioTitleFilterSentencesLst.clear();
    _audioTitleFilterSentencesLst
        .addAll(audioSortPlaylistFilterParameters.filterSentenceLst);
    _ignoreCase = audioSortPlaylistFilterParameters.ignoreCase;
    _searchInVideoCompactDescription =
        audioSortPlaylistFilterParameters.searchAsWellInVideoCompactDescription;
    _isAnd = (audioSortPlaylistFilterParameters.sentencesCombination ==
        SentencesCombination.AND);
    _isOr = !_isAnd;
    _filterMusicQuality = audioSortPlaylistFilterParameters.filterMusicQuality;
    _filterFullyListened =
        audioSortPlaylistFilterParameters.filterFullyListened;
    _filterPartiallyListened =
        audioSortPlaylistFilterParameters.filterPartiallyListened;
    _filterNotListened = audioSortPlaylistFilterParameters.filterNotListened;
    _startDownloadDateTimeController.text =
        (audioSortPlaylistFilterParameters.downloadDateStartRange != null)
            ? audioSortPlaylistFilterParameters.downloadDateStartRange
                .toString()
            : '';
    _endDownloadDateTimeController.text =
        (audioSortPlaylistFilterParameters.downloadDateEndRange != null)
            ? audioSortPlaylistFilterParameters.downloadDateEndRange.toString()
            : '';
    _startUploadDateTimeController.text =
        (audioSortPlaylistFilterParameters.uploadDateStartRange != null)
            ? audioSortPlaylistFilterParameters.uploadDateStartRange.toString()
            : '';
    _endUploadDateTimeController.text =
        (audioSortPlaylistFilterParameters.uploadDateEndRange != null)
            ? audioSortPlaylistFilterParameters.uploadDateEndRange.toString()
            : '';
    _startAudioDurationController.text =
        (audioSortPlaylistFilterParameters.durationStartRangeSec != null)
            ? audioSortPlaylistFilterParameters.durationStartRangeSec.toString()
            : '';
    _endAudioDurationController.text =
        (audioSortPlaylistFilterParameters.durationEndRangeSec != null)
            ? audioSortPlaylistFilterParameters.durationEndRangeSec.toString()
            : '';
    _startFileSizeController.text =
        (audioSortPlaylistFilterParameters.fileSizeStartRangeByte != null)
            ? audioSortPlaylistFilterParameters.fileSizeStartRangeByte
                .toString()
            : '';
    _endFileSizeController.text =
        (audioSortPlaylistFilterParameters.fileSizeEndRangeByte != null)
            ? audioSortPlaylistFilterParameters.fileSizeEndRangeByte.toString()
            : '';
  }

  SortingItem _getInitialSortingItem() {
    return _audioSortFilterService.getDefaultSortingItem();
  }

  String _sortingOptionToString(
    SortingOption option,
    BuildContext context,
  ) {
    switch (option) {
      case SortingOption.audioDownloadDate:
        return AppLocalizations.of(context)!.audioDownloadDate;
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
      child: KeyboardListener(
        focusNode: widget.focusNode,
        onKeyEvent: (event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.numpadEnter) {
              // executing the same code as in the 'Apply'
              // TextButton onPressed callback
              List<dynamic> filterSortAudioAndParmLst =
                  _filterAndSortAudioLst();
              Navigator.of(context).pop(filterSortAudioAndParmLst);
            }
          }
        },
        child: AlertDialog(
          title: Text(AppLocalizations.of(context)!.sortFilterDialogTitle),
          actionsPadding:
              // reduces the top vertical space between the buttons
              // and the content
              kDialogActionsPadding,
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
                  child: ListBody(
                    // mainAxisAlignment: MainAxisAlignment.start,
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.saveAs,
                        style: kDialogTitlesStyle,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      SizedBox(
                        width: 200,
                        child: Tooltip(
                          message: AppLocalizations.of(context)!
                              .audioTitleSearchSentenceTextFieldTooltip,
                          child: TextField(
                            key: const Key('audioTitleSearchSentenceTextField'),
                            focusNode: _audioTitleSearchSentenceFocusNode,
                            style: kDialogTextFieldStyle,
                            decoration: _dialogTextFieldDecoration,
                            controller: _audioTitleSearchSentenceController,
                            keyboardType: TextInputType.text,
                            onChanged: (value) {
                              _audioTitleSearchSentence = value;
                              _audioTitleSearchSentencePlusButtonIconColor =
                                  _audioTitleSearchSentence.isNotEmpty
                                      ? kDarkAndLightIconColor
                                      : kDarkAndLightDisabledIconColorOnDialog;

                              setState(
                                  () {}); // necessary to update Plus button color
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        AppLocalizations.of(context)!.sortBy,
                        style: kDialogTitlesStyle,
                      ),
                      _buildSortingChoiceList(context),
                      _buildSelectedSortingList(),
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
                      _buildAudioFilterSentence(),
                      _buildAudioFilterSentencesLst(),
                      Row(
                        children: <Widget>[
                          Tooltip(
                            message: AppLocalizations.of(context)!
                                .andSentencesTooltip,
                            child: Text(AppLocalizations.of(context)!.and),
                          ),
                          Checkbox(
                            key: const Key('andCheckbox'),
                            fillColor: MaterialStateColor.resolveWith(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.disabled)) {
                                  return kDarkAndLightDisabledIconColorOnDialog;
                                }
                                return kDarkAndLightIconColor;
                              },
                            ),
                            value: _isAnd,
                            onChanged:
                                (_audioTitleFilterSentencesLst.length > 1)
                                    ? _toggleCheckboxAnd
                                    : null,
                          ),
                          Tooltip(
                            message: AppLocalizations.of(context)!
                                .orSentencesTooltip,
                            child: Text(AppLocalizations.of(context)!.or),
                          ),
                          Checkbox(
                            key: const Key('orCheckbox'),
                            fillColor: MaterialStateColor.resolveWith(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.disabled)) {
                                  return kDarkAndLightDisabledIconColorOnDialog;
                                }
                                return kDarkAndLightIconColor;
                              },
                            ),
                            value: _isOr,
                            onChanged:
                                (_audioTitleFilterSentencesLst.length > 1)
                                    ? _toggleCheckboxOr
                                    : null,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(AppLocalizations.of(context)!.ignoreCase),
                          Checkbox(
                            key: const Key('ignoreCaseCheckbox'),
                            fillColor: MaterialStateColor.resolveWith(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.disabled)) {
                                  return kDarkAndLightDisabledIconColorOnDialog;
                                }
                                return kDarkAndLightIconColor;
                              },
                            ),
                            value: _ignoreCase,
                            onChanged:
                                (_audioTitleFilterSentencesLst.isNotEmpty)
                                    ? (bool? newValue) {
                                        setState(() {
                                          _modifyIgnoreCaseCheckBox(
                                            newValue,
                                          );
                                        });
                                      }
                                    : null,
                          ),
                        ],
                      ),
                      Tooltip(
                        message: AppLocalizations.of(context)!
                            .searchInVideoCompactDescriptionTooltip,
                        child: Row(
                          children: [
                            Text(AppLocalizations.of(context)!
                                .searchInVideoCompactDescription),
                            Checkbox(
                              key: const Key('searchInVideoCompactDescription'),
                              fillColor: MaterialStateColor.resolveWith(
                                (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.disabled)) {
                                    return kDarkAndLightDisabledIconColorOnDialog;
                                  }
                                  return kDarkAndLightIconColor;
                                },
                              ),
                              value: _searchInVideoCompactDescription,
                              onChanged:
                                  (_audioTitleFilterSentencesLst.isNotEmpty)
                                      ? (bool? newValue) {
                                          setState(() {
                                            _modifySearchInVideoCompactDescriptionCheckbox(
                                              newValue,
                                            );
                                          });
                                        }
                                      : null,
                            ),
                          ],
                        ),
                      ),
                      _buildAudioStateCheckboxes(context),
                      _buildAudioDateFields(context, now),
                      const SizedBox(
                        height: 10,
                      ),
                      _buildAudioFileSizeFields(context),
                      const SizedBox(
                        height: 10,
                      ),
                      _buildAudioDurationFields(context),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            Tooltip(
              message:
                  AppLocalizations.of(context)!.resetSortFilterOptionsTooltip,
              child: IconButton(
                key: const Key('resetSortFilterOptionsIconButton'),
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _resetSortFilterOptions();
                  });

                  // now clicking on Enter works since the
                  // Checkbox is not focused anymore
                  _audioTitleSearchSentenceFocusNode.requestFocus();
                },
              ),
            ),
            Tooltip(
              message: AppLocalizations.of(context)!
                  .setPlaylistSortFilterOptionsTooltip,
              child: IconButton(
                key: const Key('setPlaylistSortFilterOptionsIconButton'),
                icon: const Icon(Icons.perm_data_setting),
                onPressed: () async {
                  setState(() {
                    _setPlaylistSortFilterOptions();
                  });

                  // now clicking on Enter works since the
                  // Checkbox is not focused anymore
                  _audioTitleSearchSentenceFocusNode.requestFocus();
                },
              ),
            ),
            TextButton(
              key: const Key('applySortFilterButton'),
              onPressed: () {
                // Apply sorting and filtering options
                List<dynamic> filterSortAudioAndParmLst =
                    _filterAndSortAudioLst();
                Navigator.of(context).pop(filterSortAudioAndParmLst);
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

  Column _buildAudioDurationFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              width: 80,
              height: kDialogTextFieldHeight,
              child: TextField(
                key: const Key('audioDurationRangeStartTextField'),
                style: kDialogTextFieldStyle,
                decoration: _dialogTextFieldDecoration,
                controller: _startAudioDurationController,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 10),
            Text(AppLocalizations.of(context)!.end),
            SizedBox(
              width: 80,
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
    );
  }

  Column _buildAudioFileSizeFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              width: 80,
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
              width: 80,
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
      ],
    );
  }

  Widget _buildAudioDateFields(BuildContext context, DateTime now) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 104,
              child: Text(AppLocalizations.of(context)!.startDownloadDate),
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

                // Add this check
                _startDownloadDateTime = pickedDate;
                _startDownloadDateTimeController.text =
                    DateFormat('dd-MM-yyyy').format(_startDownloadDateTime!);

                // now clicking on Enter works since the
                // Checkbox is not focused anymore
                _audioTitleSearchSentenceFocusNode.requestFocus();
              },
            ),
            SizedBox(
              width: 80,
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
              width: 104,
              child: Text(AppLocalizations.of(context)!.endDownloadDate),
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

                // Add this check
                _endDownloadDateTime = pickedDate;
                _endDownloadDateTimeController.text =
                    DateFormat('dd-MM-yyyy').format(_endDownloadDateTime!);

                // now clicking on Enter works since the
                // Checkbox is not focused anymore
                _audioTitleSearchSentenceFocusNode.requestFocus();
              },
            ),
            SizedBox(
              width: 80,
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
              width: 104,
              child: Text(AppLocalizations.of(context)!.startUploadDate),
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

                // Add this check
                _startUploadDateTime = pickedDate;
                _startUploadDateTimeController.text =
                    DateFormat('dd-MM-yyyy').format(_startUploadDateTime!);

                // now clicking on Enter works since the
                // Checkbox is not focused anymore
                _audioTitleSearchSentenceFocusNode.requestFocus();
              },
            ),
            SizedBox(
              width: 80,
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
              width: 104,
              child: Text(AppLocalizations.of(context)!.endUploadDate),
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

                // Add this check
                _endUploadDateTime = pickedDate;
                _endUploadDateTimeController.text =
                    DateFormat('dd-MM-yyyy').format(_endUploadDateTime!);

                // now clicking on Enter works since the
                // Checkbox is not focused anymore
                _audioTitleSearchSentenceFocusNode.requestFocus();
              },
            ),
            SizedBox(
              key: const Key('endUploadDateTextField'),
              width: 80,
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
      ],
    );
  }

  Widget _buildAudioStateCheckboxes(BuildContext context) {
    return Column(
      children: [
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
                _audioTitleSearchSentenceFocusNode.requestFocus();
              },
            ),
          ],
        ),
        Row(
          children: [
            Text(AppLocalizations.of(context)!.fullyListened),
            Checkbox(
              key: const Key('filterFullyListenedCheckbox'),
              value: _filterFullyListened,
              onChanged: (bool? newValue) {
                setState(() {
                  _filterFullyListened = newValue!;
                });

                // now clicking on Enter works since the
                // Checkbox is not focused anymore
                _audioTitleSearchSentenceFocusNode.requestFocus();
              },
            ),
          ],
        ),
        Row(
          children: [
            Text(AppLocalizations.of(context)!.partiallyListened),
            Checkbox(
              key: const Key('filterPartiallyListenedCheckbox'),
              value: _filterPartiallyListened,
              onChanged: (bool? newValue) {
                setState(() {
                  _filterPartiallyListened = newValue!;
                });

                // now clicking on Enter works since the
                // Checkbox is not focused anymore
                _audioTitleSearchSentenceFocusNode.requestFocus();
              },
            ),
          ],
        ),
        Row(
          children: [
            Text(AppLocalizations.of(context)!.notListened),
            Checkbox(
              key: const Key('filterNotListenedCheckbox'),
              value: _filterNotListened,
              onChanged: (bool? newValue) {
                setState(() {
                  _filterNotListened = newValue!;
                });

                // now clicking on Enter works since the
                // Checkbox is not focused anymore
                _audioTitleSearchSentenceFocusNode.requestFocus();
              },
            ),
          ],
        ),
      ],
    );
  }

  void _modifySearchInVideoCompactDescriptionCheckbox(bool? newValue) {
    _searchInVideoCompactDescription = newValue!;

    // now clicking on Enter works since the
    // Checkbox is not focused anymore
    _audioTitleSearchSentenceFocusNode.requestFocus();
  }

  void _modifyIgnoreCaseCheckBox(bool? newValue) {
    _ignoreCase = newValue!;

    // now clicking on Enter works since the
    // Checkbox is not focused anymore
    _audioTitleSearchSentenceFocusNode.requestFocus();
  }

  SizedBox _buildAudioFilterSentencesLst() {
    return SizedBox(
      width: double.maxFinite,
      child: ListView.builder(
        itemCount: _audioTitleFilterSentencesLst.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_audioTitleFilterSentencesLst[index]),
            trailing: IconButton(
              key: const Key('removeSentenceIconButton'),
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _audioTitleFilterSentencesLst.removeAt(index);
                });

                // now clicking on Enter works since the
                // IconButton is not focused anymore
                _audioTitleSearchSentenceFocusNode.requestFocus();
              },
            ),
          );
        },
      ),
    );
  }

  SizedBox _buildAudioFilterSentence() {
    return SizedBox(
      height: kDialogTextFieldHeight,
      child: Row(
        children: [
          SizedBox(
            width: 200,
            child: Tooltip(
              message: AppLocalizations.of(context)!
                  .audioTitleSearchSentenceTextFieldTooltip,
              child: TextField(
                key: const Key('audioTitleSearchSentenceTextField'),
                focusNode: _audioTitleSearchSentenceFocusNode,
                style: kDialogTextFieldStyle,
                decoration: _dialogTextFieldDecoration,
                controller: _audioTitleSearchSentenceController,
                keyboardType: TextInputType.text,
                onChanged: (value) {
                  _audioTitleSearchSentence = value;
                  _audioTitleSearchSentencePlusButtonIconColor =
                      _audioTitleSearchSentence.isNotEmpty
                          ? kDarkAndLightIconColor
                          : kDarkAndLightDisabledIconColorOnDialog;

                  setState(() {}); // necessary to update Plus button color
                },
              ),
            ),
          ),
          SizedBox(
            width: kSmallIconButtonWidth,
            child: IconButton(
              key: const Key('addSentenceIconButton'),
              onPressed: () async {
                (_audioTitleSearchSentence != '')
                    ? setState(() {
                        _addSentenceToFilterSentencesLst();
                      })
                    : null;
              },
              padding: const EdgeInsets.all(0),
              icon: Icon(
                Icons.add,
                // since in the Dialog the disabled IconButton color
                // is not grey, we need to set it manually. Additionally,
                // the sentence TextField onChanged callback must execute
                // setState() to update the IconButton color
                color: _audioTitleSearchSentencePlusButtonIconColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addSentenceToFilterSentencesLst() {
    if (!_audioTitleFilterSentencesLst.contains(_audioTitleSearchSentence)) {
      _audioTitleFilterSentencesLst.add(_audioTitleSearchSentence);
      _audioTitleSearchSentence = '';
      _audioTitleSearchSentenceController.clear();

      // reset the Plus button color to disabled color
      // since the TextField is now empty
      _audioTitleSearchSentencePlusButtonIconColor =
          kDarkAndLightDisabledIconColorOnDialog;
    }

    // now clicking on Enter works since the
    // IconButton is not focused anymore
    _audioTitleSearchSentenceFocusNode.requestFocus();
  }

  SizedBox _buildSelectedSortingList() {
    return SizedBox(
      // Required to solve the error RenderBox was
      // not laid out: RenderPhysicalShape#ee087
      // relayoutBoundary=up2 'package:flutter/src/
      // rendering/box.dart':
      width: double.maxFinite,
      child: ListView.builder(
        // controller: _scrollController,
        itemCount: _selectedSortingItemLst.length,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(
              _sortingOptionToString(
                _selectedSortingItemLst[index].sortingOption,
                context,
              ),
              style: const TextStyle(fontSize: kDropdownMenuItemFontSize),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: kSmallIconButtonWidth,
                  child: Tooltip(
                    message: AppLocalizations.of(context)!
                        .clickToSetAscendingOrDescendingTooltip,
                    child: IconButton(
                      key: const Key('sort_ascending_or_descending_button'),
                      onPressed: () {
                        setState(() {
                          bool isAscending =
                              _selectedSortingItemLst[index].isAscending;
                          _selectedSortingItemLst[index].isAscending =
                              !isAscending; // Toggle the sorting state
                        });
                      },
                      padding: const EdgeInsets.all(0),
                      icon: Icon(
                        _selectedSortingItemLst[index].isAscending
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down, // Conditional icon
                        size: kUpDownButtonSize,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: kSmallIconButtonWidth,
                  child: IconButton(
                    key: const Key('removeSortingOptionIconButton'),
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        if (_selectedSortingItemLst.length > 1) {
                          _selectedSortingItemLst.removeAt(index);
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  DropdownButton<SortingOption> _buildSortingChoiceList(BuildContext context) {
    return DropdownButton<SortingOption>(
      key: const Key('sortingOptionDropdownButton'),
      value: SortingOption.audioDownloadDate,
      onChanged: (SortingOption? newValue) {
        setState(() {
          if (!_selectedSortingItemLst
              .any((sortingItem) => sortingItem.sortingOption == newValue)) {
            _selectedSortingItemLst.add(SortingItem(
              sortingOption: newValue!,
              isAscending: AudioSortFilterService.getDefaultSortOptionOrder(
                sortingOption: newValue,
              ),
            ));
          }
        });
      },
      items: _buildListOfSortingOptionDropdownMenuItems(context),
    );
  }

  /// The returned list of DropdownMenuItem<SortingOption> is based on the
  /// app view type. Most sorting options are excluded for the Audio Player
  /// View.
  ///
  /// This code first filters out the SortingOption values that should not
  /// be included when widget.audioLearnAppViewType is AudioLearnAppViewType.
  /// audioPlayerView using .where(), and then maps over the filtered list
  /// to create DropdownMenuItem<SortingOption> widgets. This approach
  /// ensures that you only include the relevant options in your
  /// DropdownButton.
  List<DropdownMenuItem<SortingOption>>
      _buildListOfSortingOptionDropdownMenuItems(BuildContext context) {
    return SortingOption.values.where((SortingOption value) {
      // Exclude certain options based on the app view type
      return !(widget.audioLearnAppViewType ==
              AudioLearnAppViewType.audioPlayerView &&
          (value == SortingOption.audioDownloadSpeed ||
              value == SortingOption.audioDownloadDuration ||
              value == SortingOption.audioEnclosingPlaylistTitle ||
              value == SortingOption.audioFileSize ||
              value == SortingOption.validAudioTitle ||
              value == SortingOption.audioMusicQuality ||
              value == SortingOption.videoUrl));
    }).map<DropdownMenuItem<SortingOption>>((SortingOption value) {
      return DropdownMenuItem<SortingOption>(
        value: value,
        child: Text(
          _sortingOptionToString(value, context),
          style: const TextStyle(fontSize: kDropdownMenuItemFontSize),
        ),
      );
    }).toList();
  }

  void _toggleCheckboxAnd(bool? value) {
    setState(() {
      _isAnd = !_isAnd;
      // When checkbox 1 is checked, ensure checkbox 2 is unchecked
      if (_isAnd) _isOr = false;
    });
  }

  void _toggleCheckboxOr(bool? value) {
    setState(() {
      _isOr = !_isOr;
      // When checkbox 2 is checked, ensure checkbox 1 is unchecked
      if (_isOr) _isAnd = false;
    });
  }

  // Method called when the user clicks on the 'Apply' button or
  // presses the Enter key on Windows
  List<dynamic> _filterAndSortAudioLst() {
    widget.audioSortFilterParameters = AudioSortFilterParameters(
      selectedSortItemLst: _selectedSortingItemLst,
      filterSentenceLst: _audioTitleFilterSentencesLst,
      sentencesCombination:
          (_isAnd) ? SentencesCombination.AND : SentencesCombination.OR,
      ignoreCase: _ignoreCase,
      searchAsWellInVideoCompactDescription: _searchInVideoCompactDescription,
      filterMusicQuality: _filterMusicQuality,
      filterFullyListened: _filterFullyListened,
      filterPartiallyListened: _filterPartiallyListened,
      filterNotListened: _filterNotListened,
    );

    List<Audio> filteredAndSortedAudioLst =
        _audioSortFilterService.filterAndSortAudioLst(
      audioLst: widget.selectedPlaylistAudioLst,
      audioSortFilterParameters: widget.audioSortFilterParameters,
    );

    return [
      filteredAndSortedAudioLst,
      widget.audioSortFilterParameters,
    ];
  }
}

class FilterAndSortAudioParameters {
  final List<SortingOption> _sortingOptionLst;
  get sortingOptionLst => _sortingOptionLst;

  final String _videoTitleAndDescriptionSearchWords;
  get videoTitleAndDescriptionSearchWords =>
      _videoTitleAndDescriptionSearchWords;

  bool ignoreCase;
  bool searchInVideoCompactDescription;
  bool asc;

  FilterAndSortAudioParameters({
    required List<SortingOption> sortingOptionLst,
    required String videoTitleAndDescriptionSearchWords,
    required this.ignoreCase,
    required this.searchInVideoCompactDescription,
    required this.asc,
  })  : _videoTitleAndDescriptionSearchWords =
            videoTitleAndDescriptionSearchWords,
        _sortingOptionLst = sortingOptionLst;
}
