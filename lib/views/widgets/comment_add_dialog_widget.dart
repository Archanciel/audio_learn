import 'dart:io';

import 'package:audiolearn/models/help_item.dart';
import 'package:audiolearn/viewmodels/audio_download_vm.dart';
import 'package:audiolearn/viewmodels/playlist_list_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/warning_message_vm.dart';
import '../../views/screen_mixin.dart';
import '../../constants.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/theme_provider_vm.dart';
import 'audio_set_speed_dialog_widget.dart';

class CommentAddDialogWidget extends StatefulWidget {
  const CommentAddDialogWidget({
    super.key,
  });

  @override
  State<CommentAddDialogWidget> createState() => _CommentAddDialogWidgetState();
}

class _CommentAddDialogWidgetState extends State<CommentAddDialogWidget>
    with ScreenMixin {
  final TextEditingController _playlistRootpathTextEditingController =
      TextEditingController();
  late double _audioPlaySpeed;
  bool _applyAudioPlaySpeedToExistingPlaylists = false;
  bool _applyAudioPlaySpeedToAlreadyDownloadedAudios = false;
  final FocusNode _dialogFocusNode = FocusNode();
  final FocusNode _focusNodePlaylistRootPath = FocusNode();
  late final List<HelpItem> _helpItemsLst;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Required so that clicking on Enter closes the dialog
      FocusScope.of(context).requestFocus(
        _dialogFocusNode,
      );
      _playlistRootpathTextEditingController.text = 'Rootpath';

      // Setting cursor at the end of the text. Does not work !
      _playlistRootpathTextEditingController.selection =
          TextSelection.fromPosition(
        TextPosition(
          offset: _playlistRootpathTextEditingController.text.length,
        ),
      );

      _helpItemsLst = [
        HelpItem(
          helpTitle: AppLocalizations.of(context)!.defaultApplicationHelpTitle,
          helpContent:
              AppLocalizations.of(context)!.defaultApplicationHelpContent,
        ),
        HelpItem(
          helpTitle:
              AppLocalizations.of(context)!.modifyingExistingPlaylistsHelpTitle,
          helpContent: AppLocalizations.of(context)!
              .modifyingExistingPlaylistsHelpContent,
        ),
        HelpItem(
          helpTitle:
              AppLocalizations.of(context)!.alreadyDownloadedAudiosHelpTitle,
          helpContent:
              AppLocalizations.of(context)!.alreadyDownloadedAudiosHelpContent,
        ),
        HelpItem(
          helpTitle:
              AppLocalizations.of(context)!.excludingFutureDownloadsHelpTitle,
          helpContent:
              AppLocalizations.of(context)!.excludingFutureDownloadsHelpContent,
        ),
      ];
    });
  }

  @override
  void dispose() {
    _dialogFocusNode.dispose();
    _focusNodePlaylistRootPath.dispose();
    _playlistRootpathTextEditingController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeProviderVM themeProviderVM = Provider.of<ThemeProviderVM>(context);

    FocusScope.of(context).requestFocus(
      _focusNodePlaylistRootPath,
    );

    return KeyboardListener(
      // Using FocusNode to enable clicking on Enter to close
      // the dialog
      focusNode: _dialogFocusNode,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.numpadEnter) {
            // executing the same code as in the 'Save' TextButton
            // onPressed callback
            _handleSaveButton(context);
            Navigator.of(context).pop();
          }
        }
      },
      child: AlertDialog(
        title: Text(
          key: const Key('appSettingsDialogTitleKey'),
          AppLocalizations.of(context)!.appSettingsDialogTitle,
        ),
        actionsPadding: kDialogActionsPadding,
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              createEditableColumnFunction(
                valueTextFieldWidgetKey: const Key('playlistRootpathTextField'),
                context: context,
                label: AppLocalizations.of(context)!.commentTitle,
                controller: _playlistRootpathTextEditingController,
                textFieldFocusNode: _focusNodePlaylistRootPath,
              ),
              const SizedBox(
                height: kDialogTextFieldVerticalSeparation,
              ),
              createEditableColumnFunction(
                valueTextFieldWidgetKey: const Key('playlistRootpathTextField'),
                context: context,
                label: AppLocalizations.of(context)!.commentText,
                controller: _playlistRootpathTextEditingController,
                textFieldFocusNode: _focusNodePlaylistRootPath,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            key: const Key('saveButton'),
            onPressed: () {
              _handleSaveButton(context);
              Navigator.of(context).pop();
            },
            child: Text(
              AppLocalizations.of(context)!.saveButton,
              style: (themeProviderVM.currentTheme == AppTheme.dark)
                  ? kTextButtonStyleDarkMode
                  : kTextButtonStyleLightMode,
            ),
          ),
          TextButton(
            key: const Key('cancelButton'),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              AppLocalizations.of(context)!.cancelButton,
              style: (themeProviderVM.currentTheme == AppTheme.dark)
                  ? kTextButtonStyleDarkMode
                  : kTextButtonStyleLightMode,
            ),
          ),
        ],
      ),
    );
  }

  void _handleSaveButton(BuildContext context) {
    if (_applyAudioPlaySpeedToExistingPlaylists ||
        _applyAudioPlaySpeedToAlreadyDownloadedAudios) {
      Provider.of<PlaylistListVM>(
        context,
        listen: false,
      ).updateExistingPlaylistsAndOrAudiosPlaySpeed(
        audioPlaySpeed: _audioPlaySpeed,
        applyAudioPlaySpeedToExistingPlaylists:
            _applyAudioPlaySpeedToExistingPlaylists,
        applyAudioPlaySpeedToAlreadyDownloadedAudios:
            _applyAudioPlaySpeedToAlreadyDownloadedAudios,
      );
    }
  }

  Widget _buildSetAudioSpeedTextButton(
    BuildContext context,
  ) {
    return Consumer<ThemeProviderVM>(
      builder: (context, themeProviderVM, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              // sets the rounded TextButton size improving the distance
              // between the button text and its boarder
              width: kNormalButtonWidth - 18.0,
              height: kNormalButtonHeight,
              child: Tooltip(
                message: AppLocalizations.of(context)!.setAudioPlaySpeedTooltip,
                child: TextButton(
                  key: const Key('setAudioSpeedTextButton'),
                  style: ButtonStyle(
                    shape: getButtonRoundedShape(
                        currentTheme: themeProviderVM.currentTheme),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.symmetric(
                          horizontal: kSmallButtonInsidePadding, vertical: 0),
                    ),
                    overlayColor:
                        textButtonTapModification, // Tap feedback color
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AudioSetSpeedDialogWidget(
                          audioPlaySpeed: _audioPlaySpeed,
                          updateCurrentPlayAudioSpeed: false,
                          displayApplyToExistingPlaylistCheckbox: true,
                          displayApplyToAudioAlreadyDownloadedCheckbox: true,
                          helpItemsLst: _helpItemsLst,
                        );
                      },
                    ).then((value) {
                      // not null value is boolean
                      if (value != null) {
                        // value is null if clicking on Cancel or if the dialog
                        // is dismissed by clicking outside the dialog.

                        _audioPlaySpeed = value[0] as double;
                        _applyAudioPlaySpeedToExistingPlaylists = value[1];
                        _applyAudioPlaySpeedToAlreadyDownloadedAudios =
                            value[2];

                        setState(() {}); // required, otherwise the TextButton
                        // text in the application settings dialog is not
                        // updated
                      }
                    });
                  },
                  child: Tooltip(
                    message:
                        AppLocalizations.of(context)!.setAudioPlaySpeedTooltip,
                    child: Text(
                      '${_audioPlaySpeed.toStringAsFixed(2)}x',
                      textAlign: TextAlign.center,
                      style: (themeProviderVM.currentTheme == AppTheme.dark)
                          ? kTextButtonStyleDarkMode
                          : kTextButtonStyleLightMode,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
