import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/14/models/view_models/settings_view_model.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/theme/party_theme.dart';

/// 两个设置弹层共用加载与可恢复错误提示。
class SettingsStatus extends StatelessWidget {
  final SettingsViewModel settings;

  const SettingsStatus({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    if (settings.isLoading) {
      return Semantics(liveRegion: true, child: const Text('正在读取设置…', style: TextStyle(color: PartyTheme.muted)));
    }
    final message = settings.errorMessage;
    if (message == null) return const SizedBox.shrink();
    return Semantics(
      liveRegion: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: const TextStyle(color: PartyTheme.muted)),
          TextButton(onPressed: settings.retrySave, child: const Text('重试保存')),
        ],
      ),
    );
  }
}
