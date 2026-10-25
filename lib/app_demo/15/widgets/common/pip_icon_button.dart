import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/common/pip_icon.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/theme/app_15_theme.dart';

class PipIconButton extends StatelessWidget {
  final String icon;
  final String semanticsLabel;
  final VoidCallback? onPressed;
  final double size;
  final Color color;

  const PipIconButton({
    super.key,
    required this.icon,
    required this.semanticsLabel,
    required this.onPressed,
    this.size = 24,
    this.color = App15Theme.ink,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      enabled: onPressed != null,
      label: semanticsLabel,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPressed,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Center(child: PipIcon(asset: 'assets/images/15/icons/$icon.svg', size: size, color: color)),
          ),
        ),
      ),
    );
  }
}
