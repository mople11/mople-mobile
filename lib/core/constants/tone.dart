import 'package:flutter/material.dart';

import 'color.dart';

/// 어디가남 Design System — Semantic tone.
/// Badge, Progress 등 상태 색상 계열을 쓰는 컴포넌트가 공유하는 색상 매핑.
enum AppTone { blue, green, orange, danger }

extension AppToneColors on AppTone {
  /// 대표 색 — solid 배경, 프로그레스 바 등.
  Color get color => switch (this) {
        AppTone.blue => AppColors.blue500,
        AppTone.green => AppColors.green500,
        AppTone.orange => AppColors.orange500,
        AppTone.danger => AppColors.red500,
      };

  /// solid 배경 위 전경색.
  Color get onColor => switch (this) {
        AppTone.orange => AppColors.textPrimary,
        _ => AppColors.textOnBrand,
      };

  /// soft(연한 배경) 변형의 배경색.
  Color get softBackground => switch (this) {
        AppTone.blue => AppColors.blue50,
        AppTone.green => AppColors.green50,
        AppTone.orange => AppColors.orange50,
        AppTone.danger => AppColors.dangerBg,
      };

  /// soft 변형의 전경색.
  Color get softForeground => switch (this) {
        AppTone.blue => AppColors.blue700,
        AppTone.green => AppColors.green700,
        AppTone.orange => AppColors.orange800,
        AppTone.danger => AppColors.dangerText,
      };
}
