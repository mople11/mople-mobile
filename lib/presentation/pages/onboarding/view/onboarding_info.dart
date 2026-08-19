import 'package:flutter/material.dart';
import 'package:mople_mobile/presentation/pages/onboarding/view/onboarding_model.dart';

const List<OnboardingModel> onboardingInfo = [
  OnboardingModel(
    icon: Icons.explore_rounded,
    title: '전남, 어디가남?',
    content: '전라남도, 오늘 어디가지?\n날씨와 기분에 딱 맞는 여행 추천',
  ),
  OnboardingModel(
    icon: Icons.route,
    title: 'AI가 짜주는 하루',
    content: '복잡한 계획은 그만.\nAI가 동선까지 완성된 코스를 제안해요.',
  ),
  OnboardingModel(
    icon: Icons.workspace_premium,
    title: '여행하고 도장 모으기',
    content: '다녀온 곳마다 스탬프가 쌓여요.\n나만의 전남 여행 기록을 완성하세요.',
  ),
];
