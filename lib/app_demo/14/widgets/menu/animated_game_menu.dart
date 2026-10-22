import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_x_widgets/app_demo/14/models/game_definition.dart';
import 'package:flutter_x_widgets/app_demo/14/models/view_models/settings_view_model.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/game_menu_tile.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/menu/menu_motion.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/menu/menu_band_shape.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/menu/menu_page_physics.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/motion/motion_spec.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/theme/party_theme.dart';

/// 分页物理交给 PageView，各行补偿整页位移后共享一条级联轨迹。
class AnimatedGameMenu extends StatefulWidget {
  final SettingsViewModel settings;
  final WidgetBuilder headerBuilder;
  final ValueNotifier<int>? visits;
  final ValueChanged<String?> onOpen;

  const AnimatedGameMenu({super.key, required this.settings, required this.headerBuilder, required this.onOpen, this.visits});

  @override
  State<AnimatedGameMenu> createState() => _AnimatedGameMenuState();
}

class _AnimatedGameMenuState extends State<AnimatedGameMenu> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _pages = PageController();
  late final _enter = AnimationController(vsync: this, animationBehavior: AnimationBehavior.preserve);
  Drag? _headerDrag;
  int _page = 0;
  bool _started = false;
  bool _reduced = false;
  Size? _size;
  final _vertical = [ScrollController(), ScrollController()];
  static const _iconAssets = {
    'headbands': 'assets/images/14/headbands.png',
    'truth-dare': 'assets/images/14/truth_or_dare.png',
    'bottle': 'assets/images/14/spin_the_bottle.png',
    'charades': 'assets/images/14/charades.png',
    'would-rather': 'assets/images/14/would_you_rather.png',
    'dice': 'assets/images/14/dice.png',
    'coin': 'assets/images/14/coin_toss.png',
    'pick': 'assets/images/14/pick_one.png',
    'elimination': 'assets/images/14/elimination.png',
    'teams': 'assets/images/14/random-team.png',
  };
  static const _icons = [
    Icons.style_outlined,
    Icons.local_fire_department_outlined,
    Icons.explore_outlined,
    Icons.theater_comedy_outlined,
    Icons.call_split_rounded,
    Icons.casino_outlined,
    Icons.toll_rounded,
    Icons.person_search_outlined,
    Icons.remove_circle_outline,
    Icons.groups_outlined,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.visits?.addListener(_replay);
  }

  @override
  void didUpdateWidget(AnimatedGameMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visits != widget.visits) {
      oldWidget.visits?.removeListener(_replay);
      widget.visits?.addListener(_replay);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final motion = MotionSpec.of(context, widget.settings.state);
    final size = MediaQuery.sizeOf(context);
    final changedSize = _size != null && _size != size;
    final newlyReduced = !_reduced && motion.reduceMotion;
    _size = size;
    _reduced = motion.reduceMotion;
    if (!_started) {
      _started = true;
      _enter.duration = motion.menuEnter;
      _enter.forward();
    } else if (changedSize || newlyReduced) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _settle();
      });
    }
  }

  void _replay() {
    if (!mounted) return;
    _enter.duration = MotionSpec.of(context, widget.settings.state).menuEnter;
    _enter.forward(from: 0);
  }

  void _settle() {
    _headerDrag?.cancel();
    _headerDrag = null;
    _enter.value = 1;
    if (_pages.hasClients) _pages.jumpToPage(_page);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _settle();
  }

  void _changePage(int delta) {
    if (!_pages.hasClients) return;
    _enter.value = 1;
    final target = (_page + delta).clamp(0, 1);
    final motion = MotionSpec.of(context, widget.settings.state);
    if (motion.reduceMotion) {
      _pages.jumpToPage(target);
    } else {
      _pages.animateToPage(target, duration: motion.page, curve: Curves.easeOutCubic);
    }
  }

  bool _scroll(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.horizontal) {
      if (notification is ScrollStartNotification) _enter.value = 1;
      return false;
    }
    if (notification is ScrollStartNotification) {
      _enter.value = 1;
      final source = _vertical[_page];
      final target = _vertical[1 - _page];
      if (source.hasClients && target.hasClients) {
        target.jumpTo(source.offset.clamp(target.position.minScrollExtent, target.position.maxScrollExtent));
      }
    } else if (notification is ScrollEndNotification) {
      final value = _pages.page ?? _page.toDouble();
      if ((value - value.round()).abs() < 0.001) {
        setState(() => _page = value.round());
      }
    }
    return false;
  }

  @override
  void dispose() {
    widget.visits?.removeListener(_replay);
    WidgetsBinding.instance.removeObserver(this);
    _headerDrag?.cancel();
    _enter.dispose();
    _pages.dispose();
    for (final scroll in _vertical) {
      scroll.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final motion = MotionSpec.of(context, widget.settings.state);
    // 应用内设置也能在不重播入场的情况下立即关闭位移。
    final reduced = motion.reduceMotion;
    return LayoutBuilder(
      builder: (context, available) {
        final scaler = MediaQuery.textScalerOf(context);
        final safe = MediaQuery.paddingOf(context);
        // 文字宽度必须与 GameMenuTile 的真实布局一致：两侧内边距、图标、间距，以及最宽的「未开放」标签（约 68）。
        final textWidth = (available.maxWidth - (136 + GameMenuTile.iconExtent) - safe.horizontal).clamp(1.0, double.infinity);
        var rowHeight = 104.0;
        double measure(String text, String family, double size, double height, FontWeight weight) {
          final painter = TextPainter(
            text: TextSpan(text: text, style: TextStyle(fontFamily: family, fontSize: size, height: height, fontWeight: weight)),
            textDirection: TextDirection.ltr,
            textScaler: scaler,
          )..layout(maxWidth: textWidth);
          final result = painter.height;
          painter.dispose();
          return result;
        }

        for (final game in partyGames) {
          final height =
              measure(game.title, PartyTheme.displayFamily, 24, 1.05, FontWeight.w400) +
              measure(game.subtitle, PartyTheme.bodyFamily, 14, 1.5, FontWeight.w600) +
              28;
          if (height > rowHeight) rowHeight = height;
        }
        final bottomInset = safe.bottom;
        final headerHeight = (available.maxHeight - rowHeight * 5 - bottomInset)
            .clamp(80.0, double.infinity)
            .clamp(0.0, available.maxHeight);
        return CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _changePage(-1),
            const SingleActivator(LogicalKeyboardKey.arrowRight): () => _changePage(1),
          },
          child: Focus(
            autofocus: true,
            child: Semantics(
              label: '第${_page + 1}页，共2页',
              onScrollLeft: _page < 1 ? () => _changePage(1) : null,
              onScrollRight: _page > 0 ? () => _changePage(-1) : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    key: const ValueKey('menu-header'),
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragStart: (details) {
                      _enter.value = 1;
                      if (_pages.hasClients) {
                        _headerDrag = _pages.position.drag(details, () => _headerDrag = null);
                      }
                    },
                    onHorizontalDragUpdate: (details) => _headerDrag?.update(details),
                    onHorizontalDragEnd: (details) => _headerDrag?.end(details),
                    onHorizontalDragCancel: () => _headerDrag?.cancel(),
                    child: SizedBox(
                      height: headerHeight,
                      child: widget.headerBuilder(context),
                    ),
                  ),
                  Expanded(
                    child: ClipRect(
                      key: const ValueKey('menu-viewport'),
                      child: NotificationListener<ScrollNotification>(
                        onNotification: _scroll,
                        child: PageView(
                          key: const ValueKey('menu-pages'),
                          controller: _pages,
                          clipBehavior: Clip.none,
                          allowImplicitScrolling: true,
                          pageSnapping: false,
                          physics: MenuPagePhysics(duration: motion.page, parent: const ClampingScrollPhysics()),
                          children: List.generate(
                            2,
                            (page) => LayoutBuilder(
                              builder: (context, constraints) {
                                final topInset = (constraints.maxHeight - rowHeight * 5 - bottomInset).clamp(0.0, double.infinity);
                                return ListView.builder(
                                  key: PageStorageKey('game-page-$page'),
                                  controller: _vertical[page],
                                  padding: EdgeInsets.only(top: topInset),
                                  clipBehavior: Clip.none,
                                  cacheExtent: 10000,
                                  itemCount: 5,
                                  itemBuilder: (context, index) {
                                    final gameIndex = page * 5 + index;
                                    final game = partyGames[gameIndex];
                                    final safe = MediaQuery.paddingOf(context);
                                    final tile = GameMenuTile(
                                      key: ValueKey(game.id),
                                      game: game,
                                      color: PartyTheme.menuColor(page, index),
                                      icon: _icons[gameIndex],
                                      iconAsset: _iconAssets[game.id],
                                      motion: motion,
                                      seamless: true,
                                      edge: index == 0 ? MenuBandEdge.rising : (index == 3 ? MenuBandEdge.falling : MenuBandEdge.straight),
                                      nextColor: index < 4 ? PartyTheme.menuColor(page, index + 1) : null,
                                      contentPadding: EdgeInsets.only(
                                        left: safe.left,
                                        right: safe.right,
                                        bottom: index == 4 ? bottomInset : 0,
                                      ),
                                      onPressed: () {
                                        if (_enter.isCompleted && page == _page && !_pages.position.isScrollingNotifier.value) {
                                          widget.onOpen(game.route);
                                        }
                                      },
                                    );
                                    return AnimatedBuilder(
                                      animation: Listenable.merge([_enter, _pages]),
                                      child: SizedBox(height: rowHeight + (index == 4 ? bottomInset : 0), child: tile),
                                      builder: (context, child) {
                                        final p =
                                            _pages.hasClients && _pages.position.hasContentDimensions ? _pages.page ?? 0 : _page.toDouble();
                                        final moving =
                                            (p - p.round()).abs() > 0.0001 ||
                                            (_pages.hasClients && _pages.position.isScrollingNotifier.value);
                                        final rowProgress = reduced ? p.roundToDouble() : MenuMotion.rowProgress(p, index);
                                        final compensation = constraints.maxWidth * (p - rowProgress);
                                        final scroll = _vertical[page].hasClients ? _vertical[page].offset : 0.0;
                                        final rowTop = topInset + index * rowHeight - scroll;
                                        final distance = (constraints.maxHeight - rowTop).clamp(0.0, double.infinity) + 24;
                                        final dy = reduced ? 0.0 : MenuMotion.enterOffset(_enter.value, index, distance);
                                        final visible = !moving && page == _page && _enter.isCompleted;
                                        return Transform.translate(
                                          key: ValueKey('menu-row-$page-$index'),
                                          offset: Offset(compensation, dy),
                                          child: IgnorePointer(
                                            ignoring: !visible,
                                            child: ExcludeSemantics(
                                              excluding: !visible,
                                              child: ExcludeFocus(
                                                excluding: !visible,
                                                child: Opacity(opacity: reduced ? _enter.value : 1, child: child),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
