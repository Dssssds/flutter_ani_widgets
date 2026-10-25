import 'package:flutter/foundation.dart';
import 'package:flutter_x_widgets/app_demo/15/data/demo_state.dart';
import 'package:flutter_x_widgets/app_demo/15/data/seed_data.dart';
import 'package:flutter_x_widgets/app_demo/15/models/achievement.dart';
import 'package:flutter_x_widgets/app_demo/15/models/app_state.dart';
import 'package:flutter_x_widgets/app_demo/15/models/lesson.dart';
import 'package:flutter_x_widgets/app_demo/15/models/lesson_result.dart';
import 'package:flutter_x_widgets/app_demo/15/models/repositories/pip_repository.dart';
import 'package:flutter_x_widgets/app_demo/15/models/root_tab.dart';
import 'package:flutter_x_widgets/app_demo/15/models/rules/achievement_rules.dart';
import 'package:flutter_x_widgets/app_demo/15/models/rules/daily_goal_rules.dart';
import 'package:flutter_x_widgets/app_demo/15/models/rules/lesson_rules.dart';
import 'package:flutter_x_widgets/app_demo/15/models/rules/review_rules.dart';
import 'package:flutter_x_widgets/app_demo/15/models/rules/study_rules.dart';
import 'package:flutter_x_widgets/app_demo/15/models/run_state.dart';
import 'package:flutter_x_widgets/app_demo/15/models/services/clock.dart';

enum StartLessonStatus { started, locked, missing }

enum AnswerCheck { ignored, correct, wrong }

class PipController extends ChangeNotifier {
  final PipRepository _repository;
  final Clock _clock;
  final bool readOnlyDemo;
  final bool? _launchSoundOn;

  AppState _state;
  RootTab _activeTab;
  bool _initialized = false;
  String? _loadWarning;
  bool _saveFailed = false;
  bool _disposed = false;
  Future<void> _saveQueue = Future<void>.value();

  PipController({
    required PipRepository repository,
    required Clock clock,
    this.readOnlyDemo = false,
    RootTab initialTab = RootTab.path,
    bool? soundOn,
  }) : _repository = repository,
       _clock = clock,
       _launchSoundOn = soundOn,
       _activeTab = initialTab,
       _state = createDemoState(clock.now());

  AppState get state => _state;
  RootTab get activeTab => _activeTab;
  bool get initialized => _initialized;
  bool get saveFailed => _saveFailed;
  DateTime get now => _clock.now();
  RunState? get run => _state.run;

  String? get currentLessonId => LessonRules.currentLessonId(_state.completedLessons);
  bool get allDone => currentLessonId == null;

  int get totalMastered {
    var total = 0;
    for (final terms in _state.reviewMastered.values) {
      total += terms.length;
    }
    return total;
  }

  int get completedLessonCount => _state.completedLessons.values.where((done) => done).length;

  int get totalTermCount => PipSeed.totalTerms;

  int get remainingMinutes => DailyGoalRules.remainingMinutes(_state.dailySeconds, _state.dailyGoal);

  List<String> masteredFor(String topicId) => _state.reviewMastered[topicId] ?? const <String>[];

  AchievementProgress achievementProgress(AchievementDefinition definition) => AchievementRules.progress(definition, _state);

  int get earnedAchievementCount => AchievementRules.earnedCount(PipSeed.achievements, _state);

  Lesson? lessonFor(String lessonId) => PipSeed.lessonsById[lessonId];

  Question? get currentQuestion {
    final active = _state.run;
    if (active == null) return null;
    final lesson = PipSeed.lessonsById[active.lessonId];
    if (lesson == null || active.qIndex < 0 || active.qIndex >= lesson.questions.length) return null;
    return lesson.questions[active.qIndex];
  }

  Future<void> initialize() async {
    if (readOnlyDemo) {
      _state = _applyLaunchSound(createDemoState(_clock.now()));
      _initialized = true;
      notifyListeners();
      return;
    }

    final result = await _repository.load(_clock.now());
    if (_disposed) return;
    _state = _applyLaunchSound(result.state);
    _loadWarning = result.warning;
    _initialized = true;
    notifyListeners();
  }

