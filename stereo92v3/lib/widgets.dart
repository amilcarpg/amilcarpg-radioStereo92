import 'package:flutter/material.dart';

// --- Existing ShutdownTimerDialogContent ---
class ShutdownTimerDialogContent extends StatefulWidget {
  final int initialValue;
  final List<int> options;
  final ValueChanged<int> onChanged;

  const ShutdownTimerDialogContent({
    Key? key,
    required this.initialValue,
    required this.options,
    required this.onChanged,
  }) : super(key: key);

  @override
  _ShutdownTimerDialogContentState createState() =>
      _ShutdownTimerDialogContentState();
}

class _ShutdownTimerDialogContentState
    extends State<ShutdownTimerDialogContent> {
  late int _selectedMinutes;

  @override
  void initState() {
    super.initState();
    _selectedMinutes = widget.initialValue;
    if (!widget.options.contains(_selectedMinutes)) {
      _selectedMinutes = widget.options.isNotEmpty ? widget.options.first : 5;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>(
      value: _selectedMinutes,
      items: widget.options
          .map(
            (minutes) => DropdownMenuItem(
              value: minutes,
              child: Text('$minutes minutos'),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedMinutes = value;
          });
          widget.onChanged(value);
        }
      },
      isExpanded: true,
    );
  }
}

// --- New Widgets ---

class InfoDisplay extends StatelessWidget {
  final String radioTitle;
  final String imageAssetPath;

  const InfoDisplay({
    Key? key,
    required this.radioTitle,
    required this.imageAssetPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(imageAssetPath, height: 200, width: 200),
        const SizedBox(height: 20),
        Text(
          radioTitle,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class PlayerControls extends StatelessWidget {
  final bool isPlaying;
  final bool isLoading;
  final double volume;
  final VoidCallback onPlayPauseToggle;
  final ValueChanged<double> onVolumeChanged;

  const PlayerControls({
    Key? key,
    required this.isPlaying,
    required this.isLoading,
    required this.volume,
    required this.onPlayPauseToggle,
    required this.onVolumeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isLoading) CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 20), // This SizedBox is for spacing even if loading is false
        Slider(
          value: volume,
          min: 0.0,
          max: 1.0,
          // activeColor and inactiveColor will be picked from SliderTheme in main.dart
          onChanged: onVolumeChanged,
        ),
        const SizedBox(height: 20),
        IconButton(
          icon: Icon(
            isPlaying ? Icons.pause_circle : Icons.play_circle,
            // color will be picked from IconTheme in main.dart
          ),
          iconSize: 80.0,
          onPressed: onPlayPauseToggle,
        ),
      ],
    );
  }
}

class ShutdownTimerButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ShutdownTimerButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      // style will be picked from ElevatedButtonTheme in main.dart
      child: const Text('Configurar temporizador de apagado'),
    );
  }
}
