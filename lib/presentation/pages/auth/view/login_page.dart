import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/core/navigation/app_navigation.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/data/api/kakao_auth.dart';
import 'package:mople_mobile/data/models/models.dart';
import 'package:mople_mobile/presentation/controllers/auth_controller.dart';
import 'package:mople_mobile/presentation/controllers/base/async_result.dart';
import 'package:mople_mobile/presentation/pages/auth/view/forgot_password_page.dart';
import 'package:mople_mobile/presentation/pages/auth/view/signup_page.dart';
import 'package:mople_mobile/presentation/pages/home/view/main_tab_shell.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _idController = TextEditingController();
  final _pwController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    super.dispose();
  }

  void _goHome() => context.pushAndRemoveAll(const MainTabShell());

  /// 카카오에서 OAuth 토큰을 받아 서버 세션으로 교환한다.
  Future<void> _loginWithKakao() async {
    setState(() => _submitting = true);
    try {
      final oauthToken = await KakaoAuth.obtainAccessToken();
      if (!mounted) return;
      await ref
          .read(authProvider.notifier)
          .loginWithSocial(
            provider: SocialProvider.kakao,
            oauthToken: oauthToken,
          );
      if (!mounted) return;

      final session = ref.read(authProvider).session;
      if (session?.hasError ?? false) {
        AppToast.show(
          context,
          title: '로그인 실패',
          message: session!.apiError?.displayMessage ?? '카카오 로그인에 실패했어요.',
          tone: AppToastTone.danger,
        );
        return;
      }
      _goHome();
    } on ApiException catch (e) {
      // 카카오 단계에서 실패(취소·미설정 등) — 서버까지 가지 않은 경우.
      if (!mounted) return;
      AppToast.show(
        context,
        title: '카카오 로그인',
        message: e.error.displayMessage,
        tone: AppToastTone.warning,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _submitLogin() async {
    final id = _idController.text.trim();
    final pw = _pwController.text;
    if (id.isEmpty || pw.isEmpty) {
      AppToast.show(
        context,
        title: '입력 확인',
        message: '아이디와 비밀번호를 입력해주세요.',
        tone: AppToastTone.warning,
      );
      return;
    }

    setState(() => _submitting = true);
    await ref.read(authProvider.notifier).login(id: id, pw: pw);
    if (!mounted) return;
    setState(() => _submitting = false);

    final session = ref.read(authProvider).session;
    if (session?.hasError ?? false) {
      AppToast.show(
        context,
        title: '로그인 실패',
        message: session!.apiError?.displayMessage ?? '로그인에 실패했어요.',
        tone: AppToastTone.danger,
      );
      return;
    }
    _goHome();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.space16),
                  const Icon(
                    Icons.explore_rounded,
                    size: 36,
                    color: AppColors.brandPrimary,
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  Text('다시 만나 반가워요', style: AppTextStyle.h1),
                  const SizedBox(height: AppSpacing.space1),
                  Text(
                    '어디가남과 함께 전남을 여행해요.',
                    style: AppTextStyle.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space6),
                  AppTextField.asciiOnly(
                    label: '아이디',
                    placeholder: '아이디를 입력해주세요',
                    controller: _idController,
                    enabled: !_submitting,
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  AppPasswordField(
                    label: '비밀번호',
                    placeholder: '비밀번호를 입력해주세요',
                    controller: _pwController,
                    enabled: !_submitting,
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  Align(
                    alignment: Alignment.centerRight,
                    child: AppTextLink(
                      label: '비밀번호를 잊으셨나요?',
                      tone: AppTextLinkTone.plain,
                      onTap: () => context.push(const ForgotPasswordPage()),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space5),
                  AppButton(
                    label: _submitting ? '로그인 중...' : '로그인',
                    width: double.infinity,
                    size: AppButtonSize.lg,
                    onPressed: _submitting ? null : _submitLogin,
                  ),
                  const SizedBox(height: AppSpacing.space6),
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: AppColors.borderSubtle),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.space3,
                        ),
                        child: Text(
                          '또는',
                          style: AppTextStyle.small.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: AppColors.borderSubtle),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  AppButton(
                    label: '카카오로 계속하기',
                    variant: AppButtonVariant.outline,
                    width: double.infinity,
                    size: AppButtonSize.lg,
                    leading: Container(
                      width: 20,
                      height: 20,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEE500),
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        'K',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF191600),
                        ),
                      ),
                    ),
                    onPressed: _submitting ? null : _loginWithKakao,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.space4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '아직 회원이 아니신가요? ',
                  style: AppTextStyle.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                AppTextLink(
                  label: '회원가입',
                  onTap: () => context.push(const SignupPage()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
