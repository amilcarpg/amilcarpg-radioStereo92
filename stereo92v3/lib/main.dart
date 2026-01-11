import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'config.dart' as app_config;
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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.soraTextTheme(),
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
      await player.setUrl(app_config.Config.streamUrl);
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
      await player.setUrl(app_config.Config.streamUrl);
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
    final size = MediaQuery.of(context).size;
    final isCompact = size.height < 700;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF090909), Color(0xFF150000)],
              ),
            ),
          ),
          Positioned(
            top: -120,
            left: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -140,
            right: -40,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withValues(alpha: 0.06),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Header(
                        title: radioTitle,
                        compact: isCompact,
                      ),
                      SizedBox(height: isCompact ? 20 : 32),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 28,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B0B0B),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/stereo92.png',
                              height: isCompact ? 140 : 180,
                              width: isCompact ? 140 : 180,
                            ),
                            SizedBox(height: isCompact ? 16 : 24),
                            if (_isLoading || !_playerReady)
                              const CircularProgressIndicator(
                                color: Colors.red,
                              ),
                            SizedBox(height: isCompact ? 12 : 20),
                            Row(
                              children: [
                                const Icon(
                                  Icons.volume_up,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      trackHeight: 4,
                                      activeTrackColor: Colors.red,
                                      inactiveTrackColor: Colors.white24,
                                      thumbColor: Colors.redAccent,
                                      overlayColor:
                                          Colors.red.withValues(alpha: 0.2),
                                    ),
                                    child: Slider(
                                      value: _volume,
                                      min: 0.0,
                                      max: 1.0,
                                      onChanged:
                                          _playerReady ? _setVolume : null,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _VolumeBadge(value: _volume),
                              ],
                            ),
                            SizedBox(height: isCompact ? 16 : 24),
                            _PlayButton(
                              isPlaying: _isPlaying,
                              enabled: _playerReady,
                              onPressed: _togglePlayPause,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isCompact ? 16 : 24),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _showTimerDialog(),
                          icon: const Icon(Icons.timer_outlined),
                          label: const Text(
                            'Configurar temporizador de apagado',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.red.withValues(alpha: 0.35),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.compact});

  final String title;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Stereo 92 FM',
          style: TextStyle(
            color: Colors.white,
            fontSize: compact ? 20 : 24,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: compact ? 14 : 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({
    required this.isPlaying,
    required this.enabled,
    required this.onPressed,
  });

  final bool isPlaying;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final baseColor = enabled ? Colors.red : Colors.red.withValues(alpha: 0.4);
    return InkResponse(
      onTap: enabled ? onPressed : null,
      radius: 44,
        child: Container(
          width: 92,
          height: 92,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              baseColor.withValues(alpha: 0.9),
              baseColor.withValues(alpha: 0.6),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: baseColor.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            final scale = Tween<double>(begin: 0.9, end: 1.0).animate(animation);
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: scale, child: child),
            );
          },
          child: Icon(
            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            key: ValueKey<bool>(isPlaying),
            color: Colors.white,
            size: 52,
          ),
        ),
      ),
    );
  }
}

class _VolumeBadge extends StatelessWidget {
  const _VolumeBadge({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final percent = (value * 100).round().clamp(0, 100);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white24,
        ),
      ),
      child: Text(
        '$percent%',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
