import 'package:flutter/material.dart';
import 'package:mople_mobile/core/navigation/app_navigation.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/presentation/pages/auth/forgot_password_page.dart';
import 'package:mople_mobile/presentation/pages/auth/signup_page.dart';
import 'package:mople_mobile/presentation/pages/home/main_tab_shell.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _idController = TextEditingController(text: 'traveler01');
  final _pwController = TextEditingController(text: 'password');
  bool _showPassword = false;

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    super.dispose();
  }

  void _goHome() => context.pushAndRemoveAll(const MainTabShell());

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
                  AppTextField(
                    label: '아이디',
                    placeholder: '아이디를 입력해주세요',
                    controller: _idController,
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  AppTextField(
                    label: '비밀번호',
                    placeholder: '비밀번호를 입력해주세요',
                    controller: _pwController,
                    obscureText: !_showPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: AppColors.textTertiary,
                      ),
                      onPressed: () =>
                          setState(() => _showPassword = !_showPassword),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => context.push(const ForgotPasswordPage()),
                      child: Text(
                        '비밀번호를 잊으셨나요?',
                        style: AppTextStyle.caption.copyWith(
                          fontWeight: AppFont.semibold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space5),
                  AppButton(
                    label: '로그인',
                    width: double.infinity,
                    size: AppButtonSize.lg,
                    onPressed: _goHome,
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
                    onPressed: _goHome,
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  AppButton(
                    label: 'Google로 계속하기',
                    variant: AppButtonVariant.outline,
                    width: double.infinity,
                    size: AppButtonSize.lg,
                    leading: Container(
                      width: 20,
                      height: 20,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.fromBorderSide(
                          BorderSide(color: AppColors.borderDefault),
                        ),
                      ),
                      child: const Text(
                        'G',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF4285F4),
                        ),
                      ),
                    ),
                    onPressed: _goHome,
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
          ),
        ],
      ),
    );
  }
}
