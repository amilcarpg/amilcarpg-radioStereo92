import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart' show PlayerState, ProcessingState; // Specific imports
import 'config.dart';
import 'dart:async';
import 'widgets.dart';
import 'audio_service.dart';
import 'app_styles.dart'; // Import AppStyles

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radio Stereo92',
      theme: ThemeData(
        brightness: Brightness.dark, // Overall dark theme
        primarySwatch: AppStyles.createMaterialColor(AppStyles.primaryRed),
        scaffoldBackgroundColor: AppStyles.primaryBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppStyles.primaryBackground, // Or a slightly different shade if desired
          foregroundColor: AppStyles.textOnPrimaryBackground, // Color for title text and icons
          elevation: 0, // Flat app bar
        ),
        textTheme: TextTheme(
          bodyMedium: AppStyles.generalTextStyle, // General text
          titleLarge: AppStyles.radioTitleStyle, // For the main radio title
          labelLarge: TextStyle(color: AppStyles.textOnPrimaryRed), // For button text
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: AppStyles.primaryRed,
          inactiveTrackColor: AppStyles.textOnPrimaryBackground.withOpacity(0.3),
          thumbColor: AppStyles.primaryRed,
          overlayColor: AppStyles.primaryRed.withAlpha(0x29), // From Colors.red.withAlpha(0x29)
          valueIndicatorColor: AppStyles.primaryRed,
          activeTickMarkColor: Colors.transparent,
          inactiveTickMarkColor: Colors.transparent,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppStyles.primaryRed,
            foregroundColor: AppStyles.textOnPrimaryRed, // Text color for ElevatedButton
            textStyle: TextStyle(fontSize: 16, color: AppStyles.textOnPrimaryRed),
          ),
        ),
        iconTheme: const IconThemeData(
          color: AppStyles.primaryRed, // Default color for icons if not overridden
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppStyles.primaryRed, // Color for text buttons in dialogs
          )
        ),
        dialogTheme: DialogTheme(
          backgroundColor: AppStyles.primaryBackground.withOpacity(0.9), // Slightly transparent dark dialog
          titleTextStyle: TextStyle(color: AppStyles.textOnPrimaryBackground, fontSize: 20, fontWeight: FontWeight.bold),
          contentTextStyle: TextStyle(color: AppStyles.textOnPrimaryBackground, fontSize: 16),
        )
      ),
      home: const RadioPlayer(),
    );
  }
}

class RadioPlayer extends StatefulWidget {
  const RadioPlayer({Key? key}) : super(key: key);

  @override
  _RadioPlayerState createState() => _RadioPlayerState();
}

class _RadioPlayerState extends State<RadioPlayer> {
  late AudioService _audioService;
  bool _isPlaying = false;
  bool _isLoading = false; // Represents buffering or explicit loading state
  double _volume = 0.5;
  final String radioTitle = "Stereo 92 Más Radio";
  final String imageAssetPath = 'assets/stereo92.png';
  int? _shutdownTimerDuration; // Duration in minutes for the timer
  Timer? _activeShutdownTimer; // The active Timer object

  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<ProcessingState>? _processingStateSubscription;

  @override
  void initState() {
    super.initState();
    _audioService = AudioService();
    _audioService.setVolume(_volume); // Set initial volume

    _playerStateSubscription = _audioService.playerStateStream.listen((playerState) {
      if (mounted) {
        setState(() {
          _isPlaying = playerState.playing;
          // _isLoading is more reliably managed by processingStateStream for buffering
        });
      }
    });

    _processingStateSubscription = _audioService.processingStateStream.listen((processingState) {
      if (mounted) {
        setState(() {
          _isLoading = processingState == ProcessingState.buffering ||
                       processingState == ProcessingState.loading;
        });
      }
    });
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _processingStateSubscription?.cancel();
    _activeShutdownTimer?.cancel();
    _audioService.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    // Set _isLoading true for immediate feedback before async operations complete or streams update
    if (mounted) {
      setState(() {
        _isLoading = true; 
      });
    }

    try {
      if (_isPlaying) {
        await _audioService.pause();
      } else {
        await _audioService.play(Config.streamUrl);
      }
      // _isPlaying and _isLoading related to buffering will be updated by streams.
      // If pause was successful, _isPlaying becomes false via stream.
      // If play was successful, _isPlaying becomes true and _isLoading handles buffering via stream.
    } catch (e) {
      if (mounted) {
        _showErrorDialog(_isPlaying
            ? 'Error al pausar la reproducción. Intenta nuevamente.'
            : 'Error al reproducir la radio. Verifica tu conexión.');
        setState(() {
          _isLoading = false; // Reset isLoading on error
        });
      }
    }
    // The _isLoading state set to true at the beginning of this method provides immediate UI feedback.
    // If play/pause succeeds, the _processingStateSubscription will update _isLoading based on
    // player states like buffering, loading, ready, or idle.
    // If an error occurs, the catch block above sets _isLoading = false.
    // Thus, the complex finally block is no longer needed here.
  }

