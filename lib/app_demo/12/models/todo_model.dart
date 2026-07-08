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
  /// 获取指定日期的数据 (移除缓存，每次启动均为全新初始状态)
  static Future<DayMountain> loadDay(DateTime date) async {
    final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return DayMountain(
      dateKey: dateKey,
      todos: [
        TodoItem(id: '1', text: '完成一份酷炫的 Flutter 交互设计'),
        TodoItem(id: '2', text: '去健身房跑步锻炼 30 分钟'),
        TodoItem(id: '3', text: '给 Mountain Todo 加上物理堆积效果'),
      ],
      settledLetters: [],
    );
  }

  /// 保存指定日期的数据 (空实现，不进行本地存储)
  static Future<void> saveDay(DateTime date, DayMountain data) async {
    // 不再保存数据
  }

  /// 批量获取过去 N 天的山体 (不使用缓存时，历史山为空)
  static Future<Map<String, List<SettledLetter>>> loadHistoricalMountains(DateTime currentDate, int count) async {
    return const {};
  }
}
