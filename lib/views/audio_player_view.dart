import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/audio.dart';
import '../utils/duration_expansion.dart';
import '../viewmodels/audio_player_vm.dart';
import '../constants.dart';
import 'screen_mixin.dart';
import 'widgets/display_selectable_audio_list_dialog_widget.dart';
import 'widgets/set_audio_speed_dialog_widget.dart';

/// Screen enabling the user to play an audio, change the playing
/// position or go to a previous, next or selected audio.
class AudioPlayerView extends StatefulWidget {
  const AudioPlayerView({super.key});

  @override
  _AudioPlayerViewState createState() => _AudioPlayerViewState();
}

class _AudioPlayerViewState extends State<AudioPlayerView>
    with WidgetsBindingObserver, ScreenMixin {
  final double _audioIconSizeMedium = 40;
  final double _audioIconSizeLarge = 80;
  late double _audioPlaySpeed;

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
    AudioPlayerVM audioGlobalPlayerVM = Provider.of<AudioPlayerVM>(
      context,
      listen: false,
    );

    if (audioGlobalPlayerVM.currentAudio == null) {
      _audioPlaySpeed = 1.0;
    } else {
      _audioPlaySpeed = audioGlobalPlayerVM.currentAudio!.audioPlaySpeed;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildSetAudioSpeedButton(
          context,
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

  Widget _buildSetAudioSpeedButton(
    BuildContext context,
  ) {
    return Consumer<AudioPlayerVM>(
      // using Consumer<AudioPlayerVM> ensure that _audioPlaySpeed
      // is updated when the another audio is selected in the
      // AudioOneSelectableDialogWidget or when the next or previous
      // audio is set as current audio.
      builder: (context, audioGlobalPlayerVM, child) {
        Audio? currentAudio = audioGlobalPlayerVM.currentAudio;

        if (currentAudio == null) {
          return const SizedBox.shrink();
        }

        _audioPlaySpeed = currentAudio.audioPlaySpeed;

        return GestureDetector(
          onTap: () {
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
                audioGlobalPlayerVM.changeAudioPlaySpeed(_audioPlaySpeed);
              }
            });
            focusNode.requestFocus();
          },
          child: Tooltip(
            message: AppLocalizations.of(context)!.addPlaylistButtonTooltip,
            child: Text(
              '${_audioPlaySpeed.toStringAsFixed(2)}x',
              textAlign: TextAlign.center,
              style: kPositionButtonTextStyle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayButton() {
    return Consumer<AudioPlayerVM>(
      builder: (context, audioGlobalPlayerVM, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(90.0),
              child: IconButton(
                iconSize: _audioIconSizeLarge,
                onPressed: (() async {
                  audioGlobalPlayerVM.isPlaying
                      ? await audioGlobalPlayerVM.pause()
                      : await audioGlobalPlayerVM.playFromCurrentAudioFile();
                }),
                icon: Icon(audioGlobalPlayerVM.isPlaying
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
      builder: (context, audioGlobalPlayerVM, child) {
        String? currentAudioTitleWithDuration =
            audioGlobalPlayerVM.getCurrentAudioTitleWithDuration();

        // If the current audio title is null, set it to the
        // 'no current audio' translated title
        currentAudioTitleWithDuration ??=
            AppLocalizations.of(context)!.audioPlayerViewNoCurrentAudio;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              iconSize: _audioIconSizeMedium,
              onPressed: () => audioGlobalPlayerVM.skipToStart(),
              icon: const Icon(Icons.skip_previous),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _displayOtherAudiosDialog(
                      audioGlobalPlayerVM.getCurrentAudioIndex());
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
              onLongPress: () => _displayOtherAudiosDialog(
                  audioGlobalPlayerVM.getCurrentAudioIndex()),
              child: IconButton(
                iconSize: _audioIconSizeMedium,
                onPressed: () => audioGlobalPlayerVM.skipToEndAndPlay(),
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
      builder: (context, audioGlobalPlayerVM, child) {
        // Obtaining the slider values here (when audioGlobalPlayerVM
        // call notifyListeners()) avoids that the slider generate
        // a 'Value xxx.x is not between minimum 0.0 and maximum 0.0'
        // error
        double sliderValue =
            audioGlobalPlayerVM.currentAudioPosition.inSeconds.toDouble();
        double maxDuration =
            audioGlobalPlayerVM.currentAudioTotalDuration.inSeconds.toDouble();

        // Ensure the slider value is within the range
        sliderValue = sliderValue.clamp(0.0, maxDuration);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: kDefaultMargin),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                key: const Key('audioPlayerViewAudioPosition'),
                audioGlobalPlayerVM.currentAudioPosition.HHmmssZeroHH(),
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
                      audioGlobalPlayerVM.goToAudioPlayPosition(
                        Duration(seconds: value.toInt()),
                      );
                    },
                  ),
                ),
              ),
              Text(
                key: const Key('audioPlayerViewAudioRemainingDuration'),
                audioGlobalPlayerVM.currentAudioRemainingDuration
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
      builder: (context, audioGlobalPlayerVM, child) {
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
                            iconSize: _audioIconSizeMedium,
                            onPressed: () =>
                                audioGlobalPlayerVM.changeAudioPlayPosition(
                              const Duration(minutes: -1),
                            ),
                            icon: const Icon(Icons.fast_rewind),
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                            iconSize: _audioIconSizeMedium,
                            onPressed: () =>
                                audioGlobalPlayerVM.changeAudioPlayPosition(
                              const Duration(seconds: -10),
                            ),
                            icon: const Icon(Icons.fast_rewind),
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                            iconSize: _audioIconSizeMedium,
                            onPressed: () =>
                                audioGlobalPlayerVM.changeAudioPlayPosition(
                              const Duration(seconds: 10),
                            ),
                            icon: const Icon(Icons.fast_forward),
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                            iconSize: _audioIconSizeMedium,
                            onPressed: () =>
                                audioGlobalPlayerVM.changeAudioPlayPosition(
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
                              audioGlobalPlayerVM.changeAudioPlayPosition(
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
                              audioGlobalPlayerVM.changeAudioPlayPosition(
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
                              audioGlobalPlayerVM.changeAudioPlayPosition(
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
                              audioGlobalPlayerVM.changeAudioPlayPosition(
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
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _displayOtherAudiosDialog(int audioIndex) {
    showDialog(
      context: context,
      builder: (context) => const DisplaySelectableAudioListDialogWidget(),
    ).then((selectedAudio) {
      print(selectedAudio);
    });
  }
}
