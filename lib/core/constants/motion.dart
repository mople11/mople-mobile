import 'package:flutter/animation.dart';

/// 어디가남 Design System — Transition / motion tokens.
abstract final class AppMotion {
  AppMotion._();

  static const Duration fast = Duration(milliseconds: 120);
  static const Duration base = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 320);

  // Cubic(0.4, 0, 0.2, 1) == Material 표준 커브
  static const Curve curveFast = Curves.fastOutSlowIn;
  static const Curve curveBase = Curves.fastOutSlowIn;
  static const Curve curveSlow = Cubic(0.22, 1, 0.36, 1);
}
