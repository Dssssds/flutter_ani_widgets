import 'package:flutter/material.dart';
import 'package:super_editor/super_editor.dart';

class BottomToolbar extends StatefulWidget {
  final Editor editor;
  final MutableDocumentComposer composer;
  final FocusNode editorFocusNode;

  const BottomToolbar({
    super.key,
    required this.editor,
    required this.composer,
    required this.editorFocusNode,
  });

  @override
  State<BottomToolbar> createState() => _BottomToolbarState();
}

class _BottomToolbarState extends State<BottomToolbar> {
  @override
  void initState() {
    super.initState();
    // 监听焦点变化以更新 UI
    widget.editorFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.editorFocusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    // 焦点状态改变时重建 UI
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: _buildMainToolbar(),
    );
  }

  Widget _buildMainToolbar() {
    return ListenableBuilder(
      listenable: widget.composer.selectionNotifier,
      builder: (context, _) {
        final selection = widget.composer.selection;
        final hasSelection = selection != null && !selection.isCollapsed;

        return Row(
          children: [
            // 左侧：横向滑动的工具按钮区域
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _ToolbarIcon(
                      icon: Icons.title,
                      onPressed: () => _toggleHeading(),
                      isActive: _isAnyHeading(),
                      tooltip: 'Heading',
                    ),
                    _ToolbarIcon(
                      icon: Icons.format_bold,
                      onPressed: hasSelection ? () => _toggleBold() : null,
                      isActive: hasSelection && _hasAttribution(boldAttribution),
                      tooltip: 'Bold',
                    ),
                    _ToolbarIcon(
                      icon: Icons.format_italic,
                      onPressed: hasSelection ? () => _toggleItalic() : null,
                      isActive: hasSelection && _hasAttribution(italicsAttribution),
                      tooltip: 'Italic',
                    ),
                    _ToolbarIcon(
                      icon: Icons.format_strikethrough,
                      onPressed: hasSelection ? () => _toggleStrikethrough() : null,
                      isActive: hasSelection && _hasAttribution(strikethroughAttribution),
                      tooltip: 'Strikethrough',
                    ),
                    _ToolbarIcon(
                      icon: Icons.format_underlined,
                      onPressed: hasSelection ? () => _toggleUnderline() : null,
                      isActive: hasSelection && _hasAttribution(underlineAttribution),
                      tooltip: 'Underline',
                    ),
                    _ToolbarIcon(
                      icon: Icons.format_list_bulleted,
                      onPressed: () => _toggleList(ListItemType.unordered),
                      isActive: _isUnorderedList(),
                      tooltip: 'Bullet List',
                    ),
                    _ToolbarIcon(
                      icon: Icons.format_list_numbered,
                      onPressed: () => _toggleList(ListItemType.ordered),
                      isActive: _isOrderedList(),
                      tooltip: 'Numbered List',
                    ),
                    _ToolbarIcon(
                      icon: Icons.format_quote,
                      onPressed: () => _setBlockType(blockquoteAttribution),
                      isActive: _isBlockType(blockquoteAttribution),
                      tooltip: 'Quote',
                    ),
                    _ToolbarIcon(
                      icon: Icons.code,
                      onPressed: () => _setBlockType(codeAttribution),
                      isActive: _isBlockType(codeAttribution),
                      tooltip: 'Code Block',
                    ),
                    _ToolbarIcon(
                      icon: Icons.check_box_outlined,
                      onPressed: () => _insertCheckbox(),
                      isActive: _isTaskItem(),
                      tooltip: 'Checkbox',
                    ),
                    _ToolbarIcon(
                      icon: Icons.horizontal_rule,
                      onPressed: () => _insertHorizontalRule(),
                      tooltip: 'Divider',
                    ),
                    _ToolbarIcon(
                      icon: Icons.format_clear,
                      onPressed: hasSelection ? () => _clearFormatting() : null,
                      tooltip: 'Clear Format',
                    ),
                  ],
                ),
              ),
            ),
            
            // 右侧：固定的键盘切换按钮
            Container(
              padding: const EdgeInsets.only(left: 4, right: 8),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
              child: _ToolbarIcon(
                icon: widget.editorFocusNode.hasFocus
                    ? Icons.keyboard_hide
                    : Icons.keyboard,
                onPressed: () => _toggleKeyboard(),
                tooltip: widget.editorFocusNode.hasFocus
                    ? 'Hide Keyboard'
                    : 'Show Keyboard',
              ),
            ),
          ],
        );
      },
    );
  }

  void _toggleKeyboard() {
    if (widget.editorFocusNode.hasFocus) {
      // 如果键盘已显示，则收起
      widget.editorFocusNode.unfocus();
    } else {
      // 如果键盘已收起，则显示
      widget.editorFocusNode.requestFocus();
    }
  }

  bool _hasAttribution(Attribution attribution) {
    final selection = widget.composer.selection;
    if (selection == null || selection.isCollapsed) return false;

    final node = widget.editor.context.document.getNodeById(
      selection.extent.nodeId,
    );
    if (node is! TextNode) return false;

    final baseOffset = (selection.base.nodePosition as TextPosition).offset;
    final extentOffset = (selection.extent.nodePosition as TextPosition).offset;
    final start = baseOffset < extentOffset ? baseOffset : extentOffset;
    final end = baseOffset > extentOffset ? baseOffset : extentOffset;

    if (start >= end) return false;

    return node.text.hasAttributionsThroughout(
      attributions: {attribution},
      range: SpanRange(start, end - 1),
    );
  }

  bool _isBlockType(Attribution attribution) {
    final selection = widget.composer.selection;
    if (selection == null) return false;

    final node = widget.editor.context.document.getNodeById(
      selection.extent.nodeId,
    );
    if (node is ParagraphNode) {
      return node.getMetadataValue('blockType') == attribution;
    }
    return false;
  }

  bool _isUnorderedList() {
    final selection = widget.composer.selection;
    if (selection == null) return false;

    final node = widget.editor.context.document.getNodeById(
      selection.extent.nodeId,
    );
    if (node is! ListItemNode) return false;
    return node.type == ListItemType.unordered;
  }

  bool _isOrderedList() {
    final selection = widget.composer.selection;
    if (selection == null) return false;

    final node = widget.editor.context.document.getNodeById(
      selection.extent.nodeId,
    );
    if (node is! ListItemNode) return false;
    return node.type == ListItemType.ordered;
  }

  bool _isAnyHeading() {
    final selection = widget.composer.selection;
    if (selection == null) return false;

    final node = widget.editor.context.document.getNodeById(
      selection.extent.nodeId,
    );
    if (node is! ParagraphNode) return false;

    final blockType = node.getMetadataValue('blockType');
    return blockType == header1Attribution ||
        blockType == header2Attribution ||
        blockType == header3Attribution;
  }

  bool _isTaskItem() {
    final selection = widget.composer.selection;
    if (selection == null) return false;

    final node = widget.editor.context.document.getNodeById(
      selection.extent.nodeId,
    );
    return node is TaskNode;
  }

  void _toggleBold() {
    final selection = widget.composer.selection;
    if (selection == null) return;

    widget.editor.execute([
      ToggleTextAttributionsRequest(
        documentRange: selection,
        attributions: {boldAttribution},
      ),
    ]);
  }

  void _toggleItalic() {
    final selection = widget.composer.selection;
    if (selection == null) return;

    widget.editor.execute([
      ToggleTextAttributionsRequest(
        documentRange: selection,
        attributions: {italicsAttribution},
      ),
    ]);
  }

  void _toggleStrikethrough() {
    final selection = widget.composer.selection;
    if (selection == null) return;

    widget.editor.execute([
      ToggleTextAttributionsRequest(
        documentRange: selection,
        attributions: {strikethroughAttribution},
      ),
    ]);
  }

  void _toggleUnderline() {
    final selection = widget.composer.selection;
    if (selection == null) return;

    widget.editor.execute([
      ToggleTextAttributionsRequest(
        documentRange: selection,
        attributions: {underlineAttribution},
      ),
    ]);
  }

  void _clearFormatting() {
    final selection = widget.composer.selection;
    if (selection == null || selection.isCollapsed) return;

    final node = widget.editor.context.document.getNodeById(
      selection.extent.nodeId,
    );
    if (node is! TextNode) return;

    widget.editor.execute([
      RemoveTextAttributionsRequest(
        documentRange: selection,
        attributions: {
          boldAttribution,
          italicsAttribution,
          strikethroughAttribution,
          underlineAttribution,
        },
      ),
    ]);
  }

  void _toggleHeading() {
    final selection = widget.composer.selection;
    if (selection == null) return;

    final node = widget.editor.context.document.getNodeById(
      selection.extent.nodeId,
    );
    if (node is! ParagraphNode) return;

    final currentType = node.getMetadataValue('blockType');
    Attribution newType;

    if (currentType == header1Attribution) {
      newType = header2Attribution;
    } else if (currentType == header2Attribution) {
      newType = header3Attribution;
    } else if (currentType == header3Attribution) {
      newType = paragraphAttribution;
    } else {
      newType = header1Attribution;
    }

    widget.editor.execute([
      ChangeParagraphBlockTypeRequest(nodeId: node.id, blockType: newType),
    ]);
  }

  void _setBlockType(Attribution blockType) {
    final selection = widget.composer.selection;
    if (selection == null) return;

    final node = widget.editor.context.document.getNodeById(
      selection.extent.nodeId,
    );
    if (node is! TextNode) return;

    widget.editor.execute([
      ChangeParagraphBlockTypeRequest(nodeId: node.id, blockType: blockType),
    ]);
  }

  void _toggleList(ListItemType type) {
    final selection = widget.composer.selection;
    if (selection == null) return;

    final node = widget.editor.context.document.getNodeById(
      selection.extent.nodeId,
    );

    if (node is ListItemNode) {
      widget.editor.execute([
        ConvertListItemToParagraphRequest(
          nodeId: node.id,
          paragraphMetadata: {},
        ),
      ]);
    } else if (node is ParagraphNode) {
      widget.editor.execute([
        ConvertParagraphToListItemRequest(nodeId: node.id, type: type),
      ]);
    }
  }

  void _insertCheckbox() {
    final selection = widget.composer.selection;
    if (selection == null) return;

    final node = widget.editor.context.document.getNodeById(
      selection.extent.nodeId,
    );

    if (node is ParagraphNode) {
      widget.editor.execute([ConvertParagraphToTaskRequest(nodeId: node.id)]);
    }
  }

  void _insertHorizontalRule() {
    final selection = widget.composer.selection;
    if (selection == null) return;

    widget.editor.execute([
      InsertNodeAfterNodeRequest(
        existingNodeId: selection.extent.nodeId,
        newNode: HorizontalRuleNode(id: Editor.createNodeId()),
      ),
      InsertNodeAfterNodeRequest(
        existingNodeId: selection.extent.nodeId,
        newNode: ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText(''),
        ),
      ),
    ]);
  }
}

class _ToolbarIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isActive;
  final String? tooltip;

  const _ToolbarIcon({
    required this.icon,
    required this.onPressed,
    this.isActive = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = Container(
      decoration: BoxDecoration(
        color:
            isActive ? Colors.white.withValues(alpha: 0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color:
              onPressed == null
                  ? Colors.white.withValues(alpha: 0.3)
                  : (isActive ? Colors.white : Colors.white70),
          size: 22,
        ),
        onPressed: onPressed,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        style: IconButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}
