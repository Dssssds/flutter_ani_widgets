import 'package:flutter/material.dart';

import '../models/note_model.dart';
import '../widgets/markdown_editor.dart';

class EditPage extends StatefulWidget {
  final VoidCallback? onBack;
  final Note? note;

  const EditPage({super.key, this.onBack, this.note});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  MarkdownEditorController? _editorController;

  bool get _canUndo => _editorController?.canUndo ?? false;
  bool get _canRedo => _editorController?.canRedo ?? false;

  String get _initialContent {
    if (widget.note != null) {
      return widget.note!.mdContent ?? widget.note!.content;
    }
    return '# Write everything\n\nStart typing...';
  }

  String get _groupName {
    return widget.note?.group ?? 'Untitled';
  }

  void _undo() {
    if (_editorController?.canUndo ?? false) {
      _editorController!.undo();
      setState(() {}); // 更新按钮状态
    }
  }

  void _redo() {
    if (_editorController?.canRedo ?? false) {
      _editorController!.redo();
      setState(() {}); // 更新按钮状态
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: Image.asset(
                        'assets/images/10/check.png',
                        width: 20,
                        height: 20,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        if (widget.onBack != null) {
                          widget.onBack!();
                        } else {
                          Navigator.pop(context);
                        }
                      },
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Image.asset(
                        'assets/images/10/undo-alt.png',
                        width: 20,
                        height: 20,
                        color: _canUndo ? Colors.white70 : Colors.white30,
                      ),
                      onPressed: _canUndo ? _undo : null,
                    ),
                    IconButton(
                      icon: Image.asset(
                        'assets/images/10/redo-alt.png',
                        width: 20,
                        height: 20,
                        color: _canRedo ? Colors.white70 : Colors.white30,
                      ),
                      onPressed: _canRedo ? _redo : null,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Image.asset(
                        'assets/images/10/share.png',
                        width: 20,
                        height: 20,
                        color: Colors.white70,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Image.asset(
                        'assets/images/10/more.png',
                        width: 20,
                        height: 20,
                        color: Colors.white70,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            // Meta Info Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.book_outlined, color: Colors.white54, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _groupName,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white54,
                    size: 20,
                  ),
                  const Spacer(),
                  const Icon(Icons.access_time, color: Colors.white54, size: 20),
                  const SizedBox(width: 16),
                  const Icon(Icons.info_outline, color: Colors.white54, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Editor
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: MarkdownEditor(
                  initialContent: _initialContent,
                  onControllerReady: (controller) {
                    setState(() {
                      _editorController = controller;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