  AppState _applyLaunchSound(AppState state) {
    final soundOn = _launchSoundOn;
    return soundOn == null || soundOn == state.soundOn ? state : state.copyWith(soundOn: soundOn);
  }

  void setTab(RootTab tab) {
    if (_activeTab == tab) return;
    _activeTab = tab;
    notifyListeners();
  }

  String? takeLoadWarning() {
    final warning = _loadWarning;
    _loadWarning = null;
    return warning;
  }

  bool isUnlocked(String lessonId) => LessonRules.isUnlocked(lessonId, _state.completedLessons);

  RunState? activeRunFor(String lessonId) {
    final current = _state.run;
    if (current != null && current.lessonId == lessonId) return current;
    return _state.pausedRuns[LessonRules.pauseKey(lessonId, RunMode.lesson)] ??
        _state.pausedRuns[LessonRules.pauseKey(lessonId, RunMode.review)];
  }

  StartLessonStatus startLesson(String lessonId, RunMode requestedMode) {
    if (!PipSeed.lessonsById.containsKey(lessonId)) return StartLessonStatus.missing;
    if (!LessonRules.isUnlocked(lessonId, _state.completedLessons)) return StartLessonStatus.locked;

    final completed = _state.completedLessons[lessonId] ?? false;
    final mode = LessonRules.normalizeMode(completed: completed, requested: requestedMode);
    final key = LessonRules.pauseKey(lessonId, mode);
    final current = _state.run;
    final paused = Map<String, RunState>.of(_state.pausedRuns);

    late final RunState active;
    if (current != null && current.lessonId == lessonId && current.mode == mode) {
      active = current;
    } else {
      if (current != null) {
        paused[LessonRules.pauseKey(current.lessonId, current.mode)] = current;
      }
      active = paused.remove(key) ?? RunState(lessonId: lessonId, mode: mode);
    }

    _commit(_state.copyWith(run: active, pausedRuns: paused, lives: _state.lives <= 0 ? 4 : _state.lives));
    return StartLessonStatus.started;
  }

  void selectAnswer(String value) {
    final active = _state.run;
    if (active == null || active.feedback != AnswerFeedback.none) return;
    if (active.selection == value) return;
    _commit(_state.copyWith(run: active.copyWith(selection: value)));
  }

  AnswerCheck checkAnswer() {
    final active = _state.run;
    final question = currentQuestion;
    if (active == null || question == null || active.feedback != AnswerFeedback.none || active.selection.isEmpty) {
      return AnswerCheck.ignored;
    }

    if (active.selection != question.answer) {
      _commit(
        _state.copyWith(
          lives: _state.lives > 0 ? _state.lives - 1 : 0,
          run: active.copyWith(feedback: AnswerFeedback.wrong, streak: 0, firstTry: false),
        ),
      );
      return AnswerCheck.wrong;
    }

    final now = _clock.now();
    final today = StudyRules.dayKey(now);
    var studyDates = _state.studyDates;
    var streak = _state.streak;
    var dailyDate = _state.dailyDate;
    var dailySeconds = _state.dailySeconds;

    if (dailyDate != today) {
      dailyDate = today;
      dailySeconds = 0;
    }
    if (!studyDates.contains(today)) {
      studyDates = {...studyDates, today};
      streak = StudyRules.computeStreak(studyDates, now);
    }
    dailySeconds = DailyGoalRules.addCorrectAnswer(dailySeconds, _state.dailyGoal);

    _commit(
      _state.copyWith(
        studyDates: studyDates,
        streak: streak,
        dailyDate: dailyDate,
        dailySeconds: dailySeconds,
        run: active.copyWith(
          feedback: AnswerFeedback.correct,
          correctFirstTry: active.firstTry ? active.correctFirstTry + 1 : active.correctFirstTry,
          answered: active.qIndex + 1 > active.answered ? active.qIndex + 1 : active.answered,
          streak: active.streak + 1,
        ),
      ),
    );
    return AnswerCheck.correct;
  }

  bool retryAnswer() {
    final active = _state.run;
    if (active == null || active.feedback != AnswerFeedback.wrong) return false;
    _commit(
      _state.copyWith(lives: _state.lives == 0 ? 4 : _state.lives, run: active.copyWith(selection: '', feedback: AnswerFeedback.none)),
    );
    return true;
  }

