import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'config.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radio Stereo92',
      theme: ThemeData(primarySwatch: Colors.blue),
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
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;
  double _volume = 0.5;
  final String radioTitle = "Stereo 92 Más Radio";
  int? _shutdownTimer; // Tiempo en minutos para el temporizador de apagado
  late Timer? _timer; // Temporizador

  @override
  void initState() {
    super.initState();
    _audioPlayer.setVolume(_volume);

    // Escuchar cambios en el estado del reproductor
    _audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final isBuffering =
          playerState.processingState == ProcessingState.buffering;

      setState(() {
        _isPlaying = isPlaying;
        _isLoading = isBuffering;
      });
    });

    _timer = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.setUrl(Config.streamUrl);
      await _audioPlayer.play();
    }
  }

  Future<void> _playRadio() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await _audioPlayer.setUrl(Config.streamUrl);
      await _audioPlayer.play();
    } catch (e) {
      _showErrorDialog('Error al reproducir la radio. Verifica tu conexión.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pauseRadio() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await _audioPlayer.pause();
    } catch (e) {
      _showErrorDialog('Error al pausar la reproducción. Intenta nuevamente.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _setVolume(double value) {
    setState(() {
      _volume = value;
    });
    _audioPlayer.setVolume(_volume);
  }

  void _setShutdownTimer(int minutes) {
    if (_timer != null) {
      _timer!.cancel(); // Cancelar temporizador existente
    }
    setState(() {
      _shutdownTimer = minutes;
    });
    _timer = Timer(Duration(minutes: minutes), () {
      _pauseRadio(); // Pausar la radio cuando el temporizador termine
      _showInfoDialog('La reproducción se ha detenido automáticamente.');
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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

  void _showInfoDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stereo 92 FM'),
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/stereo92.png', height: 200, width: 200),
            const SizedBox(height: 20),
            Text(
              radioTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            if (_isLoading) const CircularProgressIndicator(color: Colors.red),
            const SizedBox(height: 20),
            Slider(
              value: _volume,
              min: 0.0,
              max: 1.0,
              activeColor: Colors.red,
              inactiveColor: Colors.white,
              onChanged: _setVolume,
            ),
            const SizedBox(height: 20),
            IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause_circle : Icons.play_circle,
                color: Colors.red,
              ),
              iconSize: 80.0,
              onPressed: _togglePlayPause,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showTimerDialog(),
              child: const Text('Configurar temporizador de apagado'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  void _showTimerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        int selectedMinutes = 5; // Valor predeterminado
        return AlertDialog(
          title: const Text('Configurar temporizador de apagado'),
          content: DropdownButton<int>(
            value: selectedMinutes,
            items:
                [5, 10, 15, 30, 60]
                    .map(
                      (minutes) => DropdownMenuItem(
                        value: minutes,
                        child: Text('$minutes minutos'),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) {
                selectedMinutes = value;
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _setShutdownTimer(selectedMinutes);
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }
}
