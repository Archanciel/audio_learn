import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../views/screen_mixin.dart';
import '../../constants.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/theme_provider_vm.dart';
import 'set_audio_speed_dialog_widget.dart';

class ApplicationSettingsDialogWidget extends StatefulWidget {
  final SettingsDataService settingsDataService;
  final FocusNode focusNode;

  const ApplicationSettingsDialogWidget({
    required this.focusNode,
    required this.settingsDataService,
    super.key,
  });

  @override
  State<ApplicationSettingsDialogWidget> createState() =>
      _ApplicationSettingsDialogWidgetState();
}

class _ApplicationSettingsDialogWidgetState
    extends State<ApplicationSettingsDialogWidget> with ScreenMixin {
  final TextEditingController _playlistRootpathTextEditingController =
      TextEditingController();
  late double _audioPlaySpeed;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _audioPlaySpeed = widget.settingsDataService.get(
            settingType: SettingType.playlists,
            settingSubType: Playlists.playSpeed) ??
        1.0;

    // Add this line to request focus on the TextField after the build
    // method has been called
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(
        _focusNode,
      );
      _playlistRootpathTextEditingController.text = widget.settingsDataService
              .get(
                  settingType: SettingType.playlists,
                  settingSubType: Playlists.rootPath) ??
          '';
    });

    // Add this line to request focus on the TextField after the build
    // method has been called
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   FocusScope.of(context).requestFocus(
    //     _audioFileNameFocusNode,
    //   );
    //   _audioFileNameTextEditingController.text = '';
    // });
  }

  @override
  void dispose() {
    _playlistRootpathTextEditingController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeProviderVM themeProviderVM = Provider.of<ThemeProviderVM>(context);

    return KeyboardListener(
      // Using FocusNode to enable clicking on Enter to close
      // the dialog
      focusNode: widget.focusNode,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.numpadEnter) {
            // executing the same code as in the 'Save' TextButton
            // onPressed callback
            _updateAndSaveSettings(context);
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
          child: ListBody(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!
                            .setAudioPlaySpeedDialogTitle,
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 37,
                        child: _buildSetAudioSpeedTextButton(context),
                      ),
                    ),
                  ],
                ),
              ),
              createEditableRowFunction(
                  valueTextFieldWidgetKey:
                      const Key('playlistRootpathTextField'),
                  context: context,
                  label: AppLocalizations.of(context)!.playlistRootpathLabel,
                  controller: _playlistRootpathTextEditingController,
                  textFieldFocusNode: _focusNode),
            ],
          ),
        ),
        actions: [
          TextButton(
            key: const Key('saveButton'),
            onPressed: () {
              _updateAndSaveSettings(context);
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

  void _updateAndSaveSettings(BuildContext context) {
    widget.settingsDataService.set(
        settingType: SettingType.playlists,
        settingSubType: Playlists.playSpeed,
        value: _audioPlaySpeed);

    widget.settingsDataService.set(
        settingType: SettingType.playlists,
        settingSubType: Playlists.rootPath,
        value: _playlistRootpathTextEditingController.text);

    widget.settingsDataService.saveSettings();
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
                    // Using FocusNode to enable clicking on Enter to close
                    // the dialog
                    final FocusNode focusNode = FocusNode();
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (BuildContext context) {
                        return SetAudioSpeedDialogWidget(
                          audioPlaySpeed: _audioPlaySpeed,
                          updateCurrentPlayAudioSpeed: false,
                        );
                      },
                    ).then((value) {
                      // not null value is boolean
                      if (value != null) {
                        // value is null if clicking on Cancel or if the dialog
                        // is dismissed by clicking outside the dialog.

                        _audioPlaySpeed = value[0] as double;

                        setState(() {}); // required, otherwise the TextButton
                        // text in the application settings dialog is not
                        // updated
                      }
                    });
                    focusNode.requestFocus();
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
