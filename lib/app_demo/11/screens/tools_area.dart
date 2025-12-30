import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/11/models/photo_editor_state.dart';
import 'package:flutter_x_widgets/app_demo/11/utils/theme.dart';
import 'package:flutter_x_widgets/app_demo/11/widgets/color_panel.dart';
import 'package:flutter_x_widgets/app_demo/11/widgets/enhancer_panel.dart';
import 'package:flutter_x_widgets/app_demo/11/widgets/structure_panel.dart';
import 'package:flutter_x_widgets/app_demo/11/widgets/tone_panel.dart';
import 'package:flutter_x_widgets/app_demo/11/widgets/vignette_panel.dart';

import 'bottom_tabs.dart';
import 'top_bar.dart';

/// Container for all tool panels and navigation
class ToolsArea extends StatelessWidget {
  final PhotoEditorState state;

  const ToolsArea({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(PhotoEditorTheme.radiusPanel),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: PhotoEditorTheme.glassBlur,
          sigmaY: PhotoEditorTheme.glassBlur,
        ),
        child: Container(
          height: 350,
          decoration: BoxDecoration(
            color: PhotoEditorTheme.bgPanel,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(PhotoEditorTheme.radiusPanel),
            ),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.7),
                blurRadius: 50,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Top Bar
              TopBar(state: state),

              // Panel Container
              Expanded(
                child: ListenableBuilder(
                  listenable: state,
                  builder: (context, _) {
                    return IndexedStack(
                      index: state.activePanel.index,
                      children: [
                        EnhancerPanel(state: state),
                        ColorPanel(state: state),
                        TonePanel(state: state),
                        StructurePanel(state: state),
                        VignettePanel(state: state),
                      ],
                    );
                  },
                ),
              ),

              // Bottom Tabs
              BottomTabs(state: state),
            ],
          ),
        ),
      ),
    );
  }
}
