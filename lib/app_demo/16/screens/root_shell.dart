import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_x_widgets/app_demo/16/data/asset_manifest.dart';
import 'package:flutter_x_widgets/app_demo/16/models/app_screen.dart';
import 'package:flutter_x_widgets/app_demo/16/models/material.dart';
import 'package:flutter_x_widgets/app_demo/16/models/placed_item.dart';
import 'package:flutter_x_widgets/app_demo/16/models/view_models/diary_controller.dart';
import 'package:flutter_x_widgets/app_demo/16/screens/journal_screen.dart';
import 'package:flutter_x_widgets/app_demo/16/screens/material_drawer_screen.dart';
import 'package:flutter_x_widgets/app_demo/16/screens/month_screen.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/common/app_16_bottom_nav.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/common/app_16_icon.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/common/app_16_toast.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/motion/app_16_motion_spec.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/theme/app_16_theme.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/theme/design_tokens.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key, required this.controller});

  final DiaryController controller;

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell>
    with SingleTickerProviderStateMixin {
  final GlobalKey _paperKey = GlobalKey();
  final GlobalKey _contentKey = GlobalKey();
  late final AnimationController _flight;
  FlyingRequest? _activeFlight;

  DiaryController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _flight = AnimationController(
      vsync: this,
      duration: App16MotionSpec.stickerFlight,
    );
    _flight.addStatusListener(_onFlightStatus);
    controller.paperRectProvider = _paperRect;
    controller.addListener(_onControllerChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller.reduceMotion = MediaQuery.disableAnimationsOf(context);
  }

  Rect? _paperRect() {
    final context = _paperKey.currentContext;
    if (context == null) {
      return null;
    }
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      return null;
    }
    return box.localToGlobal(Offset.zero) & box.size;
  }

  void _onControllerChanged() {
    final request = controller.flyingRequest;
    if (request == null) {
      _activeFlight = null;
      return;
    }
    if (!identical(_activeFlight, request)) {
      _activeFlight = request;
      if (controller.reduceMotion) {
        controller.finishFlying();
      } else {
        _flight.forward(from: 0);
      }
    }
  }

  void _onFlightStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      controller.finishFlying();
    }
  }

  @override
  void dispose() {
    controller.removeListener(_onControllerChanged);
    if (controller.paperRectProvider == _paperRect) {
      controller.paperRectProvider = null;
    }
    _flight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            constraints.maxWidth < App16Design.frameWidth
                ? constraints.maxWidth
                : App16Design.frameWidth;
        final height = constraints.maxHeight;
        final media = MediaQuery.of(context);
        return Scaffold(
          body: Center(
            child: SizedBox(
              width: width,
              height: height,
              child: MediaQuery(
                data: media.copyWith(size: Size(width, height)),
                child: Material(
                  color: App16Colors.appBg,
                  child: AnnotatedRegion<SystemUiOverlayStyle>(
                    value: SystemUiOverlayStyle.dark,
                    child: SafeArea(
                      bottom: false,
                      child: AnimatedBuilder(
                        animation: Listenable.merge(<Listenable>[
                          controller,
                          _flight,
                        ]),
                        builder: (context, _) {
                          if (controller.loading) {
                            return const ColoredBox(
                              color: App16Colors.appBg,
                              child: SizedBox.expand(),
                            );
                          }
                          if (!controller.ready) {
                            return _LoadError(message: controller.loadError);
                          }
                          return _buildContent(context, width);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, double width) {
    final metrics = App16Metrics(
      Size(width, MediaQuery.sizeOf(context).height),
      bottomInset: MediaQuery.paddingOf(context).bottom,
    );
    final flight = _activeFlight;
    Rect? flightFrom;
    Rect? flightTarget;
    if (flight != null) {
      final box = _contentKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        flightFrom = box.globalToLocal(flight.from.topLeft) & flight.from.size;
        flightTarget =
            box.globalToLocal(flight.target.topLeft) & flight.target.size;
      }
    }
    return PopScope(
      canPop: controller.screen == AppScreen.journal,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && controller.screen != AppScreen.journal) {
          controller.goJournal();
        }
      },
      child: Stack(
        key: _contentKey,
        children: <Widget>[
          IndexedStack(
            index: controller.screen.index,
            children: <Widget>[
              JournalScreen(controller: controller, paperKey: _paperKey),
              MaterialDrawerScreen(controller: controller),
              MonthScreen(controller: controller),
            ],
          ),
          if (flight != null)
            _FlyingSticker(
              animation: _flight,
              item: flight.item,
              from: flightFrom ?? flight.from,
              target: flightTarget ?? flight.target,
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: App16BottomNav(
              current: controller.screen,
              height: metrics.navHeight,
              onSelect: (screen) {
                switch (screen) {
                  case AppScreen.journal:
                    controller.goJournal();
                    break;
                  case AppScreen.drawer:
                    controller.openDrawer(MaterialCategory.sticker);
                    break;
                  case AppScreen.month:
                    controller.goMonth();
                    break;
                }
              },
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 177,
            child: App16Toast(message: controller.toast),
          ),
        ],
      ),
    );
  }
}

class _FlyingSticker extends StatelessWidget {
  const _FlyingSticker({
    required this.animation,
    required this.item,
    required this.from,
    required this.target,
  });

  final Animation<double> animation;
  final PlacedItem item;
  final Rect from;
  final Rect target;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value;
        final start = from.center - const Offset(41.5, 41.5);
        final end = target.topLeft;
        final mid = Offset(
          start.dx + (end.dx - start.dx) * 0.5,
          start.dy + (end.dy - start.dy) * 0.5 - 44,
        );
        final Offset position;
        final double rotation;
        final double scale;
        if (t < 0.5) {
          final p = t / 0.5;
          position = Offset.lerp(start, mid, p)!;
          rotation = -15 * p;
          scale = 1 + 0.12 * p;
        } else {
          final p = (t - 0.5) / 0.5;
          position = Offset.lerp(mid, end, p)!;
          rotation = -15 + 6 * p;
          scale = 1.12 - 0.12 * p;
        }
        return Positioned(
          left: position.dx,
          top: position.dy,
          child: IgnorePointer(
            child: Transform.rotate(
              angle: rotation * 3.141592653589793 / 180,
              child: Transform.scale(
                scale: scale,
                child: SizedBox(
                  key: const ValueKey<String>('app16-flying-sticker'),
                  width: 83,
                  height: 83,
                  child: App16Svg(
                    src: item.src ?? App16Assets.sticker('flower'),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Text(
          message.isEmpty ? '这一页暂时打不开，请重新进入。' : message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            height: 1.6,
            color: App16Colors.errorInk,
          ),
        ),
      ),
    );
  }
}
