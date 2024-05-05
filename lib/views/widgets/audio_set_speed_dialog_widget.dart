import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../constants.dart';
import '../../models/audio.dart';
import '../../models/help_item.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/audio_player_vm.dart';
import '../../viewmodels/theme_provider_vm.dart';
import '../../views/screen_mixin.dart';
import 'help_dialog_widget.dart';

class AudioSetSpeedDialogWidget extends StatefulWidget {
  double audioPlaySpeed;

  bool displayApplyToExistingPlaylistCheckbox;
  bool displayApplyToAudioAlreadyDownloadedCheckbox;

  bool updateCurrentPlayAudioSpeed;

  AudioSetSpeedDialogWidget({
    super.key,
    required this.audioPlaySpeed,
    this.displayApplyToExistingPlaylistCheckbox = false,
    this.displayApplyToAudioAlreadyDownloadedCheckbox = false,
    this.updateCurrentPlayAudioSpeed = true,
  });

  @override
  _AudioSetSpeedDialogWidgetState createState() =>
      _AudioSetSpeedDialogWidgetState();
}

class _AudioSetSpeedDialogWidgetState extends State<AudioSetSpeedDialogWidget>
    with ScreenMixin {
  double _audioPlaySpeed = 1.0;
  bool _applyToAudioAlreadyDownloaded = false;
  bool _applyToExistingPlaylist = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    _audioPlaySpeed = widget.audioPlaySpeed;

    // Request focus when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AudioPlayerVM audioGlobalPlayerVM = Provider.of<AudioPlayerVM>(
      context,
      listen: false,
    );
    final ThemeProviderVM themeProviderVM = Provider.of<ThemeProviderVM>(
      context,
      listen: false,
    );

    if (widget.updateCurrentPlayAudioSpeed) {
      // Here, using the set audio speed dialog in the audio player
      // view
      Audio? currentAudio = audioGlobalPlayerVM.currentAudio;

      if (currentAudio != null) {
        _audioPlaySpeed = currentAudio.audioPlaySpeed;
      }
    }

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.numpadEnter) {
            // onPressed callback
            Navigator.of(context).pop(_audioPlaySpeed);
          }
        }
      },
      child: AlertDialog(
        // executing the same code as in the 'Ok' TextButton
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.setAudioPlaySpeedDialogTitle,
            ),
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => HelpDialog(
                    helpItems: [
                      HelpItem(
                        helpTitle: AppLocalizations.of(context)!
                            .defaultApplicationHelpTitle,
                        helpContent: AppLocalizations.of(context)!
                            .defaultApplicationHelpContent,
                      ),
                      HelpItem(
                        helpTitle: AppLocalizations.of(context)!
                            .modifyingExistingPlaylistsHelpTitle,
                        helpContent: AppLocalizations.of(context)!
                            .modifyingExistingPlaylistsHelpContent,
                      ),
                      HelpItem(
                        helpTitle: AppLocalizations.of(context)!
                            .alreadyDownloadedAudiosHelpTitle,
                        helpContent: AppLocalizations.of(context)!
                            .alreadyDownloadedAudiosHelpContent,
                      ),
                      HelpItem(
                        helpTitle: AppLocalizations.of(context)!
                            .excludingFutureDownloadsHelpTitle,
                        helpContent: AppLocalizations.of(context)!
                            .excludingFutureDownloadsHelpContent,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('${_audioPlaySpeed.toStringAsFixed(2)}x',
                  style: (themeProviderVM.currentTheme == AppTheme.dark)
                      ? kTextButtonStyleDarkMode
                      : kTextButtonStyleLightMode),
              _buildSlider(audioGlobalPlayerVM),
              _buildSpeedButtons(audioGlobalPlayerVM, themeProviderVM),
              (widget.displayApplyToExistingPlaylistCheckbox)
                  ? _buildApplyToExistingPlaylistRow(context)
                  : Container(),
              (widget.displayApplyToAudioAlreadyDownloadedCheckbox)
                  ? _buildApplyToAudioAlreadyDownloadedRow(context)
                  : Container(),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            key: const Key('okButtonKey'),
            child: Text(
              'Ok',
              style: (themeProviderVM.currentTheme == AppTheme.dark)
                  ? kTextButtonStyleDarkMode
                  : kTextButtonStyleLightMode,
            ),
            onPressed: () {
              Navigator.of(context).pop([
                _audioPlaySpeed,
                _applyToExistingPlaylist,
                _applyToAudioAlreadyDownloaded,
              ]);
            },
          ),
          TextButton(
            key: const Key('cancelButtonKey'),
            child: Text(
              AppLocalizations.of(context)!.cancelButton,
              style: (themeProviderVM.currentTheme == AppTheme.dark)
                  ? kTextButtonStyleDarkMode
                  : kTextButtonStyleLightMode,
            ),
            onPressed: () {
              // restoring the previous audio play speed when
              // cancel button is pressed. Otherwise, the audio
              // play speed is changed even if the user presses
              // the cancel button.
              _setPlaybackSpeed(
                audioGlobalPlayerVM,
                widget.audioPlaySpeed,
              );

              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildApplyToExistingPlaylistRow(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        createCheckboxRowFunction(
          context: context,
          label: AppLocalizations.of(context)!.applyToExistingPlaylist,
          labelTooltip:
              AppLocalizations.of(context)!.applyToExistingPlaylistTooltip,
          value: _applyToExistingPlaylist,
          onChangedFunction: (bool? value) {
            setState(() {
              _applyToExistingPlaylist = value ?? false;
            });
          },
        ),
      ],
    );
  }

  Widget _buildApplyToAudioAlreadyDownloadedRow(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        createCheckboxRowFunction(
          context: context,
          label: AppLocalizations.of(context)!.applyToAlreadyDownloadedAudio,
          labelTooltip: (widget.displayApplyToExistingPlaylistCheckbox)
              ? AppLocalizations.of(context)!
                  .applyToAlreadyDownloadedAudioTooltip
              : AppLocalizations.of(context)!
                  .applyToAlreadyDownloadedAudioOfCurrentPlaylistTooltip,
          value: _applyToAudioAlreadyDownloaded,
          onChangedFunction: (bool? value) {
            setState(() {
              _applyToAudioAlreadyDownloaded = value ?? false;

              if (widget.displayApplyToExistingPlaylistCheckbox) {
                if (_applyToAudioAlreadyDownloaded) {
                  // If this dialog was opened due to updating application
                  // settings, in this case the two checkbox are displayed.
                  //
                  // In this situation, if the user chooses to apply the
                  // modified audio play speed to the already dowmnloaded
                  // audios, then it makes sence that the apply to existing
                  // checkbox is set to true. The user can uncheck the apply
                  // to existing checkbox without the fact that the apply
                  // to already downloaded audio check box is implied.
                  setState(() {
                    _applyToExistingPlaylist = true;
                  });
                }
              }
            });
          },
        ),
      ],
    );
  }

  Row _buildSlider(
    AudioPlayerVM audioGlobalPlayerVM,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () {
            double newSpeed = _audioPlaySpeed - 0.1;
            if (newSpeed >= 0.5) {
              _setPlaybackSpeed(
                audioGlobalPlayerVM,
                newSpeed,
              );
            }
          },
        ),
        Expanded(
          child: Slider(
            min: 0.5,
            max: 2.0,
            divisions: 6,
            label: "${_audioPlaySpeed.toStringAsFixed(1)}x",
            value: _audioPlaySpeed,
            onChanged: (value) {
              _setPlaybackSpeed(
                audioGlobalPlayerVM,
                value,
              );
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            double newSpeed = _audioPlaySpeed + 0.1;
            if (newSpeed <= 2.0) {
              _setPlaybackSpeed(
                audioGlobalPlayerVM,
                newSpeed,
              );
            } else {
              if (newSpeed <= 2.001) {
                // required since _audioPlaySpeed can be
                // 1.9000000000000008. 1.9 is displayed
                // and clicking on '+' button could not
                // change the speed to 2.0 !
                newSpeed = 2.0;
                _setPlaybackSpeed(
                  audioGlobalPlayerVM,
                  newSpeed,
                );
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildSpeedButtons(
    AudioPlayerVM audioGlobalPlayerVM,
    ThemeProviderVM themeProviderVM,
  ) {
    final speeds = [0.7, 1.0, 1.25, 1.5]; // [0.7, 1.0, 1.25, 1.5, 2.0] is too
    //                                       large for the screen on S20
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: speeds.map((speed) {
        return TextButton(
          style: TextButton.styleFrom(
            minimumSize: const Size(18, 18), // Set a minimum touch target size
            padding: const EdgeInsets.symmetric(horizontal: 0),
          ),
          child: Text(
            '${speed}x',
            style: (themeProviderVM.currentTheme == AppTheme.dark)
                ? kTextButtonSmallStyleDarkMode
                : kTextButtonSmallStyleLightMode,
          ),
          onPressed: () {
            _setPlaybackSpeed(
              audioGlobalPlayerVM,
              speed,
            );
          },
        );
      }).toList(),
    );
  }

  void _setPlaybackSpeed(
    AudioPlayerVM audioGlobalPlayerVM,
    double newValue,
  ) {
    setState(() {
      _audioPlaySpeed = newValue;
    });

    if (widget.updateCurrentPlayAudioSpeed) {
      // Here, using the set audio speed dialog in the audio player
      // view

      audioGlobalPlayerVM.changeAudioPlaySpeed(_audioPlaySpeed);
    }
  }
}