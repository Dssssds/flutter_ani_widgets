import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';

abstract class PipAudio {
  Future<bool> playAsset(String path);

  Future<bool> speak(String text);

  Future<void> stop();

  Future<void> dispose();
}

class DevicePipAudio implements PipAudio {
  final AudioPlayer _player = AudioPlayer();
  final FlutterTts _tts = FlutterTts();
  bool _ttsConfigured = false;

  @override
  Future<bool> playAsset(String path) async {
    try {
      await stop();
      await _player.setAsset(path);
      await _player.play();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> speak(String text) async {
    try {
      await stop();
      if (!_ttsConfigured) {
        await _tts.setLanguage('en-US');
        await _tts.setSpeechRate(0.88);
        await _tts.awaitSpeakCompletion(true);
        _ttsConfigured = true;
      }
      await _tts.speak(text);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
    try {
      await _tts.stop();
    } catch (_) {}
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _player.dispose();
  }
}
