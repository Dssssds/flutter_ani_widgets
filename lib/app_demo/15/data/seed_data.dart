import 'package:flutter_x_widgets/app_demo/15/models/achievement.dart';
import 'package:flutter_x_widgets/app_demo/15/models/lesson.dart';
import 'package:flutter_x_widgets/app_demo/15/models/review_topic.dart';

const _coffeeMilk = Question(
  type: QuestionType.fill,
  prompt: '帮 Pip 点杯咖啡',
  cn: '来一杯加奶的咖啡。',
  first: "I'd like a coffee",
  prefix: 'with',
  suffix: '.',
  words: ['coffee', 'milk', 'tea', 'water'],
  answer: 'milk',
  explain: 'with milk = 加奶',
  audio: 'coffee-milk',
);

const _coffeeToGo = Question(
  type: QuestionType.fill,
  prompt: '告诉店员，你想带走',
  cn: '这杯咖啡可以打包吗？',
  first: 'Can I get it',
  prefix: '',
  suffix: '?',
  words: ['to go', 'here', 'today', 'again'],
  answer: 'to go',
  explain: 'to go = 打包带走',
  audio: 'to-go',
);

const _coffeeSmall = Question(
  type: QuestionType.fill,
  prompt: '选好杯型就出发',
  cn: '小杯的，谢谢。',
  first: 'A',
  prefix: '',
  suffix: 'one, please.',
  words: ['large', 'cold', 'small', 'sweet'],
  answer: 'small',
  explain: 'a small one = 小杯的',
  audio: 'small',
);

const _coffeeSmallListen = Question(
  type: QuestionType.listen,
  prompt: '听一听，Pip 点了哪一杯？',
  cn: '先听英文，再选出对应的杯型。',
  first: '',
  prefix: '',
  suffix: '',
  words: [],
  answer: 'small',
  explain: 'a small one = 小杯的',
  audio: 'small',
  audioText: 'A small one, please.',
  options: [
    ListenOption(id: 'small', label: '小杯', sub: 'small', art: 'small'),
    ListenOption(id: 'large', label: '大杯', sub: 'large', art: 'large'),
    ListenOption(id: 'iced', label: '冰杯', sub: 'iced', art: 'iced'),
  ],
);

const _coffeeThanks = Question(
  type: QuestionType.fill,
  prompt: '给店员一个好心情',
  cn: '谢谢。祝你今天愉快！',
  first: '',
  prefix: '',
  suffix: '. Have a nice day!',
  words: ['Sorry', 'Hello', 'Thank you', 'Good night'],
  answer: 'Thank you',
  explain: 'Have a nice day! = 祝你愉快！',
  audio: 'thank-you',
);

const _directionsStation = Question(
  type: QuestionType.fill,
  prompt: '先礼貌地问个路',
  cn: '请问，车站在哪里？',
  first: 'Excuse me, where is the',
  prefix: '',
  suffix: '?',
  words: ['station', 'coffee', 'menu', 'bank'],
  answer: 'station',
  explain: 'station = 车站',
  audio: 'where-station',
);

const _directionsStraight = Question(
  type: QuestionType.fill,
  prompt: '店员告诉你怎么走',
  cn: '直走两个街区。',
  first: 'Go',
  prefix: '',
  suffix: 'for two blocks.',
  words: ['straight', 'back', 'slow', 'around'],
  answer: 'straight',
  explain: 'go straight = 直走',
  audio: 'go-straight',
);

const _directionsLeftListen = Question(
  type: QuestionType.listen,
  prompt: '听一听，路口该怎么转？',
  cn: '先听英文，再选出正确的方向。',
  first: '',
  prefix: '',
  suffix: '',
  words: [],
  answer: 'left',
  explain: 'turn left = 左转',
  audio: 'turn-left',
  audioText: 'Turn left at the corner.',
  options: [
    ListenOption(id: 'left', label: '左转', sub: 'turn left', art: 'left'),
    ListenOption(id: 'right', label: '右转', sub: 'turn right', art: 'right'),
    ListenOption(id: 'straight', label: '直走', sub: 'go straight', art: 'straight'),
  ],
);

const _directionsNextTo = Question(
  type: QuestionType.fill,
  prompt: '确认目的地的位置',
  cn: '就在银行旁边。',
  first: "It's",
  prefix: '',
  suffix: 'the bank.',
  words: ['next to', 'far from', 'under', 'behind'],
  answer: 'next to',
  explain: 'next to = 在…旁边',
  audio: 'next-to-bank',
);

const _coffeeTopic = ReviewTopic(
  id: 'coffee',
  title: '点杯咖啡',
  copy: '咖啡店的 5 个说法，排队时也能顺口说出来。',
  icon: 'cup',
  terms: [
    ReviewTerm(en: 'milk', cn: '牛奶'),
    ReviewTerm(en: 'to go', cn: '打包带走'),
    ReviewTerm(en: 'a small one', cn: '小杯的'),
    ReviewTerm(en: 'Thank you', cn: '谢谢'),
    ReviewTerm(en: 'Have a nice day!', cn: '祝你今天愉快！'),
  ],
);

