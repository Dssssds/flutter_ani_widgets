import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/15/models/root_tab.dart';
import 'package:flutter_x_widgets/app_demo/15/models/services/audio_service.dart';
import 'package:flutter_x_widgets/app_demo/15/models/services/share_service.dart';
import 'package:flutter_x_widgets/app_demo/15/models/view_models/pip_controller.dart';
import 'package:flutter_x_widgets/app_demo/15/screens/achievements_screen.dart';
import 'package:flutter_x_widgets/app_demo/15/screens/path_screen.dart';
import 'package:flutter_x_widgets/app_demo/15/screens/profile_screen.dart';
import 'package:flutter_x_widgets/app_demo/15/screens/review_hub_screen.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/common/pip_bottom_nav.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/theme/app_15_theme.dart';

class RootShell extends StatefulWidget {
  final PipController controller;
  final PipAudio audio;
  final PipShare share;

  const RootShell({super.key, required this.controller, required this.audio, required this.share});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  late RootTab _lastTab;

  PipController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _lastTab = controller.activeTab;
    controller.addListener(_handleControllerChange);
  }

  @override
  void dispose() {
    controller.removeListener(_handleControllerChange);
    super.dispose();
  }

  void _handleControllerChange() {
    final tab = controller.activeTab;
    if (tab == _lastTab) return;
    _lastTab = tab;
    unawaited(widget.audio.stop());
  }

  void _selectTab(RootTab tab) {
    if (tab == controller.activeTab) return;
    controller.setTab(tab);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Scaffold(
          key: const ValueKey('app-15-root'),
          backgroundColor: App15Theme.paper,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            bottom: false,
            child: IndexedStack(
              index: controller.activeTab.index,
              children: [
                PathScreen(controller: controller, audio: widget.audio),
                ReviewHubScreen(controller: controller, audio: widget.audio),
                AchievementsScreen(controller: controller, audio: widget.audio, share: widget.share),
                ProfileScreen(controller: controller),
              ],
            ),
          ),
          bottomNavigationBar: PipBottomNav(activeTab: controller.activeTab, onSelected: _selectTab),
        );
      },
    );
  }
}
