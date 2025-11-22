import 'package:flutter/material.dart';
import 'package:super_editor/super_editor.dart';

class EditorToolbar extends StatelessWidget {
  final Editor editor;
  final MutableDocumentComposer composer;

  const EditorToolbar({
    super.key,
    required this.editor,
    required this.composer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListenableBuilder(
        listenable: composer.selectionNotifier,
        builder: (context, _) {
          final selection = composer.selection;
          final isTextSelected = selection != null && !selection.isCollapsed;

          return Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              _ToolbarButton(
                icon: Icons.format_bold,
                label: 'B',
                isActive: isTextSelected && _hasAttribution(boldAttribution),
                onPressed: isTextSelected ? () => _toggleBold() : null,
              ),
              _ToolbarButton(
                icon: Icons.format_italic,
                label: 'I',
                isActive: isTextSelected && _hasAttribution(italicsAttribution),
                onPressed: isTextSelected ? () => _toggleItalic() : null,
              ),
              _ToolbarButton(
                icon: Icons.format_strikethrough,
                label: 'S',
                isActive:
                    isTextSelected && _hasAttribution(strikethroughAttribution),
                onPressed: isTextSelected ? () => _toggleStrikethrough() : null,
              ),
              const _ToolbarDivider(),
              _ToolbarButton(
                icon: Icons.title,
                label: 'H1',
                isActive: _isBlockType(header1Attribution),
                onPressed: () => _setBlockType(header1Attribution),
              ),
              _ToolbarButton(
                icon: Icons.title,
                label: 'H2',
                isActive: _isBlockType(header2Attribution),
                onPressed: () => _setBlockType(header2Attribution),
              ),
              _ToolbarButton(
                icon: Icons.title,
                label: 'H3',
                isActive: _isBlockType(header3Attribution),
                onPressed: () => _setBlockType(header3Attribution),
              ),
              const _ToolbarDivider(),
              _ToolbarButton(
                icon: Icons.format_list_bulleted,
                label: '•',
                isActive: _isBlockType(listItemAttribution),
                onPressed: () => _toggleList(ListItemType.unordered),
              ),
              _ToolbarButton(
                icon: Icons.format_list_numbered,
                label: '1.',
                isActive: _isBlockType(listItemAttribution),
                onPressed: () => _toggleList(ListItemType.ordered),
              ),
              const _ToolbarDivider(),
              _ToolbarButton(
                icon: Icons.format_quote,
                label: '"',
                isActive: _isBlockType(blockquoteAttribution),
                onPressed: () => _setBlockType(blockquoteAttribution),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _hasAttribution(Attribution attribution) {
    final selection = composer.selection;
    if (selection == null || selection.isCollapsed) return false;

    final node = editor.context.document.getNodeById(selection.extent.nodeId);
    if (node is! TextNode) return false;

    final baseOffset = (selection.base.nodePosition as TextPosition).offset;
    final extentOffset = (selection.extent.nodePosition as TextPosition).offset;
    final start = baseOffset < extentOffset ? baseOffset : extentOffset;
    final end = baseOffset > extentOffset ? baseOffset : extentOffset;

    return node.text.hasAttributionsThroughout(
      attributions: {attribution},
      range: SpanRange(start, end - 1),
    );
  }

  bool _isBlockType(Attribution attribution) {
    final selection = composer.selection;
    if (selection == null) return false;

    final node = editor.context.document.getNodeById(selection.extent.nodeId);
    if (node is ParagraphNode) {
      return node.getMetadataValue('blockType') == attribution;
    }
    if (node is ListItemNode) {
      return attribution == listItemAttribution;
    }
    return false;
  }

  void _toggleBold() {
    final selection = composer.selection;
    if (selection == null) return;

    editor.execute([
      ToggleTextAttributionsRequest(
        documentRange: selection,
        attributions: {boldAttribution},
      ),
    ]);
  }

  void _toggleItalic() {
    final selection = composer.selection;
    if (selection == null) return;

    editor.execute([
      ToggleTextAttributionsRequest(
        documentRange: selection,
        attributions: {italicsAttribution},
      ),
    ]);
  }

  void _toggleStrikethrough() {
    final selection = composer.selection;
    if (selection == null) return;

    editor.execute([
      ToggleTextAttributionsRequest(
        documentRange: selection,
        attributions: {strikethroughAttribution},
      ),
    ]);
  }

  void _setBlockType(Attribution blockType) {
    final selection = composer.selection;
    if (selection == null) return;

    final node = editor.context.document.getNodeById(selection.extent.nodeId);
    if (node is! TextNode) return;

    editor.execute([
      ChangeParagraphBlockTypeRequest(
        nodeId: node.id,
        blockType: blockType,
      ),
    ]);
  }

  void _toggleList(ListItemType type) {
    final selection = composer.selection;
    if (selection == null) return;

    final node = editor.context.document.getNodeById(selection.extent.nodeId);

    if (node is ListItemNode) {
      editor.execute([
        ConvertListItemToParagraphRequest(
          nodeId: node.id,
          paragraphMetadata: {},
        ),
      ]);
    } else if (node is ParagraphNode) {
      editor.execute([
        ConvertParagraphToListItemRequest(
          nodeId: node.id,
          type: type,
        ),
      ]);
    }
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onPressed;

  const _ToolbarButton({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.black : Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'SF Pro Display',
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolbarDivider extends StatelessWidget {
  const _ToolbarDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      color: Colors.grey.withValues(alpha: 0.3),
    );
  }
}
