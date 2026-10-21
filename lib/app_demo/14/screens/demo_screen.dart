import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/14/models/view_models/settings_view_model.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/menu/animated_game_menu.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/menu/menu_header.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/menu/menu_meteor_background.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/motion/motion_spec.dart';

class DemoScreen extends StatefulWidget {
  final SettingsViewModel settings;
  final VoidCallback? onExit;
  final ValueNotifier<int>? menuVisits;
  const DemoScreen({super.key, required this.settings, this.onExit, this.menuVisits});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  bool _opening = false;

  Future<void> _open(String? route) async {
    if (route == null || _opening) return;
    _opening = true;
    try {
      await Navigator.of(context).pushNamed(route);
    } finally {
      if (mounted) _opening = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.settings,
      builder:
          (context, _) => Scaffold(
            body: SafeArea(
              left: false,
              right: false,
              bottom: false,
              child: AnimatedGameMenu(
                settings: widget.settings,
                visits: widget.menuVisits,
                onOpen: _open,
                headerBuilder:
                    (context, pageProgress) => Stack(
                      fit: StackFit.expand,
                      children: [
                        MenuMeteorBackground(
                          enabled: (ModalRoute.isCurrentOf(context) ?? true) && !MotionSpec.of(context, widget.settings.state).reduceMotion,
                        ),
                        SafeArea(
                          top: false,
                          bottom: false,
                          child: MenuHeader(
                            pageProgress: pageProgress,
                            onExit: widget.onExit,
                            reduceMotion: widget.settings.state.reduceMotion,
                          ),
                        ),
                      ],
                    ),
              ),
            ),
          ),
    );
  }
}