  LessonResult? advanceQuestion() {
    final active = _state.run;
    if (active == null || active.feedback != AnswerFeedback.correct) return null;
    final lesson = PipSeed.lessonsById[active.lessonId];
    if (lesson == null) return null;

    if (active.qIndex < lesson.questions.length - 1) {
      _commit(
        _state.copyWith(run: active.copyWith(qIndex: active.qIndex + 1, selection: '', feedback: AnswerFeedback.none, firstTry: true)),
      );
      return null;
    }
    return _finishRun(active, lesson);
  }

  LessonResult _finishRun(RunState active, Lesson lesson) {
    final total = lesson.questions.length;
    final accuracy = (active.correctFirstTry / total * 100).round();
    var xp = _state.xp;
    var xpAwarded = 0;
    var completedNow = false;
    final completedLessons = Map<String, bool>.of(_state.completedLessons);

    if (active.mode != RunMode.review && !(completedLessons[lesson.id] ?? false)) {
      xpAwarded = lesson.xp;
      xp += xpAwarded;
      completedLessons[lesson.id] = true;
      completedNow = true;
    }

    final paused = Map<String, RunState>.of(_state.pausedRuns)..removeWhere((key, _) => key.startsWith('${lesson.id}:'));
    final result = LessonResult(
      lessonId: lesson.id,
      title: lesson.title,
      eyebrow: lesson.eyebrow,
      xpAwarded: xpAwarded,
      accuracy: accuracy,
      correctFirstTry: active.correctFirstTry,
      total: total,
      mode: active.mode,
      completedNow: completedNow,
      streak: _state.streak,
      dailySeconds: _state.dailySeconds,
      dailyGoal: _state.dailyGoal,
      allDone: LessonRules.currentLessonId(completedLessons) == null,
    );

    _commit(_state.copyWith(xp: xp, completedLessons: completedLessons, run: null, pausedRuns: paused, lastResult: result));
    return result;
  }

  Future<void> setDailyGoal(int goal) async {
    if (!PipSeed.dailyGoalOptions.contains(goal) || goal == _state.dailyGoal) return;
    final seconds = DailyGoalRules.clampSeconds(_state.dailySeconds, goal);
    _commit(_state.copyWith(dailyGoal: goal, dailySeconds: seconds));
    await flushSaves();
  }

  Future<void> setSoundOn(bool value) async {
    if (_state.soundOn == value) return;
    _commit(_state.copyWith(soundOn: value));
    await flushSaves();
  }

  Future<void> markReviewMastered(String topicId, String en) async {
    final topic = PipSeed.reviewTopicsById[topicId];
    if (topic == null || topic.terms.every((term) => term.en != en)) return;

    final current = _state.reviewMastered[topicId] ?? const <String>[];
    final updated = ReviewRules.markMastered(current, en);
    if (identical(updated, current)) return;

    _commit(_state.copyWith(reviewMastered: {..._state.reviewMastered, topicId: updated}));
    await flushSaves();
  }

  void prepareDemoCorrectFeedback() {
    startLesson('coffee', RunMode.lesson);
    final active = _state.run;
    if (active == null || active.lessonId != 'coffee') return;
    _commit(
      _state.copyWith(
        run: active.copyWith(
          selection: 'milk',
          feedback: AnswerFeedback.correct,
          firstTry: true,
          correctFirstTry: 1,
          answered: 1,
          streak: 1,
        ),
      ),
    );
  }

  Future<void> flushSaves() => _saveQueue;

  void _commit(AppState next) {
    _state = next;
    notifyListeners();
    _scheduleSave(next);
  }

  void _scheduleSave(AppState snapshot) {
    if (readOnlyDemo) return;
    _saveQueue = _saveQueue
        .then((_) async {
          final saved = await _repository.save(snapshot);
          if (_disposed) return;
          final nextFailed = !saved;
          if (_saveFailed != nextFailed) {
            _saveFailed = nextFailed;
            notifyListeners();
          }
        })
        .catchError((Object _) {
          if (_disposed) return;
          if (!_saveFailed) {
            _saveFailed = true;
            notifyListeners();
          }
        });
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
