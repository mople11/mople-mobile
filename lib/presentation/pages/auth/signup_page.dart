import 'package:flutter/material.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool _showPw = false;
  bool _showPw2 = false;
  bool _agree = false;
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    return AppDetailScaffold(
      title: '회원가입',
      onBack: () => Navigator.of(context).pop(),
      scrollable: false,
      bodyPadding: EdgeInsets.zero,
      body: _done ? _buildDone() : _buildForm(),
    );
  }

  Widget _buildDone() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
            '회원가입이 완료됐어요',
            style: AppTextStyle.bodyLg.copyWith(fontWeight: AppFont.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.space1),
          Text(
            '어디가남과 함께 전남을 여행해보세요.',
            style: AppTextStyle.caption.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.space6),
          AppButton(
            label: '로그인하기',
            width: double.infinity,
            size: AppButtonSize.lg,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space6,
        vertical: AppSpacing.space5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '어디가남 계정을 만들어 나만의 전남 여행을 기록해보세요.',
            style: AppTextStyle.body.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: AppSpacing.space5),
          const AppTextField(label: '아이디', placeholder: '영문/숫자 4자 이상'),
          const SizedBox(height: AppSpacing.space4),
          const AppTextField(label: '닉네임', placeholder: '사용하실 닉네임을 입력해주세요'),
          const SizedBox(height: AppSpacing.space4),
          const AppTextField(label: '이메일', placeholder: 'you@example.com'),
          const SizedBox(height: AppSpacing.space4),
          AppTextField(
            label: '비밀번호',
            placeholder: '8자 이상 입력해주세요',
            obscureText: !_showPw,
            suffixIcon: IconButton(
              icon: Icon(
                _showPw
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: AppColors.textTertiary,
              ),
              onPressed: () => setState(() => _showPw = !_showPw),
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          AppTextField(
            label: '비밀번호 확인',
            placeholder: '비밀번호를 다시 입력해주세요',
            obscureText: !_showPw2,
            suffixIcon: IconButton(
              icon: Icon(
                _showPw2
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: AppColors.textTertiary,
              ),
              onPressed: () => setState(() => _showPw2 = !_showPw2),
            ),
          ),
          const SizedBox(height: AppSpacing.space5),
          AppCheckbox(
            label: '이용약관 및 개인정보처리방침에 동의합니다',
            value: _agree,
            onChanged: (v) => setState(() => _agree = v),
          ),
          const SizedBox(height: AppSpacing.space5),
          AppButton(
            label: '가입하기',
            width: double.infinity,
            size: AppButtonSize.lg,
            onPressed: _agree ? () => setState(() => _done = true) : null,
          ),
          const SizedBox(height: AppSpacing.space5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '이미 계정이 있으신가요? ',
                style: AppTextStyle.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Text(
                  '로그인',
                  style: AppTextStyle.caption.copyWith(
                    color: AppColors.textBrand,
                    fontWeight: AppFont.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
