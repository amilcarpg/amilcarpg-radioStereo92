import 'package:flutter_test/flutter_test.dart';
import 'package:stereo92v3/core/audio/retry_backoff.dart';

void main() {
  test('uses exponential delays and caps subsequent retries', () {
    final backoff = RetryBackoff();

    final delays = List<Duration>.generate(8, (_) => backoff.nextDelay());

    expect(
      delays.map((delay) => delay.inSeconds),
      <int>[1, 2, 4, 8, 16, 30, 30, 30],
    );
    expect(backoff.attempt, 8);

    backoff.reset();
    expect(backoff.nextDelay(), const Duration(seconds: 1));
  });
}
