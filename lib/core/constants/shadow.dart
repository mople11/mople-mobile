import 'package:flutter/material.dart';

import 'color.dart';

/// 어디가남 Design System — Elevation / shadow tokens.
/// 부드럽고 차가운 톤의 프리미엄 그림자. rgba(15, 23, 42, alpha) 기반.
abstract final class AppShadow {
  AppShadow._();

  static const List<BoxShadow> xs = [
    BoxShadow(color: Color(0x0F0F172A), offset: Offset(0, 1), blurRadius: 2),
  ];

  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x140F172A), offset: Offset(0, 2), blurRadius: 8),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(color: Color(0x1A0F172A), offset: Offset(0, 6), blurRadius: 16),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(color: Color(0x1F0F172A), offset: Offset(0, 12), blurRadius: 32),
  ];

  static const List<BoxShadow> xl = [
    BoxShadow(color: Color(0x290F172A), offset: Offset(0, 24), blurRadius: 48),
  ];

  // Focus rings — drawn as a 3px halo around the element. (색상 원본은 AppColors)
  static const Color ringBrand = AppColors.ringBrand;
  static const Color ringDanger = AppColors.ringDanger;

  // Elevation aliases
  static const List<BoxShadow> card = sm;
  static const List<BoxShadow> cardHover = md;
  static const List<BoxShadow> dropdown = lg;
  static const List<BoxShadow> dialog = xl;
}
