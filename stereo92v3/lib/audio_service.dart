import 'package:just_audio/just_audio.dart';
import 'dart:async';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Expose the player state stream directly from just_audio
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;

  // Expose a stream for processing state for more detailed loading/buffering states
  Stream<ProcessingState> get processingStateStream => _audioPlayer.processingStateStream;


  Future<void> play(String url) async {
    // It's good practice to set URL only if it's different or player is stopped.
    // However, for simplicity and current usage, we can set it before playing.
    try {
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
    } catch (e) {
      // Log error or rethrow to be handled by UI layer
      print("AudioService Error - play: $e");
      rethrow;
    }
  }

  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      print("AudioService Error - pause: $e");
      rethrow;
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume);
    } catch (e) {
      print("AudioService Error - setVolume: $e");
      rethrow;
    }
  }

  // setUrl is implicitly handled by play(url) for now.
  // If explicit setUrl without immediate play is needed, it can be added:
  // Future<void> setUrl(String url) async {
  //   try {
  //     await _audioPlayer.setUrl(url);
  //   } catch (e) {
  //     print("AudioService Error - setUrl: $e");
  //     rethrow;
  //   }
  // }

  void dispose() {
    _audioPlayer.dispose();
  }
}
