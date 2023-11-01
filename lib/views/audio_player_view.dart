import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/audio_global_player_vm.dart';
import '../constants.dart';
import 'screen_mixin.dart';
import 'widgets/audio_one_selectable_dialog_widget.dart';

/// Screen enabling the user to play an audio, change the playing
/// position or go to a previous, next or selected audio.
class AudioPlayerView extends StatefulWidget {
  const AudioPlayerView({Key? key}) : super(key: key);

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

        Provider.of<AudioGlobalPlayerVM>(
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
        Provider.of<AudioGlobalPlayerVM>(
          context,
          listen: false,
        ).dispose();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Player'),
      ),
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
    return Consumer<AudioGlobalPlayerVM>(
      builder: (context, audioGlobalPlayerVM, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: kDefaultMargin),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                _formatDuration(audioGlobalPlayerVM.currentAudioPosition),
                style: const TextStyle(fontSize: 15.0),
              ),
              Expanded(
                child: SliderTheme(
                  data: const SliderThemeData(
                    thumbShape: RoundSliderThumbShape(
                        enabledThumbRadius:
                            8.0), // Adjust the radius as you need
                  ),
                  child: Slider(
                    value: audioGlobalPlayerVM.currentAudioPosition.inSeconds
                        .toDouble(),
                    min: 0.0,
                    max: audioGlobalPlayerVM.currentAudioTotalDuration.inSeconds
                        .toDouble(),
                    onChanged: (double value) {
                      audioGlobalPlayerVM.goToAudioPlayPosition(
                        Duration(seconds: value.toInt()),
                      );
                    },
                  ),
                ),
              ),
              Text(
                _formatDuration(
                    audioGlobalPlayerVM.currentAudioRemainingDuration),
                style: const TextStyle(fontSize: 15.0),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }

  Widget _buildPlayButton() {
    return Consumer<AudioGlobalPlayerVM>(
      builder: (context, audioGlobalPlayerVM, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
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
          ],
        );
      },
    );
  }

  Widget _buildStartEndButtonsWithTitle() {
    return Consumer<AudioGlobalPlayerVM>(
      builder: (context, audioGlobalPlayerVM, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              iconSize: _audioIconSizeMedium,
              onPressed: () => audioGlobalPlayerVM.skipToStart(),
              icon: const Icon(Icons.skip_previous),
            ),
            Expanded(
              child: Text(
                audioGlobalPlayerVM.currentAudio?.validVideoTitle ?? '',
                style: const TextStyle(fontSize: 15.0),
                maxLines: 4,
                textAlign: TextAlign.center,
                // overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onLongPress: () => _displayOtherAudiosDialog(),
              child: IconButton(
                iconSize: _audioIconSizeMedium,
                onPressed: () => audioGlobalPlayerVM.skipToEnd(),
                icon: const Icon(Icons.skip_next),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPositionButtons() {
    return Consumer<AudioGlobalPlayerVM>(
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
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '1 m',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '10 s',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '10 s',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '1 m',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18.0),
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

  void _displayOtherAudiosDialog() {
    // Using FocusNode to enable clicking on Enter to close
    // the dialog
    final FocusNode focusNode = FocusNode();

    showDialog(
      context: context,
      builder: (context) => AudioOneSelectableDialogWidget(
        focusNode: focusNode,
      ),
    ).then((selectedAudio) {
      print(selectedAudio);
      focusNode.requestFocus();
    });
  }
}
