import 'package:super_editor/super_editor.dart';

/// 文档历史管理器，用于实现撤销/重做功能
class DocumentHistory {
  final List<String> _history = [];
  int _currentIndex = -1;
  final int maxHistorySize;

  DocumentHistory({this.maxHistorySize = 100});

  /// 记录文档状态
  void record(MutableDocument document) {
    try {
      // 将文档序列化为 Markdown
      final content = serializeDocumentToMarkdown(document);

      // 如果不在历史末尾，移除后面的历史（新编辑会清空重做栈）
      if (_currentIndex < _history.length - 1) {
        _history.removeRange(_currentIndex + 1, _history.length);
      }

      // 避免记录相同的内容
      if (_history.isEmpty || _history.last != content) {
        // 添加新快照
        _history.add(content);
        _currentIndex++;

        // 限制历史记录大小
        if (_history.length > maxHistorySize) {
          _history.removeAt(0);
          _currentIndex--;
        }
      }
    } catch (e) {
      // 序列化失败时忽略，避免崩溃
      // ignore: avoid_print
      print('Failed to record document history: $e');
    }
  }

  /// 撤销到上一个状态
  String? undo() {
    if (canUndo) {
      _currentIndex--;
      return _history[_currentIndex];
    }
    return null;
  }

  /// 重做到下一个状态
  String? redo() {
    if (canRedo) {
      _currentIndex++;
      return _history[_currentIndex];
    }
    return null;
  }

  /// 是否可以撤销
  bool get canUndo => _currentIndex > 0;

  /// 是否可以重做
  bool get canRedo => _currentIndex < _history.length - 1;

  /// 获取历史记录数量
  int get historyCount => _history.length;

  /// 获取当前索引
  int get currentIndex => _currentIndex;

  /// 清空历史记录
  void clear() {
    _history.clear();
    _currentIndex = -1;
  }
}
