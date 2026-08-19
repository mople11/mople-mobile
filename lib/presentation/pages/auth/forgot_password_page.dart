import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/core/navigation/app_navigation.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/radius.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/data/models/models.dart';
import 'package:mople_mobile/presentation/controllers/auth_controller.dart';
import 'package:mople_mobile/presentation/controllers/base/async_result.dart';
import 'package:mople_mobile/presentation/pages/auth/signup_page.dart';

enum _ForgotStep { email, code, reset, done }

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  _ForgotStep _step = _ForgotStep.email;

  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPwController = TextEditingController();
  final _newPwCheckController = TextEditingController();

  String? _codeError;
  String? _resetError;
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPwController.dispose();
    _newPwCheckController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      AppToast.show(
        context,
        title: '입력 확인',
        message: '이메일을 정확히 입력해주세요.',
        tone: AppToastTone.warning,
      );
      return;
    }
    setState(() => _submitting = true);
    final ok = await ref
        .read(authProvider.notifier)
        .requestPasswordReset(email);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) {
      setState(() => _step = _ForgotStep.code);
    } else {
      final error = ref.read(authProvider).passwordResetRequest?.apiError;
      AppToast.show(
        context,
        title: '발송 실패',
        message: error?.displayMessage ?? '인증번호 발송에 실패했어요.',
        tone: AppToastTone.danger,
      );
    }
  }

  void _submitCode() {
    if (_codeController.text.trim().length < 4) {
      setState(() => _codeError = '인증번호가 올바르지 않아요.');
      return;
    }
    setState(() {
      _codeError = null;
      _step = _ForgotStep.reset;
    });
  }

  Future<void> _resetPassword() async {
    final newPw = _newPwController.text;
    final newPwCheck = _newPwCheckController.text;
    if (newPw.length < 8 || newPw != newPwCheck) {
      setState(() => _resetError = '비밀번호를 다시 확인해주세요.');
      return;
    }

    setState(() {
      _resetError = null;
      _submitting = true;
    });
    final ok = await ref
        .read(authProvider.notifier)
        .confirmPasswordReset(
          email: _emailController.text.trim(),
          code: _codeController.text.trim(),
          newPw: newPw,
        );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (ok) {
      setState(() => _step = _ForgotStep.done);
    } else {
      final error = ref.read(authProvider).passwordResetConfirm?.apiError;
      if (error?.code == ApiErrorCode.codeMismatch) {
        setState(() {
          _step = _ForgotStep.code;
          _codeError = '인증번호가 일치하지 않아요.';
        });
      } else {
        AppToast.show(
          context,
          title: '재설정 실패',
          message: error?.displayMessage ?? '비밀번호 재설정에 실패했어요.',
          tone: AppToastTone.danger,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppDetailScaffold(
      title: '비밀번호 찾기',
      onBack: () {
        if (_step == _ForgotStep.email) {
          context.pop();
        } else {
          setState(() => _step = _ForgotStep.email);
        }
      },
      bodyPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space6,
        vertical: AppSpacing.space5,
      ),
      body: switch (_step) {
        _ForgotStep.email => _EmailStep(
          controller: _emailController,
          submitting: _submitting,
          onNext: _sendCode,
        ),
        _ForgotStep.code => _CodeStep(
          controller: _codeController,
          error: _codeError,
          onSubmit: _submitCode,
        ),
        _ForgotStep.reset => _ResetStep(
          newPwController: _newPwController,
          newPwCheckController: _newPwCheckController,
          error: _resetError,
          submitting: _submitting,
          onDone: _resetPassword,
        ),
        _ForgotStep.done => _DoneStep(onLogin: () => context.pop()),
      },
    );
  }
}

class _EmailStep extends StatelessWidget {
  const _EmailStep({
    required this.controller,
    required this.submitting,
    required this.onNext,
  });

  final TextEditingController controller;
  final bool submitting;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '가입하신 이메일로 인증번호를 보내드릴게요.',
          style: AppTextStyle.body.copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
        const SizedBox(height: AppSpacing.space5),
        AppTextField.asciiOnly(
          label: '이메일',
          placeholder: '가입한 이메일을 입력해주세요',
          controller: controller,
          enabled: !submitting,
          pattern: r'[a-zA-Z0-9@._+-]',
        ),
        const SizedBox(height: AppSpacing.space5),
        AppButton(
          label: submitting ? '발송 중...' : '인증번호 발송',
          width: double.infinity,
          size: AppButtonSize.lg,
          onPressed: submitting ? null : onNext,
        ),
        const SizedBox(height: AppSpacing.space4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '계정이 없으신가요? ',
              style: AppTextStyle.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            GestureDetector(
              onTap: () => context.push(const SignupPage()),
              child: Text(
                '회원가입',
                style: AppTextStyle.caption.copyWith(
                  color: AppColors.textBrand,
                  fontWeight: AppFont.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CodeStep extends StatelessWidget {
  const _CodeStep({
    required this.controller,
    required this.error,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final String? error;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space3,
            vertical: AppSpacing.space3,
          ),
          decoration: BoxDecoration(
            color: AppColors.infoBg,
            borderRadius: AppRadius.radiusMd,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.mail_rounded,
                size: 18,
                color: AppColors.infoText,
              ),
              const SizedBox(width: AppSpacing.space2),
              Expanded(
                child: Text(
                  '인증번호를 보냈어요. 메일함을 확인해주세요.',
                  style: AppTextStyle.caption.copyWith(
                    color: AppColors.infoText,
                    fontWeight: AppFont.semibold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space5),
        AppTextField(
          label: '인증번호',
          placeholder: '6자리 숫자를 입력해주세요',
          controller: controller,
          errorText: error,
        ),
        const SizedBox(height: AppSpacing.space5),
        AppButton(
          label: '인증 확인',
          width: double.infinity,
          size: AppButtonSize.lg,
          onPressed: onSubmit,
        ),
      ],
    );
  }
}

class _ResetStep extends StatelessWidget {
  const _ResetStep({
    required this.newPwController,
    required this.newPwCheckController,
    required this.error,
    required this.submitting,
    required this.onDone,
  });

  final TextEditingController newPwController;
  final TextEditingController newPwCheckController;
  final String? error;
  final bool submitting;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '새 비밀번호를 설정해주세요.',
          style: AppTextStyle.body.copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
        const SizedBox(height: AppSpacing.space5),
        AppPasswordField(
          label: '새 비밀번호',
          placeholder: '8자 이상 입력해주세요',
          controller: newPwController,
          enabled: !submitting,
        ),
        const SizedBox(height: AppSpacing.space4),
        AppPasswordField(
          label: '새 비밀번호 확인',
          placeholder: '비밀번호를 다시 입력해주세요',
          controller: newPwCheckController,
          enabled: !submitting,
          errorText: error,
        ),
        const SizedBox(height: AppSpacing.space5),
        AppButton(
          label: submitting ? '재설정 중...' : '비밀번호 재설정',
          width: double.infinity,
          size: AppButtonSize.lg,
          onPressed: submitting ? null : onDone,
        ),
      ],
    );
  }
}

class _DoneStep extends StatelessWidget {
  const _DoneStep({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.space16),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.successBg,
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 34,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: AppSpacing.space5),
          Text(
            '비밀번호가 재설정됐어요',
            style: AppTextStyle.bodyLg.copyWith(fontWeight: AppFont.bold),
          ),
          const SizedBox(height: AppSpacing.space1),
          Text(
            '새 비밀번호로 다시 로그인해주세요.',
            style: AppTextStyle.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.space6),
          AppButton(
            label: '로그인 페이지로',
            width: double.infinity,
            size: AppButtonSize.lg,
            onPressed: onLogin,
          ),
        ],
      ),
    );
  }
}
