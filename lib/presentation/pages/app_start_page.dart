import 'package:flutter/material.dart';
import 'package:mople_mobile/core/navigation/app_navigation.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/widgets/layout/app_scaffold.dart';
import 'package:mople_mobile/presentation/pages/auth/login_page.dart';
import 'package:mople_mobile/presentation/pages/onboarding/onboarding_page.dart';

class AppStartPage extends StatelessWidget {
  const AppStartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final captionStyle = AppTextStyle.caption.copyWith(
      color: AppColors.neutral0,
    );

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/images/sea.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            AppColors.neutral900.withValues(alpha: 0.3),
            BlendMode.srcOver,
          ),
        ),
      ),
      child: AppScaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Icon(
              Icons.explore_rounded,
              color: AppColors.neutral0,
              size: 52,
            ),
            const SizedBox(height: 10),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '어디가',
                    style: AppTextStyle.display.copyWith(
                      color: AppColors.neutral0,
                    ),
                  ),
                  TextSpan(
                    text: '남',
                    style: AppTextStyle.display.copyWith(
                      color: AppColors.orange500,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '전라남도,오늘 어디가지?\n날씨와 기분에 딱 맞는 여행 추천',
              textAlign: TextAlign.center,
              style: AppTextStyle.body.copyWith(color: AppColors.neutral0),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.orange500,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: () => context.push(const OnboardingPage()),
                child: Text(
                  '시작하기',
                  style: AppTextStyle.bodyLg.copyWith(
                    color: AppColors.neutral900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('이미 계정이 있나요? ', style: captionStyle),
                GestureDetector(
                  onTap: () => context.push(const LoginPage()),
                  child: Text(
                    '로그인',
                    style: captionStyle.copyWith(
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.neutral0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
