import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/15/data/demo_state.dart';
import 'package:flutter_x_widgets/app_demo/15/models/app_launch_config.dart';
import 'package:flutter_x_widgets/app_demo/15/models/repositories/pip_repository.dart';
import 'package:flutter_x_widgets/app_demo/15/models/services/audio_service.dart';
import 'package:flutter_x_widgets/app_demo/15/models/services/clock.dart';
import 'package:flutter_x_widgets/app_demo/15/models/services/share_service.dart';
import 'package:flutter_x_widgets/app_demo/15/models/view_models/pip_controller.dart';
import 'package:flutter_x_widgets/app_demo/15/screens/complete_screen.dart';
import 'package:flutter_x_widgets/app_demo/15/screens/quiz_screen.dart';
import 'package:flutter_x_widgets/app_demo/15/screens/root_shell.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/common/pip_frame.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/common/pip_toast.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/theme/app_15_theme.dart';

class App15 extends StatefulWidget {
  final PipRepository? repository;
  final Clock? clock;
  final PipAudio? audio;
  final PipShare? share;
  final AppLaunchConfig config;

  const App15({super.key, this.repository, this.clock, this.audio, this.share, this.config = const AppLaunchConfig()});

  @override
  State<App15> createState() => _App15State();
}

class _App15State extends State<App15> {
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final PipController _controller;
  late final PipAudio _audio;
  late final PipShare _share;
  late final bool _ownsAudio;

  @override
  void initState() {
    super.initState();
    _ownsAudio = widget.audio == null;
    _audio = widget.audio ?? DevicePipAudio();
    _share = widget.share ?? const SystemPipShare();
    _controller = PipController(
      repository: widget.repository ?? PipRepository(),
      clock: widget.clock ?? const SystemClock(),
      readOnlyDemo: widget.config.readOnlyDemo,
      initialTab: widget.config.initialTab,
      soundOn: widget.config.soundOn ? true : null,
    );
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    await _controller.initialize();
    if (!mounted) return;

    final warning = _controller.takeLoadWarning();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final messenger = _messengerKey.currentState;
      if (warning != null && messenger != null) PipToast.showWithMessenger(messenger, warning);
      _openDemoRoute();
    });
  }

  void _openDemoRoute() {
    final config = widget.config;
    if (!config.demoCorrectFeedback && !config.demoComplete) return;
    final navigator = _navigatorKey.currentState;
    if (navigator == null) return;

    if (config.demoCorrectFeedback) {
      _controller.prepareDemoCorrectFeedback();
      navigator.push(MaterialPageRoute<void>(builder: (_) => QuizScreen(controller: _controller, audio: _audio)));
      return;
    }

    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => CompleteScreen(controller: _controller, audio: _audio, result: createDemoResult(_controller.state)),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    if (_ownsAudio) {
      unawaited(_audio.dispose());
    } else {
      unawaited(_audio.stop());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pip 英语学习',
      theme: App15Theme.theme,
      scaffoldMessengerKey: _messengerKey,
      navigatorKey: _navigatorKey,
      home: PipFrame(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            if (!_controller.initialized) return const _PipLoadingView();
            return RootShell(controller: _controller, audio: _audio, share: _share);
          },
        ),
      ),
    );
  }
}

class _PipLoadingView extends StatelessWidget {
  const _PipLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      key: ValueKey('app-15-loading'),
      backgroundColor: App15Theme.paper,
      body: Center(child: SizedBox(width: 32, height: 32, child: CircularProgressIndicator(color: App15Theme.yellow, strokeWidth: 3))),
    );
  }
}
