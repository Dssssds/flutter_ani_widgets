import 'dart:async';

import 'package:flutter/material.dart';
import 'package:super_editor/super_editor.dart';

import '../utils/document_history.dart';
import 'bottom_toolbar.dart';

class MarkdownEditor extends StatefulWidget {
  final String initialContent;
  final ValueChanged<String>? onChanged;
  final ValueChanged<MarkdownEditorController>? onControllerReady;

  const MarkdownEditor({
    super.key,
    this.initialContent = '',
    this.onChanged,
    this.onControllerReady,
  });

  @override
  State<MarkdownEditor> createState() => _MarkdownEditorState();
}

class MarkdownEditorController {
  final Editor editor;
  final MutableDocumentComposer composer;
  final FocusNode focusNode;
  final DocumentHistory history;
  final void Function(String) restoreFromHistory;

  MarkdownEditorController({
    required this.editor,
    required this.composer,
    required this.focusNode,
    required this.history,
    required this.restoreFromHistory,
  });

  /// 撤销到上一个状态
  void undo() {
    final markdown = history.undo();
    if (markdown != null) {
      restoreFromHistory(markdown);
    }
  }

  /// 重做到下一个状态
  void redo() {
    final markdown = history.redo();
    if (markdown != null) {
      restoreFromHistory(markdown);
    }
  }

  /// 是否可以撤销
  bool get canUndo => history.canUndo;

  /// 是否可以重做
  bool get canRedo => history.canRedo;
}

class _MarkdownEditorState extends State<MarkdownEditor> {
  late MutableDocument _doc;
  late MutableDocumentComposer _composer;
  late Editor _editor;
  late FocusNode _editorFocusNode;
  late ScrollController _scrollController;

  // 历史记录管理
  final DocumentHistory _history = DocumentHistory();
  Timer? _recordTimer;
  bool _isRestoringFromHistory = false;

  @override
  void initState() {
    super.initState();
    _doc = deserializeMarkdownToDocument(widget.initialContent);
    _composer = MutableDocumentComposer();
    _editor = createDefaultDocumentEditor(document: _doc, composer: _composer);
    _editorFocusNode = FocusNode();
    _scrollController = ScrollController();

    // 记录初始状态
    _history.record(_doc);

    // 使用定时器定期检查文档变化
    _startRecordingTimer();

    // 在下一帧通知控制器已准备好
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.onControllerReady != null) {
        widget.onControllerReady!(MarkdownEditorController(
          editor: _editor,
          composer: _composer,
          focusNode: _editorFocusNode,
          history: _history,
          restoreFromHistory: _restoreFromHistory,
        ));
      }
    });
  }

  /// 启动定期记录定时器
  void _startRecordingTimer() {
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isRestoringFromHistory) {
        _history.record(_doc);
      }
    });
  }

  /// 从历史恢复文档
  void _restoreFromHistory(String markdown) {
    _isRestoringFromHistory = true;

    try {
      // 重新创建文档
      final newDoc = deserializeMarkdownToDocument(markdown);

      // 清空当前文档
      while (_doc.nodeCount > 0) {
        _doc.deleteNodeAt(0);
      }

      // 添加新节点
      for (int i = 0; i < newDoc.nodeCount; i++) {
        final node = newDoc.getNodeAt(i);
        if (node != null) {
          _doc.insertNodeAt(_doc.nodeCount, node);
        }
      }

      // 清除选择
      _composer.clearSelection();
    } catch (e) {
      // 使用 debugPrint 代替 print
      debugPrint('Failed to restore from history: $e');
    } finally {
      _isRestoringFromHistory = false;
    }
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _editorFocusNode.dispose();
    _scrollController.dispose();
    _editor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SuperEditor(
            editor: _editor,
            focusNode: _editorFocusNode,
            scrollController: _scrollController,
            documentOverlayBuilders: const [
              DefaultCaretOverlayBuilder(
                caretStyle: CaretStyle(color: Colors.white),
                displayCaretWithExpandedSelection: true,
                displayOnAllPlatforms: true,
              ),
            ],
            stylesheet: Stylesheet(
              inlineTextStyler: defaultInlineTextStyler,
              rules: [
                StyleRule(const BlockSelector('header1'), (doc, docNode) {
                  return {
                    'textStyle': const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SF Pro Display',
                      height: 1.2,
                    ),
                  };
                }),
                StyleRule(const BlockSelector('header2'), (doc, docNode) {
                  return {
                    'textStyle': const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SF Pro Display',
                      height: 1.3,
                    ),
                  };
                }),
                StyleRule(const BlockSelector('header3'), (doc, docNode) {
                  return {
                    'textStyle': const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SF Pro Display',
                      height: 1.4,
                    ),
                  };
                }),
                StyleRule(const BlockSelector('paragraph'), (doc, docNode) {
                  return {
                    'textStyle': const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'SF Pro Display',
                      height: 1.5,
                    ),
                  };
                }),
                StyleRule(const BlockSelector('listItem'), (doc, docNode) {
                  return {
                    'textStyle': const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'SF Pro Display',
                      height: 1.5,
                    ),
                  };
                }),
                StyleRule(const BlockSelector('blockquote'), (doc, docNode) {
                  return {
                    'textStyle': const TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                      fontFamily: 'SF Pro Display',
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  };
                }),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: BottomToolbar(
              editor: _editor,
              composer: _composer,
              editorFocusNode: _editorFocusNode,
            ),
          ),
        ),
      ],
    );
  }
}
