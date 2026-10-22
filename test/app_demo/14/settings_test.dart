import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_x_widgets/app_demo/14/models/repositories/settings_repository.dart';
import 'package:flutter_x_widgets/app_demo/14/models/services/feedback_service.dart';
import 'package:flutter_x_widgets/app_demo/14/models/services/preferences_service.dart';
import 'package:flutter_x_widgets/app_demo/14/models/settings_state.dart';
import 'package:flutter_x_widgets/app_demo/14/models/view_models/settings_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakePreferences implements PreferencesService {
  String? stored;
  bool failRead = false;
  bool failWrite = false;
  bool throwWrite = false;
  int reads = 0;
  int activeWrites = 0;
  int maxActiveWrites = 0;
  Completer<String?>? readGate;
  Completer<void>? writeGate;
  final writes = <SettingsState>[];

  @override
  Future<String?> getString(String key) async {
    expect(key, SettingsRepository.storageKey);
    reads++;
    if (failRead) throw StateError('Read failed');
    return readGate == null ? stored : await readGate!.future;
  }

  @override
  Future<bool> setString(String key, String value) async {
    expect(key, SettingsRepository.storageKey);
    activeWrites++;
    if (activeWrites > maxActiveWrites) maxActiveWrites = activeWrites;
    try {
      writes.add(SettingsState.fromJson((jsonDecode(value) as Map<String, dynamic>)['settings'] as Map<String, dynamic>));
      await writeGate?.future;
      if (throwWrite) throw StateError('Write failed');
      if (failWrite) return false;
      stored = value;
      return true;
    } finally {
      activeWrites--;
    }
  }
}

