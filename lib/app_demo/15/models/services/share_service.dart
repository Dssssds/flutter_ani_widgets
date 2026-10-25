import 'package:share_plus/share_plus.dart';

abstract class PipShare {
  Future<bool> shareText(String text);
}

class SystemPipShare implements PipShare {
  const SystemPipShare();

  @override
  Future<bool> shareText(String text) async {
    try {
      final result = await SharePlus.instance.share(ShareParams(text: text, title: 'Pip 成就'));
      return result.status != ShareResultStatus.unavailable;
    } catch (_) {
      return false;
    }
  }
}
