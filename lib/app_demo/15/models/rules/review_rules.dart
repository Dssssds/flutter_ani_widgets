import 'package:flutter_x_widgets/app_demo/15/models/review_topic.dart';

abstract final class ReviewRules {
  static int startIndex(ReviewTopic topic, Iterable<String> mastered) {
    final learned = mastered.toSet();
    final index = topic.terms.indexWhere((term) => !learned.contains(term.en));
    return index < 0 ? 0 : index;
  }

  static int masteredCount(ReviewTopic topic, Iterable<String> mastered) {
    final learned = mastered.toSet();
    return topic.terms.where((term) => learned.contains(term.en)).length;
  }

  static List<String> markMastered(List<String> mastered, String en) {
    if (mastered.contains(en)) return mastered;
    return [...mastered, en];
  }
}
