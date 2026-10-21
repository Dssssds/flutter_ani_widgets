import 'package:flutter/services.dart';

abstract class FeedbackService {
  Future<void> reveal();
}

/// 反馈失败不影响游戏结果或后续操作。
class PlatformFeedbackService implements FeedbackService {
  const PlatformFeedbackService();

  @override
  Future<void> reveal() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {
      // 不支持震动的平台及插件异常均降级为无反馈。
    }
  }
}
