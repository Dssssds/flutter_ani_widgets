import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/16/models/repositories/diary_repository.dart';
import 'package:flutter_x_widgets/app_demo/16/models/repositories/seed_repository.dart';
import 'package:flutter_x_widgets/app_demo/16/models/services/photo_service.dart';
import 'package:flutter_x_widgets/app_demo/16/models/view_models/diary_controller.dart';
import 'package:flutter_x_widgets/app_demo/16/screens/root_shell.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/theme/app_16_theme.dart';

class App16 extends StatefulWidget {
  const App16({super.key, this.controller});

  final DiaryController? controller;

  @override
  State<App16> createState() => _App16State();
}

class _App16State extends State<App16> {
  late final DiaryController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller =
        widget.controller ??
        DiaryController(
          repository: const SharedPreferencesDiaryRepository(),
          seeds: const AssetSeedRepository(),
          photos: GalleryPhotoService(),
        );
    _controller.initialize();
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '拾页',
      theme: App16Theme.theme,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(
              minScaleFactor: 0.9,
              maxScaleFactor: 1.2,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: RootShell(controller: _controller),
    );
  }
}
