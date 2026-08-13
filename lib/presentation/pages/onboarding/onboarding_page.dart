import 'package:flutter/material.dart';
import 'package:mople_mobile/core/navigation/app_navigation.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/widgets/forms/app_button.dart';
import 'package:mople_mobile/core/widgets/layout/app_scaffold.dart';
import 'package:mople_mobile/presentation/pages/auth/login_page.dart';
import 'package:mople_mobile/presentation/pages/onboarding/onboarding_info.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  bool _isLastPage = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              onPageChanged: (index) => setState(
                () => _isLastPage = onboardingInfo.length - 1 == index,
              ),
              itemCount: onboardingInfo.length,
              controller: _pageController,
              itemBuilder: (context, idx) {
                return Column(
                  children: [
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.space11),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.blue50,
                      ),
                      child: Icon(
                        onboardingInfo[idx].icon,
                        size: AppSpacing.space12,
                        color: AppColors.blue600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space7),
                    Text(onboardingInfo[idx].title, style: AppTextStyle.h1),
                    const SizedBox(height: AppSpacing.space3),
                    Text(
                      onboardingInfo[idx].content,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.body.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                    const Spacer(),
                  ],
                );
              },
            ),
          ),
          SmoothPageIndicator(
            controller: _pageController,
            count: onboardingInfo.length,
            effect: const ExpandingDotsEffect(
              dotHeight: AppSpacing.space2,
              dotWidth: AppSpacing.space2,
              dotColor: AppColors.neutral300,
              activeDotColor: AppColors.brandPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.space6),
          Visibility(
            visible: _isLastPage,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: AppButton(
              label: '로그인',
              width: double.infinity,
              size: AppButtonSize.lg,
              onPressed: () => context.pushAndRemoveAll(const LoginPage()),
            ),
          ),
        ],
      ),
    );
  }
}
