import 'package:flutter/material.dart';

import 'color.dart';

/// 어디가남 Design System — Typography tokens (Pretendard).
abstract final class AppFont {
  AppFont._();

  /// Font family. Pretendard 폰트 파일을 assets/fonts 에 추가하고
  /// pubspec.yaml 의 `flutter > fonts` 섹션에 등록해야 적용됩니다.
  static const String family = 'Pretendard';

  // Font sizes — friendly, generous scale
  static const double display = 44;
  static const double h1 = 32;
  static const double h2 = 24;
  static const double h3 = 20;
  static const double title = 18;
  static const double bodyLg = 17;
  static const double body = 15;
  static const double label = 14;
  static const double caption = 13;
  static const double small = 12;

  // Weights (Pretendard)
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extrabold = FontWeight.w800;

  // Line heights (multiplier, matches CSS line-height ratio)
  static const double lhTight = 1.2;
  static const double lhSnug = 1.35;
  static const double lhNormal = 1.5;
  static const double lhRelaxed = 1.65;

  // Letter spacing (em) — apply as `em * fontSize` for Flutter's px-based letterSpacing
  static const double lsTight = -0.02;
  static const double lsSnug = -0.01;
  static const double lsNormal = 0.0;
  static const double lsWide = 0.02;
}

/// 타입 스케일 프리셋 — 굵기 대비 기반 위계 (800/700/600/400).
/// 기본 색상이 내장되어 있어 대부분의 경우 copyWith 없이 그대로 사용합니다.
/// (heading/body → textPrimary, label/caption/small → textSecondary)
abstract final class AppTextStyle {
  AppTextStyle._();

  static const TextStyle display = TextStyle(
    fontFamily: AppFont.family,
    fontSize: AppFont.display,
    fontWeight: AppFont.extrabold,
    height: AppFont.lhTight,
    letterSpacing: AppFont.display * AppFont.lsTight,
    color: AppColors.textPrimary,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: AppFont.family,
    fontSize: AppFont.h1,
    fontWeight: AppFont.bold,
    height: AppFont.lhTight,
    letterSpacing: AppFont.h1 * AppFont.lsSnug,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: AppFont.family,
    fontSize: AppFont.h2,
    fontWeight: AppFont.bold,
    height: AppFont.lhSnug,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: AppFont.family,
    fontSize: AppFont.h3,
    fontWeight: AppFont.bold,
    height: AppFont.lhSnug,
    color: AppColors.textPrimary,
  );

  static const TextStyle title = TextStyle(
    fontFamily: AppFont.family,
    fontSize: AppFont.title,
    fontWeight: AppFont.bold,
    height: AppFont.lhSnug,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLg = TextStyle(
    fontFamily: AppFont.family,
    fontSize: AppFont.bodyLg,
    fontWeight: AppFont.regular,
    height: AppFont.lhNormal,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: AppFont.family,
    fontSize: AppFont.body,
    fontWeight: AppFont.regular,
    height: AppFont.lhNormal,
    color: AppColors.textPrimary,
  );

  static const TextStyle label = TextStyle(
    fontFamily: AppFont.family,
    fontSize: AppFont.label,
    fontWeight: AppFont.medium,
    height: AppFont.lhNormal,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: AppFont.family,
    fontSize: AppFont.caption,
    fontWeight: AppFont.regular,
    height: AppFont.lhNormal,
    color: AppColors.textSecondary,
  );

  static const TextStyle small = TextStyle(
    fontFamily: AppFont.family,
    fontSize: AppFont.small,
    fontWeight: AppFont.regular,
    height: AppFont.lhNormal,
    color: AppColors.textSecondary,
  );
}
