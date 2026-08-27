import 'package:flutter/material.dart';

import '../../constants/color.dart';
import 'app_text_field.dart';

/// 비밀번호 입력칸. 보기/숨기기 토글을 위젯 안에서 관리한다.
///
/// 화면마다 `bool _showPw` 상태와 눈 모양 [IconButton] 을 따로 들고 있으면
/// 아이콘·색이 조금씩 어긋나므로, 토글 상태까지 이 위젯이 갖는다.
class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
    super.key,
    this.label,
    this.placeholder,
    this.controller,
    this.onChanged,
    this.enabled = true,
    this.errorText,
  });

  final String? label;
  final String? placeholder;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final String? errorText;

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      placeholder: widget.placeholder,
      controller: widget.controller,
      onChanged: widget.onChanged,
      enabled: widget.enabled,
      errorText: widget.errorText,
      obscureText: !_visible,
      // 보기 토글로 가림을 풀면 일반 입력칸이 되어 자동완성·오타수정이 살아난다.
      // 비밀번호가 IME 사전과 추천 목록에 남지 않도록 항상 꺼 둔다.
      keyboardType: TextInputType.visiblePassword,
      autocorrect: false,
      enableSuggestions: false,
      suffixIcon: IconButton(
        icon: Icon(
          _visible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
          color: AppColors.textTertiary,
        ),
        tooltip: _visible ? '비밀번호 숨기기' : '비밀번호 보기',
        onPressed: () => setState(() => _visible = !_visible),
      ),
    );
  }
}
