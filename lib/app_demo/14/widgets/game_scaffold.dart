import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/theme/party_theme.dart';

class GameScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onAppearance;

  const GameScaffold({super.key, required this.title, required this.child, required this.onAppearance});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(tooltip: '关闭游戏', onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
                      Expanded(
                        child: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                      ),
                      IconButton(
                        tooltip: '游戏外观',
                        onPressed: onAppearance,
                        icon: const Icon(Icons.palette_outlined, color: PartyTheme.muted),
                      ),
                    ],
                  ),
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
