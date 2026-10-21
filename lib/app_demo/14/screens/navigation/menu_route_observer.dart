import 'package:flutter/material.dart';

/// 只在页面退出转场完成后通知首页；弹层不会触发重新入场。
class MenuRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  final visits = ValueNotifier(0);
  int _generation = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _generation++;
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (route is! PageRoute || previousRoute is! PageRoute || !previousRoute.isFirst) return;
    final generation = ++_generation;
    route.completed.then((_) {
      if (generation == _generation && previousRoute.isCurrent) visits.value++;
    });
  }

  void dispose() {
    _generation++;
    visits.dispose();
  }
}
