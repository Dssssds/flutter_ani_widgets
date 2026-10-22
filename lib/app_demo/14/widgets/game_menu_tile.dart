import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/14/models/game_definition.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/motion/motion_spec.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/menu/menu_band_shape.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/press_scale_button.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/theme/party_theme.dart';

class GameMenuTile extends StatelessWidget {
  final GameDefinition game;
  final Color color;
  final IconData icon;
  final String? iconAsset;

  static const iconExtent = 56.0;
  final MotionSpec motion;
  final VoidCallback? onPressed;
  final bool seamless;
  final MenuBandEdge edge;
  final Color? nextColor;

  /// Additional safe-area padding for content only, never the color band.
  final EdgeInsets contentPadding;

  const GameMenuTile({
    super.key,
    required this.game,
    required this.color,
    required this.icon,
    required this.motion,
    this.iconAsset,
    this.onPressed,
    this.seamless = false,
    this.edge = MenuBandEdge.straight,
    this.nextColor,
    this.contentPadding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = seamless ? BorderRadius.zero : BorderRadius.circular(18);
    final tile = PressScaleButton(
      borderRadius: borderRadius,
      pressScale: seamless ? 1 : 0.97,
      label: '${game.title}，${game.isAvailable ? '开始游戏' : '未开放'}',
      motion: motion,
      onPressed: game.isAvailable ? onPressed : null,
      child: Ink(
        decoration: BoxDecoration(color: color, borderRadius: borderRadius),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: seamless ? 22 : 18, vertical: seamless ? 12 : 16) + contentPadding,
          child: Row(
            children: [
              SizedBox.square(
                dimension: iconExtent,
                child:
                    iconAsset == null
                        ? Icon(icon, size: 40, color: PartyTheme.ink)
                        : Image.asset(
                          iconAsset!,
                          width: iconExtent,
                          height: iconExtent,
                          fit: BoxFit.contain,
                          excludeFromSemantics: true,
                          errorBuilder: (context, error, stackTrace) => Icon(icon, size: 40, color: PartyTheme.ink),
                        ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.title,
                      style: const TextStyle(
                        fontFamily: PartyTheme.displayFamily,
                        fontSize: 24,
                        height: 1.05,
                        fontWeight: FontWeight.w400,
                        color: PartyTheme.ink,
                      ),
                    ),
                    SizedBox(height: seamless ? 4 : 6),
                    Text(game.subtitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: PartyTheme.ink)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (game.isAvailable)
                const Icon(Icons.arrow_outward_rounded, size: 20, color: PartyTheme.ink)
              else
                // 未开放用文字标签说明原因，不用锁图标，避免被误读为可解锁。
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: PartyTheme.ink.withValues(alpha: .6), width: 1.5),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Text('未开放', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: PartyTheme.ink)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (edge == MenuBandEdge.straight) return tile;
    return Stack(
      fit: StackFit.expand,
      children: [IgnorePointer(child: ColoredBox(color: nextColor ?? color)), ClipPath(clipper: MenuBandClipper(edge: edge), child: tile)],
    );
  }
}
