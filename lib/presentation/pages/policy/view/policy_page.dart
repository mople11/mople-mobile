import 'package:flutter/material.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/presentation/pages/policy/policy_documents.dart';

/// 이용약관·개인정보처리방침 열람 화면.
///
/// 스토어 정책상 약관·처리방침은 "준비 중" 안내가 아니라 실제 본문을
/// 앱 안에서 열람할 수 있어야 한다. 문안은 `policy_documents.dart` 에 있다.
class PolicyPage extends StatelessWidget {
  const PolicyPage({super.key, required this.document});

  /// 이용약관 화면.
  const PolicyPage.terms({super.key}) : document = termsOfService;

  /// 개인정보처리방침 화면.
  const PolicyPage.privacy({super.key}) : document = privacyPolicy;

  final PolicyDocument document;

  @override
  Widget build(BuildContext context) {
    return AppDetailScaffold(
      title: document.title,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '시행일: ${document.updatedAt}',
            style: AppTextStyle.caption.copyWith(color: AppColors.textTertiary),
          ),
          const SizedBox(height: AppSpacing.space5),
          for (final section in document.sections) ...[
            Text(
              section.title,
              style: AppTextStyle.body.copyWith(fontWeight: AppFont.bold),
            ),
            const SizedBox(height: AppSpacing.space2),
            Text(
              section.body,
              style: AppTextStyle.body.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: AppSpacing.space5),
          ],
        ],
      ),
    );
  }
}
