import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:volume_controller/volume_controller.dart';
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
  final VolumeController _volumeController = VolumeController();
  AudioPlayer? _audioPlayer;
  StreamSubscription<PlayerState>? _playerStateSub;
  bool _playerReady = false;
  bool _isPlaying = false;
  bool _isLoading = false;
  double _volume = 0.5;
  final String radioTitle = "Stereo 92 Mÿs Radio";
  int? _shutdownTimer; // Tiempo en minutos para el temporizador de apagado
  late Timer? _timer; // Temporizador

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initVolume();
      _initPlayer();
    });

    _timer = null;
  }

  Future<void> _initVolume() async {
    try {
      final currentVolume = await _volumeController.getVolume();
      if (!mounted) return;
      setState(() {
        _volume = currentVolume;
      });
    } catch (_) {
      // Ignore failures and keep the default slider value.
    }

    _volumeController.listener((volume) {
      if (!mounted) return;
      setState(() {
        _volume = volume;
      });
    });
  }

  Future<void> _initPlayer() async {
    if (!mounted) return;

    final player = AudioPlayer();
    player.setVolume(1.0);

    // Escuchar cambios en el estado del reproductor
    _playerStateSub = player.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final isBuffering =
          playerState.processingState == ProcessingState.buffering;

      if (!mounted) return;
      setState(() {
        _isPlaying = isPlaying;
        _isLoading = isBuffering;
      });
    });

    if (!mounted) return;
    setState(() {
      _audioPlayer = player;
      _playerReady = true;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _playerStateSub?.cancel();
    _audioPlayer?.dispose();
    _volumeController.removeListener();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    final player = _audioPlayer;
    if (player == null) {
      return;
    }

    if (_isPlaying) {
      await player.pause();
    } else {
      await player.setUrl(Config.streamUrl);
      await player.play();
    }
  }

  Future<void> _playRadio() async {
    final player = _audioPlayer;
    if (player == null) {
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });
      await player.setUrl(Config.streamUrl);
      await player.play();
    } catch (e) {
      _showErrorDialog('Error al reproducir la radio. Verifica tu conexi½n.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pauseRadio() async {
    final player = _audioPlayer;
    if (player == null) {
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });
      await player.pause();
    } catch (e) {
      _showErrorDialog('Error al pausar la reproducci½n. Intenta nuevamente.');
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
    _volumeController.setVolume(_volume);
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
      _showInfoDialog('La reproducci½n se ha detenido automÿticamente.');
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
            title: const Text('Informaci½n'),
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
            if (_isLoading || !_playerReady)
              const CircularProgressIndicator(color: Colors.red),
            const SizedBox(height: 20),
            Slider(
              value: _volume,
              min: 0.0,
              max: 1.0,
              activeColor: Colors.red,
              inactiveColor: Colors.white,
              onChanged: _playerReady ? _setVolume : null,
            ),
            const SizedBox(height: 20),
            IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause_circle : Icons.play_circle,
                color: Colors.red,
              ),
              iconSize: 80.0,
              onPressed: _playerReady ? _togglePlayPause : null,
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
