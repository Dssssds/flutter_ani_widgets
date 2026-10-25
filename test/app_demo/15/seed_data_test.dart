import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_x_widgets/app_demo/15/data/asset_manifest.dart';
import 'package:flutter_x_widgets/app_demo/15/data/seed_data.dart';
import 'package:flutter_x_widgets/app_demo/15/models/lesson.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('seed data', () {
    test('contains three lessons with fifteen questions', () {
      expect(PipSeed.lessonOrder, ['coffee', 'directions', 'challenge']);
      expect(PipSeed.lessons, hasLength(3));
      expect(PipSeed.coffeeLesson.questions, hasLength(5));
      expect(PipSeed.directionsLesson.questions, hasLength(4));
      expect(PipSeed.challengeLesson.questions, hasLength(6));
      expect(PipSeed.lessons.fold<int>(0, (sum, lesson) => sum + lesson.questions.length), 15);
    });

    test('keeps the lesson and challenge order from the handoff copy', () {
      expect(PipSeed.coffeeLesson.questions.map((question) => question.audio), ['coffee-milk', 'to-go', 'small', 'small', 'thank-you']);
      expect(PipSeed.directionsLesson.questions.map((question) => question.audio), [
        'where-station',
        'go-straight',
        'turn-left',
        'next-to-bank',
      ]);
      expect(PipSeed.challengeLesson.questions.map((question) => question.audio), [
        'coffee-milk',
        'to-go',
        'small',
        'where-station',
        'go-straight',
        'turn-left',
      ]);
    });

    test('includes a listening question with options in every lesson', () {
      for (final lesson in PipSeed.lessons) {
        final listening = lesson.questions.where((question) => question.type == QuestionType.listen).toList();
        expect(listening, isNotEmpty, reason: lesson.id);
        for (final question in listening) {
          expect(question.options, hasLength(3), reason: '${lesson.id} ${question.audio}');
          expect(question.options.map((option) => option.id), contains(question.answer));
        }
      }
    });

    test('exposes review topics, terms and achievements', () {
      expect(PipSeed.reviewTopics, hasLength(4));
      expect(PipSeed.reviewTopics.map((topic) => topic.id), ['coffee', 'greeting', 'menu', 'directions']);
      expect(PipSeed.reviewTopics.fold<int>(0, (sum, topic) => sum + topic.terms.length), PipSeed.totalTerms);
      expect(PipSeed.achievements, hasLength(5));
      expect(PipSeed.achievements.map((achievement) => achievement.id), ['streak', 'xp', 'coffee', 'directions', 'unit']);
    });

    test('keeps review-only nodes and daily goal options explicit', () {
      expect(PipSeed.reviewOnlyNodeIds, {'greeting', 'menu'});
      expect(PipSeed.dailyGoalOptions, [5, 10, 15, 20]);
    });
  });

  group('assets', () {
    test('registers every image, icon, audio clip and font', () async {
      final assets = <String>[
        PipAssets.pip,
        PipAssets.birdWave,
        PipAssets.birdThink,
        PipAssets.birdCelebrate,
        PipAssets.chime,
        for (final name in ['arrow', 'back', 'bolt', 'book', 'check', 'close', 'compass', 'cup', 'flag', 'flame', 'heart'])
          PipAssets.icon(name),
        for (final name in ['lock', 'mute', 'play', 'review', 'share', 'sound', 'spark', 'star', 'target', 'trophy', 'user'])
          PipAssets.icon(name),
        for (final name in ['small', 'large', 'iced', 'left', 'right', 'straight']) PipAssets.option(name),
        for (final name in ['coffee-milk', 'to-go', 'small', 'thank-you', 'where-station', 'go-straight', 'turn-left', 'next-to-bank'])
          PipAssets.audio(name),
        'assets/fonts/Nunito.ttf',
      ];

      for (final asset in assets) {
        final data = await rootBundle.load(asset);
        expect(data.lengthInBytes, greaterThan(0), reason: asset);
      }
    });
  });
}
