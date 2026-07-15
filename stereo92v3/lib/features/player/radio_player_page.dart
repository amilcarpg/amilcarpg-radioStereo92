import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/audio/radio_playback_controller.dart';
import '../../core/telemetry/telemetry_service.dart';
import '../../core/timer/shutdown_timer_controller.dart';
import '../../core/volume/system_volume_controller.dart';
import '../../l10n/generated/app_localizations.dart';

class RadioPlayerPage extends StatefulWidget {
  const RadioPlayerPage({
    super.key,
    required this.playback,
    required this.timer,
    required this.consent,
    required this.volume,
  });

  final RadioPlaybackController playback;
  final ShutdownTimerController timer;
  final TelemetryConsentService consent;
  final SystemVolumeController volume;

  @override
  State<RadioPlayerPage> createState() => _RadioPlayerPageState();
}

class _RadioPlayerPageState extends State<RadioPlayerPage> {
  StreamSubscription<Object>? _errorSubscription;
  StreamSubscription<RadioPlaybackStatus>? _statusSubscription;
  double _volume = 0.5;
  bool _errorShown = false;

  @override
  void initState() {
    super.initState();
    _initializeVolume();
    _errorSubscription = widget.playback.errorStream.listen((_) {
      if (!mounted || _errorShown) return;
      _errorShown = true;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.playbackError)),
      );
    });
    _statusSubscription = widget.playback.statusStream.listen((status) {
      if (status == RadioPlaybackStatus.playing) _errorShown = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.consent.consent == null) {
        _showInitialConsentDialog();
      }
    });
  }

  Future<void> _initializeVolume() async {
    try {
      final value = await widget.volume.getVolume();
      if (mounted) setState(() => _volume = value.clamp(0.0, 1.0));
      widget.volume.addListener((value) {
        if (mounted) setState(() => _volume = value.clamp(0.0, 1.0));
      });
    } catch (_) {
      // The volume slider remains usable with its safe default.
    }
  }

  @override
  void dispose() {
    _errorSubscription?.cancel();
    _statusSubscription?.cancel();
    widget.volume.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.sizeOf(context);
    final compact = size.height < 700;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[Color(0xFF090909), Color(0xFF150000)],
              ),
            ),
            child: SizedBox.expand(),
          ),
          Positioned(
            top: -120,
            left: -60,
            child: _GlowCircle(size: 220, opacity: 0.08),
          ),
          Positioned(
            bottom: -140,
            right: -40,
            child: _GlowCircle(size: 260, opacity: 0.06),
          ),
          SafeArea(
            child: Column(
              children: <Widget>[
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 12),
                    child: IconButton(
                      tooltip: l10n.privacy,
                      constraints: const BoxConstraints(
                        minWidth: 48,
                        minHeight: 48,
                      ),
                      onPressed: _showPrivacySettings,
                      icon: const Icon(Icons.privacy_tip_outlined),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            _Header(l10n: l10n, compact: compact),
                            SizedBox(height: compact ? 20 : 32),
                            _PlayerCard(
                              playback: widget.playback,
                              compact: compact,
                              volume: _volume,
                              onVolumeChanged: _setVolume,
                            ),
                            SizedBox(height: compact ? 16 : 24),
                            _TimerSection(
                              controller: widget.timer,
                              onConfigure: _showTimerDialog,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _setVolume(double value) async {
    setState(() => _volume = value);
    try {
      await widget.volume.setVolume(value);
    } catch (_) {
      // A platform volume failure must not interrupt playback.
    }
  }

  Future<void> _showInitialConsentDialog() async {
    final l10n = AppLocalizations.of(context);
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.privacyTitle),
        content: Text(l10n.privacyMessage),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.privacyDecline),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.privacyAccept),
          ),
        ],
      ),
    );
    await widget.consent.update(accepted ?? false);
  }

  Future<void> _showPrivacySettings() async {
    final l10n = AppLocalizations.of(context);
    var enabled = widget.consent.consent == true;
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.privacy),
          content: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.telemetrySetting),
            subtitle: Text(enabled ? l10n.telemetryOn : l10n.telemetryOff),
            value: enabled,
            onChanged: (value) async {
              setDialogState(() => enabled = value);
              await widget.consent.update(value);
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.close),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showTimerDialog() async {
    final l10n = AppLocalizations.of(context);
    var selectedMinutes = 5;
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.timerTitle),
          content: DropdownButtonFormField<int>(
            value: selectedMinutes,
            decoration: InputDecoration(labelText: l10n.timerConfigure),
            items: <int>[5, 10, 15, 30, 60]
                .map(
                  (minutes) => DropdownMenuItem<int>(
                    value: minutes,
                    child: Text(l10n.minutes(minutes)),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setDialogState(() => selectedMinutes = value);
              }
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                widget.timer.start(Duration(minutes: selectedMinutes));
                Navigator.pop(context);
              },
              child: Text(l10n.accept),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.l10n, required this.compact});

  final AppLocalizations l10n;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          l10n.stationName,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: compact ? 20 : 24,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.stationTagline,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: compact ? 15 : 17,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.6,
          ),
        ),
      ],
    );
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({
    required this.playback,
    required this.compact,
    required this.volume,
    required this.onVolumeChanged,
  });

  final RadioPlaybackController playback;
  final bool compact;
  final double volume;
  final ValueChanged<double> onVolumeChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0B0B),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: StreamBuilder<RadioPlaybackStatus>(
        stream: playback.statusStream,
        initialData: playback.status,
        builder: (context, snapshot) {
          final status = snapshot.data ?? RadioPlaybackStatus.idle;
          final statusLabel = _statusLabel(l10n, status);
          final busy = status == RadioPlaybackStatus.connecting ||
              status == RadioPlaybackStatus.retrying;
          return Column(
            children: <Widget>[
              Image.asset(
                'assets/stereo92.png',
                height: compact ? 140 : 180,
                width: compact ? 140 : 180,
                semanticLabel: l10n.stationName,
              ),
              SizedBox(height: compact ? 16 : 24),
              Semantics(
                liveRegion: true,
                label: statusLabel,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (busy) ...<Widget>[
                      const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Flexible(
                      child: Text(
                        statusLabel,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: compact ? 12 : 20),
              Semantics(
                label: l10n.volume,
                value: l10n.percentValue((volume * 100).round()),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.volume_up, color: Colors.white70),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Slider(
                        value: volume,
                        activeColor: Colors.red,
                        inactiveColor: Colors.white24,
                        onChanged: onVolumeChanged,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.percentValue((volume * 100).round()),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              SizedBox(height: compact ? 16 : 24),
              _PlayButton(playback: playback, status: status),
            ],
          );
        },
      ),
    );
  }

  String _statusLabel(AppLocalizations l10n, RadioPlaybackStatus status) {
    return switch (status) {
      RadioPlaybackStatus.idle => l10n.statusIdle,
      RadioPlaybackStatus.connecting => l10n.statusConnecting,
      RadioPlaybackStatus.playing => l10n.statusPlaying,
      RadioPlaybackStatus.paused => l10n.statusPaused,
      RadioPlaybackStatus.retrying => l10n.statusRetrying,
      RadioPlaybackStatus.failed => l10n.statusFailed,
    };
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.playback, required this.status});

  final RadioPlaybackController playback;
  final RadioPlaybackStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final active = playback.wantsToPlay;
    final failed = status == RadioPlaybackStatus.failed;
    final label = failed ? l10n.retry : (active ? l10n.pause : l10n.play);
    return Semantics(
      key: const ValueKey<String>('play_button'),
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        child: InkResponse(
          onTap: () {
            if (failed) {
              playback.retry();
            } else if (active) {
              playback.pause();
            } else {
              playback.play();
            }
          },
          radius: 48,
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: <Color>[Colors.red, Color(0xFF9B0000)],
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              failed
                  ? Icons.refresh_rounded
                  : active
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 52,
            ),
          ),
        ),
      ),
    );
  }
}

class _TimerSection extends StatelessWidget {
  const _TimerSection({required this.controller, required this.onConfigure});

  final ShutdownTimerController controller;
  final VoidCallback onConfigure;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (!controller.isActive) {
          return SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onConfigure,
              icon: const Icon(Icons.timer_outlined),
              label: Text(l10n.timerConfigure, textAlign: TextAlign.center),
            ),
          );
        }
        final remaining = controller.remaining;
        final hours = remaining.inHours;
        final minutes = remaining.inMinutes.remainder(60);
        final seconds = remaining.inSeconds.remainder(60);
        final value = hours > 0
            ? '${hours.toString().padLeft(2, '0')}:'
                '${minutes.toString().padLeft(2, '0')}:'
                '${seconds.toString().padLeft(2, '0')}'
            : '${minutes.toString().padLeft(2, '0')}:'
                '${seconds.toString().padLeft(2, '0')}';
        return Semantics(
          liveRegion: true,
          child: Column(
            children: <Widget>[
              Text(l10n.timerActive(value)),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: controller.cancel,
                icon: const Icon(Icons.timer_off_outlined),
                label: Text(l10n.timerCancel),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red.withValues(alpha: opacity),
        ),
      ),
    );
  }
}
