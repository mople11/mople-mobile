import 'package:flutter/material.dart';

/// GetX 없이 표준 [Navigator] 위에 얹는 얇은 내비게이션 헬퍼.
///
/// `Get.to` / `Get.back` / `Get.offAll` / `Get.until` 과 1:1로 대응해
/// 화면 전환 호출부는 그대로 두고 구현만 순정 Flutter Navigator로 바꾼다.
extension AppNavigation on BuildContext {
  /// `context.push(Widget())` 대응.
  Future<T?> push<T>(Widget page) =>
      Navigator.push<T>(this, MaterialPageRoute(builder: (_) => page));

  /// `context.pop()` 대응.
  void pop<T>([T? result]) => Navigator.pop(this, result);

  /// `context.pushAndRemoveAll(Widget())` 대응. 이전 스택을 모두 비우고 새 화면으로 교체한다.
  Future<T?> pushAndRemoveAll<T>(Widget page) =>
      Navigator.pushAndRemoveUntil<T>(
        this,
        MaterialPageRoute(builder: (_) => page),
        (route) => false,
      );

  /// `context.popToFirst()` 대응. 최초 화면까지 스택을 되돌린다.
  void popToFirst() => Navigator.popUntil(this, (route) => route.isFirst);
}
