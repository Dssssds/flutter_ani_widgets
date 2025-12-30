import 'package:flutter/material.dart';

import '../widgets/markdown_editor.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  MarkdownEditorController? _editorController;

  bool get _canUndo => _editorController?.canUndo ?? false;
  bool get _canRedo => _editorController?.canRedo ?? false;

  // 新建笔记的初始内容
  String get _initialContent {
    return '# New Note\n\nStart writing...';
  }

  // 默认分组
  String _selectedGroup = 'Work';

  void _undo() {
    if (_editorController?.canUndo ?? false) {
      _editorController!.undo();
      setState(() {});
    }
  }

  void _redo() {
    if (_editorController?.canRedo ?? false) {
      _editorController!.redo();
      setState(() {});
    }
  }

  void _save() {
    // TODO: 实现保存功能
    // 1. 获取编辑器内容
    // 2. 创建新的 Note 对象
    // 3. 保存到数据源
    // 4. 返回首页
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            _buildTopBar(),

            // Meta Info Row
            _buildMetaInfo(),

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

  Widget _buildTopBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            // Cancel 按钮
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white70),
              onPressed: () => Navigator.pop(context),
            ),
            const Spacer(),
            // Undo/Redo
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
            // Save 按钮
            TextButton(
              onPressed: _save,
              child: const Text(
                'Done',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.book_outlined, color: Colors.white54, size: 20),
          const SizedBox(width: 8),
          // 可点击选择分组
          GestureDetector(
            onTap: _showGroupSelector,
            child: Row(
              children: [
                Text(
                  _selectedGroup,
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
              ],
            ),
          ),
          const Spacer(),
          const Icon(Icons.access_time, color: Colors.white54, size: 20),
          const SizedBox(width: 16),
          const Icon(Icons.info_outline, color: Colors.white54, size: 20),
        ],
      ),
    );
  }

  void _showGroupSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2C2C2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Group',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ..._buildGroupOptions(),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildGroupOptions() {
    final groups = ['Work', 'Life', 'Important', 'Reading'];
    return groups.map((group) {
      return ListTile(
        title: Text(
          group,
          style: const TextStyle(color: Colors.white),
        ),
        trailing: _selectedGroup == group
            ? const Icon(Icons.check, color: Colors.blue)
            : null,
        onTap: () {
          setState(() {
            _selectedGroup = group;
          });
          Navigator.pop(context);
        },
      );
    }).toList();
  }
}