const _greetingTopic = ReviewTopic(
  id: 'greeting',
  title: '打个招呼',
  copy: '把这 4 句说顺，见面就不紧张。',
  icon: 'book',
  terms: [
    ReviewTerm(en: 'Hello.', cn: '你好。'),
    ReviewTerm(en: 'Nice to meet you.', cn: '很高兴认识你。'),
    ReviewTerm(en: 'How are you?', cn: '你好吗？'),
    ReviewTerm(en: 'See you.', cn: '回头见。'),
  ],
);

const _menuTopic = ReviewTopic(
  id: 'menu',
  title: '看懂菜单',
  copy: '下次买咖啡，认得这些就够用。',
  icon: 'review',
  terms: [
    ReviewTerm(en: 'a latte', cn: '一杯拿铁'),
    ReviewTerm(en: 'an espresso', cn: '一杯浓缩咖啡'),
    ReviewTerm(en: 'iced coffee', cn: '冰咖啡'),
    ReviewTerm(en: 'decaf', cn: '低因咖啡'),
  ],
);

const _directionsTopic = ReviewTopic(
  id: 'directions',
  title: '问个方向',
  copy: '问路、找店、确认位置，一次练顺。',
  icon: 'compass',
  terms: [
    ReviewTerm(en: 'station', cn: '车站'),
    ReviewTerm(en: 'go straight', cn: '直走'),
    ReviewTerm(en: 'turn left', cn: '左转'),
    ReviewTerm(en: 'next to', cn: '在…旁边'),
  ],
);

const _streakAchievement = AchievementDefinition(
  id: 'streak',
  title: '一周不掉线',
  description: '连续学习 7 天',
  icon: 'flame',
  metric: AchievementMetric.streak,
  target: 7,
);

const _xpAchievement = AchievementDefinition(
  id: 'xp',
  title: '千分俱乐部',
  description: '累计超过 1,000 XP',
  icon: 'bolt',
  metric: AchievementMetric.xp,
  target: 1000,
);

const _coffeeAchievement = AchievementDefinition(
  id: 'coffee',
  title: '咖啡自由',
  description: '完成「点杯咖啡」',
  icon: 'cup',
  metric: AchievementMetric.coffee,
  target: 1,
);

const _directionsAchievement = AchievementDefinition(
  id: 'directions',
  title: '问路达人',
  description: '完成「问个方向」',
  icon: 'compass',
  metric: AchievementMetric.directions,
  target: 1,
);

const _unitAchievement = AchievementDefinition(
  id: 'unit',
  title: '单元通关',
  description: '完成咖啡店单元挑战',
  icon: 'trophy',
  metric: AchievementMetric.challenge,
  target: 1,
);

abstract final class PipSeed {
  static const unitEyebrow = '第 3 单元 · 通勤英语';
  static const unitTitle = '咖啡店，开口不慌';
  static const totalTerms = 17;

  static const lessonOrder = <String>['coffee', 'directions', 'challenge'];
  static const reviewOnlyNodeIds = <String>{'greeting', 'menu'};
  static const dailyGoalOptions = <int>[5, 10, 15, 20];

  static const coffeeLesson = Lesson(
    id: 'coffee',
    title: '点杯咖啡',
    nodeTitle: '点杯咖啡',
    eyebrow: '第 3 课',
    xp: 24,
    estimated: '约 2 分钟',
    icon: 'cup',
    questions: [_coffeeMilk, _coffeeToGo, _coffeeSmall, _coffeeSmallListen, _coffeeThanks],
  );

  static const directionsLesson = Lesson(
    id: 'directions',
    title: '问个方向',
    nodeTitle: '问个方向',
    eyebrow: '第 4 课',
    xp: 24,
    estimated: '约 2 分钟',
    icon: 'compass',
    questions: [_directionsStation, _directionsStraight, _directionsLeftListen, _directionsNextTo],
  );

  static const challengeLesson = Lesson(
    id: 'challenge',
    title: '单元挑战',
    nodeTitle: '单元挑战',
    eyebrow: '咖啡店单元',
    xp: 50,
    estimated: '约 3 分钟',
    icon: 'flag',
    questions: [_coffeeMilk, _coffeeToGo, _coffeeSmallListen, _directionsStation, _directionsStraight, _directionsLeftListen],
  );

  static const lessons = <Lesson>[coffeeLesson, directionsLesson, challengeLesson];

  static const lessonsById = <String, Lesson>{'coffee': coffeeLesson, 'directions': directionsLesson, 'challenge': challengeLesson};

  static const reviewTopics = <ReviewTopic>[_coffeeTopic, _greetingTopic, _menuTopic, _directionsTopic];

  static final reviewTopicsById = {for (final topic in reviewTopics) topic.id: topic};

  static const achievements = <AchievementDefinition>[
    _streakAchievement,
    _xpAchievement,
    _coffeeAchievement,
    _directionsAchievement,
    _unitAchievement,
  ];

  static final achievementsById = {for (final achievement in achievements) achievement.id: achievement};
}
