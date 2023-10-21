import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/audio.dart';
import '../models/playlist.dart';
import '../viewmodels/audio_global_player_vm.dart';

class AudioPlayerView extends StatefulWidget {
  final Audio audio;

  AudioPlayerView({Key? key})
      : audio = _createAudio(),
        super(key: key);

  static Playlist _createPlaylist() {
    final pl = Playlist(
      url: 'url',
      playlistType: PlaylistType.local,
      playlistQuality: PlaylistQuality.voice,
    );

    pl.downloadPath =
        "C:\\Users\\Jean-Pierre\\Downloads\\Audio\\audio_learn_short";

    return pl;
  }

  static Audio _createAudio() {
    final au = Audio(
      enclosingPlaylist: _createPlaylist(),
      originalVideoTitle: 'originalVideoTitle',
      compactVideoDescription: 'compactVideoDescription',
      videoUrl: 'videoUrl',
      audioDownloadDateTime: DateTime.now(),
      audioDownloadDuration: Duration.zero,
      videoUploadDate: DateTime.now(),
      audioDuration: Duration.zero,
    );

    au.audioFileName =
        "231004-214307-15 minutes de Janco pour retourner un climatosceptique 23-10-01.mp3";

    return au;
  }

  @override
  _AudioPlayerViewState createState() => _AudioPlayerViewState();
}

class _AudioPlayerViewState extends State<AudioPlayerView> {
  final double _audioIconSizeSmaller = 40;
  final double _audioIconSizeMedium = 50;
  final double _audioIconSizeLarge = 80;

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
              _buildSlider(),
              _buildPositions(),
            ],
          ),
          _buildPlayButtons(),
          _buildPositionButtons()
        ],
      ),
    );
  }

  Widget _buildSlider() {
    return Consumer<AudioGlobalPlayerVM>(
      builder: (context, audioGlobalPlayerVM, child) {
        return Slider(
          value: audioGlobalPlayerVM.position.inSeconds.toDouble(),
          min: 0.0,
          max: audioGlobalPlayerVM.duration.inSeconds.toDouble(),
          onChanged: (double value) {
            audioGlobalPlayerVM.seekTo(
              Duration(seconds: value.toInt()),
            );
          },
        );
      },
    );
  }

  Widget _buildPositions() {
    return Consumer<AudioGlobalPlayerVM>(
      builder: (context, audioGlobalPlayerVM, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(audioGlobalPlayerVM.position),
                style: const TextStyle(fontSize: 20.0),
              ),
              Text(
                _formatDuration(audioGlobalPlayerVM.remaining),
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
                    : audioGlobalPlayerVM.playFromFile();
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
                            onPressed: () => audioGlobalPlayerVM.seekBy(
                              const Duration(minutes: -1),
                            ),
                            icon: const Icon(Icons.fast_rewind),
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                            iconSize: _audioIconSizeMedium,
                            onPressed: () => audioGlobalPlayerVM.seekBy(
                              const Duration(seconds: -10),
                            ),
                            icon: const Icon(Icons.fast_rewind),
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                            iconSize: _audioIconSizeMedium,
                            onPressed: () => audioGlobalPlayerVM.seekBy(
                              const Duration(seconds: 10),
                            ),
                            icon: const Icon(Icons.fast_forward),
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                            iconSize: _audioIconSizeMedium,
                            onPressed: () => audioGlobalPlayerVM.seekBy(
                              const Duration(minutes: 1),
                            ),
                            icon: const Icon(Icons.fast_forward),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '1 m',
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