  void _handleVolumeChanged(double newVolume) {
    if (mounted) {
      setState(() {
        _volume = newVolume;
      });
      _audioService.setVolume(newVolume);
    }
  }

  void _handleSetShutdownTimer(int minutes) {
    _activeShutdownTimer?.cancel(); // Cancel any existing timer
    if (mounted) {
      setState(() {
        _shutdownTimerDuration = minutes;
      });
    }
    _activeShutdownTimer = Timer(Duration(minutes: minutes), () async {
      try {
        await _audioService.pause(); // Pause the radio
         if (mounted) {
          _showInfoDialog('La reproducción se ha detenido automáticamente.');
          setState(() {
            _shutdownTimerDuration = null; // Clear timer display
          });
        }
      } catch (e) {
        if (mounted) {
          _showErrorDialog('Error al detener la radio automáticamente.');
        }
      }
    });
  }

  void _showErrorDialog(String message) {
    if (mounted) { // Ensure widget is still mounted before showing dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    }
  }

  void _showInfoDialog(String message) {
    if (mounted) { // Ensure widget is still mounted
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Información'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stereo 92 FM'),
        // backgroundColor will be picked from theme's appBarTheme
      ),
      body: Container(
        // color will be picked from theme's scaffoldBackgroundColor
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InfoDisplay(
              radioTitle: radioTitle,
              imageAssetPath: imageAssetPath,
            ),
            const SizedBox(height: 30), // Adjusted spacing
            PlayerControls(
              isPlaying: _isPlaying,
              isLoading: _isLoading,
              volume: _volume,
              onPlayPauseToggle: _togglePlayPause,
              onVolumeChanged: _handleVolumeChanged,
            ),
            const SizedBox(height: 30), // Adjusted spacing
            // Display active shutdown timer duration if any
            if (_shutdownTimerDuration != null) 
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  'Apagado automático en: $_shutdownTimerDuration min',
                  style: AppStyles.timerTextStyle, // Use style from AppStyles
                ),
              ),
            ShutdownTimerButton(
              onPressed: _displayShutdownTimerDialog,
            ),
          ],
        ),
      ),
    );
  }

  void _displayShutdownTimerDialog() {
    int currentDialogSelection = _shutdownTimerDuration ?? 5; // Default to current timer or 5
    final List<int> timerOptions = [5, 10, 15, 30, 45, 60, 90, 120]; // Expanded options

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Configurar temporizador de apagado'),
          content: ShutdownTimerDialogContent(
            initialValue: currentDialogSelection,
            options: timerOptions,
            onChanged: (newValue) {
              currentDialogSelection = newValue;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Optionally, offer a way to cancel the timer
                // For now, just closes dialog. To cancel, user can set timer to 0 or a new value.
              },
              child: const Text('Cancelar'),
            ),
             TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Add an option to clear the timer, e.g. by passing 0 or a special value
                // For now, this is not implemented in _handleSetShutdownTimer
                // setState(() {
                //   _activeShutdownTimer?.cancel();
                //   _shutdownTimerDuration = null;
                // });
                // _showInfoDialog("Temporizador cancelado. Seleccione una duración o cierre.");
                if (mounted) {
                  _activeShutdownTimer?.cancel();
                  setState(() {
                    _shutdownTimerDuration = null;
                  });
                  _showInfoDialog("Temporizador existente cancelado.");
                }
              },
              child: const Text('Limpiar Actual'), // Button to clear existing timer
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleSetShutdownTimer(currentDialogSelection);
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }
}
