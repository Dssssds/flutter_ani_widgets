import 'package:flutter_x_widgets/app_demo/15/models/achievement.dart';
import 'package:flutter_x_widgets/app_demo/15/models/app_state.dart';

class AchievementProgress {
  final bool earned;
  final String text;

  const AchievementProgress({required this.earned, required this.text});
}

abstract final class AchievementRules {
  static AchievementProgress progress(AchievementDefinition definition, AppState state) {
    return switch (definition.metric) {
      AchievementMetric.streak => AchievementProgress(
        earned: state.streak >= definition.target,
        text:
            state.streak >= definition.target
                ? '已连续学习 ${state.streak} 天'
                : '${state.streak.clamp(0, definition.target)} / ${definition.target} 天',
      ),
      AchievementMetric.xp => AchievementProgress(
        earned: state.xp >= definition.target,
        text:
            state.xp >= definition.target
                ? '累计 ${formatNumber(state.xp)} XP'
                : '${formatNumber(state.xp)} / ${formatNumber(definition.target)} XP',
      ),
      AchievementMetric.coffee => _lessonProgress(state.completedLessons['coffee'] ?? false, '完成点单课解锁'),
      AchievementMetric.directions => _lessonProgress(state.completedLessons['directions'] ?? false, '完成问路课解锁'),
      AchievementMetric.challenge => _lessonProgress(state.completedLessons['challenge'] ?? false, '完成挑战解锁'),
    };
  }

  static int earnedCount(Iterable<AchievementDefinition> definitions, AppState state) {
    return definitions.where((definition) => progress(definition, state).earned).length;
  }

  static String shareText(AchievementDefinition definition, AppState state) {
    return '我在 Pip 英语学习里解锁了「${definition.title}」：${definition.description}。'
        '连续学习 ${state.streak} 天，累计 ${formatNumber(state.xp)} XP。';
  }

  static String formatNumber(int value) {
    final text = value.toString();
    final buffer = StringBuffer();
    for (var index = 0; index < text.length; index++) {
      if (index > 0 && (text.length - index) % 3 == 0) buffer.write(',');
      buffer.write(text[index]);
    }
    return buffer.toString();
  }

  static AchievementProgress _lessonProgress(bool completed, String pending) {
    return AchievementProgress(earned: completed, text: completed ? '已完成' : pending);
  }
}
