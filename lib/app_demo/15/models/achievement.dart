enum AchievementMetric { streak, xp, coffee, directions, challenge }

class AchievementDefinition {
  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementMetric metric;
  final int target;

  const AchievementDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.metric,
    required this.target,
  });
}
