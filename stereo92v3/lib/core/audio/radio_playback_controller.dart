enum RadioPlaybackStatus {
  idle,
  connecting,
  playing,
  paused,
  retrying,
  failed,
}

abstract interface class RadioPlaybackController {
  RadioPlaybackStatus get status;
  bool get wantsToPlay;
  Stream<RadioPlaybackStatus> get statusStream;
  Stream<Object> get errorStream;

  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> retry();
}
