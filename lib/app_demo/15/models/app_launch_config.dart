import 'package:flutter_x_widgets/app_demo/15/models/root_tab.dart';

class AppLaunchConfig {
  final RootTab initialTab;
  final bool demoCorrectFeedback;
  final bool demoComplete;
  final bool readOnlyDemo;
  final bool soundOn;

  const AppLaunchConfig({
    this.initialTab = RootTab.path,
    this.demoCorrectFeedback = false,
    this.demoComplete = false,
    this.readOnlyDemo = false,
    this.soundOn = false,
  });
}
