import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_x_widgets/app_demo/16/models/rules/diary_rules.dart';
import 'package:flutter_x_widgets/app_demo/16/models/view_models/diary_controller.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/common/app_16_icon.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/common/app_16_pressable.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/motion/app_16_motion_spec.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/theme/app_16_theme.dart';

Future<void> showApp16TextEditor(
  BuildContext context,
  DiaryController controller,
) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    barrierColor: App16Colors.sheetScrim,
    builder: (sheetContext) {
      final keyboard = MediaQuery.viewInsetsOf(sheetContext).bottom;
      return Padding(
        padding: EdgeInsets.only(
          left: 15,
          right: 15,
          bottom: keyboard > 0 ? keyboard + 16 : 110,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: _TextEditorSheet(controller: controller),
          ),
        ),
      );
    },
  );
  if (controller.editing) {
    controller.cancelEditor();
  }
}

class _TextEditorSheet extends StatefulWidget {
  const _TextEditorSheet({required this.controller});

  final DiaryController controller;

  @override
  State<_TextEditorSheet> createState() => _TextEditorSheetState();
}

class _TextEditorSheetState extends State<_TextEditorSheet> {
  late final TextEditingController _title;
  late final TextEditingController _note;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.controller.entry.title);
    _note = TextEditingController(text: widget.controller.entry.note);
    _title.addListener(_refresh);
    _note.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _title
      ..removeListener(_refresh)
      ..dispose();
    _note
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  bool get _valid =>
      _title.text.trim().isNotEmpty && _note.text.trim().isNotEmpty;

  void _submit() {
    if (!_valid) {
      return;
    }
    final applied = widget.controller.applyText(_title.text, _note.text);
    if (applied) {
      Navigator.of(context).pop();
    }
  }

  void _close() {
    widget.controller.cancelEditor();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return Container(
      constraints: BoxConstraints(maxHeight: height * 0.74),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: App16Colors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x30704458),
            offset: Offset(0, 10),
            blurRadius: 50,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Expanded(
                  child: Text(
                    '写一点今天',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: App16Colors.ink,
                    ),
                  ),
                ),
                App16Pressable(
                  onTap: _close,
                  semanticLabel: '关闭文字编辑',
                  child: const SizedBox(
                    width: 44,
                    height: 44,
                    child: Center(child: App16Icon(name: 'i-close', size: 20)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              '这一页的名字',
              style: TextStyle(fontSize: 13, color: App16Colors.muted),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _title,
              autofocus: true,
              maxLength: DiaryRules.maxTitleLength,
              maxLines: 1,
              inputFormatters: <TextInputFormatter>[
                LengthLimitingTextInputFormatter(DiaryRules.maxTitleLength),
              ],
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: App16Colors.ink,
              ),
              cursorColor: App16Colors.berry,
              decoration: _decoration('给今天起个名字'),
            ),
            const SizedBox(height: 14),
            const Text(
              '想记下的话',
              style: TextStyle(fontSize: 13, color: App16Colors.muted),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _note,
              minLines: 4,
              maxLines: 4,
              maxLength: DiaryRules.maxNoteLength,
              inputFormatters: <TextInputFormatter>[
                LengthLimitingTextInputFormatter(DiaryRules.maxNoteLength),
              ],
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: App16Colors.ink,
              ),
              cursorColor: App16Colors.berry,
              decoration: _decoration('今天发生了什么？'),
            ),
            const SizedBox(height: 10),
            AnimatedOpacity(
              opacity: _valid ? 1 : 0.55,
              duration: App16MotionSpec.motion(context, App16MotionSpec.press),
              child: App16Pressable(
                onTap: _valid ? _submit : null,
                semanticLabel: '写到纸上',
                child: Container(
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: App16Colors.berry,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text('写到纸上', style: App16Typography.primaryButton),
                      SizedBox(width: 6),
                      App16Icon(name: 'i-check', size: 16, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 15, color: App16Colors.muted),
      filled: true,
      fillColor: App16Colors.inputBg,
      counterText: '',
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: App16Colors.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: App16Colors.berry, width: 1.2),
      ),
    );
  }
}
