import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/14/models/settings_state.dart';
import 'package:flutter_x_widgets/app_demo/14/models/view_models/settings_view_model.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/sheets/settings_status.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/theme/party_theme.dart';

class AppearanceSheet extends StatelessWidget {
  final SettingsViewModel settings;
  const AppearanceSheet({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ListenableBuilder(
          listenable: settings,
          builder:
              (context, _) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Expanded(child: Text('游戏外观', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700))),
                      IconButton(tooltip: '关闭外观', onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('立即应用到硬币与游戏界面。', style: TextStyle(color: PartyTheme.muted)),
                  SettingsStatus(settings: settings),
                  const SizedBox(height: 24),
                  for (final appearance in CoinAppearance.values)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Semantics(
                        selected: settings.state.appearance == appearance,
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: BorderSide(
                              color: settings.state.appearance == appearance ? PartyTheme.coinColors(appearance).first : Colors.white24,
                            ),
                          ),
                          minTileHeight: 64,
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(colors: PartyTheme.coinColors(appearance)),
                            ),
                          ),
                          title: Text(PartyTheme.appearanceName(appearance)),
                          trailing: settings.state.appearance == appearance ? const Icon(Icons.check_circle_outline) : null,
                          onTap: () => settings.setAppearance(appearance),
                        ),
                      ),
                    ),
                ],
              ),
        ),
      ),
    );
  }
}
