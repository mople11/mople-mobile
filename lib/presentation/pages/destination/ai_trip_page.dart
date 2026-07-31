import 'package:flutter/material.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/radius.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/mock/eodiganam_data.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/presentation/pages/destination/course_page.dart';

enum _AiStep { input, loading, result }

class AiTripPage extends StatefulWidget {
  const AiTripPage({super.key});

  @override
  State<AiTripPage> createState() => _AiTripPageState();
}

class _AiTripPageState extends State<AiTripPage> {
  _AiStep _step = _AiStep.input;
  List<String> _moods = const ['heal'];
  double _hours = 6;

  void _generate() {
    setState(() => _step = _AiStep.loading);
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _step = _AiStep.result);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppDetailScaffold(
      title: switch (_step) {
        _AiStep.input => 'AI 맞춤 코스',
        _AiStep.loading => 'AI 코스 생성',
        _AiStep.result => 'AI 추천 코스',
      },
      onBack: () {
        if (_step == _AiStep.input) {
          Navigator.of(context).pop();
        } else {
          setState(() => _step = _AiStep.input);
        }
      },
      scrollable: false,
      bodyPadding: EdgeInsets.zero,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_step) {
      case _AiStep.loading:
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.space8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 52,
                  height: 52,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.brandPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.space5),
                Text(
                  '딱 맞는 코스를 짜고 있어요',
                  style: AppTextStyle.bodyLg,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.space2),
                Text(
                  '날씨 · 기분 · 이동수단을 분석 중이에요…',
                  style: AppTextStyle.caption,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      case _AiStep.result:
        final route = EodiganamData.route;
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space5,
            vertical: AppSpacing.space4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space3,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.fillBrandSoft,
                  borderRadius: AppRadius.radiusPill,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_rounded,
                      size: 13,
                      color: AppColors.textBrand,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '96% 일치하는 코스를 찾았어요',
                      style: AppTextStyle.small.copyWith(
                        color: AppColors.textBrand,
                        fontWeight: AppFont.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.space4),
              Container(
                padding: const EdgeInsets.all(AppSpacing.space5),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  border: Border.all(color: AppColors.borderSubtle),
                  borderRadius: AppRadius.radiusLg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const WeatherChip(
                          condition: WeatherCondition.sunny,
                          temp: 24,
                        ),
                        const SizedBox(width: AppSpacing.space2),
                        const AppBadge(label: '힐링', tone: AppTone.green),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.space2),
                    Text(route.title, style: AppTextStyle.h3),
                    const SizedBox(height: 4),
                    Text(
                      route.summary,
                      style: AppTextStyle.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    Row(
                      children: [
                        const Icon(
                          Icons.explore_rounded,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${route.steps.length}곳',
                          style: AppTextStyle.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: AppFont.semibold,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.space4),
                        const Icon(
                          Icons.navigation_rounded,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          route.distance,
                          style: AppTextStyle.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: AppFont.semibold,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.space4),
                        const Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          route.cost,
                          style: AppTextStyle.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: AppFont.semibold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    RouteStepList(steps: route.steps),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.space4),
              AppButton(
                label: '이 코스 자세히 보기',
                width: double.infinity,
                size: AppButtonSize.lg,
                onPressed: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const CoursePage())),
              ),
              const SizedBox(height: AppSpacing.space2),
              AppButton(
                label: '다시 추천받기',
                variant: AppButtonVariant.ghost,
                width: double.infinity,
                onPressed: () => setState(() => _step = _AiStep.input),
              ),
            ],
          ),
        );
      case _AiStep.input:
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space5,
            vertical: AppSpacing.space4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '어떤 여행을 원하세요?',
                style: AppTextStyle.bodyLg.copyWith(fontWeight: AppFont.bold),
              ),
              const SizedBox(height: AppSpacing.space3),
              MoodSelector(
                columns: 3,
                value: _moods.isEmpty ? null : _moods.first,
                options: EodiganamData.moods,
                onChanged: (v) => setState(() => _moods = [v]),
              ),
              const SizedBox(height: AppSpacing.space6),
              Text(
                '누구와 함께 가나요?',
                style: AppTextStyle.bodyLg.copyWith(fontWeight: AppFont.bold),
              ),
              const SizedBox(height: AppSpacing.space3),
              _CompanionGrid(),
              const SizedBox(height: AppSpacing.space5),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space4,
                  vertical: AppSpacing.space4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  border: Border.all(color: AppColors.borderSubtle),
                  borderRadius: AppRadius.radiusLg,
                ),
                child: AppSlider(
                  label: '여행 시간',
                  value: _hours,
                  min: 2,
                  max: 12,
                  formatValue: (v) => '${v.round()}시간',
                  onChanged: (v) => setState(() => _hours = v),
                ),
              ),
              const SizedBox(height: AppSpacing.space6),
              AppButton(
                label: 'AI 코스 생성하기',
                width: double.infinity,
                size: AppButtonSize.lg,
                onPressed: _generate,
              ),
            ],
          ),
        );
    }
  }
}

class _CompanionGrid extends StatefulWidget {
  @override
  State<_CompanionGrid> createState() => _CompanionGridState();
}

class _CompanionGridState extends State<_CompanionGrid> {
  String _value = '연인';
  static const _options = [
    ('연인', Icons.favorite_rounded),
    ('가족', Icons.groups_rounded),
    ('친구', Icons.group_add_rounded),
    ('혼자', Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.space3,
      crossAxisSpacing: AppSpacing.space3,
      childAspectRatio: 2.4,
      children: [
        for (final (label, icon) in _options)
          Material(
            color: _value == label
                ? AppColors.fillBrandSoft
                : AppColors.surfaceCard,
            borderRadius: AppRadius.radiusMd,
            child: InkWell(
              onTap: () => setState(() => _value = label),
              borderRadius: AppRadius.radiusMd,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: AppRadius.radiusMd,
                  border: Border.all(
                    color: _value == label
                        ? AppColors.brandPrimary
                        : AppColors.borderSubtle,
                    width: _value == label ? 2 : 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color: _value == label
                          ? AppColors.textBrand
                          : AppColors.textPrimary,
                    ),
                    const SizedBox(width: AppSpacing.space2),
                    Text(
                      label,
                      style: AppTextStyle.body.copyWith(
                        fontWeight: _value == label
                            ? AppFont.bold
                            : AppFont.medium,
                        color: _value == label
                            ? AppColors.textBrand
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
