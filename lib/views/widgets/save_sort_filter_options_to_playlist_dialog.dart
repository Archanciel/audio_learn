import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../views/screen_mixin.dart';
import '../../models/audio.dart';
import '../../models/playlist.dart';
import '../../services/settings_data_service.dart';
import '../../utils/ui_util.dart';
import '../../viewmodels/playlist_list_vm.dart';
import '../../viewmodels/theme_provider_vm.dart';

class SaveSortFilterOptionsToPlaylistDialogWidget extends StatefulWidget {
  final String playlistTitle;
  final AudioLearnAppViewType applicationViewType;
  final FocusNode focusNode;

  const SaveSortFilterOptionsToPlaylistDialogWidget({
    required this.playlistTitle,
    required this.applicationViewType,
    required this.focusNode,
    super.key,
  });

  @override
  State<SaveSortFilterOptionsToPlaylistDialogWidget> createState() =>
      _SaveSortFilterOptionsToPlaylistDialogWidgetState();
}

class _SaveSortFilterOptionsToPlaylistDialogWidgetState
    extends State<SaveSortFilterOptionsToPlaylistDialogWidget>
    with ScreenMixin {
  final FocusNode _localPlaylistTitleFocusNode = FocusNode();

  bool _isAutomaticApplicationChecked = false;

  @override
  void initState() {
    super.initState();

    // Add this line to request focus on the TextField after the build
    // method has been called
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(
        _localPlaylistTitleFocusNode,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeProviderVM themeProviderVM = Provider.of<ThemeProviderVM>(context);
    String viewNameTranslatedLabelStr = '';

    switch (widget.applicationViewType) {
      case AudioLearnAppViewType.playlistDownloadView:
        viewNameTranslatedLabelStr = AppLocalizations.of(context)!
            .saveSortFilterOptionsForView(
                AppLocalizations.of(context)!.appBarTitleDownloadAudio);
        break;
      case AudioLearnAppViewType.audioPlayerView:
        viewNameTranslatedLabelStr = AppLocalizations.of(context)!
            .saveSortFilterOptionsForView(
                AppLocalizations.of(context)!.appBarTitleAudioPlayer);
        break;
      case AudioLearnAppViewType.audioExtractorView:
        viewNameTranslatedLabelStr = AppLocalizations.of(context)!
            .saveSortFilterOptionsForView(
                AppLocalizations.of(context)!.appBarTitleAudioExtractor);
        break;
      default:
        break;
    }

    return KeyboardListener(
      // Using FocusNode to enable clicking on Enter to close
      // the dialog
      focusNode: widget.focusNode,
      onKeyEvent: (event) async {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.numpadEnter) {
            // executing the same code as in the 'Add'
            // TextButton onPressed callback
            Navigator.of(context).pop(_isAutomaticApplicationChecked);
          }
        }
      },
      child: AlertDialog(
        title: Text(
          key: const Key('saveSortFilterOptionsToPlaylistDialogTitleKey'),
          AppLocalizations.of(context)!
              .saveSortFilterOptionsToPlaylistDialogTitle,
        ),
        actionsPadding: kDialogActionsPadding,
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              createLabelRowFunction(
                // displaying the playlist title in which to save the
                // sort and filter options
                valueTextWidgetKey:
                    const Key('saveSortFilterOptionsToPlaylistTitleKey'),
                context: context,
                label: AppLocalizations.of(context)!
                    .saveSortFilterOptionsToPlaylist(widget.playlistTitle),
              ),
              createLabelRowFunction(
                // displaying the view for which the sort and filter
                // options are saved
                valueTextWidgetKey:
                    const Key('saveSortFilterOptionsForViewNameKey'),
                context: context,
                label: viewNameTranslatedLabelStr,
              ),
              Tooltip(
                message: AppLocalizations.of(context)!
                    .saveSortFilterOptionsAutomaticApplicationTooltip,
                child: createCheckboxRowFunction(
                  // displaying the checkbox to automatically apply the
                  // sort and filter options when the playlist is opened
                  checkBoxWidgetKey:
                      const Key('saveSortFilterOptionsAutomaticApplicationKey'),
                  context: context,
                  label: AppLocalizations.of(context)!
                      .saveSortFilterOptionsAutomaticApplication,
                  value: _isAutomaticApplicationChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      _isAutomaticApplicationChecked = value ?? false;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            key: const Key('saveSortFilterOptionsToPlaylistSaveButton'),
            onPressed: () async {
              Navigator.of(context).pop(_isAutomaticApplicationChecked);
            },
            child: Text(
              AppLocalizations.of(context)!.saveButton,
              style: (themeProviderVM.currentTheme == AppTheme.dark)
                  ? kTextButtonStyleDarkMode
                  : kTextButtonStyleLightMode,
            ),
          ),
          TextButton(
            key: const Key('sortFilterOptionsToPlaylistCancelButton'),
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
    );
  }
}
