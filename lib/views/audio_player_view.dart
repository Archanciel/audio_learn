import 'package:audio_learn/services/settings_data_service.dart';
import 'package:audio_learn/viewmodels/theme_provider_vm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../constants.dart';
import '../models/audio.dart';
import '../services/sort_filter_parameters.dart';
import '../utils/duration_expansion.dart';
import '../viewmodels/audio_player_vm.dart';
import '../viewmodels/playlist_list_vm.dart';
import 'screen_mixin.dart';
import 'widgets/list_playable_audios_dialog_widget.dart';
import 'widgets/save_sort_filter_options_to_playlist_dialog.dart';
import 'widgets/set_audio_speed_dialog_widget.dart';
import 'widgets/sort_and_filter_audio_dialog_widget.dart';

/// Screen enabling the user to play an audio, change the playing
/// position or go to a previous, next or selected audio.
class AudioPlayerView extends StatefulWidget {
  const AudioPlayerView({super.key});

  @override
  _AudioPlayerViewState createState() => _AudioPlayerViewState();
}

class _AudioPlayerViewState extends State<AudioPlayerView>
    with WidgetsBindingObserver, ScreenMixin {
  final double _audioIconSizeSmall = 35;
  final double _audioIconSizeMedium = 40;
  final double _audioIconSizeLarge = 80;
  late double _audioPlaySpeed;

  bool _wasSortFilterAudioSettingsApplied = false;

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // writeToLogFile(message: '_AudioPlayerViewState.initState() AudioPlayerView opened');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// WidgetsBindingObserver method called when the app's lifecycle
  /// state changes.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // writeToLogFile(
        //     message:
        //         'WidgetsBinding didChangeAppLifecycleState(): app resumed'); // Provider.of<AudioGlobalPlayerVM>(context, listen: false).resume();
        break;
      // App paused and sent to background
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // writeToLogFile(
        //     message:
        //         'WidgetsBinding didChangeAppLifecycleState(): app inactive, paused or closed');

        Provider.of<AudioPlayerVM>(
          context,
          listen: false,
        ).updateAndSaveCurrentAudio(forceSave: true);
        break;
      case AppLifecycleState.detached:
        // If the app is closed while an audio is playing, ensures
        // that the audio player is disposed. Otherwise, the audio
        // will continue playing. If we close the emulator, when
        // restarting it, the audio will be playing again, and the
        // only way to stop the audio play is to restart cold
        // version of the emulator !
        //
        // WARNING: must be positioned after calling
        // updateAndSaveCurrentAudio() method, otherwise the audio
        // player remains playing !
        Provider.of<AudioPlayerVM>(
          context,
          listen: false,
        ).disposeAudioPlayer(); // Calling this method instead of
        //                         the AudioPlayerVM dispose()
        //                         method enables audio player view
        //                         integr test to be ok even if the
        //                         test app is not the active Windows
        //                         app.

        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    AudioPlayerVM globalAudioPlayerVM = Provider.of<AudioPlayerVM>(
      context,
      listen: false,
    );

    if (globalAudioPlayerVM.currentAudio == null) {
      _audioPlaySpeed = 1.0;
    } else {
      _audioPlaySpeed = globalAudioPlayerVM.currentAudio!.audioPlaySpeed;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildSetAudioVolumeIconButton(context),
            const SizedBox(
              width: kRowButtonGroupWidthSeparator,
            ),
            _buildSetAudioSpeedTextButton(context),
            _buildAudioPopupMenuButton(
              context: context,
              playlistListVMlistenFalse: Provider.of<PlaylistListVM>(
                context,
                listen: false,
              ),
            ),
          ],
        ),
        // const SizedBox(height: 10.0),
        _buildPlayButton(),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildStartEndButtonsWithTitle(),
            _buildAudioSlider(),
            _buildPositionButtons(),
          ],
        ),
      ],
    );
  }

  Widget _buildSetAudioVolumeIconButton(
    BuildContext context,
  ) {
    return Consumer2<ThemeProviderVM, AudioPlayerVM>(
      builder: (context, themeProviderVM, globalAudioPlayerVM, child) {
        _audioPlaySpeed =
            globalAudioPlayerVM.currentAudio?.audioPlaySpeed ?? _audioPlaySpeed;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Tooltip(
              message:
                  AppLocalizations.of(context)!.decreaseAudioVolumeIconButton,
              child: SizedBox(
                width: kSmallButtonWidth,
                child: IconButton(
                  icon: const Icon(Icons.arrow_drop_down),
                  iconSize: kUpDownButtonSize,
                  onPressed: globalAudioPlayerVM.isCurrentAudioVolumeMin()
                      ? null // Disable the button if the volume is min
                      : () {
                          globalAudioPlayerVM.changeAudioVolume(
                            volumeChangedValue: -0.1,
                          );
                        },
                ),
              ),
            ),
            Tooltip(
              message:
                  AppLocalizations.of(context)!.increaseAudioVolumeIconButton,
              child: SizedBox(
                width: kSmallButtonWidth,
                child: IconButton(
                    icon: const Icon(Icons.arrow_drop_up),
                    iconSize: kUpDownButtonSize,
                    onPressed: globalAudioPlayerVM.isCurrentAudioVolumeMax()
                        ? null // Disable the button if the volume is max
                        : () {
                            globalAudioPlayerVM.changeAudioVolume(
                              volumeChangedValue: 0.1,
                            );
                          }),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSetAudioSpeedTextButton(
    BuildContext context,
  ) {
    return Consumer2<ThemeProviderVM, AudioPlayerVM>(
      builder: (context, themeProviderVM, globalAudioPlayerVM, child) {
        _audioPlaySpeed =
            globalAudioPlayerVM.currentAudio?.audioPlaySpeed ?? _audioPlaySpeed;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Tooltip(
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
                  overlayColor: textButtonTapModification, // Tap feedback color
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
                      );
                    },
                  ).then((value) {
                    // not null value is boolean
                    if (value != null) {
                      // value is null if clicking on Cancel or if the dialog
                      // is dismissed by clicking outside the dialog.

                      setState(() {
                        _audioPlaySpeed = value as double;
                      });
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
          ],
        );
      },
    );
  }

  /// Builds the audio popup menu button located on the right of the
  /// screen. This button allows the user to sort and filter the
  /// displayed audio list and to save the sort and filter settings to
  /// the selected playlist.
  Widget _buildAudioPopupMenuButton({
    required BuildContext context,
    required PlaylistListVM playlistListVMlistenFalse,
  }) {
    return SizedBox(
      width: kRowButtonGroupWidthSeparator,
      child: PopupMenuButton<PlaylistPopupMenuButton>(
        key: const Key('audio_popup_menu_button'),
        enabled: (playlistListVMlistenFalse.isButtonAudioPopupMenuEnabled),
        onSelected: (PlaylistPopupMenuButton value) {
          // Handle menu item selection
          switch (value) {
            case PlaylistPopupMenuButton.openSortFilterAudioSettingsDialog:
              // Using FocusNode to enable clicking on Enter to close
              // the dialog
              final FocusNode focusNode = FocusNode();
              showDialog(
                context: context,
                barrierDismissible:
                    false, // This line prevents the dialog from closing when tapping outside
                builder: (BuildContext context) {
                  return SortAndFilterAudioDialogWidget(
                    selectedPlaylistAudioLst: playlistListVMlistenFalse
                        .getSelectedPlaylistPlayableAudiosApplyingSortFilterParameters(
                      AudioLearnAppViewType.audioPlayerView,
                    ),
                    audioSortDefaultFilterParameters: playlistListVMlistenFalse
                        .createDefaultAudioSortFilterParameters(),
                    audioSortPlaylistFilterParameters: playlistListVMlistenFalse
                        .getSelectedPlaylistAudioSortFilterParamForView(
                      AudioLearnAppViewType.audioPlayerView,
                    ),
                    focusNode: focusNode,
                  );
                },
              ).then((filterSortAudioAndParmLst) {
                if (filterSortAudioAndParmLst != null) {
                  List<Audio> returnedAudioList = filterSortAudioAndParmLst[0];
                  AudioSortFilterParameters audioSortFilterParameters =
                      filterSortAudioAndParmLst[1];
                  playlistListVMlistenFalse
                      .setSortedFilteredSelectedPlaylistPlayableAudiosAndParms(
                    returnedAudioList,
                    audioSortFilterParameters,
                  );
                }
              });
              focusNode.requestFocus();
              break;
            case PlaylistPopupMenuButton.saveSortFilterAudiosSettingsToPlaylist:
              // Using FocusNode to enable clicking on Enter to close
              // the dialog
              final FocusNode focusNode = FocusNode();
              showDialog(
                context: context,
                barrierDismissible:
                    false, // This line prevents the dialog from closing when tapping outside
                builder: (BuildContext context) {
                  return SaveSortFilterOptionsToPlaylistDialogWidget(
                    playlistTitle:
                        playlistListVMlistenFalse.uniqueSelectedPlaylist!.title,
                    applicationViewType: AudioLearnAppViewType.audioPlayerView,
                    focusNode: focusNode,
                  );
                },
              ).then((isSortFilterParmsApplicationAutomatic) {
                if (isSortFilterParmsApplicationAutomatic != null) {
                  // if the user clicked on Save, not on Cancel button
                  playlistListVMlistenFalse
                      .savePlaylistAudioSortFilterParmsToPlaylist(
                    AudioLearnAppViewType.audioPlayerView,
                    isSortFilterParmsApplicationAutomatic,
                  );
                }
              });
              focusNode.requestFocus();
              break;
            default:
              break;
          }
        },
        icon: const Icon(Icons.filter_list),
        itemBuilder: (BuildContext context) {
          return [
            PopupMenuItem<PlaylistPopupMenuButton>(
              key: const Key(
                  'define_sort_and_filter_audio_settings_dialog_item'),
              value: PlaylistPopupMenuButton.openSortFilterAudioSettingsDialog,
              child: Text(
                  AppLocalizations.of(context)!.defineSortFilterAudiosSettings),
            ),
            PopupMenuItem<PlaylistPopupMenuButton>(
              key: const Key(
                  'save_sort_and_filter_audio_settings_in_playlist_item'),
              value: PlaylistPopupMenuButton
                  .saveSortFilterAudiosSettingsToPlaylist,
              child: Text(AppLocalizations.of(context)!
                  .saveSortFilterAudiosSettingsToPlaylist),
            ),
          ];
        },
      ),
    );
  }

  Widget _buildPlayButton() {
    return Consumer<AudioPlayerVM>(
      builder: (context, globalAudioPlayerVM, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(90.0),
              child: IconButton(
                iconSize: _audioIconSizeLarge,
                onPressed: (() async {
                  globalAudioPlayerVM.isPlaying
                      ? await globalAudioPlayerVM.pause()
                      : await globalAudioPlayerVM.playFromCurrentAudioFile();
                }),
                icon: Icon(globalAudioPlayerVM.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStartEndButtonsWithTitle() {
    return Consumer<AudioPlayerVM>(
      builder: (context, globalAudioPlayerVM, child) {
        String? currentAudioTitleWithDuration =
            globalAudioPlayerVM.getCurrentAudioTitleWithDuration();

        // If the current audio title is null, set it to the
        // 'no current audio' translated title
        currentAudioTitleWithDuration ??=
            AppLocalizations.of(context)!.audioPlayerViewNoCurrentAudio;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              key: const Key('audioPlayerViewSkipToStartButton'),
              iconSize: _audioIconSizeMedium,
              onPressed: () => globalAudioPlayerVM.skipToStart(),
              icon: const Icon(Icons.skip_previous),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (globalAudioPlayerVM
                      .getPlayableAudiosApplyingSortFilterParameters(
                        AudioLearnAppViewType.audioPlayerView,
                      )
                      .isEmpty) {
                    // there is no audio to play
                    return;
                  }

                  _displayOtherAudiosDialog();
                },
                child: Text(
                  currentAudioTitleWithDuration,
                  style: const TextStyle(
                    fontSize: kTitleFontSize,
                  ),
                  maxLines: 5,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            GestureDetector(
              onLongPress: () {
                if (globalAudioPlayerVM
                    .getPlayableAudiosApplyingSortFilterParameters(
                      AudioLearnAppViewType.audioPlayerView,
                    )
                    .isEmpty) {
                  // there is no audio to play
                  return;
                }

                _displayOtherAudiosDialog();
              },
              child: IconButton(
                key: const Key('audioPlayerViewSkipToEndButton'),
                iconSize: _audioIconSizeMedium,
                onPressed: () => globalAudioPlayerVM.skipToEndAndPlay(),
                icon: const Icon(Icons.skip_next),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAudioSlider() {
    return Consumer<AudioPlayerVM>(
      builder: (context, globalAudioPlayerVM, child) {
        // Obtaining the slider values here (when globalAudioPlayerVM
        // call notifyListeners()) avoids that the slider generate
        // a 'Value xxx.x is not between minimum 0.0 and maximum 0.0'
        // error
        double sliderValue =
            globalAudioPlayerVM.currentAudioPosition.inSeconds.toDouble();
        double maxDuration =
            globalAudioPlayerVM.currentAudioTotalDuration.inSeconds.toDouble();

        // Ensure the slider value is within the range
        sliderValue = sliderValue.clamp(0.0, maxDuration);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: kDefaultMargin),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                key: const Key('audioPlayerViewAudioPosition'),
                globalAudioPlayerVM.currentAudioPosition.HHmmssZeroHH(),
                style: kSliderValueTextStyle,
              ),
              Expanded(
                child: SliderTheme(
                  data: const SliderThemeData(
                    trackHeight: kSliderThickness,
                    thumbShape: RoundSliderThumbShape(
                        enabledThumbRadius:
                            6.0), // Adjust the radius as you need
                  ),
                  child: Slider(
                    min: 0.0,
                    max: maxDuration,
                    value: sliderValue,
                    onChanged: (double value) {
                      globalAudioPlayerVM.goToAudioPlayPosition(
                        durationPosition: Duration(seconds: value.toInt()),
                      );
                    },
                  ),
                ),
              ),
              Text(
                key: const Key('audioPlayerViewAudioRemainingDuration'),
                globalAudioPlayerVM.currentAudioRemainingDuration
                    .HHmmssZeroHH(),
                style: kSliderValueTextStyle,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPositionButtons() {
    return Consumer<AudioPlayerVM>(
      builder: (context, globalAudioPlayerVM, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 120,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: _audioIconSizeMedium - 7,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: IconButton(
                            key: const Key('audioPlayerViewRewind1mButton'),
                            iconSize: _audioIconSizeMedium,
                            onPressed: () =>
                                globalAudioPlayerVM.changeAudioPlayPosition(
                              positiveOrNegativeDuration:
                                  const Duration(minutes: -1),
                            ),
                            icon: const Icon(Icons.fast_rewind),
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                            key: const Key('audioPlayerViewRewind10sButton'),
                            iconSize: _audioIconSizeMedium,
                            onPressed: () =>
                                globalAudioPlayerVM.changeAudioPlayPosition(
                              positiveOrNegativeDuration:
                                  const Duration(seconds: -10),
                            ),
                            icon: const Icon(Icons.fast_rewind),
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                            key: const Key('audioPlayerViewForward10sButton'),
                            iconSize: _audioIconSizeMedium,
                            onPressed: () =>
                                globalAudioPlayerVM.changeAudioPlayPosition(
                              positiveOrNegativeDuration:
                                  const Duration(seconds: 10),
                            ),
                            icon: const Icon(Icons.fast_forward),
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                            key: const Key('audioPlayerViewForward1mButton'),
                            iconSize: _audioIconSizeMedium,
                            onPressed: () =>
                                globalAudioPlayerVM.changeAudioPlayPosition(
                              positiveOrNegativeDuration:
                                  const Duration(minutes: 1),
                            ),
                            icon: const Icon(Icons.fast_forward),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              globalAudioPlayerVM.changeAudioPlayPosition(
                            positiveOrNegativeDuration:
                                const Duration(minutes: -1),
                          ),
                          child: const Text(
                            '1 m',
                            textAlign: TextAlign.center,
                            style: kPositionButtonTextStyle,
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              globalAudioPlayerVM.changeAudioPlayPosition(
                            positiveOrNegativeDuration:
                                const Duration(seconds: -10),
                          ),
                          child: const Text(
                            '10 s',
                            textAlign: TextAlign.center,
                            style: kPositionButtonTextStyle,
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              globalAudioPlayerVM.changeAudioPlayPosition(
                            positiveOrNegativeDuration:
                                const Duration(seconds: 10),
                          ),
                          child: const Text(
                            '10 s',
                            textAlign: TextAlign.center,
                            style: kPositionButtonTextStyle,
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              globalAudioPlayerVM.changeAudioPlayPosition(
                            positiveOrNegativeDuration:
                                const Duration(minutes: 1),
                          ),
                          child: const Text(
                            '1 m',
                            textAlign: TextAlign.center,
                            style: kPositionButtonTextStyle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  _buildUndoRedoButtons(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUndoRedoButtons() {
    return Consumer<AudioPlayerVM>(
      builder: (context, globalAudioPlayerVM, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              key: const Key('audioPlayerViewUndoButton'),
              iconSize: _audioIconSizeSmall,
              onPressed: globalAudioPlayerVM.isUndoListEmpty()
                  ? null // Disable the button if the volume is min
                  : () {
                      globalAudioPlayerVM.undo();
                    },
              icon: const Icon(Icons.undo),
            ),
            IconButton(
              key: const Key('audioPlayerViewRedoButton'),
              iconSize: _audioIconSizeSmall,
              onPressed: globalAudioPlayerVM.isRedoListEmpty()
                  ? null // Disable the button if the volume is min
                  : () {
                      globalAudioPlayerVM.redo();
                    },
              icon: const Icon(Icons.redo),
            ),
          ],
        );
      },
    );
  }

  void _displayOtherAudiosDialog() {
    showDialog(
      context: context,
      builder: (context) => const ListPlayableAudiosDialogWidget(),
    ).then((selectedAudio) {
      // TODO: why nothing is done there ?
      print(selectedAudio);
    });
  }
}
