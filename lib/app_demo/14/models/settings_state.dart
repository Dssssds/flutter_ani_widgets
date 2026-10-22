enum MotionSpeed { standard, fast }

/// 游戏共用的不可变设置。
class SettingsState {
  final MotionSpeed motionSpeed;
  final bool reduceMotion;
  final bool hapticsEnabled;

  const SettingsState({this.motionSpeed = MotionSpeed.standard, this.reduceMotion = false, this.hapticsEnabled = true});

  SettingsState copyWith({MotionSpeed? motionSpeed, bool? reduceMotion, bool? hapticsEnabled}) {
    return SettingsState(
      motionSpeed: motionSpeed ?? this.motionSpeed,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    );
  }

  Map<String, Object> toJson() => {
    'motionSpeed': motionSpeed.name,
    'reduceMotion': reduceMotion,
    'hapticsEnabled': hapticsEnabled,
  };

  /// 无效字段交给仓库统一回退，避免静默接受损坏的数据。
  ///
  /// 旧版本保存过的 `appearance` 字段不再使用，读取时直接忽略。
  factory SettingsState.fromJson(Map<String, dynamic> json) {
    final speed = MotionSpeed.values.where((value) => value.name == json['motionSpeed']).firstOrNull;
    if (speed == null || json['reduceMotion'] is! bool || json['hapticsEnabled'] is! bool) {
      throw const FormatException('Invalid settings fields');
    }
    return SettingsState(motionSpeed: speed, reduceMotion: json['reduceMotion'] as bool, hapticsEnabled: json['hapticsEnabled'] as bool);
  }
}
