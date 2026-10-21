enum MotionSpeed { standard, fast }

enum CoinAppearance { gold, ice, rose }

/// 游戏与外观共用的不可变设置。
class SettingsState {
  final MotionSpeed motionSpeed;
  final bool reduceMotion;
  final CoinAppearance appearance;
  final bool hapticsEnabled;

  const SettingsState({
    this.motionSpeed = MotionSpeed.standard,
    this.reduceMotion = false,
    this.appearance = CoinAppearance.gold,
    this.hapticsEnabled = true,
  });

  SettingsState copyWith({MotionSpeed? motionSpeed, bool? reduceMotion, CoinAppearance? appearance, bool? hapticsEnabled}) {
    return SettingsState(
      motionSpeed: motionSpeed ?? this.motionSpeed,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      appearance: appearance ?? this.appearance,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    );
  }

  Map<String, Object> toJson() => {
    'motionSpeed': motionSpeed.name,
    'reduceMotion': reduceMotion,
    'appearance': appearance.name,
    'hapticsEnabled': hapticsEnabled,
  };

  /// 无效字段交给仓库统一回退，避免静默接受损坏的数据。
  factory SettingsState.fromJson(Map<String, dynamic> json) {
    final speed = MotionSpeed.values.where((value) => value.name == json['motionSpeed']).firstOrNull;
    final appearance = CoinAppearance.values.where((value) => value.name == json['appearance']).firstOrNull;
    if (speed == null || appearance == null || json['reduceMotion'] is! bool || json['hapticsEnabled'] is! bool) {
      throw const FormatException('Invalid settings fields');
    }
    return SettingsState(
      motionSpeed: speed,
      reduceMotion: json['reduceMotion'] as bool,
      appearance: appearance,
      hapticsEnabled: json['hapticsEnabled'] as bool,
    );
  }
}
