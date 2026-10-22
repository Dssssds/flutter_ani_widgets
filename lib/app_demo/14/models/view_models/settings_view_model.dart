import 'package:flutter/foundation.dart';
import 'package:flutter_x_widgets/app_demo/14/models/repositories/settings_repository.dart';
import 'package:flutter_x_widgets/app_demo/14/models/settings_state.dart';

/// 设置先更新内存，再串行保存；无仓库时保持纯会话模式。
class SettingsViewModel extends ChangeNotifier {
  final SettingsRepository? _repository;
  SettingsState _state = const SettingsState();
  Future<void>? _initialization;
  Future<void> _saveQueue = Future<void>.value();
  bool _hasLocalChanges = false;
  bool _disposed = false;
  bool _isLoading = false;
  String? _errorMessage;

  SettingsViewModel({SettingsRepository? repository}) : _repository = repository;

  SettingsState get state => _state;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 多次调用共享同一次读取，不覆盖加载期间的用户修改。
  Future<void> initialize() => _initialization ??= _load();

  Future<void> _load() async {
    if (_repository == null || _disposed) return;
    _isLoading = true;
    _notify();
    try {
      final result = await _repository.load();
      if (_disposed) return;
      if (!_hasLocalChanges) _state = result.state;
      _errorMessage = result.warning;
    } catch (_) {
      if (!_disposed) _errorMessage = '无法读取已保存的设置，已使用默认值。可重试保存当前设置。';
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  void setMotionSpeed(MotionSpeed value) {
    if (_state.motionSpeed == value) return;
    _update(_state.copyWith(motionSpeed: value));
  }

  void setReduceMotion(bool value) {
    if (_state.reduceMotion == value) return;
    _update(_state.copyWith(reduceMotion: value));
  }

  void setHapticsEnabled(bool value) {
    if (_state.hapticsEnabled == value) return;
    _update(_state.copyWith(hapticsEnabled: value));
  }

  void _update(SettingsState value) {
    if (_disposed) return;
    _hasLocalChanges = true;
    _state = value;
    _notify();
    _enqueueSave(value);
  }

  Future<void> retrySave() => _disposed ? Future<void>.value() : _enqueueSave(_state);

  Future<void> _enqueueSave(SettingsState snapshot) {
    if (_repository == null) return Future<void>.value();
    final initialization = initialize();
    _saveQueue = _saveQueue.then((_) async {
      await initialization;
      try {
        await _repository.save(snapshot);
        if (!_disposed) _errorMessage = null;
      } catch (_) {
        if (!_disposed) _errorMessage = '设置保存失败，当前选择仍然有效。请重试保存。';
      }
      _notify();
    });
    return _saveQueue;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
