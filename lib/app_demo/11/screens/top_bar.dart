import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/11/models/photo_editor_state.dart';
import 'package:flutter_x_widgets/app_demo/11/utils/theme.dart';

/// Top header bar with title and action buttons
class TopBar extends StatelessWidget {
  final PhotoEditorState state;

  const TopBar({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.03)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          _IconButton(
            icon: Icons.chevron_left,
            onPressed: () {
              state.resetAll(); // 重置所有编辑状态
              Navigator.pop(context);
            },
          ),

          // Title
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add,
                color: PhotoEditorTheme.accentSecondary,
                size: 20,
                shadows: [
                  Shadow(color: PhotoEditorTheme.accentGlow, blurRadius: 8),
                ],
              ),
              SizedBox(width: 10),
              Text('LUMINAR', style: PhotoEditorTheme.titleStyle),
            ],
          ),

          // Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _IconButton(
                icon: Icons.refresh,
                onPressed: () => state.resetAll(),
              ),
              const SizedBox(width: 8),
              _IconButton(
                icon: Icons.upload_outlined,
                onPressed: () {
                  // Export action - implement as needed
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Styled icon button
class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _IconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Icon(icon, color: PhotoEditorTheme.textSecondary, size: 20),
        ),
      ),
    );
  }
}
