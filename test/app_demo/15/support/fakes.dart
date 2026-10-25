import 'package:flutter/services.dart';
import 'package:flutter_x_widgets/app_demo/15/models/services/audio_service.dart';
import 'package:flutter_x_widgets/app_demo/15/models/services/clock.dart';
import 'package:flutter_x_widgets/app_demo/15/models/services/preferences_service.dart';
import 'package:flutter_x_widgets/app_demo/15/models/services/share_service.dart';

class FakePreferencesService implements PreferencesService {
  final Map<String, String> values;

  bool failReads = false;
  bool failWrites = false;

  FakePreferencesService([Map<String, String>? initial]) : values = {...?initial};

  @override
  Future<String?> getString(String key) async {
    if (failReads) throw StateError('read failure');
    return values[key];
  }

  @override
  Future<bool> setString(String key, String value) async {
    if (failWrites) return false;
    values[key] = value;
    return true;
  }
}

class FixedClock implements Clock {
  DateTime value;

  FixedClock(this.value);

  @override
  DateTime now() => value;
}

class FakePipAudio implements PipAudio {
  final List<String> playedAssets = [];
  final List<String> spoken = [];
  int stopCount = 0;

  bool failAssets = false;
  bool failSpeak = false;

  @override
  Future<bool> playAsset(String path) async {
    playedAssets.add(path);
    return !failAssets;
  }

  @override
  Future<bool> speak(String text) async {
    spoken.add(text);
    return !failSpeak;
  }

  @override
  Future<void> stop() async {
    stopCount += 1;
  }

  @override
  Future<void> dispose() async {}
}

class FakePipShare implements PipShare {
  bool result = true;
  final List<String> sharedTexts = [];

  @override
  Future<bool> shareText(String text) async {
    sharedTexts.add(text);
    return result;
  }
}

Future<void> loadNunito() async {
  final loader = FontLoader('Nunito')..addFont(rootBundle.load('assets/fonts/Nunito.ttf'));
  await loader.load();
}
