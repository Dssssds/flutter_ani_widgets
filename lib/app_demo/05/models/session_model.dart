

/// 会话数据模型
class Session {
  final String id;
  final String title;
  final DateTime? date;
  final String timeOfDay; // 如"Morning Session"
  final Duration duration;
  final Duration targetDuration;
  final String notes;
  final double progress; // 0.0 到 1.0

  const Session({
    required this.id,
    required this.title,
    this.date,
    required this.timeOfDay,
    required this.duration,
    required this.targetDuration,
    this.notes = '',
    this.progress = 0.0,
  });
}

/// 用户数据模型
class User {
  final String id;
  final String name;
  final String avatarUrl;
  final DateTime? sessionDate;

  const User({
    required this.id,
    required this.name,
    required this.avatarUrl,
    this.sessionDate,
  });
}

/// 模拟数据服务
class SessionService {
  // 当前用户
  static const User currentUser = User(
    id: 'u1',
    name: 'Oliver Johnson',
    avatarUrl: 'OJ',
    sessionDate: null,
  );

  // 当前会话
  static Session getCurrentSession() {
    return const Session(
      id: 's1',
      title: 'Independent Play',
      date: null,
      timeOfDay: 'Session: June 27, 2023',
      duration: Duration(minutes: 1, seconds: 10),
      targetDuration: Duration(minutes: 1),
      notes: 'Oliver is playing with blocks independently. He\'s building a tower and showing good focus. Occasionally looks up but returns to task without prompting.',
      progress: 0.67,
    );
  }

  // 历史会话
  static List<Session> getPreviousSessions() {
    return [
      Session(
        id: 's2',
        title: 'Independent Play',
        date: DateTime(2023, 6, 25), // 6月25日
        timeOfDay: 'Morning Session',
        duration: Duration(minutes: 6, seconds: 45),
        targetDuration: Duration(minutes: 8),
        notes: '',
        progress: 1.0,
      ),
      Session(
        id: 's3',
        title: 'Independent Play',
        date: DateTime(2023, 6, 22), // 6月22日
        timeOfDay: 'Afternoon Session',
        duration: Duration(minutes: 5, seconds: 12),
        targetDuration: Duration(minutes: 8),
        notes: '',
        progress: 1.0,
      ),
      Session(
        id: 's4',
        title: 'Independent Play',
        date: DateTime(2023, 6, 20), // 6月20日
        timeOfDay: 'Morning Session',
        duration: Duration(minutes: 4, seconds: 16),
        targetDuration: Duration(minutes: 8),
        notes: '',
        progress: 1.0,
      ),
    ];
  }
}
