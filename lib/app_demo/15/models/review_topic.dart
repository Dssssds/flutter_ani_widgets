class ReviewTerm {
  final String en;
  final String cn;

  const ReviewTerm({required this.en, required this.cn});
}

class ReviewTopic {
  final String id;
  final String title;
  final String copy;
  final String icon;
  final List<ReviewTerm> terms;

  const ReviewTopic({required this.id, required this.title, required this.copy, required this.icon, required this.terms});
}
