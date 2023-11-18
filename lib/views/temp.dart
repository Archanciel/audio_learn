import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../utils/duration_expansion.dart';
import '../viewmodels/audio_player_vm.dart';
import 'screen_mixin.dart';
import 'widgets/audio_one_selectable_dialog_widget.dart';

const double kRowWidthSeparator = 3.0;
const double kSmallestButtonWidth = 40.0;
const double kSmallButtonWidth = 48.0;
const double kSmallButtonInsidePadding = 3.0;
const double kDefaultMargin = 5.0;
const double kRoundedButtonBorderRadius = 11.0;
const Color kDarkAndLightIconColor =
    Color.fromARGB(246, 44, 61, 255); // rgba(44, 61, 246, 255)
const Color kButtonColor = Color(0xFF3D3EC2);


const kPositionButtonTextStyle = TextStyle(
  // the color is the one defined in textTheme bodyMedium
  // specified in the ScreenMixin theme's
  fontSize: 17.0,
  color: kButtonColor,
);

const kSliderValueTextStyle = TextStyle(
  // the color is the one defined in textTheme bodyMedium
  // specified in the ScreenMixin theme's
  fontSize: kTitleFontSize,
  color: kButtonColor,
);

const double kTitleFontSize = 15.0;

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
        Provider.of<AudioPlayerVM>(
          context,
          listen: false,
        ).disposeAudioPlayer(); // Calling this method instead of
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10.0),
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
      ),
    );
  }

  Widget _buildAudioSlider() {
    return Consumer<AudioPlayerVM>(
      builder: (context, audioGlobalPlayerVM, child) {
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
                audioGlobalPlayerVM.currentAudioPosition.HHmmssZeroHH(),
                style: kSliderValueTextStyle,
              ),
              Expanded(
                child: SliderTheme(
                  data: const SliderThemeData(
                    trackHeight: 2.0,
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
      builder: (context) => const AudioOneSelectableDialogWidget(),
    ).then((selectedAudio) {
      print(selectedAudio);
    });
  }
}
