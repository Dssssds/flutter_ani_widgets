import 'package:flutter/material.dart';

import '../widgets/markdown_editor.dart';

class EditPage extends StatefulWidget {
  final VoidCallback? onBack;

  const EditPage({super.key, this.onBack});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  MarkdownEditorController? _editorController;

  bool get _canUndo => _editorController?.canUndo ?? false;
  bool get _canRedo => _editorController?.canRedo ?? false;

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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.book_outlined, color: Colors.white54, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Work',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white54,
                    size: 20,
                  ),
                  Spacer(),
                  Icon(Icons.access_time, color: Colors.white54, size: 20),
                  SizedBox(width: 16),
                  Icon(Icons.info_outline, color: Colors.white54, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Editor
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: MarkdownEditor(
                  initialContent:
                      '# Write everything\necstatic cover\n\nPeople can be clever as high as the sky, but as long as they don twate, they will be lost in society and from history\n\n| Top here to continue',
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
