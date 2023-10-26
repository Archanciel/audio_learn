import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/audio_global_player_vm.dart';
import 'screen_mixin.dart';

class AudioPlayerView extends StatefulWidget {
  AudioPlayerView({Key? key}) : super(key: key);

  @override
  _AudioPlayerViewState createState() => _AudioPlayerViewState();
}

class _AudioPlayerViewState extends State<AudioPlayerView>
    with WidgetsBindingObserver, ScreenMixin {
  final double _audioIconSizeSmaller = 30;
  final double _audioIconSizeMedium = 40;
  final double _audioIconSizeLarge = 70;

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        writeToLogFile(
            message:
                'WidgetsBinding didChangeAppLifecycleState(): app resumed'); // Provider.of<AudioGlobalPlayerVM>(context, listen: false).resume();
        // Provider.of<AudioGlobalPlayerVM>(context, listen: false).resume();
        break;
      // App paused and sent to background
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        writeToLogFile(
            message:
                'WidgetsBinding didChangeAppLifecycleState(): app inactive, paused or closed');
        Provider.of<AudioGlobalPlayerVM>(context, listen: false)
            .updateAndSaveCurrentAudio();
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
          Column(
            children: [
              const SizedBox(height: 16.0),
              _buildAudioSlider(),
              _buildPositions(),
            ],
          ),
          _buildPlayButtons(),
          _buildPositionButtons()
        ],
      ),
    );
  }

  Widget _buildAudioSlider() {
    return Consumer<AudioGlobalPlayerVM>(
      builder: (context, audioGlobalPlayerVM, child) {
        return Slider(
          value: audioGlobalPlayerVM.currentAudioPosition.inSeconds.toDouble(),
          min: 0.0,
          max: audioGlobalPlayerVM.currentAudioTotalDuration.inSeconds
              .toDouble(),
          onChanged: (double value) {
            audioGlobalPlayerVM.goToAudioPlayPosition(
              Duration(seconds: value.toInt()),
            );
          },
        );
      },
    );
  }

  /// Displays under the audio slider at left the current position
  /// and at right the remaining time of the audio file.
  Widget _buildPositions() {
    return Consumer<AudioGlobalPlayerVM>(
      builder: (context, audioGlobalPlayerVM, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(audioGlobalPlayerVM.currentAudioPosition),
                style: const TextStyle(fontSize: 20.0),
              ),
              Text(
                _formatDuration(
                    audioGlobalPlayerVM.currentAudioRemainingDuration),
                style: const TextStyle(fontSize: 20.0),
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

  Widget _buildPlayButtons() {
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
            IconButton(
              iconSize: _audioIconSizeLarge,
              onPressed: (() {
                audioGlobalPlayerVM.isPlaying
                    ? audioGlobalPlayerVM.pause()
                    : audioGlobalPlayerVM.playFromCurrentAudioFile();
              }),
              icon: Icon(audioGlobalPlayerVM.isPlaying
                  ? Icons.pause
                  : Icons.play_arrow),
            ),
            IconButton(
              iconSize: _audioIconSizeMedium,
              onPressed: () => audioGlobalPlayerVM.skipToEnd(),
              icon: const Icon(Icons.skip_next),
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
                          style: TextStyle(fontSize: 21.0),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '10 s',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 21.0),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '1 m',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 21.0),
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
}
