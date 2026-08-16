import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/data/models/models.dart';

import '../../constants/color.dart';
import '../../constants/font.dart';
import '../../constants/spacing.dart';
import '../forms/app_button.dart';

/// 컨트롤러의 `AsyncValue<T>?` 를 로딩/에러/데이터 세 갈래로 그려주는 공통 위젯.
///
/// 컨트롤러들은 "아직 한 번도 안 불러온 상태"를 `null` 로 표현하므로
/// [value] 가 nullable 이다. null 과 loading 은 똑같이 로딩으로 취급한다.
///
/// 에러 문구는 [ApiError.displayMessage] 를 그대로 쓴다 — 서버가 한글 메시지를
/// 내려주면 그게 보이고, 없으면 코드별 기본 문구로 대체된다.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    super.key,
    required this.value,
    required this.builder,
    this.onRetry,
    this.loadingHeight = 160,
    this.isEmpty,
    this.emptyMessage = '표시할 내용이 없어요.',
  });

  final AsyncValue<T>? value;
  final Widget Function(T data) builder;
  final VoidCallback? onRetry;
  final double loadingHeight;

  /// 데이터는 왔지만 비어 있는 경우를 가려내는 판정식(예: 리스트가 비었는지).
  final bool Function(T data)? isEmpty;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final current = value;
    if (current == null || current.isLoading) {
      return SizedBox(
        height: loadingHeight,
        child: const Center(
          child: SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: AppColors.brandPrimary,
            ),
          ),
        ),
      );
    }

    if (current.hasError) {
      final error = current.error;
      final message = error is ApiError
          ? error.displayMessage
          : '잠시 후 다시 시도해주세요.';
      return _Message(
        icon: Icons.cloud_off_rounded,
        message: message,
        onRetry: onRetry,
      );
    }

    final data = current.value as T;
    if (isEmpty?.call(data) ?? false) {
      return _Message(icon: Icons.inbox_rounded, message: emptyMessage);
    }
    return builder(data);
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.message, this.onRetry});

  final IconData icon;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 30, color: AppColors.textTertiary),
          const SizedBox(height: AppSpacing.space2),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyle.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.space3),
            AppButton(
              label: '다시 시도',
              size: AppButtonSize.sm,
              variant: AppButtonVariant.outline,
              onPressed: onRetry,
            ),
          ],
        ],
      ),
    );
  }
}
