import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  void _changeSliderValue(double newValue) {
    setState(() {
      _audioPlaySpeed = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
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
            _buildSlider(),
            _buildSpeedButtons(),
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

  Row _buildSlider() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () {
            double newSpeed = _audioPlaySpeed - 0.25;
            if (newSpeed >= 0.5) {
              _changeSliderValue(newSpeed);
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
              _changeSliderValue(value);
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            double newSpeed = _audioPlaySpeed + 0.25;
            if (newSpeed <= 2.0) {
              _changeSliderValue(newSpeed);
            }
          },
        ),
      ],
    );
  }

  Widget _buildSpeedButtons() {
    final speeds = [0.5, 1.0, 1.5, 2.0];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: speeds.map((speed) {
        return TextButton(
          child: Text('${speed}x'),
          onPressed: () => _setPlaybackSpeed(speed),
        );
      }).toList(),
    );
  }

  void _setPlaybackSpeed(double speed) {
    setState(() {
      _audioPlaySpeed = speed;
    });
    // Ajouter la logique pour changer la vitesse de lecture de l'audio
  }
}
