import 'package:flutter/material.dart';

import '../../constants/color.dart';

/// 서버 이미지 URL을 안전하게 그리는 위젯.
///
/// 서버가 썸네일을 안 내려주거나(빈 문자열) URL이 깨진 경우 `Image.network` 는
/// 예외를 던져 카드 전체가 에러 박스로 바뀐다. 목록 화면은 이런 항목이 하나만
/// 있어도 화면이 망가지므로, 빈 값과 로딩 실패를 모두 자리표시자로 대체한다.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({super.key, required this.url, this.fit = BoxFit.cover});

  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (url.trim().isEmpty) return const _Placeholder();
    return Image.network(
      url,
      fit: fit,
      errorBuilder: (_, _, _) => const _Placeholder(),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceSunken,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_rounded,
        size: 28,
        color: AppColors.textTertiary,
      ),
    );
  }
}
