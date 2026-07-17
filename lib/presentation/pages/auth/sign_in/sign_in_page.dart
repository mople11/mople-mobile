import 'package:flutter/material.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/widgets/forms/app_button.dart';
import 'package:mople_mobile/core/widgets/forms/app_social_login_button.dart';
import 'package:mople_mobile/core/widgets/forms/app_text_field.dart';
import 'package:mople_mobile/core/widgets/layout/app_scaffold.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _idTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
  bool isEnabled = false;

  void _onChangedButton() {
    setState(() {
      isEnabled =
          _idTextController.text.isNotEmpty &&
          _passwordTextController.text.isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    _idTextController.addListener(_onChangedButton);
    _passwordTextController.addListener(_onChangedButton);
  }

  @override
  void dispose() {
    _idTextController.dispose();
    _passwordTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          const Icon(Icons.explore_rounded, color: AppColors.blue500, size: 36),
          const SizedBox(height: AppSpacing.space3),
          const Text('다시 만나 반가워요', style: AppTextStyle.h1),
          const SizedBox(height: AppSpacing.space1),
          Text(
            '어디가남과 함께 전남을 여행해요!',
            style: AppTextStyle.bodyLg.copyWith(color: AppColors.neutral600),
          ),
          const SizedBox(height: AppSpacing.space6),
          AppTextFormField(label: '아이디', controller: _idTextController,),
          const SizedBox(height: AppSpacing.space3),
          AppTextFormField(
            controller: _passwordTextController,
            label: '비밀번호',
            obscureText: true,
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            '비밀번호를 잊어버리셨나요?',
            style: AppTextStyle.caption.copyWith(
              color: AppColors.blue500,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          AppButton(
            label: '로그인',
            width: double.infinity,
            onPressed: isEnabled ? () {} : null,
          ),
          const SizedBox(height: AppSpacing.space6),
          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.space3),
                child: Text('또는', style: AppTextStyle.caption),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: AppSpacing.space6),
          AppSocialLoginButton(
            iconPath: 'assets/images/svg/kakao_logo.svg',
            social: '카카오',
            onPressed: () {},
          ),
          const SizedBox(height: AppSpacing.space2),
          AppSocialLoginButton(
            iconPath: 'assets/images/svg/google_logo.svg',
            social: '구글',
            onPressed: () {},
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('아직 회원이 아니신가요? ', style: AppTextStyle.label),
              Text(
                '회원가입',
                style: AppTextStyle.label.copyWith(color: AppColors.blue500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
