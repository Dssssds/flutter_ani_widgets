import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/common/pip_icon_button.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/theme/app_15_theme.dart';

class PipScreenHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final String backSemanticsLabel;

  const PipScreenHeader({super.key, required this.title, required this.onBack, this.backSemanticsLabel = '返回学习路径'});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 69,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 25, 24, 0),
        child: Row(
          children: [
            PipIconButton(icon: 'back', semanticsLabel: backSemanticsLabel, onPressed: onBack),
            const SizedBox(width: 12),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: App15Theme.pathTitleStyle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
