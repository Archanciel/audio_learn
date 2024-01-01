import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/audio.dart';
import '../../viewmodels/audio_player_vm.dart';

class SetAudioSpeedDialogWidget extends StatefulWidget {
  double audioPlaySpeed;

  SetAudioSpeedDialogWidget({
    super.key,
    required this.audioPlaySpeed,
  });

  @override
  _SetAudioSpeedDialogWidgetState createState() =>
      _SetAudioSpeedDialogWidgetState();
}

class _SetAudioSpeedDialogWidgetState extends State<SetAudioSpeedDialogWidget> {
  double _audioPlaySpeed = 1.0;
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
    AudioPlayerVM audioGlobalPlayerVM = Provider.of<AudioPlayerVM>(
      context,
      listen: false,
    );
    Audio? currentAudio = audioGlobalPlayerVM.currentAudio;

    if (currentAudio != null) {
      _audioPlaySpeed = currentAudio.audioPlaySpeed;
    }

    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: (event) {
        if (event.isKeyPressed(LogicalKeyboardKey.enter) ||
            event.isKeyPressed(LogicalKeyboardKey.numpadEnter)) {
          // executing the same code as in the 'Ok' TextButton
          // onPressed callback
          Navigator.of(context).pop(_audioPlaySpeed);
        }
      },
      child: AlertDialog(
        title: const Text('Vitesse de lecture'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('${_audioPlaySpeed.toStringAsFixed(2)}x'),
            _buildSlider(audioGlobalPlayerVM),
            _buildSpeedButtons(audioGlobalPlayerVM),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(_audioPlaySpeed);
            },
          ),
        ],
      ),
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
            }
          },
        ),
      ],
    );
  }

  Widget _buildSpeedButtons(
    AudioPlayerVM audioGlobalPlayerVM,
  ) {
    final speeds = [0.7, 1.0, 1.25, 1.5, 2.0];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: speeds.map((speed) {
        return TextButton(
          style: TextButton.styleFrom(
            minimumSize: const Size(18, 18), // Set a minimum touch target size
            padding:
                const EdgeInsets.symmetric(horizontal: 0), // Adjust padding as needed
          ),
          child: Text('${speed}x'),
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

    audioGlobalPlayerVM.changeAudioPlaySpeed(_audioPlaySpeed);
  }
}
