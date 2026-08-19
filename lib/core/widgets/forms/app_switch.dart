import 'package:flutter/material.dart';

import '../../constants/color.dart';
import '../../constants/font.dart';
import '../../constants/radius.dart';
import '../../constants/spacing.dart';

/// 브랜드 색을 입힌 토글 스위치.
///
/// [label] 을 주면 "라벨 + 스위치" 한 줄로 그리고, 라벨을 이미 바깥에서
/// 그리는 화면(설정 목록의 행 등)은 [label] 없이 스위치만 쓴다. 어느 쪽이든
/// 색상은 이 위젯이 정하므로 화면마다 머티리얼 기본색이 새지 않는다.
class AppSwitch extends StatelessWidget {
  const AppSwitch({super.key, this.label, required this.value, this.onChanged});

  final String? label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final toggle = Switch(
      value: value,
      onChanged: onChanged,
      activeTrackColor: AppColors.brandPrimary,
      activeThumbColor: AppColors.neutral0,
      inactiveTrackColor: AppColors.neutral300,
      inactiveThumbColor: AppColors.neutral0,
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    );

    if (label == null) return toggle;

    return InkWell(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      borderRadius: AppRadius.radiusPill,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label!, style: AppTextStyle.body),
          const SizedBox(width: AppSpacing.space2),
          toggle,
        ],
      ),
    );
  }
}
