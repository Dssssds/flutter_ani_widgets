import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 待办事项数据模型
class TodoItem {
  final String id;
  String text;
  bool isCompleted;
  DateTime? completedAt;

  TodoItem({
    required this.id,
    required this.text,
    this.isCompleted = false,
    this.completedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isCompleted': isCompleted,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
        id: json['id'] as String,
        text: json['text'] as String,
        isCompleted: json['isCompleted'] as bool? ?? false,
        completedAt: json['completedAt'] != null
            ? DateTime.tryParse(json['completedAt'] as String)
            : null,
      );
}

/// 已固定的物理字母模型（构成山体的一部分）
class SettledLetter {
  final String todoId; // 所属待办任务的 id
  final String char;
  final double x;
  final double y;
  final double angle;
  final double size;
  final int colorValue; // ARGB色值

  SettledLetter({
    required this.todoId,
    required this.char,
    required this.x,
    required this.y,
    required this.angle,
    required this.size,
    required this.colorValue,
  });

  Map<String, dynamic> toJson() => {
        'todoId': todoId,
        'char': char,
        'x': x,
        'y': y,
        'angle': angle,
        'size': size,
        'colorValue': colorValue,
      };

  factory SettledLetter.fromJson(Map<String, dynamic> json) => SettledLetter(
        todoId: json['todoId'] as String? ?? '',
        char: json['char'] as String,
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
        angle: (json['angle'] as num).toDouble(),
        size: (json['size'] as num).toDouble(),
        colorValue: json['colorValue'] as int? ?? 0xFFFFFFFF,
      );
}

/// 每日的山体和待办数据，用于持久化
class DayMountain {
  final String dateKey; // YYYY-MM-DD
  final List<TodoItem> todos;
  final List<SettledLetter> settledLetters;

  DayMountain({
    required this.dateKey,
    required this.todos,
    required this.settledLetters,
  });

  Map<String, dynamic> toJson() => {
        'dateKey': dateKey,
        'todos': todos.map((e) => e.toJson()).toList(),
        'settledLetters': settledLetters.map((e) => e.toJson()).toList(),
      };

  factory DayMountain.fromJson(Map<String, dynamic> json) {
    var rawTodos = json['todos'] as List? ?? [];
    var rawLetters = json['settledLetters'] as List? ?? [];
    return DayMountain(
      dateKey: json['dateKey'] as String,
      todos: rawTodos.map((e) => TodoItem.fromJson(e as Map<String, dynamic>)).toList(),
      settledLetters: rawLetters.map((e) => SettledLetter.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

/// SharedPreferences 存储管理类
class TodoStorage {
  // 内存级静态 Session 缓存
  static final Map<String, DayMountain> _cache = {};

  /// 清空 Session 缓存 (每次重新进入 Demo 时调用)
  static void clearCache() {
    _cache.clear();
  }

  /// 从指定日期的静态内存缓存中移除待办项，用于处理异步切换日期时已完成待办的删除
  static void removeTodoFromCache(String dateKey, String todoId) {
    if (_cache.containsKey(dateKey)) {
      final dayData = _cache[dateKey]!;
      dayData.todos.removeWhere((t) => t.id == todoId);
    }
  }

  /// 获取指定日期的数据
  static Future<DayMountain> loadDay(DateTime date) async {
    final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    if (_cache.containsKey(dateKey)) {
      return _cache[dateKey]!;
    }

    // 仅“今天”加载默认的演示种子数据，其他日期默认为空模板
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    final List<TodoItem> defaultTodos = isToday
        ? [
            TodoItem(id: '1', text: '完成一份酷炫的 Flutter 交互设计'),
            TodoItem(id: '2', text: '去健身房跑步锻炼 30 分钟'),
            TodoItem(id: '3', text: '给 Mountain Todo 加上物理堆积效果'),
          ]
        : [];

    final data = DayMountain(
      dateKey: dateKey,
      todos: defaultTodos,
      settledLetters: [],
    );
    _cache[dateKey] = data;
    return data;
  }

  /// 保存指定日期的数据
  static Future<void> saveDay(DateTime date, DayMountain data) async {
    final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    _cache[dateKey] = data;
  }

  /// 批量获取过去 N 天的山体 (从内存缓存中获取，供视差山体渲染)
  static Future<Map<String, List<SettledLetter>>> loadHistoricalMountains(DateTime currentDate, int count) async {
    final Map<String, List<SettledLetter>> result = {};
    for (int i = 1; i <= count; i++) {
      final targetDate = currentDate.subtract(Duration(days: i));
      final dateStr = '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';
      if (_cache.containsKey(dateStr)) {
        final dayData = _cache[dateStr]!;
        if (dayData.settledLetters.isNotEmpty) {
          result[dateStr] = dayData.settledLetters;
        }
      }
    }
    return result;
  }
}
