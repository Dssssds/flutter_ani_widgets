import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/11/models/photo_editor_state.dart';
import 'package:flutter_x_widgets/app_demo/11/screens/preview_area.dart';
import 'package:flutter_x_widgets/app_demo/11/screens/tools_area.dart';
import 'package:flutter_x_widgets/app_demo/11/utils/theme.dart';

class HomePage extends StatefulWidget {
  final ImageProvider imageProvider;
  const HomePage({super.key, required this.imageProvider});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PhotoEditorState _state;

  @override
  void initState() {
    super.initState();
    _state = PhotoEditorState();
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PhotoEditorTheme.bgPanel,
      body: SafeArea(
        child: Column(
          children: [
            // Preview Area (takes remaining space)
            Expanded(
              child: PreviewArea(
                imageProvider: widget.imageProvider,
                state: _state,
              ),
            ),

            // Tools Area (fixed height)
            ToolsArea(state: _state),
          ],
        ),
      ),
    );
  }
}
