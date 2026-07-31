import 'package:flutter/material.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/radius.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/presentation/pages/auth/signup_page.dart';

enum _ForgotStep { email, code, reset, done }

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  _ForgotStep _step = _ForgotStep.email;
  final _codeController = TextEditingController();
  String? _codeError;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return AppDetailScaffold(
      title: '비밀번호 찾기',
      onBack: () {
        if (_step == _ForgotStep.email) {
          Navigator.of(context).pop();
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
          onNext: () => setState(() => _step = _ForgotStep.code),
        ),
        _ForgotStep.code => _CodeStep(
          controller: _codeController,
          error: _codeError,
          onSubmit: _submitCode,
        ),
        _ForgotStep.reset => _ResetStep(
          onDone: () => setState(() => _step = _ForgotStep.done),
        ),
        _ForgotStep.done => _DoneStep(
          onLogin: () => Navigator.of(context).pop(),
        ),
      },
    );
  }
}

class _EmailStep extends StatelessWidget {
  const _EmailStep({required this.onNext});

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
        const AppTextField(label: '이메일', placeholder: '가입한 이메일을 입력해주세요'),
        const SizedBox(height: AppSpacing.space5),
        AppButton(
          label: '인증번호 발송',
          width: double.infinity,
          size: AppButtonSize.lg,
          onPressed: onNext,
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
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SignupPage())),
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
        const SizedBox(height: AppSpacing.space4),
        Center(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '코드를 못 받으셨나요? ',
                  style: AppTextStyle.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                TextSpan(
                  text: '재발송',
                  style: AppTextStyle.caption.copyWith(
                    color: AppColors.textBrand,
                    fontWeight: AppFont.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ResetStep extends StatelessWidget {
  const _ResetStep({required this.onDone});

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
        const AppTextField(
          label: '새 비밀번호',
          placeholder: '8자 이상 입력해주세요',
          obscureText: true,
        ),
        const SizedBox(height: AppSpacing.space4),
        const AppTextField(
          label: '새 비밀번호 확인',
          placeholder: '비밀번호를 다시 입력해주세요',
          obscureText: true,
        ),
        const SizedBox(height: AppSpacing.space5),
        AppButton(
          label: '비밀번호 재설정',
          width: double.infinity,
          size: AppButtonSize.lg,
          onPressed: onDone,
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
