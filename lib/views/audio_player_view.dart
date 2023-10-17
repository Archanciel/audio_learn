import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/audio.dart';
import '../models/playlist.dart';
import '../viewmodels/audio_player_vm.dart';

class AudioPlayerView extends StatefulWidget {
  final Playlist playlist;
  final Audio audio;

  AudioPlayerView({Key? key})
      : playlist = _createPlaylist(),
        audio = _createAudio(),
        super(key: key);

  static Playlist _createPlaylist() {
    final pl = Playlist(
      url: 'url',
      playlistType: PlaylistType.local,
      playlistQuality: PlaylistQuality.voice,
    );

    pl.downloadPath = 'audio';
    
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

    au.audioFileName = 'myAudio.mp3';

    return au;
  }

  @override
  _AudioPlayerViewState createState() => _AudioPlayerViewState();
}

class _AudioPlayerViewState extends State<AudioPlayerView> {
  final double _audioIconSizeSmaller = 50;
  final double _audioIconSizeMedium = 60;
  final double _audioIconSizeLarge = 90;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AudioPlayerVM(),
      child: Scaffold(
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
      ),
    );
  }

  Widget _buildSlider() {
    return Consumer<AudioPlayerVM>(
      builder: (context, viewModel, child) {
        return Slider(
          value: viewModel.position.inSeconds.toDouble(),
          min: 0.0,
          max: viewModel.duration.inSeconds.toDouble(),
          onChanged: (double value) {
            viewModel.seekTo(
              widget.audio,
              Duration(seconds: value.toInt()),
            );
          },
        );
      },
    );
  }

  Widget _buildPositions() {
    return Consumer<AudioPlayerVM>(
      builder: (context, viewModel, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(viewModel.position),
                style: const TextStyle(fontSize: 20.0),
              ),
              Text(
                _formatDuration(viewModel.remaining),
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
    return Consumer<AudioPlayerVM>(
      builder: (context, viewModel, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              iconSize: _audioIconSizeMedium,
              onPressed: () => viewModel.skipToStart(widget.audio),
              icon: const Icon(Icons.skip_previous),
            ),
            IconButton(
              iconSize: _audioIconSizeLarge,
              onPressed: (() {
                widget.audio.isPlaying
                    ? viewModel.pause(widget.audio)
                    : viewModel.playFromAssets(widget.audio);
              }),
              icon: Icon(widget.audio.isPlaying ? Icons.pause : Icons.play_arrow),
            ),
            IconButton(
              iconSize: _audioIconSizeMedium,
              onPressed: () => viewModel.skipToEnd(widget.audio),
              icon: const Icon(Icons.skip_next),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPositionButtons() {
    return Consumer<AudioPlayerVM>(
      builder: (context, viewModel, child) {
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
                            onPressed: () => viewModel.seekBy(
                              widget.audio,
                              const Duration(minutes: -1),
                            ),
                            icon: const Icon(Icons.fast_rewind),
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                            iconSize: _audioIconSizeMedium,
                            onPressed: () => viewModel.seekBy(
                              widget.audio,
                              const Duration(seconds: -10),
                            ),
                            icon: const Icon(Icons.fast_rewind),
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                            iconSize: _audioIconSizeMedium,
                            onPressed: () => viewModel.seekBy(
                              widget.audio,
                              const Duration(seconds: 10),
                            ),
                            icon: const Icon(Icons.fast_forward),
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                            iconSize: _audioIconSizeMedium,
                            onPressed: () => viewModel.seekBy(
                              widget.audio,
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
