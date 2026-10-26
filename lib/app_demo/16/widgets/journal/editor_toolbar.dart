import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/16/models/material.dart';
import 'package:flutter_x_widgets/app_demo/16/models/view_models/diary_controller.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/common/app_16_icon.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/common/app_16_pressable.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/journal/text_editor_sheet.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/theme/app_16_theme.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/theme/design_tokens.dart';

class EditorToolbar extends StatefulWidget {
  const EditorToolbar({super.key, required this.controller});

  final DiaryController controller;

  @override
  State<EditorToolbar> createState() => _EditorToolbarState();
}

class _EditorToolbarState extends State<EditorToolbar> {
  final FocusNode _textFocus = FocusNode(debugLabel: 'app16-text-tool');

  @override
  void dispose() {
    _textFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metrics = App16Metrics.of(context);
    return Container(
      height: 56,
      margin: EdgeInsets.only(top: metrics.short ? 6 : 8, left: 5, right: 5),
      child: Row(
        children: <Widget>[
          _ToolButton(
            icon: 'i-photo',
            label: '照片',
            onTap: widget.controller.uploadPhoto,
          ),
          _ToolButton(
            icon: 'i-sticker',
            label: '贴纸',
            onTap: () => widget.controller.openDrawer(MaterialCategory.sticker),
          ),
          _ToolButton(
            icon: 'i-tape',
            label: '胶带',
            onTap: () => widget.controller.openDrawer(MaterialCategory.tape),
          ),
          _ToolButton(
            icon: 'i-type',
            label: '文字',
            focusNode: _textFocus,
            onTap: () async {
              widget.controller.openEditor();
              await showApp16TextEditor(context, widget.controller);
              if (mounted) {
                _textFocus.requestFocus();
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.focusNode,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: App16Pressable(
        onTap: onTap,
        semanticLabel: label,
        focusNode: focusNode,
        minSize: 44,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            App16Icon(name: icon, size: 23, color: App16Colors.muted),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: App16Colors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
