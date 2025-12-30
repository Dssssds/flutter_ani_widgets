import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/11/models/photo_editor_state.dart';
import 'package:flutter_x_widgets/app_demo/11/utils/theme.dart';

/// Bottom tab navigation for switching panels
class BottomTabs extends StatelessWidget {
  final PhotoEditorState state;

  const BottomTabs({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 95,
      padding: const EdgeInsets.only(top: 15, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:
                EditorPanel.values.map((panel) {
                  final isActive = state.activePanel == panel;
                  return _TabItem(
                    icon: _getIconForPanel(panel),
                    label: _getLabelForPanel(panel),
                    isActive: isActive,
                    onTap: () => state.setActivePanel(panel),
                  );
                }).toList(),
          );
        },
      ),
    );
  }

  IconData _getIconForPanel(EditorPanel panel) {
    switch (panel) {
      case EditorPanel.enhance:
        return Icons.auto_fix_high;
      case EditorPanel.color:
        return Icons.palette_outlined;
      case EditorPanel.tone:
        return Icons.grid_on;
      case EditorPanel.structure:
        return Icons.layers_outlined;
      case EditorPanel.vignette:
        return Icons.vignette;
    }
  }

  String _getLabelForPanel(EditorPanel panel) {
    switch (panel) {
      case EditorPanel.enhance:
        return 'Enhance';
      case EditorPanel.color:
        return 'Color';
      case EditorPanel.tone:
        return 'Tone';
      case EditorPanel.structure:
        return 'Structure';
      case EditorPanel.vignette:
        return 'Vignette';
    }
  }
}

/// Individual tab item
class _TabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: 65,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color:
                    isActive
                        ? PhotoEditorTheme.accentPrimary.withOpacity(0.15)
                        : Colors.transparent,
                boxShadow:
                    isActive
                        ? [
                          BoxShadow(
                            color: PhotoEditorTheme.accentPrimary.withOpacity(
                              0.2,
                            ),
                            blurRadius: 20,
                          ),
                        ]
                        : null,
              ),
              child: Icon(
                icon,
                size: 24,
                color:
                    isActive
                        ? PhotoEditorTheme.accentPrimary
                        : PhotoEditorTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            // Label
            Text(
              label,
              style: PhotoEditorTheme.labelStyle.copyWith(
                color:
                    isActive
                        ? PhotoEditorTheme.textPrimary
                        : PhotoEditorTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
