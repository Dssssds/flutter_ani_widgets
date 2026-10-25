import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/theme/app_15_theme.dart';

abstract final class PipToast {
  static void show(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    showWithMessenger(messenger, message);
  }

  static void showWithMessenger(ScaffoldMessengerState messenger, String message) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: App15Theme.ink,
          elevation: 0,
          duration: const Duration(milliseconds: 4300),
          margin: const EdgeInsets.only(left: 20, right: 20, bottom: 184),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Text(message, style: App15Theme.captionStyle.copyWith(color: App15Theme.paper, fontSize: 14, height: 1.5)),
        ),
      );
  }
}
