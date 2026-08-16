import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/core/navigation/app_navigation.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/data/models/models.dart';
import 'package:mople_mobile/presentation/controllers/base/async_result.dart';
import 'package:mople_mobile/presentation/controllers/my_page_controller.dart';

/// 프로필 편집 — `PATCH /users/me`.
///
/// 서버가 받는 항목은 `nickname` 과 `profileImg` 뿐이다. 이메일 변경 엔드포인트가
/// 없어 여기서는 다루지 않는다(예전 목업 화면에는 이메일 칸이 있었지만 저장되지
/// 않는 값이었다).
class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({super.key});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  late final TextEditingController _nicknameController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // build 안에서 만들면 리빌드마다 새로 생성돼 커서가 튄다.
    _nicknameController = TextEditingController(
      text: ref.read(myPageProvider).profile.nickname,
    );
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) {
      AppToast.show(
        context,
        title: '입력 확인',
        message: '닉네임을 입력해주세요.',
        tone: AppToastTone.warning,
      );
      return;
    }

    setState(() => _saving = true);
    final ok = await ref
        .read(myPageProvider.notifier)
        .updateProfile(nickname: nickname);
    if (!mounted) return;
    setState(() => _saving = false);

    if (!ok) {
      // 중복 닉네임이면 서버가 NICKNAME_DUPLICATE 를 내려준다.
      final error = ref.read(myPageProvider).profileUpdate;
      AppToast.show(
        context,
        title: '저장 실패',
        message: error?.apiError?.displayMessage ?? '프로필을 저장하지 못했어요.',
        tone: AppToastTone.danger,
      );
      return;
    }

    AppToast.show(
      context,
      title: '프로필 저장 완료',
      message: '변경한 정보가 저장되었어요.',
      tone: AppToastTone.success,
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(myPageProvider).profile;

    return AppDetailScaffold(
      title: '프로필 편집',
      onBack: () => context.pop(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: AppAvatar(
              name: profile.nickname.isEmpty ? '여행' : profile.nickname,
              size: AppAvatarSize.lg,
              ring: true,
            ),
          ),
          const SizedBox(height: AppSpacing.space6),
          AppTextField(
            label: '닉네임',
            placeholder: '사용하실 닉네임을 입력해주세요',
            controller: _nicknameController,
            enabled: !_saving,
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            '이메일과 아이디는 변경할 수 없어요.',
            style: AppTextStyle.caption.copyWith(color: AppColors.textTertiary),
          ),
          const SizedBox(height: AppSpacing.space6),
          AppButton(
            label: _saving ? '저장 중...' : '저장',
            width: double.infinity,
            size: AppButtonSize.lg,
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }
}
