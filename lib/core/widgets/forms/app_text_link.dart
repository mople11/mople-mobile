import 'package:flutter/material.dart';

import '../../constants/color.dart';
import '../../constants/font.dart';

/// 링크 강조 수준. [brand] 는 회원가입·로그인처럼 다음 화면으로 보내는 링크,
/// [plain] 은 "비밀번호를 잊으셨나요?" 처럼 본문 색을 유지하는 보조 링크.
enum AppTextLinkTone { brand, plain }

/// 문장 안이나 버튼 아래에 놓이는 텍스트 링크.
///
/// [GestureDetector] + [Text] 조합을 화면마다 되풀이하면 색·굵기가 조금씩
/// 달라지므로 한 곳에서 정의한다.
class AppTextLink extends StatelessWidget {
  const AppTextLink({
    super.key,
    required this.label,
    required this.onTap,
    this.tone = AppTextLinkTone.brand,
  });

  final String label;
  final VoidCallback? onTap;
  final AppTextLinkTone tone;

  @override
  Widget build(BuildContext context) {
    final style = switch (tone) {
      AppTextLinkTone.brand => AppTextStyle.caption.copyWith(
        color: AppColors.textBrand,
        fontWeight: AppFont.bold,
      ),
      AppTextLinkTone.plain => AppTextStyle.caption.copyWith(
        fontWeight: AppFont.semibold,
      ),
    };

    // GestureDetector 는 포커스 순회에 들어가지 않아 키보드·스위치 컨트롤로는
    // 누를 수 없고, 스크린리더도 버튼으로 읽지 않는다. TextButton 은 그 둘을
    // 기본으로 주므로, 기본 여백·최소 크기만 걷어내 기존 모양을 유지한다.
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        foregroundColor: style.color,
        textStyle: style,
      ),
      child: Text(label, style: style),
    );
  }
}
