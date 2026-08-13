import 'package:flutter/material.dart';
import 'package:mople_mobile/core/navigation/app_navigation.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/radius.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/presentation/pages/plan/results_page.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  String _companion = 'couple';
  String _transport = 'car';
  double _hours = 6;

  static const _companions = [
    ('solo', '🧍 혼자'),
    ('couple', '💕 연인'),
    ('family', '👨‍👩‍👧 가족'),
    ('friends', '🧑‍🤝‍🧑 친구'),
  ];
  static const _transports = [
    ('car', '🚗 자동차'),
    ('transit', '🚌 대중교통'),
    ('walk', '🚶 도보'),
    ('bike', '🚲 자전거'),
  ];

  @override
  Widget build(BuildContext context) {
    return AppDetailScaffold(
      title: '맞춤 코스 만들기',
      onBack: () => context.pop(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PlanSection(
            label: '누구와 함께 가나요?',
            child: _PickGrid(
              options: _companions,
              value: _companion,
              onChanged: (v) => setState(() => _companion = v),
            ),
          ),
          _PlanSection(
            label: '이동수단은요?',
            child: _PickGrid(
              options: _transports,
              value: _transport,
              onChanged: (v) => setState(() => _transport = v),
            ),
          ),
          _PlanSection(
            label: '얼마나 여행하시나요?',
            child: Container(
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
          ),
        ],
      ),
      bottomBar: AppBottomActionBar(
        padding: const EdgeInsets.all(AppSpacing.space5),
        child: AppButton(
          label: '코스 추천받기',
          width: double.infinity,
          size: AppButtonSize.lg,
          onPressed: () => context.push(
            ResultsPage(
              companionLabel: _companions
                  .firstWhere((c) => c.$1 == _companion)
                  .$2,
              transportLabel: _transports
                  .firstWhere((t) => t.$1 == _transport)
                  .$2,
              hours: _hours,
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanSection extends StatelessWidget {
  const _PlanSection({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyle.bodyLg.copyWith(fontWeight: AppFont.bold),
          ),
          const SizedBox(height: AppSpacing.space3),
          child,
        ],
      ),
    );
  }
}

class _PickGrid extends StatelessWidget {
  const _PickGrid({
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final List<(String, String)> options;
  final String value;
  final ValueChanged<String> onChanged;

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
        for (final (v, label) in options)
          _PickTile(
            label: label,
            selected: v == value,
            onTap: () => onChanged(v),
          ),
      ],
    );
  }
}

class _PickTile extends StatelessWidget {
  const _PickTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.fillBrandSoft : AppColors.surfaceCard,
      borderRadius: AppRadius.radiusMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusMd,
        child: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
          decoration: BoxDecoration(
            borderRadius: AppRadius.radiusMd,
            border: Border.all(
              color: selected ? AppColors.brandPrimary : AppColors.borderSubtle,
              width: selected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.body.copyWith(
              fontWeight: selected ? AppFont.bold : AppFont.medium,
              color: selected ? AppColors.textBrand : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
