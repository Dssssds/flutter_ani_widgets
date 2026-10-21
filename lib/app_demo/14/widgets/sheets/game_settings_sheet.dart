import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/14/models/settings_state.dart';
import 'package:flutter_x_widgets/app_demo/14/models/view_models/settings_view_model.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/sheets/settings_status.dart';

class GameSettingsSheet extends StatelessWidget {
  final SettingsViewModel settings;
  const GameSettingsSheet({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ListenableBuilder(
          listenable: settings,
          builder:
              (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Expanded(child: Text('游戏设置', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700))),
                      IconButton(tooltip: '关闭设置', onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SettingsStatus(settings: settings),
                  const SizedBox(height: 24),
                  const Text('界面动画速度', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    children:
                        MotionSpeed.values
                            .map(
                              (speed) => ChoiceChip(
                                label: Text(speed == MotionSpeed.standard ? '标准' : '快速'),
                                selected: settings.state.motionSpeed == speed,
                                onSelected: (_) => settings.setMotionSpeed(speed),
                              ),
                            )
                            .toList(),
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('减少动态效果'),
                    subtitle: Text(MediaQuery.disableAnimationsOf(context) ? '系统已要求减少动态效果，始终优先生效。' : '使用短淡入，取消位移与按压缩放。'),
                    value: settings.state.reduceMotion,
                    onChanged: settings.setReduceMotion,
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('震动'),
                    subtitle: const Text('揭晓结果时提供轻触反馈。'),
                    value: settings.state.hapticsEnabled,
                    onChanged: settings.setHapticsEnabled,
                  ),
                ],
              ),
        ),
      ),
    );
  }
}
