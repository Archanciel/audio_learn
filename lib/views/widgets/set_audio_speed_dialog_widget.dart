import 'package:flutter/material.dart';

class SetAudioSpeedDialogWidget extends StatefulWidget {
  const SetAudioSpeedDialogWidget({super.key});

  @override
  _SetAudioSpeedDialogWidgetState createState() => _SetAudioSpeedDialogWidgetState();
}

class _SetAudioSpeedDialogWidgetState extends State<SetAudioSpeedDialogWidget> {
  double _sliderValue = 1.0;

  void _changeSliderValue(double newValue) {
    setState(() {
      _sliderValue = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Vitesse de lecture'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('${_sliderValue.toStringAsFixed(1)}x'),
          _buildSlider(),
          _buildSpeedButtons(),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Row _buildSlider() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () {
            double newSpeed = _sliderValue - 0.25;
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
            label: "${_sliderValue.toStringAsFixed(1)}x",
            value: _sliderValue,
            onChanged: (value) {
              _changeSliderValue(value);
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            double newSpeed = _sliderValue + 0.25;
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
      _sliderValue = speed;
    });
    // Ajouter la logique pour changer la vitesse de lecture de l'audio
  }
}