String encodeSettings(SettingsState state) => jsonEncode({'schema': SettingsRepository.schemaVersion, 'settings': state.toJson()});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Settings state and repository', () {
    test('defaults and copyWith preserve all fields', () {
      const defaults = SettingsState();
      expect(defaults.motionSpeed, MotionSpeed.standard);
      expect(defaults.reduceMotion, isFalse);
      expect(defaults.hapticsEnabled, isTrue);
      final state = defaults.copyWith(motionSpeed: MotionSpeed.fast, reduceMotion: true, hapticsEnabled: false);
      final copy = SettingsState.fromJson(state.copyWith().toJson());
      expect(copy.toJson(), state.toJson());
    });

    test('missing settings load defaults without warning', () async {
      final result = await SettingsRepository(preferencesService: FakePreferences()).load();
      expect(result.state.toJson(), const SettingsState().toJson());
      expect(result.warning, isNull);
    });

    test('round trips versioned settings in an isolated key', () async {
      final preferences = FakePreferences();
      final repository = SettingsRepository(preferencesService: preferences);
      const state = SettingsState(motionSpeed: MotionSpeed.fast, reduceMotion: true, hapticsEnabled: false);
      await repository.save(state);
      expect((jsonDecode(preferences.stored!) as Map)['schema'], SettingsRepository.schemaVersion);
      final result = await repository.load();
      expect(result.state.toJson(), state.toJson());
      expect(result.warning, isNull);
    });

    for (final raw in [
      'broken json',
      '[]',
      '{"schema":999,"settings":{}}',
      '{"schema":1,"settings":null}',
      '{"schema":1,"settings":{"motionSpeed":"slow","reduceMotion":false,"hapticsEnabled":true}}',
      '{"schema":1,"settings":{"motionSpeed":"standard","reduceMotion":"false","hapticsEnabled":true}}',
      '{"schema":1,"settings":{"motionSpeed":"standard","reduceMotion":false,"hapticsEnabled":null}}',
    ]) {
      test('invalid data falls back with warning: $raw', () async {
        final result = await SettingsRepository(preferencesService: FakePreferences()..stored = raw).load();
        expect(result.state.toJson(), const SettingsState().toJson());
        expect(result.warning, isNotEmpty);
      });
    }

    test('legacy appearance field from older saves is ignored', () async {
      const raw =
          '{"schema":1,"settings":{"motionSpeed":"fast","reduceMotion":true,"appearance":"rose","hapticsEnabled":false}}';
      final result = await SettingsRepository(preferencesService: FakePreferences()..stored = raw).load();
      expect(result.warning, isNull);
      expect(result.state.toJson(), const SettingsState(motionSpeed: MotionSpeed.fast, reduceMotion: true, hapticsEnabled: false).toJson());
      expect(result.state.toJson().containsKey('appearance'), isFalse);
    });

    test('read exception falls back with warning', () async {
      final result = await SettingsRepository(preferencesService: FakePreferences()..failRead = true).load();
      expect(result.state.toJson(), const SettingsState().toJson());
      expect(result.warning, isNotEmpty);
    });

    test('false and thrown writes are both failures', () async {
      for (final preferences in [FakePreferences()..failWrite = true, FakePreferences()..throwWrite = true]) {
        await expectLater(SettingsRepository(preferencesService: preferences).save(const SettingsState()), throwsStateError);
      }
    });

    test('production adapter uses legacy shared preferences', () async {
      SharedPreferences.setMockInitialValues({'other.demo': 'untouched'});
      const service = SharedPreferencesService();
      expect(await service.getString(SettingsRepository.storageKey), isNull);
      expect(await service.setString(SettingsRepository.storageKey, 'value'), isTrue);
      expect(await service.getString(SettingsRepository.storageKey), 'value');
      expect((await SharedPreferences.getInstance()).getString('other.demo'), 'untouched');
    });
  });

  group('Settings view model', () {
    test('no argument construction stays in memory and notifies only on change', () async {
      final settings = SettingsViewModel();
      addTearDown(settings.dispose);
      var notifications = 0;
      settings.addListener(() => notifications++);
      await settings.initialize();
      settings.setHapticsEnabled(true);
      settings.setHapticsEnabled(false);
      settings.setMotionSpeed(MotionSpeed.fast);
      settings.setReduceMotion(true);
      await settings.retrySave();
      expect(settings.state.hapticsEnabled, isFalse);
      expect(notifications, 3);
      expect(settings.errorMessage, isNull);
      expect(settings.isLoading, isFalse);
    });

    test('initialize is one future and loads saved state once', () async {
      final preferences = FakePreferences()..readGate = Completer<String?>();
      final settings = SettingsViewModel(repository: SettingsRepository(preferencesService: preferences));
      addTearDown(settings.dispose);
      final first = settings.initialize();
      expect(identical(first, settings.initialize()), isTrue);
      expect(settings.isLoading, isTrue);
      preferences.readGate!.complete(encodeSettings(const SettingsState(reduceMotion: true, hapticsEnabled: false)));
      await first;
      expect(settings.state.reduceMotion, isTrue);
      expect(settings.state.hapticsEnabled, isFalse);
      expect(settings.isLoading, isFalse);
      await settings.initialize();
      expect(preferences.reads, 1);
    });

    test('late initialization never overwrites newer in-memory changes', () async {
      final preferences = FakePreferences()..readGate = Completer<String?>();
      final settings = SettingsViewModel(repository: SettingsRepository(preferencesService: preferences));
      addTearDown(settings.dispose);
      final loading = settings.initialize();
      settings.setMotionSpeed(MotionSpeed.fast);
      settings.setHapticsEnabled(false);
      expect(settings.state.motionSpeed, MotionSpeed.fast);
      preferences.readGate!.complete(encodeSettings(const SettingsState(reduceMotion: true)));
      await loading;
      preferences.readGate = null;
      await settings.retrySave();
      expect(settings.state.motionSpeed, MotionSpeed.fast);
      expect(settings.state.reduceMotion, isFalse);
      expect(settings.state.hapticsEnabled, isFalse);
      expect((await SettingsRepository(preferencesService: preferences).load()).state.toJson(), settings.state.toJson());
    });

    test('changes before explicit initialize are preserved and persisted', () async {
      final preferences = FakePreferences()..stored = encodeSettings(const SettingsState(reduceMotion: true));
      final settings = SettingsViewModel(repository: SettingsRepository(preferencesService: preferences));
      addTearDown(settings.dispose);
      settings.setMotionSpeed(MotionSpeed.fast);
      await settings.retrySave();
      expect(settings.state.motionSpeed, MotionSpeed.fast);
      expect(preferences.reads, 1);
      expect(preferences.writes.last.motionSpeed, MotionSpeed.fast);
    });

    test('save operations are serial and keep the latest snapshot', () async {
      final preferences = FakePreferences()..writeGate = Completer<void>();
      final settings = SettingsViewModel(repository: SettingsRepository(preferencesService: preferences));
      addTearDown(settings.dispose);
      await settings.initialize();
      settings.setMotionSpeed(MotionSpeed.fast);
      settings.setReduceMotion(true);
      settings.setHapticsEnabled(false);
      final saved = settings.retrySave();
      await Future<void>.delayed(Duration.zero);
      expect(preferences.writes.length, 1);
      expect(settings.state.hapticsEnabled, isFalse);
      preferences.writeGate!.complete();
      await saved;
      expect(preferences.maxActiveWrites, 1);
      expect(preferences.writes[0].reduceMotion, isFalse);
      expect(preferences.writes[1].reduceMotion, isTrue);
      expect(preferences.writes.last.toJson(), settings.state.toJson());
    });

    test('save failure preserves state, surfaces error, and retry recovers', () async {
      final preferences = FakePreferences()..failWrite = true;
      final settings = SettingsViewModel(repository: SettingsRepository(preferencesService: preferences));
      addTearDown(settings.dispose);
      await settings.initialize();
      settings.setReduceMotion(true);
      await settings.retrySave();
      expect(settings.state.reduceMotion, isTrue);
      expect(settings.errorMessage, contains('保存失败'));
      preferences.failWrite = false;
      await settings.retrySave();
      expect(settings.errorMessage, isNull);
      expect(preferences.writes.last.reduceMotion, isTrue);
    });

    test('exception does not poison later saves', () async {
      final preferences = FakePreferences()..throwWrite = true;
      final settings = SettingsViewModel(repository: SettingsRepository(preferencesService: preferences));
      addTearDown(settings.dispose);
      settings.setHapticsEnabled(false);
      await settings.retrySave();
      expect(settings.errorMessage, isNotNull);
      preferences.throwWrite = false;
      settings.setReduceMotion(true);
      await settings.retrySave();
      expect(settings.errorMessage, isNull);
      expect(preferences.writes.last.reduceMotion, isTrue);
    });

    test('read warning is visible and saving repairs corrupt data', () async {
      final preferences = FakePreferences()..stored = 'invalid';
      final settings = SettingsViewModel(repository: SettingsRepository(preferencesService: preferences));
      addTearDown(settings.dispose);
      await settings.initialize();
      expect(settings.errorMessage, contains('无法读取'));
      await settings.retrySave();
      expect(settings.errorMessage, isNull);
      expect((await SettingsRepository(preferencesService: preferences).load()).warning, isNull);
    });

    test('dispose during initialization suppresses late notifications', () async {
      final preferences = FakePreferences()..readGate = Completer<String?>();
      final settings = SettingsViewModel(repository: SettingsRepository(preferencesService: preferences));
      var notifications = 0;
      settings.addListener(() => notifications++);
      final loading = settings.initialize();
      settings.setReduceMotion(true);
      final pending = settings.retrySave();
      settings.dispose();
      final countAtDispose = notifications;
      preferences.readGate!.complete(encodeSettings(const SettingsState()));
      await loading;
      await pending;
      expect(notifications, countAtDispose);
    });

    test('dispose during failed save suppresses late notifications', () async {
      final preferences =
          FakePreferences()
            ..writeGate = Completer<void>()
            ..throwWrite = true;
      final settings = SettingsViewModel(repository: SettingsRepository(preferencesService: preferences));
      await settings.initialize();
      settings.setReduceMotion(true);
      final pending = settings.retrySave();
      await Future<void>.delayed(Duration.zero);
      settings.dispose();
      preferences.writeGate!.complete();
      await pending;
      settings.setHapticsEnabled(false);
      expect(settings.state.hapticsEnabled, isTrue);
    });
  });

  group('Platform feedback', () {
    test('reveal requests medium impact', () async {
      final calls = <MethodCall>[];
      final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        calls.add(call);
        return null;
      });
      addTearDown(() => messenger.setMockMethodCallHandler(SystemChannels.platform, null));
      await const PlatformFeedbackService().reveal();
      expect(calls.single.method, 'HapticFeedback.vibrate');
      expect(calls.single.arguments, 'HapticFeedbackType.mediumImpact');
    });

    test('platform exceptions are harmless', () async {
      final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(SystemChannels.platform, (_) async => throw PlatformException(code: 'unsupported'));
      addTearDown(() => messenger.setMockMethodCallHandler(SystemChannels.platform, null));
      await expectLater(const PlatformFeedbackService().reveal(), completes);
    });
  });
}
