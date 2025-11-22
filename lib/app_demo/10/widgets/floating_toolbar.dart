import 'package:flutter/material.dart';
import 'package:super_editor/super_editor.dart';

class FloatingEditorToolbar extends StatelessWidget {
  final Editor editor;
  final MutableDocumentComposer composer;
  final FocusNode editorFocusNode;

  const FloatingEditorToolbar({
    super.key,
    required this.editor,
    required this.composer,
    required this.editorFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: composer.selectionNotifier,
      builder: (context, _) {
        final selection = composer.selection;
        if (selection == null || selection.isCollapsed) {
          return const SizedBox.shrink();
        }
        
        return const SizedBox.shrink();
      },
    );
  }



}
