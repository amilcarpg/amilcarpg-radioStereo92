class RetryBackoff {
  RetryBackoff({
    this.delays = const <Duration>[
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 4),
      Duration(seconds: 8),
      Duration(seconds: 16),
      Duration(seconds: 30),
    ],
  }) : assert(delays.isNotEmpty);

  final List<Duration> delays;
  int _attempt = 0;

  int get attempt => _attempt;

  Duration nextDelay() {
    final delay = delays[_attempt.clamp(0, delays.length - 1)];
    _attempt++;
    return delay;
  }

  void reset() => _attempt = 0;
}
