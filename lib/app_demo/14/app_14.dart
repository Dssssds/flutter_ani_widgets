import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/14/models/repositories/settings_repository.dart';
import 'package:flutter_x_widgets/app_demo/14/models/services/random_source.dart';
import 'package:flutter_x_widgets/app_demo/14/models/services/feedback_service.dart';
import 'package:flutter_x_widgets/app_demo/14/models/view_models/settings_view_model.dart';
import 'package:flutter_x_widgets/app_demo/14/screens/navigation/demo_routes.dart';
import 'package:flutter_x_widgets/app_demo/14/screens/navigation/menu_route_observer.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/motion/motion_spec.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/theme/party_theme.dart';

class App14 extends StatefulWidget {
  final SettingsRepository? settingsRepository;
  final RandomSource? random;
  final FeedbackService? feedback;

  const App14({super.key, this.settingsRepository, this.random, this.feedback});

  @override
  State<App14> createState() => _App14State();
}

class _App14State extends State<App14> {
  late final _settings = SettingsViewModel(repository: widget.settingsRepository ?? SettingsRepository());
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await _settings.initialize();
    if (mounted) setState(() => _loaded = true);
  }

  final _navigatorKey = GlobalKey<NavigatorState>();
  final _menuObserver = MenuRouteObserver();
  final _canPop = ValueNotifier(false);
  late final _observer = _DemoNavigationObserver(() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _canPop.value = _navigatorKey.currentState?.canPop() ?? false;
    });
  });

  @override
  void dispose() {
    _menuObserver.dispose();
    _settings.dispose();
    _canPop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return MaterialApp(
        theme: PartyTheme.theme,
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: Semantics(label: '正在读取游戏设置', child: const CircularProgressIndicator()))),
      );
    }
    final host = Navigator.maybeOf(context);
    final canExit = host?.canPop() ?? false;
    void exit() {
      if (mounted && host != null && host.canPop()) host.pop();
    }

    return ValueListenableBuilder<bool>(
      valueListenable: _canPop,
      builder:
          (context, canPop, _) => PopScope(
            canPop: !canPop,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop && canPop) _navigatorKey.currentState?.maybePop();
            },
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              // 需要将这个 title 的内容换成英文的
              title: 'Party Game Box',
              theme: PartyTheme.theme,
              navigatorKey: _navigatorKey,
              navigatorObservers: [_observer, _menuObserver],
              onGenerateRoute:
                  (route) => DemoRoutes.create(
                    route,
                    _settings,
                    MotionSpec(_settings.state, systemReduceMotion: MediaQuery.maybeOf(context)?.disableAnimations ?? false),
                    canExit ? exit : null,
                    menuVisits: _menuObserver.visits,
                    random: widget.random,
                    feedback: widget.feedback,
                  ),
            ),
          ),
    );
  }
}

class _DemoNavigationObserver extends NavigatorObserver {
  final VoidCallback onChanged;
  _DemoNavigationObserver(this.onChanged);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => onChanged();

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => onChanged();
}
