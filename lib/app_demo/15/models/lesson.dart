enum QuestionType { fill, listen }

class ListenOption {
  final String id;
  final String label;
  final String sub;
  final String art;

  const ListenOption({required this.id, required this.label, required this.sub, required this.art});
}

class Question {
  final QuestionType type;
  final String prompt;
  final String cn;
  final String first;
  final String prefix;
  final String suffix;
  final List<String> words;
  final String answer;
  final String explain;
  final String? audio;
  final String? audioText;
  final List<ListenOption> options;

  const Question({
    required this.type,
    required this.prompt,
    required this.cn,
    required this.first,
    required this.prefix,
    required this.suffix,
    required this.words,
    required this.answer,
    required this.explain,
    this.audio,
    this.audioText,
    this.options = const [],
  });
}

class Lesson {
  final String id;
  final String title;
  final String nodeTitle;
  final String eyebrow;
  final int xp;
  final String estimated;
  final String icon;
  final List<Question> questions;

  const Lesson({
    required this.id,
    required this.title,
    required this.nodeTitle,
    required this.eyebrow,
    required this.xp,
    required this.estimated,
    required this.icon,
    required this.questions,
  });
}
