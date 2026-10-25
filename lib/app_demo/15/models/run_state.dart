enum RunMode { lesson, review }

enum AnswerFeedback { none, correct, wrong }

class RunState {
  final String lessonId;
  final RunMode mode;
  final int qIndex;
  final int answered;
  final int correctFirstTry;
  final String selection;
  final AnswerFeedback feedback;
  final bool firstTry;
  final int streak;

  const RunState({
    required this.lessonId,
    required this.mode,
    this.qIndex = 0,
    this.answered = 0,
    this.correctFirstTry = 0,
    this.selection = '',
    this.feedback = AnswerFeedback.none,
    this.firstTry = true,
    this.streak = 0,
  });

  RunState copyWith({
    String? lessonId,
    RunMode? mode,
    int? qIndex,
    int? answered,
    int? correctFirstTry,
    String? selection,
    AnswerFeedback? feedback,
    bool? firstTry,
    int? streak,
  }) {
    return RunState(
      lessonId: lessonId ?? this.lessonId,
      mode: mode ?? this.mode,
      qIndex: qIndex ?? this.qIndex,
      answered: answered ?? this.answered,
      correctFirstTry: correctFirstTry ?? this.correctFirstTry,
      selection: selection ?? this.selection,
      feedback: feedback ?? this.feedback,
      firstTry: firstTry ?? this.firstTry,
      streak: streak ?? this.streak,
    );
  }
}
