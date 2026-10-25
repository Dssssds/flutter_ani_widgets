import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_x_widgets/app_demo/15/data/seed_data.dart';
import 'package:flutter_x_widgets/app_demo/15/models/rules/daily_goal_rules.dart';
import 'package:flutter_x_widgets/app_demo/15/models/rules/lesson_rules.dart';
import 'package:flutter_x_widgets/app_demo/15/models/rules/review_rules.dart';
import 'package:flutter_x_widgets/app_demo/15/models/rules/study_rules.dart';
import 'package:flutter_x_widgets/app_demo/15/models/run_state.dart';

void main() {
  final now = DateTime(2026, 10, 25, 9, 30);

  group('StudyRules', () {
    test('counts the previous seven days as a seven day streak', () {
      final dates = StudyRules.previousDays(now, 7);

      expect(dates, hasLength(7));
      expect(StudyRules.computeStreak(dates, now), 7);
    });

    test('counts today when it is present', () {
      final dates = StudyRules.withToday(StudyRules.previousDays(now, 6), now);

      expect(StudyRules.computeStreak(dates, now), 7);
    });

    test('returns zero for empty dates', () {
      expect(StudyRules.computeStreak(const <String>{}, now), 0);
    });

    test('stops counting at the first missing day', () {
      final dates = {
        StudyRules.dayKey(now),
        StudyRules.dayKey(StudyRules.shiftDays(now, 1)),
        StudyRules.dayKey(StudyRules.shiftDays(now, 3)),
      };

      expect(StudyRules.computeStreak(dates, now), 2);
    });

    test('crosses month boundaries', () {
      final novemberFirst = DateTime(2026, 11, 1, 8);
      final dates = {StudyRules.dayKey(novemberFirst), StudyRules.dayKey(StudyRules.shiftDays(novemberFirst, 1))};

      expect(StudyRules.dayKey(StudyRules.shiftDays(novemberFirst, 1)), '2026-10-31');
      expect(StudyRules.computeStreak(dates, novemberFirst), 2);
    });
  });

  group('LessonRules', () {
    test('unlocks only coffee at the beginning', () {
      const completed = {'coffee': false, 'directions': false, 'challenge': false};

      expect(LessonRules.isUnlocked('coffee', completed), isTrue);
      expect(LessonRules.isUnlocked('directions', completed), isFalse);
      expect(LessonRules.isUnlocked('challenge', completed), isFalse);
      expect(LessonRules.currentLessonId(completed), 'coffee');
    });

    test('unlocks directions after coffee', () {
      const completed = {'coffee': true, 'directions': false, 'challenge': false};

      expect(LessonRules.isUnlocked('directions', completed), isTrue);
      expect(LessonRules.isUnlocked('challenge', completed), isFalse);
      expect(LessonRules.currentLessonId(completed), 'directions');
    });

    test('unlocks the challenge after directions', () {
      const completed = {'coffee': true, 'directions': true, 'challenge': false};

      expect(LessonRules.isUnlocked('challenge', completed), isTrue);
      expect(LessonRules.currentLessonId(completed), 'challenge');
    });

    test('returns no current lesson after the challenge', () {
      const completed = {'coffee': true, 'directions': true, 'challenge': true};

      expect(LessonRules.currentLessonId(completed), isNull);
    });

    test('rejects unknown lesson ids and keeps pause keys stable', () {
      expect(LessonRules.isUnlocked('greeting', const {}), isFalse);
      expect(LessonRules.pauseKey('coffee', RunMode.lesson), 'coffee:lesson');
      expect(LessonRules.pauseKey('coffee', RunMode.review), 'coffee:review');
    });

    test('completed lessons always resume in review mode', () {
      expect(LessonRules.normalizeMode(completed: true, requested: RunMode.lesson), RunMode.review);
      expect(LessonRules.normalizeMode(completed: false, requested: RunMode.review), RunMode.lesson);
    });
  });

  group('DailyGoalRules', () {
    test('derives minutes and progress from seconds', () {
      expect(DailyGoalRules.displayMinutes(360, 10), 6);
      expect(DailyGoalRules.displayMinutes(359, 10), 5);
      expect(DailyGoalRules.displayMinutes(900, 10), 10);
      expect(DailyGoalRules.progressPercent(360, 10), 60);
      expect(DailyGoalRules.progressPercent(600, 10), 100);
    });

    test('adds thirty seconds per correct answer and caps at the goal', () {
      expect(DailyGoalRules.addCorrectAnswer(360, 10), 390);
      expect(DailyGoalRules.addCorrectAnswer(590, 10), 600);
      expect(DailyGoalRules.addCorrectAnswer(600, 10), 600);
    });

    test('clamps seconds when the goal changes', () {
      expect(DailyGoalRules.clampSeconds(900, 10), 600);
      expect(DailyGoalRules.clampSeconds(120, 10), 120);
      expect(DailyGoalRules.remainingMinutes(360, 10), 4);
      expect(DailyGoalRules.remainingMinutes(600, 10), 0);
    });
  });

  group('ReviewRules', () {
    test('starts at the first mastered gap and counts only valid terms', () {
      final topic = PipSeed.reviewTopicsById['coffee']!;

      expect(ReviewRules.startIndex(topic, ['milk']), 1);
      expect(ReviewRules.startIndex(topic, ['milk', 'to go', 'a small one', 'Thank you', 'Have a nice day!']), 0);
      expect(ReviewRules.masteredCount(topic, ['milk', 'unknown']), 1);
    });

    test('markMastered adds a term once and preserves the original list otherwise', () {
      final original = <String>['milk'];

      expect(ReviewRules.markMastered(original, 'to go'), ['milk', 'to go']);
      expect(identical(ReviewRules.markMastered(original, 'milk'), original), isTrue);
    });
  });
}
